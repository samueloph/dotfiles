# Samuel Henrique \<samueloph\> dotfiles and scripts for setup

## About
I've decided to create this to speedup configuration of newly installed systems but also to be able to point other people to the way I configure it in case they find it useful.

At the same time this has been a very good exercise in writting bash code and gave me a good understanding of its limits.

As of 2022-10-23, I have spent an estimated amount of 100 hours working on this.

## Setup
In order to setup everything, you can call `setup_debian.sh` with the `--setup-all` option, you can get a list of available options with `setup_debian.sh -h`. This script will generate logs and backup files for changes made.

Individual `setup_*.sh` scripts can also be called, eg.: `vim/setup_vim.sh` for vim setup only.

The `sbuild_debian/setup_sbuild_debian.sh` script might be especially useful for people who just want to setup a chroot environment to be used with sbuild. You just need to call it with a release codename, like `sbuild_debian/setup_sbuild_debian.sh unstable` and it will setup a chroot with eatmydata, ccache, apt-cacher-nd, aliases and auto updates done by a cronjob.

The script `sbuild_debian/setup_sbuild_debian.sh` can be used to install and configure chroots to be used by sbuild.

A list of vscode extensions I use is available at [vscode/vscode_extensions.md](vscode/vscode_extensions.md).

Settings are at [vscode/supporting_files/settings.json](vscode/supporting_files/settings.json).

Keybindings at [vscode/supporting_files/keybindings.json](vscode/supporting_files/keybindings.json).

## Setup scripts
### setup_debian.sh
Run all other setup scripts and can be controlled with arguments (to chose only certain scripts).
### misc/setup_misc.sh
Run all the scripts under the `misc/` folder (described below).
#### misc/setup_apt_repos.sh
Setup unstable and experimental repos, with pinning so they don't get used by default (except with firefox, which is pulled from unstable.)
#### misc/setup_misc_packages.sh
Install miscellaneous packages from the official repository, the list of packages installed is on [misc/supporting_files/package_list_misc_packages](misc/supporting_files/package_list_misc_packages).
#### misc/setup_firefox.sh
Install firefox and remove firefox-esr (requires unstable repo set on `misc/setup_apt_repos.sh`).
#### misc/setup_git.sh
Setup .gitconfig (mainly name and email address).
#### misc/setup_battery_tools.sh
Install tools related to battery usage (usefull for laptops), the list of packages installed is on [misc/supporting_files/package_list_battery_tools](misc/supporting_files/package_list_battery_tools).
#### misc/setup_fstrim.sh
Enable fstrim (for systems with SSD drives).
#### misc/setup_tmpfs.sh
Mount `/tmp` in memory (useful for systems with at last 16GiB of RAM).
### bash/setup_bash.sh
Enable usage of `~/.bashrc.d/` folder and add scripts there, also install a `~/.inputrc` dotfile with autocompletion improvements. Part of the setup will install and enable powerline with gitstatus.
### gnome/setup_gnome.sh
Configure Gnome with dark theme, Hack font, animations disabled...
### vim/setup_vim.sh
Install vim-plug, extensions and add my own [vim/supporting_files/.vimrc](vim/supporting_files/.vimrc).
### snap/setup_snap_packages.sh
Install snapd and all the packages I use, packages are listed in the script itself at [snap_packages/setup_snap_packages.sh](snap_packages/setup_snap_packages.sh).
### vscode/setup_vscode.sh
Install vscode with my list of extensions and my own settings and keybindings.

Extensions I use can be seen at [vscode/vscode_extensions.md](vscode/vscode_extensions.md).

Settings are at [vscode/supporting_files/settings.json](vscode/supporting_files/settings.json).

Keybindings at [vscode/supporting_files/keybindings.json](vscode/supporting_files/keybindings.json).
### packaging_tools/setup_packaging_tools.sh
Setup sbuild with chroots for unstable, stable and oldstable. It install packages and dotfiles, and will mount chroots on memory if the system has at least 16GiB of RAM.
### sbuild_debian/setup_sbuild_debian.sh
Install a chroot to be used by sbuild. It will set the chroot to be used with apt-cacher-ng, eatmydata and ccache. It will also mount the chroots on memory if the system has at least 16 GiB of RAM. Chroot auto updates are enabled with a cronjob.

This script is usually called by `setup_packaging_tools.sh` but it can be used it directly too.

It expects the release codenames as arguments (eg.: `sbuild_debian/setup_sbuild_debian.sh unstable` for unstable installation or `sbuild_debian/setup_sbuild_debian.sh unstable trixie`... for more than a single chroot).
