#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"

setup_git(){

    echo -e "\e[1;32m--------------------[GIT]--------------------\e[0m"
    apt_install_wrapper git

    # fill in template config files with personal information
    if [[ $supporting_files_folder/.gitconfig-template -nt $supporting_files_folder/.gitconfig ]]
    then

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/name" &>/dev/null ||
        read -rp "Name: " NAME &&
        echo "NAME=\"$NAME\"" > "$project_toplevel/util/variables/name"

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/email_address" &>/dev/null ||
        read -rp "Email address: " EMAIL_ADDRESS &&
        echo "EMAIL_ADDRESS=\"$EMAIL_ADDRESS\"" > "$project_toplevel/util/variables/email_address"

        sed -e "s/\${NAME-PLACEHOLDER}/$NAME/g" \
            -e "s/\${EMAIL-PLACEHOLDER}/$EMAIL_ADDRESS/g" \
            "$supporting_files_folder/.gitconfig-template" > "$supporting_files_folder/.gitconfig"
    else
        echo "Skipping $supporting_files_folder/.gitconfig generation because the file is newer than its template, remove it for regeneration"
    fi

    copy_files_wrapper --sudo=false "$supporting_files_folder/.gitconfig" "$HOME/.gitconfig"

    echo -e "\e[1;32m--------------------[/GIT]-------------------\e[0m"
}

setup_git
