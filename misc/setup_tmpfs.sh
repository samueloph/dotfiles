#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_tmpfs(){
    # Mount tmp in RAM, to save disk writes and increase performance on systems with
    # lots of RAM.
    print_header "[TMPFS]"

    # If the machine doesn't have at least 16GiB of RAM, skip this.
    if [[ $(( $(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024) )) -ge 16000 ]]
    then
        if systemctl status tmp.mount &>/dev/null; then
            print_skip "tmp is already mounted as tmpfs"
        else
            print_in_progress "Setting up tmp to be mounted as tmpfs (effective after reboot)"
            sudo cp /usr/share/systemd/tmp.mount /etc/systemd/system/
            sudo systemctl enable tmp.mount
        fi
    else
        print_warning "This system has less than 16Gib of RAM, not setting TMPFS"
    fi

    print_header "[/TMPFS]"
}

setup_tmpfs
