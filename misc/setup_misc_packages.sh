#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_misc_packages"

setup_git(){
    # setup miscellaneous
    echo -e "\e[1;32m--------------------[MISC PACKAGES]--------------------\e[0m"

    apt_install_wrapper "${PACKAGE_LIST_MICS_PACKAGES[@]}"

    echo -e "\e[1;32m--------------------[/MISC PACKAGES]--------------------\e[0m"
}
