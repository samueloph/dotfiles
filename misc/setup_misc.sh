#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_misc(){

    print_header "[MISC]"

    # setup miscellaneous
    bash "$project_toplevel/misc/setup_apt_repos.sh"
    bash "$project_toplevel/misc/setup_misc_packages.sh"
    bash "$project_toplevel/misc/setup_firefox.sh"
    bash "$project_toplevel/misc/setup_git.sh"
    bash "$project_toplevel/misc/setup_battery_tools.sh"

    print_header "[/MISC]"
}

setup_misc
