#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$supporting_files_folder/extension_list_vscode"


pretty_print_vscode_extensions(){
    # Print all the extensions in a nice markdown table.

    # EXTENSION_LIST_OF_DICT_VSCODE is a list containing all the variable names for the
    # dictionaries describing the extensions (one dictionary for each category).
    # extension_id is a dictionary that contains the extension id and their
    # descriptions.
    #
    # Iterate on array listing every variable name for the dictionary of extensions
    for extension_dict_varname in "${EXTENSION_LIST_OF_DICT_VSCODE[@]}"; do

        # Get the variable named by the list by reference.
        declare -n extension_dict="$extension_dict_varname"

        # Remove cruft from variable name to get a nice category name.
        extension_category="${extension_dict_varname:22}"

        # Capitalize the first letter of the category.
        echo "## ${extension_category^}"

        # Markdown table header.
        echo "|Package ID|Description|URL|"
        echo "|---|---|---|"
        # Iterate on every key-value pair of the dictionary (ie. every extension).
        for extension_id in "${!extension_dict[@]}"; do
            echo "|$extension_id|${extension_dict[$extension_id]}|https://marketplace.visualstudio.com/items?itemName=$extension_id|"
        done
        # Empty line at the end for some space between tables.
        echo ""
    done
}

pretty_print_vscode_extensions
