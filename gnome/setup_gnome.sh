#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck source=/dev/null
source "$project_toplevel/util/create_backup_of_file"
# shellcheck source=/dev/null
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck source=/dev/null
source "$project_toplevel/util/print_utils"

# shellcheck source=/dev/null
source "$supporting_files_folder/package_list_gnome"


setup_gnome(){
    print_header "[GNOME]"

    # tweak some gnome settings using gsettings
    apt_install_wrapper "${PACKAGE_LIST_GNOME[@]}"

    # Dark theme
    if [[ $(gsettings get org.gnome.desktop.interface gtk-theme) != "'Adwaita-dark'" ]]
    then
        echo "►► Setting Gnome theme to Adwaita-dark"
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    else
        echo "✔ Gnome theme is already Adwaita-dark"
    fi

    # Dark theme (color scheme)
    if [[ $(gsettings get org.gnome.desktop.interface color-scheme) != "'prefer-dark'" ]]
    then
        echo "►► Setting Gnome to dark mode"
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    else
        echo "✔ Gnome is already set to dark mode"
    fi

    # Night light (dim screen at night)
    if [[ $(gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled) != "true" ]]
    then
        echo "►► Enabling Night Light on Gnome"
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    else
        echo "✔ Night Light is already enabled on Gnome"
    fi

    # Disable animations
    if [[ $(gsettings get org.gnome.desktop.interface enable-animations) == "true" ]]
    then
        echo "►► Setting Gnome animations to false"
        gsettings set org.gnome.desktop.interface enable-animations false
    else
        echo "✔ Gnome animations is already set to false"
    fi

    # Use "Hack" font
    if [[ $(gsettings get org.gnome.desktop.interface monospace-font-name) != "'Hack 11'" ]]
    then
        echo "►► Setting Gnome monospace font to Hack 11"
        gsettings set org.gnome.desktop.interface monospace-font-name "Hack 11"
    else
        echo "✔ Gnome monospace font is already Hack 11"
    fi

    # Focus on mouse hover
    if [[ $(gsettings get org.gnome.desktop.wm.preferences focus-mode) != "'sloppy'" ]]
    then
        echo "►► Setting Gnome to focus on mouse hover"
        gsettings set org.gnome.desktop.wm.preferences focus-mode "sloppy"
    else
        echo "✔ Gnome is already set to focus on mouse hover"
    fi

    # Add keyboard layouts for both "English (US)" and "English (US alt. intl.)" (for the Brazilian ortography).
    if [[ $(gsettings get org.gnome.desktop.input-sources sources) != "[('xkb', 'us'), ('xkb', 'us+alt-intl')]" ]]
    then
        echo "►► Configuring keyboard layouts on Gnome"
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'us+alt-intl')]"
    else
        echo "✔ Keyboard layouts are already configured on Gnome"
    fi

    # Disable "initial setup" startup window.
    if ! grep -q "yes" ~/.config/gnome-initial-setup-done 2>/dev/null; then
        echo "►► Disabling \"initial setup\" startup window on Gnome"
        if [[ -f "$HOME/.config/gnome-initial-setup-done" ]]; then
            create_backup_of_file --sudo=false "$HOME/.config/gnome-initial-setup-done"
        fi
        echo "yes" > ~/.config/gnome-initial-setup-done
    else
        echo "✔ \"initial setup\" startup window is already disabled on Gnome"
    fi

    print_header "[/GNOME]"
}

setup_gnome
