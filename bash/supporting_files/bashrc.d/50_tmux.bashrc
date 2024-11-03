#!/bin/bash

# Based-on:
# https://github.com/caarlos0/dotfiles.fish/blob/main/tmux/conf.d/tmux-trap.fish
# https://carlosbecker.com/posts/tmux-sessionizer/
function __trap_exit_tmux {
    if [[ -z "$NVIM_LISTEN_ADDRESS" ]] || \
       [[ -z "$NVIM" ]] || \
       [[ $(tmux list-windows | wc -l) = 1 ]] || \
       [[ $(tmux list-panes | wc -l) = 1 ]]
    then
        exit
    else
	    tmux switch-client -t default
    fi
}

if [[ $- == *i* ]]; then
	trap __trap_exit_tmux EXIT
fi

# Based-on:
# https://github.com/ThePrimeagen/.dotfiles/blob/602019e902634188ab06ea31251c01c1a43d1621/zsh/.zsh_profile#L40
if [[ "${SHELLOPTS}" =~ :(emacs|vi): ]]; then
    # CTRL-f - Run tmux-sessionizer over my project folders.
    bind -m emacs-standard -x '"\C-f": tmux-sessionizer'
    bind -m vi-command -x '"\C-f": tmux-sessionizer'
    bind -m vi-insert -x '"\C-f": tmux-sessionizer'
fi
