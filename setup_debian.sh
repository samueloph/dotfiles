#!/bin/bash
# Set of functions to setup a recently installed Debian Testing system, it should
# also work on Ubuntu.
# This script is idempotent
# author: Samuel Henrique <samueloph@debian.org>

# changelog
# 2020-01-25:
#  * log changes within logs folder and print everything at the end
#  * refactored way schroots are created and create stable and oldstable ones
# 2020-01-26:
#  * don't hardcode my personal information
#  * add comments in the code

# runs (to confirm that the script is working):
# 2020-01-18: debian testing (bullseye)

set -euo pipefail

apt_install_wrapper(){
    # runs 'apt install' for packages that are not currently installed, can install
    # local .deb files and will run 'apt update' if last one wass more than a day
    # ago.
    # input: list of packages
    local one_day_ago
    local pkgcache_modification_timestamp
    local to_be_installed=""
    local package_list=("$@")

    one_day_ago=$(date -d 'now - 1 days' +%s)
    pkgcache_modification_timestamp=$(date -r "/var/cache/apt/pkgcache.bin" +%s)

    for package in "${package_list[@]}"
    do
        # var can be a location to a .deb file, so remove the path part of it
        local packagename
        packagename=$(awk -F "/" '{print $NF}' <<< "$package" | awk '{gsub(".deb$", "");print}')

        # select package to be installed if not already in the system
        if ! (dpkg-query -W -f='${Status}' "$packagename" 2>/dev/null | grep -q "install ok installed"); then
            to_be_installed="$to_be_installed $package"
        else
            echo "✔ $packagename is already installed"
        fi
    done

    # install everything that was selected to be installed
    if [[ -n $to_be_installed ]]; then
        echo "--------------------------------------------------------------------------------"
        echo "►► Installing $to_be_installed"
        # apt cache needs update if last one was less than 1 day ago
        if [[ pkgcache_modification_timestamp -le one_day_ago ]]; then
            sudo apt update
        fi
        sudo apt install "$to_be_installed"
        echo "--------------------------------------------------------------------------------"
    fi
}

atom_packages_installer(){
    # install atom packages if they're not already installed
    # input: list of packages
    for package in "$@"
    do
        # only proceed if it's not already installed
        if [[ ! -d "$HOME/.atom/packages/$package" ]]
        then
            apm install $package
        else
            echo "✔ atom package $package is already installed"
        fi
    done
}

copy_files_wrapper(){
    # copy files if they're not already at the destination, create a backups
    # of changed files and log it.
    # input:
    # $1: source file
    # $2: destination file
    # $3: 'sudo' if sudo is needed
    # output: will increment value of RETURNVAR if any file is changed
    local SOURCE
    local DEST
    local SUDO

    SOURCE="${DIR_PATH}/${1}"
    DEST=$2
    SUDO=${3:-}

    # if no ovewrite is needed, copy file
    if [[ ! -f $DEST ]]; then
        ((RETURNVAR+=1))
        echo "►► Copying $DEST"
        $SUDO cp "$SOURCE" "$DEST"
    # ovewrite is needed
    else
        # check if file is already the same
        if [[ $(md5sum "$SOURCE" | cut -f1 -d" ") == $(md5sum "$DEST" | cut -f1 -d" ") ]]; then
            echo "✔ $DEST is already the same"
        # file is different, create a backup and ovewrite
        else
            ((RETURNVAR+=1))
            echo "[WARN] $DEST already exists and it's different, old file will be ${DEST}.bkp-$timestamp"
            mv "$DEST" "${DEST}.bkp-${timestamp}"
            $SUDO cp "$SOURCE" "$DEST"

            # log changes
            echo "$SOURCE" >> "$changed_files"
            echo "${DEST}.bkp-${timestamp}" >> "$backup_files"
        fi
    fi
}

