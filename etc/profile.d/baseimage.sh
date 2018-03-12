# File mode creation mask
if [ "$(id -u)" != "0" ]; then
    umask 0077
fi
