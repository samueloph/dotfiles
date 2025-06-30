#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/package_list_sbuild_debian"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

backup_files_logfile="$project_toplevel/logs/backup_files_logfile"
changed_files_logfile="$project_toplevel/logs/changed_files_logfile"

setup_sbuild_debian(){
    # Install and configure sbuild with the unshare backend, using apt-cacher-ng.

    print_header "[SETUP-SBUILD]"

    apt_install_wrapper "${PACKAGE_LIST_SBUILD_DEBIAN[@]}"

    # Fill in template config files with personal information.
    if [[ $supporting_files_folder/config.pl -nt $HOME/.config/sbuild/config.pl ]]
    then
        # shellcheck disable=SC1094,SC1091
        source "$project_toplevel/util/variables/gpg_key_id" &>/dev/null \
        || read -rp "GPG key ID (for sbuild config.pl): " GPG_KEY_ID \
        && echo "GPG_KEY_ID=\"$GPG_KEY_ID\"" > "$project_toplevel/util/variables/gpg_key_id"

        if [[ ! "$GPG_KEY_ID" ]]; then
            sed -e "/\${GPG_KEY-PLACEHOLDER}/s/^# *//" \
                -e "s/\${GPG_KEY-PLACEHOLDER}/${GPG_KEY_ID}/g" \
                -i "$supporting_files_folder/config.pl"
        fi

        mkdir -p "$HOME/.config/sbuild"
        copy_files_wrapper --sudo=false "$supporting_files_folder/config.pl" "$HOME/.config/sbuild/config.pl"
    else
        print_skip "Skipping $supporting_files_folder/config.pl copying because you already have a file in the destination and it's newer than the one from this script."
    fi

    print_header "[/SETUP-SBUILD]"
}

setup_sbuild_debian
