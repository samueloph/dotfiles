#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_fstrim(){
    # Enable fstrim, for systems with an SSD.
    print_header "[FSTRIM]"

    if systemctl status fstrim.timer &>/dev/null; then
        echo "✔ fstrim is already enabled"
    else
        echo "►► enabling fstrim"
        sudo systemctl enable --now fstrim.timer
    fi

    print_header "[/FSTRIM]"
}

setup_fstrim
