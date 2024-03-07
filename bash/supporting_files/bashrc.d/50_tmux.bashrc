#!/bin/bash

function __trap_exit_tmux {
	tmux list-windows || exit
	tmux list-panes || exit
	tmux switch-client -t default
}

if [[ $- == *i* ]]; then
	trap __trap_exit_tmux EXIT
fi

# forget the find window.  That is for chumps
bind-key -r f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"

if [[ "${SHELLOPTS}" =~ :(emacs|vi): ]]; then
    # CTRL-f - Run tmux-sessionizer over my project folders.
    bind -m emacs-standard -x '"\C-f": tmux-sessionizer'
    bind -m vi-command -x '"\C-f": tmux-sessionizer'
    bind -m vi-insert -x '"\C-f": tmux-sessionizer'
fi
