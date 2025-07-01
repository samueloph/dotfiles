#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/package_list_misc_packages"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_misc_packages(){
    # setup miscellaneous
    print_header "[MISC PACKAGES]"

    apt_install_wrapper "${PACKAGE_LIST_MISC_PACKAGES[@]}"


    if [[ $(dpkg --print-foreign-architectures) != "i386" ]]; then
        print_in_progress "Enabling i386 arch in dpkg, for Steam"
        sudo dpkg --add-architecture i386
        sudo apt update
    else
        print_skip "i386 arch is already enabled in dpkg"
    fi

    apt_install_wrapper steam-installer

    print_header "[/MISC PACKAGES]"
}

setup_misc_packages
