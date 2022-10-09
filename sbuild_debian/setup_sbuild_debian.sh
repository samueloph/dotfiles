#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_sbuild_debian"

# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/copy_files_wrapper"

backup_files_logfile="$project_toplevel/logs/backup_files_logfile"
changed_files_logfile="$project_toplevel/logs/changed_files_logfile"

arch="$(dpkg --print-architecture)"

setup_sbuild_debian(){
    # Create chroot and configure it to be used with sbuild, using eatmydata,
    # ccache and apt-cacher-ng.
    #
    # Input:
    # $1: Release codename, eg.: unstable, bookworm, trixie.

    if [[ $# -ne 1 ]]; then
        echo "Exactly 1 argument is required: setup_sbuild_debian.sh <release_codename>"
        echo "<release_codename> is the codename of the chroot you want to prepare."
        exit 1
    fi

    local release=$1

    echo -e "\e[32m--------------------[CREATE-${release^^}-SCHROOT]--------------------\e[0m"

    apt_install_wrapper "${PACKAGE_LIST_SBUILD_DEBIAN[@]}"

    # Only proceed if no chroot for $release is found.
    if find /etc/schroot/chroot.d/ -type f -name "${release}-${arch}-sbuild-*" \
        -exec false {} +
    then
        test_ccache="true"
        echo "►► setting up sbuild's ${release} chroot"
        echo "--------------------------------------------------------------------------------"
        sudo sbuild-createchroot --include=eatmydata,ccache,gnupg "$release" \
        "/srv/chroot/${release}-${arch}-sbuild" http://127.0.0.1:3142/deb.debian.org/debian
        sudo sbuild-adduser "$USER" &>/dev/null
        echo "--------------------------------------------------------------------------------"
    else
        echo "✔ sbuild's ${release} chroot is already configured"
    fi


    # Setup release codename as an alias so we can call autopkgtest by the
    # schroot alias instead of using the chroot name.
    setup_schroot_alias "$release" "$release"

    # Set known aliases for other releases if they're the one being configured
    # by this function.
    if [[ $release == "unstable" ]]; then
        setup_schroot_alias "$release" "experimental"
        setup_schroot_alias "$release" "UNRELEASED"
    else
    # If release is not unstable, assume it's either stable or oldstable and
    # set aliases to -security, -backports and -backports-sloppy.
        setup_schroot_alias "$release" "${release}-security"
        setup_schroot_alias "$release" "${release}-backports"
        setup_schroot_alias "$release" "${release}-backports-sloppy"
    fi

    # Setup eatmydata.
    if ! find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
        -exec grep -q "^command-prefix.*eatmydata" {} +
    then
        echo "►► setting eatmydata command-prefix for ${release}'s schroot"
        if ! find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
            -exec grep -q "^command-prefix" {} +
        then
            echo "command-prefix=eatmydata" \
            | sudo tee -a "/etc/schroot/chroot.d/${release}-${arch}-sbuild-"* >/dev/null
        else
            sudo find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
                -exec sed -i -e '/command-prefix/ {/eatmydata/! s/$/,eatmydata/}' {} +
        fi
    else
        echo "✔ eatmydata command-prefix is already set in ${release}'s schroot"
    fi

    setup_ccache "$release"

    # Create a cronjob to update any/all sbuild chroots.
    copy_files_wrapper --sudo=true "$supporting_files_folder/sbuild-update-all" /etc/cron.d/

    echo -e "\e[32m--------------------[/CREATE-${release^^}-SCHROOT]-------------------\e[0m"
}

setup_ccache(){

    local release=$1
    # Flag to control whether ccache needs to be tested or not, will be set to
    # true if ccache is installed or changed.
    local test_ccache="false"
    local ccache_dir="/var/cache/ccache-sbuild"
    local sbuild_setup_file_destination="$ccache_dir/sbuild-setup"

    # Setup ccache.
    echo -e "[CCACHE FOR SCHROOT]"

    if [[ ! -d $ccache_dir ]]; then
        test_ccache="true"
        echo "►► setting up ccache folder"
        sudo install --group=sbuild --mode=2775 -d $ccache_dir
        sudo env CCACHE_DIR=$ccache_dir ccache --max-size 4G
    else
        echo "✔ ccache folder is already setup"
    fi

    copy_files_wrapper --sudo=true "$supporting_files_folder/sbuild-setup" $ccache_dir/sbuild-setup

    fstab_schroot_ccacche="$ccache_dir $ccache_dir none rw,bind 0 0"

    if ! grep -q "$fstab_schroot_ccacche" /etc/schroot/sbuild/fstab; then
        test_ccache="true"
        echo "►► setting up mounting of ccache folder from sbuild's chroot"
        echo "$fstab_schroot_ccacche" | sudo tee -a /etc/schroot/sbuild/fstab >/dev/null

        echo "/etc/schroot/sbuild/fstab" >> "$changed_files_logfile"
    else
        echo "✔ ccache folder is already on chroot's fstab"
    fi

    if ! find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
        -exec grep -q "^command-prefix.*$sbuild_setup_file_destination" {} +
    then
        test_ccache="true"
        echo "►► setting ccache command-prefix for ${release}'s schroot"
        if ! find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
            -exec grep -q "^command-prefix" {} +
        then
            echo "command-prefix=$sbuild_setup_file_destination" \
            | sudo tee -a "/etc/schroot/chroot.d/${release}-${arch}-sbuild-"* >/dev/null
        else
            # The sed expression below is escaping any forward slashes from the variable
            # sbuild_setup_file_destination by using parameter expansion in the format:
            # ${parameter/pattern/string}.
            sudo find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
                -exec sed -i \
                -e "/command-prefix/ {/${sbuild_setup_file_destination//\//\\/}/! s/$/,${sbuild_setup_file_destination//\//\\/}/}" {} +
        fi
    else
        echo "✔ ccache command-prefix is already set in ${release}'s schroot"
    fi

    # Test ccache if needed.
    if [[ $test_ccache == "true" ]]; then
        if sudo schroot -c "source:${release}-${arch}-sbuild" -d /home -- ccache -p \
            | grep -q "$ccache_dir/ccache.conf"
        then
            echo "✔ ccache sucessfully tested"
        else
            echo "⚠️ could not test ccache, something is wrong ⚠️"
        fi
    else
        echo "✔ skip ccache test because there were no changes"
    fi

    echo -e "[/CCACHE FOR SCHROOT]"
}

setup_schroot_alias(){

    local release=$1
    local release_alias=$2

    # Setup schroot aliases.
    if ! find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
        -exec grep -q "^aliases.*\(=\|,\)$release_alias\($\|,\)" {} +
    then
        echo "►► setting $release_alias alias for ${release}'s schroot"
        if ! find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
            -exec grep -q "^aliases" {} +
        then
            echo "aliases=$release_alias" \
            | sudo tee -a "/etc/schroot/chroot.d/${release}-${arch}-sbuild-"* >/dev/null
        else
            sudo find /etc/schroot/chroot.d/ -name "${release}-${arch}-sbuild-*" \
                -exec sed -i -e "/aliases/ s/$/,${release_alias}/" {} +
        fi
    else
        echo "✔ $release_alias alias is set for ${release}'s schroot"
    fi
}

setup_sbuild_tmpfs(){
    fstab_schroot_overlay_tmpfs="none /var/lib/schroot/union/overlay tmpfs uid=root,gid=root,mode=0750 0 0"

    if ! grep -q "$fstab_schroot_overlay_tmpfs" /etc/fstab; then
        echo "►► Using tmpfs for builds"
        local timestamp

        # timestamp to use for backup files
        timestamp=$(date -d now +'%Y-%m-%d-%Hh%Mm%Ss')
        sudo cp /etc/fstab /etc/fstab.bkp-"$timestamp"
        echo "/etc/fstab" >> "$changed_files_logfile"
        echo "/etc/fstab.bkp-${timestamp}" >> "$backup_files_logfile"
        echo "$fstab_schroot_overlay_tmpfs" | sudo tee -a /etc/fstab > /dev/null
    else
        echo "✔ tmpfs is already used for builds"
    fi
}

for release in "$@"
do
    setup_sbuild_debian "$release"
done

# If the machine has at least 16GiB of RAM, mount schroots on tmpfs.
# You can call setup_sbuild_tmpfs directly if you want to force it.
if [[ $(( $(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024) )) -ge 16000 ]]
then
    setup_sbuild_tmpfs
fi
