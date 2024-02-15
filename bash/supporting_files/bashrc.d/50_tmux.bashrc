#!/bin/bash

function __trap_exit_tmux {
	tmux list-windows || exit
	tmux list-panes || exit
	tmux switch-client -t default
}

if [[ $- == *i* ]]; then
	trap __trap_exit_tmux EXIT
fi

# CTRL-f - Run tmux-sessionizer over my project folders.
bind -m emacs-standard -x '"\C-f": tmux-sessionizer'
bind -m vi-command -x '"\C-f": tmux-sessionizer'
bind -m vi-insert -x '"\C-f": tmux-sessionizer'
