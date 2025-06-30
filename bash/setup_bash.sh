#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/create_backup_of_file"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/package_list_bash"

setup_bash(){

    print_header "[BASH]"

    apt_install_wrapper "${PACKAGE_LIST_BASH[@]}"

    copy_files_wrapper --sudo=false "$supporting_files_folder/.inputrc" "$HOME/.inputrc"

    setup_bashrcd

    for bashrc_script in "$supporting_files_folder"/bashrc.d/*.bashrc; do
        copy_files_wrapper --sudo=false "$bashrc_script" "$HOME/.bashrc.d/"
    done

    if [[ ! ${STABLE_CODENAME:-} ]]; then
        # Generate 35_deb_packaging_personal_vars.bashrc
        # shellcheck disable=SC1094,SC1091
        source "$project_toplevel/util/variables/name" &>/dev/null \
        || read -rp "Name: " NAME \
        && echo "NAME=\"$NAME\"" > "$project_toplevel/util/variables/name"

        # shellcheck disable=SC1094,SC1091
        source "$project_toplevel/util/variables/email_address" &>/dev/null \
        || read -rp "Email address: " EMAIL_ADDRESS \
        && echo "EMAIL_ADDRESS=\"$EMAIL_ADDRESS\"" > "$project_toplevel/util/variables/email_address"

        echo "DEBEMAIL=\"$EMAIL_ADDRESS\"" > "$HOME/.bashrc.d/35_deb_packaging_personal_vars.bashrc"
        echo "DEBFULLNAME=\"$NAME\"" >> "$HOME/.bashrc.d/35_deb_packaging_personal_vars.bashrc"
        echo "export DEBEMAIL DEBFULLNAME" >> "$HOME/.bashrc.d/35_deb_packaging_personal_vars.bashrc"
    fi

    print_header "[/BASH]"
}

# Enable the usage of ~/.bashrc.d/* scripts in ~/.bashrc.
# The files are parsed in sorted order from the ~/.bashrc.d/ folder, so numbers
# can be prepended to scripts to ensure a given order (eg.: ~/.bashrc.d/10_powerline.bashrc).
setup_bashrcd(){
    bashrcd_script_identifier="samueloph dotfiles bashrcd"
    bashrcd_script_version=$(grep "START $bashrcd_script_identifier" "$supporting_files_folder/bashrcd_script.bashrc" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")

    # If the script already exists in ~/.bashrc and has a different version, use
    # perl to remove it, then append the new script to the end of ~/.bashrc.
    #
    # Check if there is any version of the script present.
    if grep -q "START ${bashrcd_script_identifier}.*" "$HOME/.bashrc"; then
        # Check if the version present is the one set as the latest one ($bashrcd_script_version).
        if grep -q "START ${bashrcd_script_identifier} ${bashrcd_script_version}" "$HOME/.bashrc"
        then
            print_skip "bashrc.d is already enabled"
        # Not the latest version, remove it and append the new one to the end of ~/.bashrc.
        else
            print_in_progress "Updating bashrc.d script in ~/.bashrc"
            create_backup_of_file "$HOME/.bashrc"
            # -i: in-place editing of file.
            # -0: slurp mode, work on entire file at once (instead of line-by-line),
            #     this allows multi-line search-and-replace.
            # -pe: enables search and replace from command line.
            #
            # The "/s" modifier at the end of the regex changes the behavior of the
            # dot "." metacharacter to match newlines "\n" as well.
            # Note the lack of the "/g" modifier, as we only expect a single match
            # in the whole ~/.bashrc file.
            perl -i -0pe "s/### START ${bashrcd_script_identifier}.*END ${bashrcd_script_identifier}//s" \
                "$HOME/.bashrc"
            tail -n +2 "$supporting_files_folder/bashrcd_script.bashrc" >> "$HOME/.bashrc"
        fi
    # If the script is not in ~/.bashrc yet, add it and create the ~/.bashrc.d folder.
    else
        print_in_progress "Setting up bashrc.d script in ~/.bashrc and creating the ~/.bashrc.d folder"
        mkdir -p "$HOME/.bashrc.d"
        create_backup_of_file "$HOME/.bashrc"
        tail -n +2 "$supporting_files_folder/bashrcd_script.bashrc" >> "$HOME/.bashrc"
    fi
}

setup_bash
