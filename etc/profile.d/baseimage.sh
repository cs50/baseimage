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

# Python
export PATH="$HOME"/.local/bin:"$PATH"

# Ruby
export GEM_HOME="$HOME"/.gem
export PATH="$GEM_HOME"/bin:"$PATH"