create_schroot(){
    # create schroot, using eatmydata and ccache
    # input:
    # $1: release to create the schroot for
    # $2: aliases to be used for the schroot
    local release=$1
    local release_alias=$2
    # flag to control whether ccache needs to be tested or not, will be set to true
    # if ccache is installed or changed
    local test_ccache="false"
    local ccache_dir="/var/cache/ccache-sbuild"

    echo -e "\e[32m[CREATE-${release^^}-SCHROOT]\e[0m"
    # only proceed if no chroot for $release is found
    if find /etc/schroot/chroot.d/ -type f -name "${release}-amd64-sbuild-*" -exec false {} +; then
        test_ccache="true"
        echo "►► setting up sbuild's ${release} chroot"
        echo "--------------------------------------------------------------------------------"
        apt_install_wrapper apt-cacher-ng
        sudo sbuild-createchroot --include=eatmydata,ccache,gnupg "$release" "/srv/chroot/${release}-amd64-sbuild http://127.0.0.1:3142/deb.debian.org/debian"
        sudo sbuild-adduser "$LOGNAME" >/dev/null 2>&1
        echo "--------------------------------------------------------------------------------"
    else
        echo "✔ sbuild's ${release} chroot is already configured"
    fi


    # setup release as an alias so we can call autopkgtest by the schroot alias instead of using the full schroot name
    setup_schroot_alias "$release" "$release"
    setup_schroot_alias "$release" "$release_alias"

    # setup eatmydata
    if ! find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec grep -q "^command-prefix.*eatmydata" {} +; then
        echo "►► setting eatmydata command-prefix for ${release}'s schroot"
        if ! find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec grep -q "^command-prefix" {} +; then
            echo "command-prefix=eatmydata" | sudo tee -a "/etc/schroot/chroot.d/${release}-amd64-sbuild-"* >/dev/null
        else
            sudo find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec sed -i -e '/command-prefix/ {/eatmydata/! s/$/,eatmydata/}' {} +
        fi
    else
        echo "✔ ccache command-prefix is already set in ${release}'s schroot"
    fi

    # setup ccache
    echo -e "[CCACHE FOR SCHROOT]"

    if [[ ! -d $ccache_dir ]];then
        test_ccache="true"
        echo "►► setting up ccache folder"
        sudo install --group=sbuild --mode=2775 -d $ccache_dir
        sudo env CCACHE_DIR=$ccache_dir ccache --max-size 4G
    else
        echo "✔ ccache folder is already setup"
    fi
    copy_files_wrapper sbuild-setup $ccache_dir/sbuild-setup sudo

    if ! grep -q "$ccache_dir $ccache_dir none rw,bind 0 0" /etc/schroot/sbuild/fstab; then
        test_ccache="true"
        echo "►► setting up mounting of ccache folder from sbuild's chroot"
        echo "$ccache_dir /$ccache_dir none rw,bind 0 0" | sudo tee -a /etc/schroot/sbuild/fstab >/dev/null

        echo "/etc/schroot/sbuild/fstab" >> "$changed_files"
    else
        echo "✔ ccache folder is already on chroot's fstab"
    fi

    if ! find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec grep -q "^command-prefix.*$ccache_dir/sbuild-setup" {} +; then
        test_ccache="true"
        echo "►► setting ccache command-prefix for ${release}'s schroot"
        if ! find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec grep -q "^command-prefix" {} +; then
            echo "command-prefix=/var/cache/ccache-sbuild/sbuild-setup" | sudo tee -a  "/etc/schroot/chroot.d/${release}-amd64-sbuild-"* >/dev/null
        else
            sudo find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec sed -i -e '/command-prefix/ {/\/var\/cache\/ccache-sbuild\/sbuild-setup/! s/$/,\/var\/cache\/ccache-sbuild\/sbuild-setup/}' {} +
        fi
    else
        echo "✔ ccache command-prefix is already set in ${release}'s schroot"
    fi

    # test ccache if needed
    if [[ $test_ccache == "true" ]];then
        if sudo schroot -c "source:${release}-amd64-sbuild" -d /home -- ccache -p | grep -q "$ccache_dir/ccache.conf"; then
            echo "✔ ccache sucessfully tested"
        else
            echo "⚠️ could not test ccache, something is wrong ⚠️"
        fi
    else
        echo "✔ skip ccache test because there were no changes"
    fi

    echo -e "[/CCACHE FOR SCHROOT]"

    echo -e "\e[32m[/CREATE-${release^^}-SCHROOT]\e[0m"
}

setup_schroot_alias(){

    local release=$1
    local release_alias=$2

    # setup schroot aliases
    if ! find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec grep -q "^aliases.*\(=\|,\)$release_alias\($\|,\)" {} +; then
        echo "►► setting $release_alias alias for ${release}'s schroot"
        if ! find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec grep -q "^aliases" {} +; then
            echo "aliases=$release_alias" | sudo tee -a "/etc/schroot/chroot.d/${release}-amd64-sbuild-"* >/dev/null
        else
            sudo find /etc/schroot/chroot.d/ -name "${release}-amd64-sbuild-*" -exec sed -i -e "/aliases/ s/$/,${release_alias}/" {} +
        fi
    else
        echo "✔ $release_alias alias is set for ${release}'s schroot"
    fi
}

