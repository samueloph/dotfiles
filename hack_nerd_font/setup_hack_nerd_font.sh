#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
# source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

setup_hack_nerd_font(){

    print_header "[HACK NERD FONT]"

    if ! ( fc-list; exit 0) | grep -q "HackNerdFont-Regular"; then
        if [[ ! -f "${supporting_files_folder}/Hack.tar.xz" ]]; then
            print_in_progress "Downloading zip file of patched Hack font"
            cd "${supporting_files_folder}"
            wcurl https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.tar.xz -o Hack.tar.xz
            tar xf Hack.tar.xz
            ls
            cd -
        else
            print_skip "Hack.tar.xz is already present in ${supporting_files_folder}"
        fi
        hack_tarball_sha256_sum=$(sha256sum Hack.tar.xz | cut -d' ' -f1)
        if [ "$hack_tarball_sha256_sum" == "1d00a1435638084174516975840854368a45ac30bb0bad2c0c49db713b5925f0" ]; then
            mkdir -p ~/.local/share/fonts
            copy_files_wrapper --sudo=false "${supporting_files_folder}/HackNerdFontMono-Regular.ttf" ~/.local/share/fonts
            print_in_progress "Installing font HackNerdFontMono-Regular"
            fc-cache -f
            print_info "If you didn't run --setup-all or --setup-gnome, you now need to set this font to be used on gnome tweaks"
        else
            print_warning "Checksum of download tarball for Hack fonts didn't match the expected one, ignoring Hack font installation"
        fi
    else
        print_skip "Font HackNerdFontMono-Regular is already installed"
    fi

    print_header "[/HACK NERD FONT]"
}

setup_hack_nerd_font
