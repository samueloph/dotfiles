#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/copy_files_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/create_backup_of_file"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/extension_list_vscode"
# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/package_list_vscode"

setup_vscode(){

    print_header "[VSCODE]"

    apt_install_wrapper "${PACKAGE_LIST_VSCODE[@]}"
    snap_installed_packages=$(snap list)
    if ! echo "$snap_installed_packages" | grep -q "vscode"; then
        print_in_progress "Installing vscode snap"
        sudo snap install code --classic
    else
        print_skip "vscode snap is already installed"
    fi
    setup_vscode_extensions
    setup_vscode_settings
    setup_vscode_keybindings

    print_header "[/VSCODE]"
}

setup_vscode_extensions(){
    # package_lists_vscode* is a list containing all the variable names for the
    # dictionaries describing the extensions (one dictionary for each category).
    # package_dict_vscode* is a dictionary that contains the extension id and their
    # descriptions.

    print_header "[VSCODE EXTENSIONS]"
    # Cache list of installed extensions to be used below.
    vscode_installed_extensions=$(/snap/bin/code --list-extensions)

    # Iterate on array listing every variable name for the dictionary of extensions
    for package_dict_varname in "${EXTENSION_LIST_OF_DICT_VSCODE[@]}"; do
        print_header_2 "${package_dict_varname}"
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
    print_header "[/VSCODE EXTENSIONS]"
}

setup_vscode_settings(){

    print_header "[VSCODE SETTINGS]"

    settings_identifier="samueloph vscode settings"
    settings_version=$(grep "START $settings_identifier" "$supporting_files_folder/settings.json" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")

    # If no settings file exists, just copy ours there.
    if [[ ! -f "$HOME/.config/Code/User/settings.json" ]]; then
        copy_files_wrapper --sudo=false "$supporting_files_folder/settings.json" "$HOME/.config/Code/User/settings.json"
    else
        # If there is a settings file already, check if it has our settings.
        if grep -q "START ${settings_identifier}.*" "$HOME/.config/Code/User/settings.json"
        then
            # Check if the version present is the one set as the latest one ($settings_version).
            if grep -q "START ${settings_identifier} ${settings_version}" "$HOME/.config/Code/User/settings.json"
            then
                print_skip "vscode settings are already set"
            # Not the latest version, remove it and append the new one to the end of the file.
            else
                print_in_progress "updating vscode settings"
                create_backup_of_file "$HOME/.config/Code/User/settings.json"
                # -i: in-place editing of file.
                # -0: slurp mode, work on entire file at once (instead of line-by-line),
                #     this allows multi-line search-and-replace.
                # -pe: enables search and replace from command line.
                #
                # The "/s" modifier at the end of the regex changes the behavior of the
                # dot "." metacharacter to match newlines "\n" as well.
                # Note the lack of the "/g" modifier, as we only expect a single match
                # in the whole settings file.
                perl -i -0pe "s/\s*\/\/ START ${settings_identifier}.*END ${settings_identifier}//s" \
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
            create_backup_of_file "$HOME/.config/Code/User/settings.json"
            # Remove last "}" from settings so we can append our file to it.
            sed -i 's/}[^}]*$//' "$HOME/.config/Code/User/settings.json"
            # Tail to remove the first line of the settings we are going to
            # ship (to remove the "{").
            tail -n +2 "$supporting_files_folder/settings.json" >> "$HOME/.config/Code/User/settings.json"
        fi
    fi

    print_header "[/VSCODE SETTINGS]"
}

setup_vscode_keybindings(){

    print_header "[VSCODE KEYBINDINGS]"

    keybindings_identifier="samueloph vscode keybindings"
    keybindings_version=$(grep "START $keybindings_identifier" "$supporting_files_folder/keybindings.json" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}")

    # If no keybindings file exists, just copy ours there.
    if [[ ! -f "$HOME/.config/Code/User/keybindings.json" ]]; then
        copy_files_wrapper --sudo=false "$supporting_files_folder/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
    else
        # If there is a keybindings file already, check if it has our keybindings.
        if grep -q "START ${keybindings_identifier}.*" "$HOME/.config/Code/User/keybindings.json"
        then
            # Check if the version present is the one set as the latest one ($keybindings_version).
            if grep -q "START ${keybindings_identifier} ${keybindings_version}" "$HOME/.config/Code/User/keybindings.json"
            then
                print_skip "vscode keybindings are already set"
            # Not the latest version, remove it and append the new one to the end of the file.
            else
                print_in_progress "updating vscode keybindings"
                create_backup_of_file "$HOME/.config/Code/User/keybindings.json"
                # -i: in-place editing of file.
                # -0: slurp mode, work on entire file at once (instead of line-by-line),
                #     this allows multi-line search-and-replace.
                # -pe: enables search and replace from command line.
                #
                # The "/s" modifier at the end of the regex changes the behavior of the
                # dot "." metacharacter to match newlines "\n" as well.
                # Note the lack of the "/g" modifier, as we only expect a single match
                # in the whole keybindings file.
                perl -i -0pe "s/\s*\/\/ START ${keybindings_identifier}.*END ${keybindings_identifier}//s" \
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
            create_backup_of_file "$HOME/.config/Code/User/keybindings.json"
            # Remove last "]" from keybindings so we can append our file to it.
            sed -i 's/][^]]*$//' "$HOME/.config/Code/User/keybindings.json"
            # Tail to remove the first line of the keybindings we are going to
            # ship (to remove the "[").
            tail -n +2 "$supporting_files_folder/keybindings.json" >> "$HOME/.config/Code/User/keybindings.json"
        fi
    fi

    print_header "[/VSCODE KEYBINDINGS]"
}

setup_vscode
