#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_misc_packages"
# shellcheck source=/dev/null
source "$project_toplevel/util/print_utils"

setup_git(){
    # setup miscellaneous
    print_header "[MISC PACKAGES]"

    apt_install_wrapper "${PACKAGE_LIST_MICS_PACKAGES[@]}"

    print_header "[/MISC PACKAGES]"
}
