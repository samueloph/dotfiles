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
source "$supporting_files_folder/package_list_nvim"

setup_nvim(){

    print_header "[NEOVIM]"

    #apt_install_wrapper "${PACKAGE_LIST_NEOVIM[@]}"

    # Install packer.
    #

    # create config folder if it doesnt exist
    #mkdir -p "$HOME/.config/nvim"

    # copy over all configs

    # warn that user needs to start nvim once to start all plugins
    # nvim --headless "+Lazy! sync" +qa


    copy_files_wrapper --sudo=false "$supporting_files_folder/nvim" ~/.config/

    print_header "[/NEOVIM]"
}

setup_nvim
