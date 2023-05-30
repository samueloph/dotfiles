#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_git(){

    print_header "[GIT]"

    apt_install_wrapper git

    # fill in template config files with personal information
    if [[ $supporting_files_folder/.gitconfig-template -nt $supporting_files_folder/.gitconfig ]]
    then

        # shellcheck disable=SC1094,SC1091
        source "$project_toplevel/util/variables/name" &>/dev/null \
        || read -rp "Name: " NAME \
        && echo "NAME=\"$NAME\"" > "$project_toplevel/util/variables/name"

        # shellcheck disable=SC1094,SC1091
        source "$project_toplevel/util/variables/email_address" &>/dev/null \
        || read -rp "Email address: " EMAIL_ADDRESS \
        && echo "EMAIL_ADDRESS=\"$EMAIL_ADDRESS\"" > "$project_toplevel/util/variables/email_address"

        sed -e "s/\${NAME-PLACEHOLDER}/$NAME/g" \
            -e "s/\${EMAIL-PLACEHOLDER}/$EMAIL_ADDRESS/g" \
            "$supporting_files_folder/.gitconfig-template" > "$supporting_files_folder/.gitconfig"
    else
        echo "Skipping $supporting_files_folder/.gitconfig copying because you already have a file in the destination and it's newer than the one from this script."
    fi

    copy_files_wrapper --sudo=false "$supporting_files_folder/.gitconfig" "$HOME/.gitconfig"

    print_header "[/GIT]"
}

setup_git
