# File mode creation mask
if [ "$(id -u)" != "0" ]; then
    umask 0077
fi

# Aliases
alias cp="cp -i"
alias ll="ls -l --color=auto"
alias mv="mv -i"
alias pip="pip3 --no-cache-dir"
alias pip3="pip3 --no-cache-dir"
alias python="python3"
alias rm="rm -i"
alias sudo="sudo "
