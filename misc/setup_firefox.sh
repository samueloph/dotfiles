#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_firefox(){
    # install firefox from unstable and remove firefox-esr
    print_header "[FIREFOX]"

    if ! (dpkg-query -W -f='${Status}' firefox 2>/dev/null | grep -q "install ok installed")
    then
        print_header_2 "[apt]"
        # Call apt update as it's very likely the unstable repo was added just
        # now (by this dotfiles script).
        sudo apt update -qq
        sudo DEBIAN_FRONTEND=noninteractive apt install -y -t sid firefox
        print_in_progress "Removing firefox ESR now that regular firefox is installed"
        sudo apt remove -y firefox-esr
        print_header_2 "[/apt]"
    else
        print_skip "firefox is already installed"
    fi

    print_header "[/FIREFOX]"
}

setup_firefox
