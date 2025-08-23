#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/package_list_neovim"

install_neovim(){
        sudo wcurl https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage -o /usr/bin/nvim
        sudo chmod +x /usr/bin/nvim
}

setup_neovim(){

    print_header "[NEOVIM]"

    apt_install_wrapper "${PACKAGE_LIST_NEOVIM[@]}"

    # Rememove neovim installed from APT
    if (dpkg-query -W -f='${Status}' "neovim" 2>/dev/null | grep -q "install ok installed")
    then
        print_in_progress "Removing neovim installed with APT"
        sudo apt remove neovim
    fi

    # Check if nvim exists
    if [ -f /usr/bin/nvim ]; then

        # Get version installed
        current_version=$(nvim --version | head -n1 | awk '{print $2}')

        print_in_progress "Verifying what's the latest neovim release"
        # Get latest version from GitHub
        latest_url=$(curl -L -s -w "%{url_effective}" -o /dev/null https://github.com/neovim/neovim/releases/latest)
        latest_version=${latest_url##*/}

        # If the versions don't match, assume GitHub's is newer
        if [ "$current_version" != "$latest_version" ]; then
            sudo rm /usr/bin/nvim
            install_neovim
        else
            print_skip "Neovim installed is already the latest version"
        fi
    # If there's no neovim binary, install it
    else
        install_neovim
    fi

    copy_files_wrapper --sudo=false "$supporting_files_folder/nvim" ~/.config/

    print_header "[/NEOVIM]"
}

setup_neovim
