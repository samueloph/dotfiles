#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$project_toplevel/util/create_backup_of_file"
# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/copy_files_wrapper"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_bash"

setup_bash(){
    echo -e "\e[1;32m--------------------[BASH]--------------------\e[0m"

    apt_install_wrapper "${PACKAGE_LIST_BASH[@]}"

    copy_files_wrapper --sudo=false "$supporting_files_folder/.inputrc" "$HOME/.inputrc"

    setup_bashrcd

    if [[ $supporting_files_folder/bashrc.d/30_packaging.template -nt $HOME/.bashrc.d/30_packaging.bashrc ]]
    then
        # Fill in template config bashrc script with the correct values.

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/stable_codename"
        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/oldstable_codename"

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/name" &>/dev/null \
        || read -rp "Name: " NAME \
        && echo "NAME=\"$NAME\"" > "$project_toplevel/util/variables/name"

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/email_address" &>/dev/null \
        || read -rp "Email address: " EMAIL_ADDRESS \
        && echo "EMAIL_ADDRESS=\"$EMAIL_ADDRESS\"" > "$project_toplevel/util/variables/email_address"

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/gpg_key_id" &>/dev/null \
        || read -rp "GPG key ID: " GPG_KEY_ID \
        && echo "GPG_KEY_ID=\"$GPG_KEY_ID\"" > "$project_toplevel/util/variables/gpg_key_id"

        sed -e "/\${NAME-PLACEHOLDER}/s/^# *//" \
            -e "/\${EMAIL-PLACEHOLDER}/s/^# *//" \
            -e "/export DEBEMAIL DEBFULLNAME/s/^# *//" \
            -e "/\${GPG_KEY-PLACEHOLDER}/s/^# *//" \
            -e "/\${STABLE-PLACEHOLDER}/s/^# *//" \
            -e "/\${OLDSTABLE-PLACEHOLDER}/s/^# *//" \
            -e "s/\${NAME-PLACEHOLDER}/$NAME/g" \
            -e "s/\${EMAIL-PLACEHOLDER}/$EMAIL_ADDRESS/g" \
            -e "s/\${GPG_KEY-PLACEHOLDER}/$GPG_KEY_ID/g" \
            -e "s/\${STABLE-PLACEHOLDER}/$STABLE_CODENAME/g" \
            -e "s/\${OLDSTABLE-PLACEHOLDER}/$OLDSTABLE_CODENAME/g" \
            -i "$supporting_files_folder/bashrc.d/30_packaging.bashrc"
    else
        echo "Skipping $supporting_files_folder/bashrc.d/30_packaging.bashrc copying because you already have a file in the destination and it's newer than the one from this script."
    fi

    for bashrc_script in "$supporting_files_folder"/bashrc.d/*.bashrc; do
        copy_files_wrapper --sudo=false "$bashrc_script" "$HOME/.bashrc.d/"
    done

    echo -e "\e[1;32m--------------------[/BASH]-------------------\e[0m"
}

# Enable the usage of ~/.bashrc.d/* scripts in ~/.bashrc.
# The files are parsed in sorted order from the ~/.bashrc.d/ folder, so numbers
# can be prepended to scripts to ensure a given order (eg.: ~/.bashrc.d/10_powerline.bashrc).
setup_bashrcd(){
    # Anytime the script is updated, the version needs to be updated both here
    # and in bashrcd_script.bashrc.
    bashrcd_script_version="2022-10-08"
    bashrcd_script_header="samueloph dotfiles bashrcd"

    # If the script already exists in ~/.bashrc and has a different version, use
    # perl to remove it, then append the new script to the end of ~/.bashrc.
    #
    # Check if there is any version of the script present.
    if grep -q "START ${bashrcd_script_header}.*" "$HOME/.bashrc"; then
        # Check if the version present is the one set as the latest one ($bashrcd_script_version).
        if grep -q "START ${bashrcd_script_header} ${bashrcd_script_version}" "$HOME/.bashrc"
        then
            echo "✔ bashrc.d is already enabled"
        # Not the latest version, remove it and append the new one to the end of ~/.bashrc.
        else
            echo "►► updating bashrc.d script in ~/.bashrc"
            create_backup_of_file --sudo=false "$HOME/.bashrc"
            # -i: in-place editing of file.
            # -0: slurp mode, work on entire file at once (instead of line-by-line),
            #     this allows multi-line search-and-replace.
            # -pe: enables search and replace from command line.
            #
            # The "/s" modifier at the end of the regex changes the behavior of the
            # dot "." metacharacter to match newlines "\n" as well.
            # Note the lack of the "/g" modifier, as we only expect a single match
            # in the whole ~/.bashrc file.
            perl -i -0pe "s/.*START ${bashrcd_script_header}.*END ${bashrcd_script_header}.*//s" \
                "$HOME/.bashrc"
            tail -n +2 "$supporting_files_folder/bashrcd_script.bashrc" >> "$HOME/.bashrc"
        fi
    # If the script is not in ~/.bashrc yet, add it and create the ~/.bashrc.d folder.
    else
        echo "►► setting up bashrc.d script in ~/.bashrc and creating the ~/.bashrc.d folder"
        mkdir -p "$HOME/.bashrc.d"
        create_backup_of_file --sudo=false "$HOME/.bashrc"
        tail -n +2 "$supporting_files_folder/bashrcd_script.bashrc" >> "$HOME/.bashrc"
    fi
}

setup_bash
