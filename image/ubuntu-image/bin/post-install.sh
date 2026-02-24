#!/usr/bin/env bash

# Configure pipx bin directory
echo 'PIPX_BIN_DIR="/usr/local/bin"' >> /etc/environment

# Run any added custom scripts
CUSTOM_SCRIPTS_DIR="/usr/share/os2borgerpc/custom_scripts"
if [ -d "$CUSTOM_SCRIPTS_DIR" ]; then
  CUSTOM_SCRIPTS=$(find $CUSTOM_SCRIPTS_DIR -maxdepth 1 -regex ".*\.sh\|.*\.py")
  for FILE in $CUSTOM_SCRIPTS; do
    sed --in-place "s/\r//" "$FILE"
    "$FILE"
  done
  rm --recursive $CUSTOM_SCRIPTS_DIR
fi

# Remove post-install script
#rm --force "$0"
