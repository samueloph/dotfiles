#!/bin/bash

set -euo pipefail

# Path of this file, to be used to evaluate path of other files in the project.
script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
project_toplevel="$script_path/.."
supporting_files_folder="$script_path/supporting_files"

# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/create_backup_of_file"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/apt_install_wrapper"
# shellcheck disable=SC1094,SC1091
source "$project_toplevel/util/print_utils"

# shellcheck disable=SC1094,SC1091
source "$supporting_files_folder/package_list_gnome"


setup_gnome(){
    print_header "[GNOME]"

    # tweak some gnome settings using gsettings
    apt_install_wrapper "${PACKAGE_LIST_GNOME[@]}"

    # Dark theme
    if [[ $(gsettings get org.gnome.desktop.interface gtk-theme) != "'Adwaita-dark'" ]]
    then
        print_in_progress "Setting Gnome theme to Adwaita-dark"
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    else
        print_skip "Gnome theme is already Adwaita-dark"
    fi

    # Dark theme (color scheme)
    if [[ $(gsettings get org.gnome.desktop.interface color-scheme) != "'prefer-dark'" ]]
    then
        print_in_progress "Setting Gnome to dark mode"
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    else
        print_skip "Gnome is already set to dark mode"
    fi

    # Night light (dim screen at night)
    # if [[ $(gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled) != "true" ]]
    # then
    #     print_in_progress "Enabling Night Light on Gnome"
    #     gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    # else
    #     print_skip "Night Light is already enabled on Gnome"
    # fi

    # Disable animations
    if [[ $(gsettings get org.gnome.desktop.interface enable-animations) == "true" ]]
    then
        print_in_progress "Setting Gnome animations to false"
        gsettings set org.gnome.desktop.interface enable-animations false
    else
        print_skip "Gnome animations is already set to false"
    fi

    # Use "Hack Nerd Font Mono" font
    if [[ $(gsettings get org.gnome.desktop.interface monospace-font-name) != "'Hack Nerd Font Mono 11'" ]]
    then
        print_in_progress "Setting Gnome monospace font to Hack Nerd Font Mono 11"
        gsettings set org.gnome.desktop.interface monospace-font-name "Hack Nerd Font Mono 11"
    else
        print_skip "Gnome monospace font is already Hack Nerd Font Mono 11"
    fi

    # Add keyboard layouts for both "English (US)" and "English (US alt. intl.)" (for the Brazilian ortography).
    if [[ $(gsettings get org.gnome.desktop.input-sources sources) != "[('xkb', 'us'), ('xkb', 'us+alt-intl')]" ]]
    then
        print_in_progress "Configuring keyboard layouts on Gnome"
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'us+alt-intl')]"
    else
        print_skip "Keyboard layouts are already configured on Gnome"
    fi

    # Set Capslock to act as a control key.
    if [[ $(gsettings get org.gnome.desktop.input-sources xkb-options) != "['caps:ctrl_modifier']" ]]
    then
        print_in_progress "Capslock key changed to act as Ctrl"
        gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"
    else
        print_skip "Capslock key already changed to act as Ctrl"
    fi

    # Set shortcuts to switch to workspace and move windows to workspaces, like if it was i3.
    # Partial Ubuntu support: first check if we are running the dash-to-dock extension
    # and disable its hot-keys.
    if gsettings get org.gnome.shell.extensions.dash-to-dock hot-keys
    then
        print_in_progress "Disable hot-keys from dash-to-dock in order to unblock worskpace switching hot-keys"
        gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
    else
        print_skip "Dash-to-dock is not installed, no need to remove its hot-keys shortcuts"
    fi

    # Remove default switch to application shortcuts as they use Meta+number and we want to override.
    for number in {1..9}; do gsettings set org.gnome.shell.keybindings switch-to-application-"${number}" '[]'; done

    # We never check if the shortcut is already there, always set it up. TODO: Only set if not enabled.
    print_in_progress "Setting shortcuts for worskpace switching and moving windows to worskpaces: Meta + number, Meta + Shift + number"
    for number in {1..9}; do gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-"${number}" "['<Super>$number']";done
    for number in {1..9}; do gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-"${number}" "['<Super><Shift>$number']";done

    # Disable "initial setup" startup window.
    if ! grep -q "yes" ~/.config/gnome-initial-setup-done 2>/dev/null; then
        print_in_progress "Disabling \"initial setup\" startup window on Gnome"
        if [[ -f "$HOME/.config/gnome-initial-setup-done" ]]; then
            create_backup_of_file "$HOME/.config/gnome-initial-setup-done"
        fi
        echo "yes" > ~/.config/gnome-initial-setup-done
    else
        print_skip "\"initial setup\" startup window is already disabled on Gnome"
    fi

    print_header "[/GNOME]"
}

setup_gnome
