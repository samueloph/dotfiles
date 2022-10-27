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
source "$project_toplevel/util/create_backup_of_file"

# shellcheck source=/dev/null
source "$supporting_files_folder/extension_list_vscode"
# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_vscode"

setup_vscode(){
    echo -e "\e[1;32m--------------------[VSCODE]--------------------\e[0m"

    apt_install_wrapper "${PACKAGE_LIST_VSCODE[@]}"
    snap_installed_packages=$(snap list)
    if ! echo "$snap_installed_packages" | grep -q "vscode"; then
        echo "►► Installing vscode snap"
        sudo snap install code --classic
    else
        echo "✔ vscode snap is already installed"
    fi
    setup_vscode_extensions
    setup_vscode_settings
    setup_vscode_keybindings

    echo -e "\e[1;32m--------------------[/VSCODE]-------------------\e[0m"
}

setup_vscode_extensions(){
    # package_lists_vscode* is a list containing all the variable names for the
    # dictionaries describing the extensions (one dictionary for each category).
    # package_dict_vscode* is a dictionary that contains the extension id and their
    # descriptions.

    echo -e "\e[1;32m--------------------[VSCODE EXTENSIONS]--------------------\e[0m"
    # Cache list of installed extensions to be used below.
    vscode_installed_extensions=$(/snap/bin/code --list-extensions)

    # Iterate on array listing every variable name for the dictionary of extensions
    for package_dict_varname in "${EXTENSION_LIST_OF_DICT_VSCODE[@]}"; do
        echo -e "\e[1;32m----------------------------------------${package_dict_varname}----------------------------------------\e[0m"
        # Get the variable named by the list by reference.
        declare -n package_dict="$package_dict_varname"
        # Iterate on every key-value pair of the dictionary.
        for package_id in "${!package_dict[@]}"; do
            if ! grep -qi "$package_id" <<< "$vscode_installed_extensions"
            then
                # We need to suppress node deprecation notices due to:
                # https://github.com/microsoft/vscode/issues/82524
                NODE_OPTIONS="--no-deprecation" /snap/bin/code --install-extension "$package_id"
            fi
        done
    done
    echo -e "\e[1;32m--------------------[/VSCODE EXTENSIONS]--------------------\e[0m"
}

setup_vscode_settings(){
    echo -e "\e[1;32m--------------------[VSCODE SETTINGS]--------------------\e[0m"

    # Anytime the settings are updated, the version needs to be updated both here
    # and in the settings files.
    settings_version="2022-10-27"
    settings_header="samueloph vscode settings"

    # If no settings file exists, just copy ours there.
    if [[ ! -f "$HOME/.config/Code/User/settings.json" ]]; then
        copy_files_wrapper --sudo=false "$supporting_files_folder/settings.json" "$HOME/.config/Code/User/settings.json"
    else
        # If there is a settings file already, check if it has our settings.
        if grep -q "START ${settings_header}.*" "$HOME/.config/Code/User/settings.json"
        then
            # Check if the version present is the one set as the latest one ($settings_version).
            if grep -q "START ${settings_header} ${settings_version}" "$HOME/.config/Code/User/settings.json"
            then
                echo "✔ vscode settings are already set"
            # Not the latest version, remove it and append the new one to the end of the file.
            else
                echo "►► updating vscode settings"
                create_backup_of_file --sudo=false "$HOME/.config/Code/User/settings.json"
                # -i: in-place editing of file.
                # -0: slurp mode, work on entire file at once (instead of line-by-line),
                #     this allows multi-line search-and-replace.
                # -pe: enables search and replace from command line.
                #
                # The "/s" modifier at the end of the regex changes the behavior of the
                # dot "." metacharacter to match newlines "\n" as well.
                # Note the lack of the "/g" modifier, as we only expect a single match
                # in the whole settings file.
                perl -i -0pe "s/\s*\/\/ START ${settings_header}.*END ${settings_header}.*//s" \
                    "$HOME/.config/Code/User/settings.json"
                # Remove last "}" from settings so we can append our file to it.
                sed -i 's/}[^}]*$//' "$HOME/.config/Code/User/settings.json"
                # Tail to remove the first line of the settings we are going to
                # ship (to remove the "{").
                tail -n +2 "$supporting_files_folder/settings.json" >> "$HOME/.config/Code/User/settings.json"
            fi
        # If the settings file exists but doesn't have any version of the settings
        # shipped by this script.
        else
            create_backup_of_file --sudo=false "$HOME/.config/Code/User/settings.json"
            # Remove last "}" from settings so we can append our file to it.
            sed -i 's/}[^}]*$//' "$HOME/.config/Code/User/settings.json"
            # Tail to remove the first line of the settings we are going to
            # ship (to remove the "{").
            tail -n +2 "$supporting_files_folder/settings.json" >> "$HOME/.config/Code/User/settings.json"
        fi
    fi

    echo -e "\e[1;32m--------------------[/VSCODE SETTINGS]-------------------\e[0m"
}