setup_gnome(){
    # tweak some gnome settings using gsettings
    echo -e "\e[92m[GNOME]\e[0m"
    apt_install_wrapper "$pkglist_gnome"

    if [[ $(gsettings get org.gnome.desktop.interface gtk-theme) != "'Adwaita-dark'" ]]; then
        echo "►► Setting Gnome theme to Adwaita-dark"
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    else
        echo "✔ Gnome theme is already Adwaita-dark"
    fi

    if [[ $(gsettings get org.gnome.desktop.interface enable-animations) == "true" ]]; then
        echo "►► Setting Gnome animations to false"
        gsettings set org.gnome.desktop.interface enable-animations false
    else
        echo "✔ Gnome animations is already set to false"
    fi

    if [[ $(gsettings get org.gnome.desktop.interface monospace-font-name) != "'Hack 11'" ]]; then
        echo "►► Setting Gnome monospace font to Hack 11"
        gsettings set org.gnome.desktop.interface monospace-font-name "Hack 11"
    else
        echo "✔ Gnome monospace font is already Hack 11"
    fi

    echo -e "\e[92m[/GNOME]\e[0m"
}

setup_apt(){
    # configure unstable and experimental repositories, but pinning them so no
    # unintended upgrade happens
    echo -e "\e[92m[APT]\e[0m"

    RETURNVAR=0

    copy_files_wrapper apt_preferences_unstable /etc/apt/preferences.d/unstable sudo
    copy_files_wrapper apt_sources_unstable /etc/apt/sources.list.d/unstable.list sudo

    copy_files_wrapper apt_sources_experimental /etc/apt/sources.list.d/experimental.list sudo

    # if any changed was made, run 'apt update'
    if [[ $RETURNVAR -gt 0 ]]; then
        echo "--------------------------------------------------------------------------------"
        sudo apt update
        echo "--------------------------------------------------------------------------------"
    fi

    echo -e "\e[92m[/APT]\e[0m"
}

setup_firefox(){
    # install firefox from unstable and remove firefox-esr
    echo -e "\e[92m[FIREFOX]\e[0m"
    if ! (dpkg-query -W -f='${Status}' firefox 2>/dev/null | grep -q "install ok installed"); then
        echo "--------------------------------------------------------------------------------"
        sudo apt install -t sid firefox
        sudo apt remove firefox-esr
        echo "--------------------------------------------------------------------------------"
    else
        echo "✔ firefox is already installed"
    fi

    echo -e "\e[92m[/FIREFOX]\e[0m"
}

setup_i3(){
    # setup various i3 tools and settings
    echo -e "\e[92m[I3]\e[0m"
    apt_install_wrapper "$pkglist_i3"

    # install i3-gnome if not already installed
    if [[ ! -f /usr/share/xsessions/i3-gnome.desktop ]]; then
        git clone https://github.com/i3-gnome/i3-gnome
        (cd i3-gnome && sudo make install)
        rm -rf i3-gnome
    else
        echo "✔ i3-gnome is already installed"
    fi

    mkdir -p ~/.config/i3
    copy_files_wrapper i3_config ~/.config/i3/config
    copy_files_wrapper .i3status.conf ~/.i3status.conf
    copy_files_wrapper redshift.conf ~/.config/redshift.conf

    echo -e "\e[92m[/I3]\e[0m"
}

setup_tools(){
    # setup miscellaneous
    echo -e "\e[92m[TOOLS]\e[0m"
    apt_install_wrapper "$pkglist_tools"

    # fill in template config files with personal information
    if [[ .gitconfig-template -nt .gitconfig ]]; then
        if [[ -z $config_files_name ]]; then
            read -rp "Name: " config_files_name
        fi
        if [[ -z $config_files_email ]]; then
            read -rp "Email: " config_files_email
        fi
        sed -e "s/\${NAME-PLACEHOLDER}/$config_files_name/g" -e "s/\${EMAIL-PLACEHOLDER}/$config_files_email/g" .gitconfig-template > .gitconfig
    else
        echo "Skipping .gitconfig generation because file '.gitconfig' is newer than its template, remove it for regeneration"
    fi

    copy_files_wrapper .gitconfig ~/.gitconfig

    echo -e "\e[92m[/TOOLS]\e[0m"
}

