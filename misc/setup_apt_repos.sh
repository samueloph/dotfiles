#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/create_backup_of_file"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_apt_repos(){
    # configure unstable and experimental repositories, but pinning them so no
    # unintended upgrade happens
    print_header "[APT REPOS]"

    copy_files_wrapper --sudo=true "$supporting_files_folder/debian.sources" /etc/apt/sources.list.d/debian.sources
    copy_files_wrapper --sudo=true "$supporting_files_folder/unstable.sources" /etc/apt/sources.list.d/unstable.sources
    copy_files_wrapper --sudo=true "$supporting_files_folder/apt_preferences_unstable" /etc/apt/preferences.d/unstable
    copy_files_wrapper --sudo=true "$supporting_files_folder/experimental.sources" /etc/apt/sources.list.d/experimental.sources
    # Remove /etc/apt/sources.list since we're using the new format (.sources)
    if [[ -f "/etc/apt/sources.liist" ]]; then
        print_in_progress "Removing /etc/apt/sources.list in favor of /etc/apt/sources.list.d/debian.sources"
        create_backup_of_file "/etc/apt/sources.list"
        sudo rm /etc/apt/sources.list
    fi

    print_header "[/APT REPOS]"
}

setup_apt_repos
