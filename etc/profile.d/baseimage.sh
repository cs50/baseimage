# If not root
if [ "$(id -u)" != "0" ]; then

    # Clang
    export CC="clang"
    export CFLAGS="-fsanitize=signed-integer-overflow -fsanitize=undefined -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wshadow"
    export LDLIBS="-lcrypt -lcs50 -lm"

    # File mode creation mask
    umask 0077
fi

# Aliases
alias pip="pip3 --no-cache-dir"
alias pip3="pip3 --no-cache-dir"
alias pylint="pylint3"
alias python="python3"
alias swift="swift 2> /dev/null"  # https://github.com/cs50/baseimage/issues/49

# Flask
export FLASK_APP="application.py"
export FLASK_DEBUG="0"
export FLASK_ENV="development"

# Python
export PATH="$HOME"/.local/bin:"$PATH"

# Ruby
export GEM_HOME="$HOME"/.gem
export PATH="$GEM_HOME"/bin:"$PATH"
