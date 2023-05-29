#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

# shellcheck source=/dev/null
source "$project_toplevel/util/print_utils"

setup_tmpfs(){
    # mount tmp in RAM, to save disk writes and increase performance on systems with
    # lots of RAM
    print_header "[TMPFS]"

    if systemctl status tmp.mount &>/dev/null; then
        echo "✔ tmp is already mounted as tmpfs"
    else
        echo "►► setting up tmp to be mounted as tmpfs (effective after reboot)"
        sudo cp /usr/share/systemd/tmp.mount /etc/systemd/system/
        sudo systemctl enable tmp.mount
    fi

    print_header "[/TMPFS]"
}

setup_tmpfs