setup_battery(){
    # install battery saving tools
    echo -e "\e[92m[BATTERY]\e[0m"
    apt_install_wrapper "$pkglist_battery"

    echo -e "\e[92m[/BATTERY]\e[0m"
}

setup_atom(){
    # install atom and its packages
    echo -e "\e[92m[ATOM]\e[0m"
        apt_install_wrapper "$pkglist_atom"

    if ! dpkg-query -W -f='${Status}' atom >/dev/null 2>&1; then
        curl -fLso atom.deb https://atom.io/download/deb
        apt_install_wrapper ./atom.deb
        rm atom.deb
    else
        echo "✔ atom is already installed"
    fi

    # Use wrapper instead of installing everything everytime, ideally it will \
    # instal the same packages as the following command:
    # apm stars --user samueloph --install
    # but the starred packages might be out of sync
    atom_packages_installer "$pkglist_atom_extensions"

    echo -e "\e[92m[/ATOM]\e[0m"
}

setup_vim(){
    # vimrc-pre-pluginstall is needed to allow for PlugInstall to work, otherwise
    # it will try to use uninstalled plugins.
    # After vimrc-pre-pluginstall is copied and PlugInstall is run, the real
    # dotfile is copied.
    echo -e "\e[92m[VIM]\e[0m"
    apt_install_wrapper "$pkglist_vim"

    # install vim-plug
    curl -fLso ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # only proceed if file does not exists or it has not been copied already
    if [[ ! -f ~/.vimrc || $(md5sum ~/.vimrc | cut -f1 -d" " 2>/dev/null) != $(md5sum .vimrc | cut -f1 -d" ") ]]; then
        echo "►► Setting up vim-plug and .vimrc"
        copy_files_wrapper .vimrc-pre-pluginstall ~/.vimrc
        vim +'PlugInstall --sync' +qa
        cp "$DIR_PATH"/.vimrc ~/.vimrc
    else
        echo "✔ .vimrc is already the same"
    fi

    echo -e "\e[92m[/VIM]\e[0m"
}

setup_bash(){
    echo -e "\e[92m[BASH]\e[0m"
    apt_install_wrapper "$pkglist_bash"

    if [[ .bashrc-template -nt .bashrc ]]; then
        # fill in template config files with personal information
        if [[ -z $config_files_name ]]; then
            read -rp "Name: " config_files_name
        fi
        if [[ -z $config_files_email ]]; then
            read -rp "Email: " config_files_email
        fi
        if [[ -z $config_files_gpgkey ]]; then
            read -rp "GPG Key: " config_files_gpgkey
        fi
        sed -e "s/\${NAME-PLACEHOLDER}/$config_files_name/g" -e "s/\${EMAIL-PLACEHOLDER}/$config_files_email/g" -e "s/\${KEY-PLACEHOLDER}/$config_files_gpgkey/g" -e "s/\${STABLE-PLACEHOLDER}/$stable_codename/g" -e "s/\${OLDSTABLE-PLACEHOLDER}/$oldstable_codename/g" .bashrc-template > .bashrc
    else
        echo "Skipping .bashrc generation because file '.bashrc' is newer than its template, remove it for regeneration"
    fi
    copy_files_wrapper .bashrc ~/.bashrc
    copy_files_wrapper .inputrc ~/.inputrc

    echo -e "\e[92m[/BASH]\e[0m"
}

setup_packaging_tools(){
    # install and configure a bunch of tools needed for packaging work

    echo -e "\e[92m[PACKAGING-TOOLS]\e[0m"
    apt_install_wrapper "$pkglist_packaging_tools"

    create_schroot unstable experimental
    create_schroot "$stable_codename" "${stable_codename}-backports"
    create_schroot "$oldstable_codename" "${oldstable_codename}-backports-sloppy"

    if ! grep -q "none /var/lib/schroot/union/overlay tmpfs uid=root,gid=root,mode=0750 0 0" /etc/fstab; then
        echo "►► Using tmpfs for builds"
        sudo cp /etc/fstab /etc/fstab.bkp-"$timestamp"
        echo "/etc/fstab" >> "$changed_files"
        echo "/etc/fstab.bkp-${timestamp}" >> "$backup_files"
        echo "none /var/lib/schroot/union/overlay tmpfs uid=root,gid=root,mode=0750 0 0" | sudo tee -a /etc/fstab > /dev/null
    else
        echo "✔ tmpfs is already used for builds"
    fi

    # fill in template config files with personal information
    if [[ .sbuildrc-template -nt .sbuildrc ]]; then
        if [[ -z $config_files_gpgkey ]]; then
            read -rp "GPG Key: " config_files_gpgkey
        fi
        sed -e "s/\${KEY-PLACEHOLDER}/${config_files_gpgkey}/g" .sbuildrc-template > .sbuildrc
    else
        echo "Skipping .gitconfig generation because file '.gitconfig' is newer than its template, remove it for regeneration"
    fi

    copy_files_wrapper .sbuildrc ~/.sbuildrc

    echo -e "\e[92m[/PACKAGING-TOOLS]\e[0m"
}

