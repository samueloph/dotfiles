#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_snap(){

    print_header "[SNAP]"

    apt_install_wrapper snapd

    snap_installed_packages=$(snap list)
    if ! echo "$snap_installed_packages" | grep -q "spotify"; then
        print_in_progress "Installing spotify snap"
        sudo snap install spotify
    else
        print_skip "spotify snap is already installed"
    fi
    if ! echo "$snap_installed_packages" | grep -q "dbeaver-ce"; then
        print_in_progress "Installing dbeaver-ce snap"
        sudo snap install dbeaver-ce
    else
        print_skip "dbeaver-ce snap is already installed"
    fi
    if ! echo "$snap_installed_packages" | grep -q "discord"; then
        print_in_progress "Installing discord snap"
        sudo snap install discord
    else
        print_skip "discord snap is already installed"
    fi
    if ! echo "$snap_installed_packages" | grep -q "vscode"; then
        print_in_progress "Installing vscode snap"
        sudo snap install code --classic
    else
        print_skip "vscode snap is already installed"
    fi

    print_header "[/SNAP]"
}

setup_snap
print_warning "If you installed any snap packages, you will need to logout and login again so Gnome can pick up the snap packages' shortcuts"
