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
source "$supporting_files_folder/package_list_vim"

setup_vim(){

    print_header "[VIM]"

    # vimrc-pre-pluginstall is needed to allow for PlugInstall to work, otherwise
    # it will try to use uninstalled plugins.
    # After vimrc-pre-pluginstall is copied and PlugInstall is run, the real
    # dotfile is copied.
    apt_install_wrapper "${PACKAGE_LIST_VIM[@]}"

    # install vim-plug
    curl -fLso ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # only proceed if file does not exists or it has not been copied already
    if ! cmp -s "$supporting_files_folder/.vimrc" "$HOME/.vimrc"; then
        print_in_progress "Setting up vim-plug and .vimrc"
        copy_files_wrapper --sudo=false "$supporting_files_folder/.vimrc-pre-pluginstall" "$HOME/.vimrc"
        vim +'PlugInstall --sync' +qa
        cp "$supporting_files_folder/.vimrc" "$HOME/.vimrc"
    else
        print_skip ".vimrc is already the same"
    fi

    print_header "[/VIM]"
}

setup_vim
