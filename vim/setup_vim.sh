#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_vim"

setup_vim(){
    echo -e "\e[1;32m--------------------[VIM]--------------------\e[0m"

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
        echo "►► Setting up vim-plug and .vimrc"
        copy_files_wrapper --sudo=false "$supporting_files_folder/.vimrc-pre-pluginstall" "$HOME/.vimrc"
        vim +'PlugInstall --sync' +qa
        cp "$supporting_files_folder/.vimrc" "$HOME/.vimrc"
    else
        echo "✔ .vimrc is already the same"
    fi

    echo -e "\e[1;32m--------------------[/VIM]-------------------\e[0m"
}

setup_vim