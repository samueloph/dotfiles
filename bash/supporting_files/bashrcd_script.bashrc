# shellcheck shell=bash
### START samueloph dotfiles bashrcd 2022-11-01 \/

# Anything that's inside this block might be overwritten by
# samueloph's dotfiles script.

# Import all .bashrc files (sorted) under "~/.bashrc.d/"
# shellcheck disable=SC2012,SC1090
for bashrc_script in $(find "$HOME"/.bashrc.d/*.bashrc -type f | sort -V); do
    source "$bashrc_script"
done

### END samueloph dotfiles bashrcd