setup_tmpfs(){
    # mount tmp in RAM, to save disk writes and increase performance on systems with
    # lots of RAM
    echo -e "\e[92m[tmpfs]\e[0m"

    if systemctl status tmp.mount >/dev/null 2>&1;then
        echo "✔ tmp is already mounted as tmpfs"
    else
        echo "►► setting up tmp to be mounted as tmpfs (effective after reboot)"
        sudo cp /usr/share/systemd/tmp.mount /etc/systemd/system/
        sudo systemctl enable tmp.mount
    fi

    echo -e "\e[92m[/tmpfs]\e[0m"
}

setup_ssd(){
    # enable fstrim, for ssd systems
    echo -e "\e[92m[ssd]\e[0m"

    if systemctl status fstrim.timer >/dev/null 2>&1;then
        echo "✔ fstrim is already enabled"
    else
        echo "►► enabling fstrim"
        sudo systemctl enable --now fstrim.timer
    fi

    echo -e "\e[92m[/ssd]\e[0m"
}

# lists of packages to be used by the functions above
pkglist_atom_extensions=(
    atom-beautify
    autocomplete-clang
    file-icons
    git-blame
    git-plus
    highlight-line
    highlight-selected
    linter
    linter-clang
    linter-shellcheck
    markdown-pdf
    minimap
    minimap-bookmarks
    minimap-find-and-replace
    minimap-git-diff
    minimap-highlight-selected
    minimap-linter
    minimap-pigments
    minimap-selection
    minimap-split-diff
    pdf-view
    pigments
    script
    split-diff
    tabs-to-spaces
)

pkglist_gnome=(
    fonts-hack
)

pkglist_i3=(
    fonts-hack
    i3
    j4-dmenu-desktop
    light
    nitrogen
    policykit-1-gnome
    redshift-gtk
    xss-lock
)

pkglist_atom=(
    clang
    flake8
    shellcheck
)

pkglist_bash=(
    powerline
    powerline-gitstatus
)
pkglist_vim=(
    curl
    flake8
    vim
)

pkglist_battery=(
    acpi-call-dkms
    tlp
)

pkglist_tools=(
    colordiff
    docker.io
    make
    msmtp
    nmap
    python3-pip
    rsync
    screen
    signing-party
    telegram-desktop
    tree
    virt-manager
    whois
)

pkglist_packaging_tools=(
    ccache
    debhelper
    dh-make
    diffoscope
    dput-ng
    git
    git-buildpackage
    myrepos
    piuparts
    quilt
    sbuild-debian-developer-setup
)

# codenames of releases to be used by the packaging tools setup
stable_codename="buster"
oldstable_codename="stretch"

# personal information used to fill in configuration files
config_files_name=""
config_files_email=""
config_files_gpgkey=""

# path of this script, to be used to evaluate path of dotfiles
DIR_PATH="$(dirname "$(realpath "$0")")"
# variable used to get return values from functions
RETURNVAR=0
# timestamp to use for backup files
timestamp=$(date -d now +'%Y-%m-%d-%Hh%Mm%Ss')

# variables used for logging
logs_folder="logs/"
changed_files="${logs_folder}changed-files"
backup_files="${logs_folder}backup-files"

# initiate logging
mkdir -p $logs_folder
echo "--- run $timestamp ---" | tee -a $changed_files $backup_files
echo "changed-files" >> $changed_files
echo "backup-files" >> $backup_files


# call all the functions
setup_apt
setup_firefox
setup_tools
setup_battery
setup_atom
setup_i3
setup_vim
setup_bash
setup_tmpfs
setup_ssd
setup_packaging_tools
setup_gnome

# print a summary of the changes
echo -e "\e[92m[CHANGES]\e[0m"

paste <(echo "$DIR_PATH/$changed_files") <(echo "$DIR_PATH/$backup_files")
paste "$changed_files" "$backup_files"

echo -e "\e[92m[/CHANGES]\e[0m"
