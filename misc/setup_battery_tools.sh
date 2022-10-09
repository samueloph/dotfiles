#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_battery_tools"

setup_battery_tools(){
    # install battery saving tools
    echo -e "\e[1;32m--------------------[BATTERY]--------------------\e[0m"

    apt_install_wrapper "${PACKAGE_LIST_BATTERY_TOOLS[@]}"

    echo -e "\e[1;32m--------------------[/BATTERY]--------------------\e[0m"
}

setup_battery_tools