setup_vscode_keybindings(){

    echo -e "\e[1;32m--------------------[VSCODE KEYBINDINGS]--------------------\e[0m"

    # Anytime the keybindings are updated, the version needs to be updated both here
    # and in the keybindings files.
    keybindings_version="2022-10-08"
    keybindings_header="samueloph vscode keybindings"

    # If no keybindings file exists, just copy ours there.
    if [[ ! -f "$HOME/.config/Code/User/keybindings.json" ]]; then
        copy_files_wrapper --sudo=false "$supporting_files_folder/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
    else
        # If there is a keybindings file already, check if it has our keybindings.
        if grep -q "START ${keybindings_header}.*" "$HOME/.config/Code/User/keybindings.json"
        then
            # Check if the version present is the one set as the latest one ($keybindings_version).
            if grep -q "START ${keybindings_header} ${keybindings_version}" "$HOME/.config/Code/User/keybindings.json"
            then
                echo "✔ vscode keybindings are already set"
            # Not the latest version, remove it and append the new one to the end of the file.
            else
                echo "►► updating vscode keybindings"
                create_backup_of_file --sudo=false "$HOME/.config/Code/User/keybindings.json"
                # -i: in-place editing of file.
                # -0: slurp mode, work on entire file at once (instead of line-by-line),
                #     this allows multi-line search-and-replace.
                # -pe: enables search and replace from command line.
                #
                # The "/s" modifier at the end of the regex changes the behavior of the
                # dot "." metacharacter to match newlines "\n" as well.
                # Note the lack of the "/g" modifier, as we only expect a single match
                # in the whole keybindings file.
                perl -i -0pe "s/\s*\/\/ START ${keybindings_header}.*END ${keybindings_header}.*//s" \
                    "$HOME/.config/Code/User/keybindings.json"
                # Remove last "]" from keybindings so we can append our file to it.
                sed -i 's/][^]]*$//' "$HOME/.config/Code/User/keybindings.json"
                # Tail to remove the first line of the keybindings we are going to
                # ship (to remove the "[").
                tail -n +2 "$supporting_files_folder/keybindings.json" >> "$HOME/.config/Code/User/keybindings.json"
            fi
        # If the keybindings file exists but doesn't have any version of the keybindings
        # shipped by this script.
        else
            create_backup_of_file --sudo=false "$HOME/.config/Code/User/keybindings.json"
            # Remove last "]" from keybindings so we can append our file to it.
            sed -i 's/][^]]*$//' "$HOME/.config/Code/User/keybindings.json"
            # Tail to remove the first line of the keybindings we are going to
            # ship (to remove the "[").
            tail -n +2 "$supporting_files_folder/keybindings.json" >> "$HOME/.config/Code/User/keybindings.json"
        fi
    fi

    echo -e "\e[1;32m--------------------[/VSCODE KEYBINDINGS]-------------------\e[0m"
}

setup_vscode
