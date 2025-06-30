#!/bin/bash

# Path of this script, to be used to evaluate path other files.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path"

# Timestamp to use for backup file names.
timestamp=$(date -d now +'%Y-%m-%d-%Hh%Mm%Ss')

# Variables used for logging.
logs_folder="logs"
changed_files_logfile="$project_toplevel/$logs_folder/changed_files_logfile"
backup_files_logfile="$logs_folder/backup_files_logfile"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

# Simple argument validation, it only validates that at least 1 argument was passed
# and that the first argument is valid. Any other invalid arguments will be gracefully
# ignored.
if [[ $# -eq 0 ]] \
|| [[ ! $1 =~ --setup-(all|alacritty|misc|bash|gnome|vim|nvim|hack-nerd-font|tmux|snap-packages|vscode|packaging-tools|sbuild-debian) ]]
then
    print_warning "At least 1 argument is required: setup_debian.sh [options...]"
    echo "Available options are:"
    echo "--setup-alacritty"
    echo "--setup-all"
    echo "--setup-bash"
    echo "--setup-gnome"
    echo "--setup-misc"
    echo "--setup-nvim"
    echo "--setup-hack-nerd-font"
    echo "--setup-packaging-tools"
    echo "--setup-sbuild-debian"
    echo "--setup-snap-packages"
    echo "--setup-tmux"
    echo "--setup-vim"
    echo "--setup-vscode"
    echo "For more information, read the README.md file."
    exit 1
fi

# Initialize logging.
mkdir -p $logs_folder
echo "--- run $timestamp ---" | tee -a "$changed_files_logfile" "$backup_files_logfile"
echo "changed-files" >> "$changed_files_logfile"
echo "backup-files" >> "$backup_files_logfile"

# Call all setup scripts requested for in the arguments.
for argument in "$@" ; do
    if [[ $argument == "--setup-all" ]]; then
        # Call all the setup scripts.
        bash "$project_toplevel/hack_nerd_font/setup_hack_nerd_font.sh"
        bash "$project_toplevel/alacritty/setup_alacritty.sh"
        bash "$project_toplevel/misc/setup_misc.sh"
        bash "$project_toplevel/bash/setup_bash.sh"
        bash "$project_toplevel/gnome/setup_gnome.sh"
        bash "$project_toplevel/vim/setup_vim.sh"
        bash "$project_toplevel/nvim/setup_nvim.sh"
        bash "$project_toplevel/tmux/setup_tmux.sh"
        bash "$project_toplevel/snap_packages/setup_snap_packages.sh"
        bash "$project_toplevel/vscode/setup_vscode.sh"
        bash "$project_toplevel/packaging_tools/setup_packaging_tools.sh"
        echo "If you installed any snap packages, you will need to logout and login again so Gnome can pick up the snap packages' shortcuts"
        break
    fi
    if [[ $argument == "--setup-alacritty" ]]; then
        bash "$project_toplevel/alacritty/setup_alacritty.sh"
    fi
    if [[ $argument == "--setup-misc" ]]; then
        bash "$project_toplevel/misc/setup_misc.sh"
    fi
    if [[ $argument == "--setup-bash" ]]; then
        bash "$project_toplevel/bash/setup_bash.sh"
    fi
    if [[ $argument == "--setup-gnome" ]]; then
        bash "$project_toplevel/gnome/setup_gnome.sh"
    fi
    if [[ $argument == "--setup-vim" ]]; then
        bash "$project_toplevel/vim/setup_vim.sh"
    fi
    if [[ $argument == "--setup-tmux" ]]; then
        bash "$project_toplevel/tmux/setup_tmux.sh"
    fi
    if [[ $argument == "--setup-nvim" ]]; then
        bash "$project_toplevel/nvim/setup_nvim.sh"
    fi
    if [[ $argument == "--setup-hack-nerd-font" ]]; then
        bash "$project_toplevel/hack_nerd_font/setup_hack_nerd_font.sh"
    fi
    if [[ $argument == "--setup-snap-packages" ]]; then
        bash "$project_toplevel/snap_packages/setup_snap_packages.sh"
        print_warning "If you installed any snap packages, you will need to logout and login again so Gnome can pick up the snap packages' shortcuts"
    fi
    if [[ $argument == "--setup-vscode" ]]; then
        bash "$project_toplevel/vscode/setup_vscode.sh"
    fi
    if [[ $argument == "--setup-packaging-tools" ]]; then
        bash "$project_toplevel/packaging_tools/setup_packaging_tools.sh"
    fi
    if [[ $argument == "--setup-sbuild-debian" ]]; then
        bash "$project_toplevel/sbuild_debian/setup_sbuild_debian.sh" unstable
    fi
done

# Print a summary of the changes.
print_header "[CHANGES]"

paste <(echo "$changed_files_logfile") <(echo "$backup_files_logfile")
paste "$changed_files_logfile" "$backup_files_logfile"

print_header "[/CHANGES]"
