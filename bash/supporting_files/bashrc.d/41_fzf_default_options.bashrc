#!/bin/bash

# https://github.com/junegunn/fzf/issues/3608#issuecomment-1923652967
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"\
" --cycle --layout=reverse --keep-right"

# Use fzf for Ctrl+r
source /usr/share/doc/fzf/examples/key-bindings.bash
