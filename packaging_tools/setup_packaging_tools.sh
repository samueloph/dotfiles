#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/variables/stable_codename"
# shellcheck source=/dev/null
source "$project_toplevel/util/variables/oldstable_codename"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_packaging_tools"

setup_packaging_tools(){

    echo -e "\e[1;32m--------------------[PACKAGING TOOLS]--------------------\e[0m"

    # install and configure a bunch of tools needed for packaging work

    apt_install_wrapper "${PACKAGE_LIST_PACKAGING_TOOLS[@]}"

    "$project_toplevel/sbuild_debian/setup_sbuild_debian.sh" unstable "$STABLE_CODENAME" "$OLDSTABLE_CODENAME"

    # fill in template config files with personal information
    if [[ $supporting_files_folder/.sbuildrc-template -nt $supporting_files_folder/.sbuildrc ]]
    then

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/gpg_key_id" &>/dev/null ||
        read -rp "GPG key ID: " GPG_KEY_ID &&
        echo "GPG_KEY_ID=\"$GPG_KEY_ID\"" > "$project_toplevel/util/variables/gpg_key_id"

        sed "s/\${KEY-PLACEHOLDER}/${GPG_KEY_ID}/g" \
            "$supporting_files_folder/.sbuildrc-template" > "$supporting_files_folder/.sbuildrc"
    else
        echo "Skipping $supporting_files_folder/.sbuildrc generation because the file is newer than its template, remove it for regeneration"
    fi

    if [[ $supporting_files_folder/.devscripts-template -nt $supporting_files_folder/.devscripts ]]
    then

        # shellcheck source=/dev/null
        source "$project_toplevel/util/variables/salsa_token" &>/dev/null ||
        read -rp "Salsa token: " SALSA_TOKEN &&
        echo "SALSA_TOKEN=\"$SALSA_TOKEN\"" > "$project_toplevel/util/variables/salsa_token"

        sed "s/\${SALSA_TOKEN-PLACEHOLDER}/${SALSA_TOKEN}/g" \
            "$supporting_files_folder/.devscripts-template" > "$supporting_files_folder/.devscripts"
    else
        echo "Skipping $supporting_files_folder/.devscripts generation because the file is newer than its template, remove it for regeneration"
    fi

    copy_files_wrapper --sudo=false "$supporting_files_folder/.sbuildrc" "$HOME/.sbuildrc"
    copy_files_wrapper --sudo=false "$supporting_files_folder/.gbp.conf" "$HOME/.gbp.conf"
    copy_files_wrapper --sudo=false "$supporting_files_folder/.devscripts" "$HOME/.devscripts"

    echo -e "\e[1;32m--------------------[/PACKAGING-TOOLS]-------------------\e[0m"
}

setup_packaging_tools
