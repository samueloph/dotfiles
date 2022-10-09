#!/bin/bash

set -euo pipefail

setup_firefox(){
    # install firefox from unstable and remove firefox-esr
    echo -e "\e[1;32m--------------------[FIREFOX]--------------------\e[0m"

    if ! (dpkg-query -W -f='${Status}' firefox 2>/dev/null | grep -q "install ok installed")
    then
        echo "--------------------------------------------------------------------------------"
        # Call apt update as it's very likely the unstable repo was added just
        # now (by this dotfiles script).
        sudo apt update -qq
        sudo DEBIAN_FRONTEND=noninteractive apt install -y -t sid firefox
        echo "Removing firefox ESR now that regular firefox is installed..."
        sudo apt remove -y firefox-esr
        echo "--------------------------------------------------------------------------------"
    else
        echo "✔ firefox is already installed"
    fi

    echo -e "\e[1;32m--------------------[/FIREFOX]--------------------\e[0m"
}

setup_firefox
