## TODO
1. gnome add shortcut to "open terminal"
1. gnome disable alt tab windows grouping (possibly the default now)
1. gnome show battery percentage and enable hot corner
1. gnome install and enable gpaste and system monitor extensions
1. gnome install paperwm
1. fix failure to update .bashrc when there's a new debian release (changing stable_codename on setup_debian.sh is not enough and rerunning the script will not update .bashrc, the check needs to be smarter)
1. configure msmt (and caff) with d.o and gmail
1. colorful manpages (probably with "most")
1. firefox tab manager (arrow button on the right side that lists all tabs open), might be enabled by other extensions already: browser.tabs.tabmanager.enabled
1. enable sudo for current user
1. consider using stow for all dotfiles (and keep bashscript for commands that need to be run)
1. gnome-boxes with spice-vdagent (for shared copy-pasting)
1. context.vim with configuration described in https://github.com/wellle/context.vim/issues/53#issuecomment-1267599583
1. vscode set python formatter to black
1. ddcutil and gnome extension to change external display's brightness
1. bluetooth experimental mode (so I can see power level of my bluetooth headset)
1. clarify the variables/ folder is prefered over environment variables as its value persists (for future executions)
1. default to only install chroot for unstable
1. move DEBEMAIL and DEBFULLNAME to its own bashrc file.
1. make use of distro-info-data and deprecate usage of variable files for release codenames, this also allow us to make 30_packaging.bashrc not need any changes if we make the bp/bps commands read from distro-info-data.
