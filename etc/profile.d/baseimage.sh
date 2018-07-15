# File mode creation mask
if [ "$(id -u)" != "0" ]; then
    umask 0077
fi

# Aliases
alias pip="pip3 --no-cache-dir"
alias pip3="pip3 --no-cache-dir"
alias python="python3"

# Flask
export FLASK_APP="application.py"

# PATH
export PYENV_ROOT=/opt/pyenv
export PATH=/opt/cs50/bin:/opt/bin:/usr/local/sbin:/usr/local/bin:"$PYENV_ROOT"/shims:"$PYENV_ROOT"/bin:/usr/sbin:/usr/bin:/sbin:/bin
