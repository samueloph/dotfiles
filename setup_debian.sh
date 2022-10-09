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

# Simple argument validation, it only validates that at least 1 argument was passed
# and that the first argument is valid. Any other invalid arguments will be gracefully
# ignored.
if [[ $# -eq 0 ]] \
|| [[ ! $1 =~ --setup-(all|misc|bash|gnome|vim|snap-packages|vscode|packaging-tools) ]]
then
    echo "At least 1 argument is required: setup_debian.sh [options...]"
    echo "Available options are:"
    echo "--setup-all"
    echo "--setup-misc"
    echo "--setup-bash"
    echo "--setup-gnome"
    echo "--setup-vim"
    echo "--setup-snap-packages"
    echo "--setup-vscode"
    echo "--setup-packaging-tools"
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
    if [[ $argument == "--setup-all" ]] ; then
        # Call all the setup scripts.
        bash "$project_toplevel/misc/setup_misc.sh"
        bash "$project_toplevel/bash/setup_bash.sh"
        bash "$project_toplevel/gnome/setup_gnome.sh"
        bash "$project_toplevel/vim/setup_vim.sh"
        bash "$project_toplevel/snap/setup_snap_packages.sh"
        bash "$project_toplevel/vscode/setup_vscode.sh"
        bash "$project_toplevel/packaging_tools/setup_packaging_tools.sh"
        break
    fi
    if [[ $argument == "--setup-misc" ]] ; then
        bash "$project_toplevel/misc/setup_misc.sh"
    fi
    if [[ $argument == "--setup-bash" ]] ; then
        bash "$project_toplevel/bash/setup_bash.sh"
    fi
    if [[ $argument == "--setup-gnome" ]] ; then
        bash "$project_toplevel/gnome/setup_gnome.sh"
    fi
    if [[ $argument == "--setup-vim" ]] ; then
        bash "$project_toplevel/vim/setup_vim.sh"
    fi
    if [[ $argument == "--setup-snap-packages" ]] ; then
        bash "$project_toplevel/snap/setup_snap_packages.sh"
    fi
    if [[ $argument == "--setup-vscode" ]] ; then
        bash "$project_toplevel/vscode/setup_vscode.sh"
    fi
    if [[ $argument == "--setup-packaging-tools" ]] ; then
        bash "$project_toplevel/packaging_tools/setup_packaging_tools.sh"
    fi
done

# Print a summary of the changes.
echo -e "\e[1;32m--------------------[CHANGES]--------------------\e[0m"

paste <(echo "$changed_files_logfile") <(echo "$backup_files_logfile")
paste "$changed_files_logfile" "$backup_files_logfile"

echo -e "\e[1;32m--------------------[/CHANGES]--------------------\e[0m"
