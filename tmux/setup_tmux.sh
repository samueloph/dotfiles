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

# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/package_list_tmux"

setup_tmux(){

    print_header "[TMUX]"

    #apt_install_wrapper "${PACKAGE_LIST_TMUX[@]}"

    copy_files_wrapper --sudo=false "$supporting_files_folder/tmux-sessionizer" ~/.local/bin/
    copy_files_wrapper --sudo=false "$supporting_files_folder/.tmux.conf" ~/


    print_header "[/TMUX]"
}

setup_tmux
