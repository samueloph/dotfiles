#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

setup_misc(){
    echo -e "\e[1;32m--------------------[MISC]--------------------\e[0m"
    # setup miscellaneous
    bash "$project_toplevel/misc/setup_apt_repos.sh"
    bash "$project_toplevel/misc/setup_misc_packages.sh"
    bash "$project_toplevel/misc/setup_firefox.sh"
    bash "$project_toplevel/misc/setup_git.sh"
    bash "$project_toplevel/misc/setup_battery_tools.sh"
    bash "$project_toplevel/misc/setup_fstrim.sh"
    bash "$project_toplevel/misc/setup_tmpfs.sh"

    echo -e "\e[1;32m--------------------[/MISC]-------------------\e[0m"

}

setup_misc
