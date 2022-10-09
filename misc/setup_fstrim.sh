#!/bin/bash

set -euo pipefail

setup_fstrim(){
    # Enable fstrim, for systems with an SSD.
    echo -e "\e[1;32m--------------------[FSTIM]--------------------\e[0m"

    if systemctl status fstrim.timer &>/dev/null; then
        echo "✔ fstrim is already enabled"
    else
        echo "►► enabling fstrim"
        sudo systemctl enable --now fstrim.timer
    fi

    echo -e "\e[1;32m--------------------[/FSTRIM]-------------------\e[0m"
}

setup_fstrim
