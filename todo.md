## TODO
1. gnome disable alt tab windows grouping (possibly the default now)
1. gnome show battery percentage and enable hot corner
1. gnome install paperwm
1. configure msmt (and caff) with d.o and gmail
1. colorful manpages (probably with "most")
1. firefox tab manager (arrow button on the right side that lists all tabs open), might be enabled by other extensions already: browser.tabs.tabmanager.enabled
1. enable sudo for current user
1. consider using stow for all dotfiles (and keep bashscript for commands that need to be run)
1. context.vim with configuration described in https://github.com/wellle/context.vim/issues/53#issuecomment-1267599583
1. ddcutil and gnome extension to change external display's brightness
1. bluetooth experimental mode (so I can see power level of my bluetooth headset)
https://www.reddit.com/r/Fedora/comments/shc2kh/get_bluetooth_device_battery_level_in_power/
1. clarify the variables/ folder is prefered over environment variables as its value persists (for future executions)
1. alias vim d/ = vim debian/
1. play sound when terminal command finishes running
https://gitlab.com/EvanHahn/dotfiles/-/blob/ece393e625bb8254fe05774df33bb5af8a73d7e7/home/zsh/.config/zsh/aliases.zsh#L48-56
1. firefox set the right profile for snap applications (otherwise it always opens up in a new window)
https://github.com/microsoft/vscode/issues/96829#issuecomment-695391809
1. json crack - Seamlessly visualize your JSON data instantly into graphs.
Need to check if this leaks the json to a server or it runs locally
https://marketplace.visualstudio.com/items?itemName=AykutSarac.jsoncrack-vscode
1. vim-plug auto update
https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
https://github.com/junegunn/vim-plug/wiki/faq#shouldnt-vim-plug-update-itself-on-plugupdate-like-vundle
1. log headers with aligned text on setup scripts
https://unix.stackexchange.com/questions/267729/how-can-i-print-a-variable-with-padded-center-alignment
1. vscode enable middle click pase
https://github.com/Microsoft/vscode/issues/110
https://stackoverflow.com/questions/36723333/how-to-enable-middle-mouse-button-click-paste-in-vs-code
1. gnome alt tab only on current screen/workspace
https://linuxiac.com/alt-tab-to-switch-only-on-current-workspace-in-gnome-shell/ (this doesnt work)
1. vim debugging extension
https://github.com/puremourning/vimspector
1. gnome-clock configure clocks for other countries

1. sway

1. gnome shortcut for each workspace - https://www.reddit.com/r/gnome/comments/j6lr73/comment/g84nhqr/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
1. make sure copying from nvim and tmux works both in local and remote mode
1. harpoon remapt ctrl+; to ctrl+h, the former is not supported by terminal emulators
1. make sure python and rust tests are discoverable
1. neovim as pager - https://vi.stackexchange.com/questions/16582/how-to-use-neovim-as-a-pager
1. inputrc alt . for last parameter on vim mode
1. nvim session manager - https://github.com/rmagatti/auto-session - https://github.com/folke/persistence.nvim
1. nvim spellcheck
1. tmux smart window names - https://github.com/ofirgall/tmux-window-name
1. neovim emacs mapings on insert mode for ctrl w, ctrl a and ctrl e, also for readline on vi mode
1. readline vi mode alt . - https://superuser.com/questions/18498/last-parameter-of-last-command-in-bash-in-vi-mode/559246#559246
1. readline vi mode extended commands - https://www.reddit.com/r/vim/comments/u0nihr/comment/i47rzqd/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
1. sudo vim - https://github.com/vim-scripts/sudo.vim/tree/master
1. LSCOLORS theme - https://github.com/sharkdp/vivid
1. alacritty LSCOLORS - https://github.com/alacritty/alacritty/issues/4710

1. gnome 46 (Ubuntu 24.04) requires a manual change for the tilling to work - https://askubuntu.com/a/1494637 
> Please, run the Extensions (gnome-extensions-app) application and disable Ubuntu Tiling Assistant (under the Built-In section).
> 
> Instead of disabling this extension, you can just go to the Settings of this extension and disable Open after tiling a window (under Tiling Popup section).
> 
> If this does not help, please follow my comment above: Go to Gnome Settings → Keyboard → Keyboard Shortcuts → Windows and remove any non-default customizations.

1. gnome nightlight: lower intesity and only trigger at 1AM
