#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/print_utils"

setup_snap(){

    print_header "[SNAP]"

    apt_install_wrapper snapd

    snap_installed_packages=$(snap list)
    if ! echo "$snap_installed_packages" | grep -q "spotify"; then
        echo "►► Installing spotify snap"
        sudo snap install spotify
    else
        echo "✔ spotify snap is already installed"
    fi
    if ! echo "$snap_installed_packages" | grep -q "dbeaver-ce"; then
        echo "►► Installing dbeaver-ce snap"
        sudo snap install dbeaver-ce
    else
        echo "✔ dbeaver-ce snap is already installed"
    fi
    if ! echo "$snap_installed_packages" | grep -q "discord"; then
        echo "►► Installing discord snap"
        sudo snap install discord
    else
        echo "✔ discord snap is already installed"
    fi
    if ! echo "$snap_installed_packages" | grep -q "vscode"; then
        echo "►► Installing vscode snap"
        sudo snap install code --classic
    else
        echo "✔ vscode snap is already installed"
    fi

    print_header "[/SNAP]"
}

setup_snap
echo "If you installed any snap packages, you will need to logout and login again so Gnome can pick up the snap packages' shortcuts"
