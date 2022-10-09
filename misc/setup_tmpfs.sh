#!/bin/bash

set -euo pipefail

setup_tmpfs(){
    # mount tmp in RAM, to save disk writes and increase performance on systems with
    # lots of RAM
    echo -e "\e[1;32m--------------------[TMPFS]--------------------\e[0m"

    if systemctl status tmp.mount &>/dev/null; then
        echo "✔ tmp is already mounted as tmpfs"
    else
        echo "►► setting up tmp to be mounted as tmpfs (effective after reboot)"
        sudo cp /usr/share/systemd/tmp.mount /etc/systemd/system/
        sudo systemctl enable tmp.mount
    fi

    echo -e "\e[1;32m--------------------[/TMPFS]-------------------\e[0m"
}

setup_tmpfs
