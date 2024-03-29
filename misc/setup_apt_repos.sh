#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_apt_repos(){
    # configure unstable and experimental repositories, but pinning them so no
    # unintended upgrade happens
    print_header "[APT REPOS]"

    copy_files_wrapper --sudo=true "$supporting_files_folder/apt_preferences_unstable" /etc/apt/preferences.d/unstable
    copy_files_wrapper --sudo=true "$supporting_files_folder/apt_sources_unstable" /etc/apt/sources.list.d/unstable.list
    copy_files_wrapper --sudo=true "$supporting_files_folder/apt_sources_experimental" /etc/apt/sources.list.d/experimental.list

    print_header "[/APT REPOS]"
}

setup_apt_repos
