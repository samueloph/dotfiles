# shellcheck shell=bash
# Increase history size
HISTSIZE=5000
HISTFILESIZE=10000

# Add timestamp to bash history
export HISTTIMEFORMAT="%g/%m/%d %H:%M "

# Append to the history file, don't overwrite it
shopt -s histappend

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# shellcheck disable=SC2034
force_color_prompt=yes
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias ll='ls -l'

# Automatically run "ls" after "cd"
[[ $- == *i* ]] && function cd {
    builtin cd "$@" && ls -Ftr1
}

export EDITOR=vim
