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

setup_hack_nerd_font(){

    print_header "[HACK NERD FONT]"

    if [[ ! -f "${supporting_files_folder}/Hack.tar.xz" ]]; then
        print_in_progress "Downloading zip file of patched Hack font"
        cd "${supporting_files_folder}"
        curl -s -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.tar.xz -o Hack.tar.xz
        tar xf Hack.tar.xz
        ls
        cd -
    else
        print_skip "Hack.tar.xz is already present in ${supporting_files_folder}"
    fi

    # fc-list | grep HackNerdFont
    # cp HackNerdFont-Bold.ttf /home/samueloph/.local/share/fonts/
    # fc-cache -f
    # fc-cache -fv # for verbose
    # fc-list | grep HackNerdFont

    print_header "[/HACK NERD FONT]]"
}

setup_hack_nerd_font
