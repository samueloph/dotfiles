# samueloph Debian testing setup

## TL;DR: Run `setup_debian.sh` for system setup

## setup_debian.sh

1. Personal information

 You will be asked to provide information needed to generate the dotfiles; Name, Email and GPG key. This information will not be asked if the generated dotfiles (under the same directory as the script) are newer than its templates.

1. Backups

 All the files changed are backed up up in their own folders using the format `ORIGINALNAME.bkp-TIMESTAMP`

1. Logs

 Logs for the changed files and their backups are stored under the logs/ folder, the output of the scrip will contain a summary of the changes.

1. Customization

 The scripts consists of a bunch of functions that are called sequentially, in order to only run some of them, one can comment the unwanted the function calls.

1. Constants

 Functions will mostly use a constants that are made of a list of packages to be installed. The current stable and oldstable releases' codenames are also constants needed to generate the dotfiles.

## Main functions

1. setup_apt

 Configure unstable and experimental repositories with pinning.

1. setup_firefox

 Install firefox from unstable in favor of firefox-esr from testing

1. setup_tools

 Install miscellaneous tools and setup gitconfig.

1. setup_battery

 Install battery tools, for laptops.

1. setup_atom

 Install atom (FROM EXTERNAL REPOSITORY) and atom extensions.

1. setup_i3

 Install i3, its dotfiles and some extras. This will also install i3-gnome (FROM EXTERNAL REPOSITORY).

1. setup_vim

 Install vimplug, extensions and setup vimrc.

1. setup_bash

 Setup bashrc and inputrc.

1. setup_tmpfs

 Setup tmpfs to mount tmp on RAM (for systems with a good amount of RAM).

1. setup_ssd

 Setup trim for SSD systems.

1. setup_packaging_tools

 Install and setup sbuild, with schroots for unstable, stable and oldstable.

1. setup_gnome

 Setup gnome's display options, such as font and dark theme.
