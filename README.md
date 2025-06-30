# Samuel Henrique \<samueloph\> dotfiles and scripts for setup


## About
I've decided to create this to speedup configuration of newly installed systems but also to be able to point other people to the way I configure it in case they find it useful.

At the same time this has been a very good exercise in writting bash code and gave me a good understanding of its limits.

As of 2022-10-23, I have spent an estimated amount of 100 hours working on this.

## Written for Debian Testing
If you try to run this on a Debian Stable system, both `setup_firefox` and `setup_apt_repos` are not going to work properly and will partially upgrade your machine to Debian Testing.

If you want to run it in another release, or even another distro, you can manually invoke the setup commands you need, just make sure you do not call the ones mentioned above.

## Setup
In order to setup everything, you can call `setup_debian.sh` with the `--setup-all` option, you can get a list of available options with `setup_debian.sh -h`. This script will generate logs and backup files for changes made.

This has only been thoroughly tested on Debian testing, some things will break if you run this on Debian stable.

Individual `setup_*.sh` scripts can also be called, eg.: `vim/setup_vim.sh` for vim setup only.

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
### bash/setup_bash.sh
Enable usage of `~/.bashrc.d/` folder and add scripts there, also install a `~/.inputrc` dotfile with autocompletion improvements. Part of the setup will install and enable powerline with gitstatus.
### gnome/setup_gnome.sh
Configure Gnome with dark theme, Hack font, animations disabled...
### vim/setup_vim.sh
Install vim-plug, extensions and add my own [vim/supporting_files/.vimrc](vim/supporting_files/.vimrc).
### snap_packages/setup_snap_packages.sh
Install snapd and all the packages I use, packages are listed in the script itself at [snap_packages/setup_snap_packages.sh](snap_packages/setup_snap_packages.sh).
### vscode/setup_vscode.sh
Note: I've moved to neovim, so this setup is not kept up-to-date.

Install vscode with my list of extensions and my own settings and keybindings.

Extensions I use can be seen at [vscode/vscode_extensions.md](vscode/vscode_extensions.md).

Settings are at [vscode/supporting_files/settings.json](vscode/supporting_files/settings.json).

Keybindings at [vscode/supporting_files/keybindings.json](vscode/supporting_files/keybindings.json).
### packaging_tools/setup_packaging_tools.sh
Install packages and dotfiles used in packaging.
### sbuild_debian/setup_sbuild_debian.sh
Configures sbuild with the unshare backend and apt-cacher-ng.

This script is called by `setup_packaging_tools.sh` but it can be invoked directly too.
