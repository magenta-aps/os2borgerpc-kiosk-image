#!/bin/bash

# Find current directory

DIR=$(dirname ${BASH_SOURCE[0]})

# Step 1: Check for valid APT repositories.
# apt-get update returns exit code 0 even when it fails due to
# missing internet connection, DNS issues or similar so
# we cannot use the exit code to check for failure
if apt-get update | grep --quiet "Err"; then
  printf "\nUpdating repositories failed\n"
  exit 1
fi

# Update and upgrade the system
apt-get -y upgrade | tee /tmp/os2borgerpc_upgrade_log.txt
apt-get -y dist-upgrade | tee /tmp/os2borgerpc_upgrade_log.txt


# Install OS2bogerPC specific dependencies
#
# The DEPENDENCIES file contains packages/programs
# required by OS2borgerPC AND extra packages which are free dependencies
# of Skype and MS Fonts - to shorten the postinstall process.
DEPENDENCIES=( $(cat "$DIR/DEPENDENCIES") )

PKGS_TO_INSTALL=""

dpkg -l | grep "^ii" > /tmp/installed-package-list.txt

for PKG in "${DEPENDENCIES[@]}"
do
    grep -w "ii  $PKG " /tmp/installed-package-list.txt > /dev/null
    if [[ $? -ne 0 ]]; then
        PKGS_TO_INSTALL=$PKGS_TO_INSTALL" "$PKG
    fi
done

if [ "$PKGS_TO_INSTALL" != "" ]; then
    echo  -n "Some dependencies are missing."
    echo " The following packages will be installed: $PKGS_TO_INSTALL"

    # Step 1: Check for valid APT repositories.
    # apt-get update returns exit code 0 even when it fails due to
    # missing internet connection, DNS issues or similar so
    # we cannot use the exit code to check for failure
    if apt-get update | grep --quiet "Err"; then
      printf "\nUpdating repositories failed\n"
      exit 1
    fi

    # Step 2: Do the actual installation. Abort if it fails.
    # shellcheck disable=SC2086 # We want word-splitting here
    if ! apt-get -y install $PKGS_TO_INSTALL; then
      printf "\nPackage installation failed\n"
      exit 1
    fi
fi

# Install os2borgerpc client, exit if it fails
# We fix the version of chardet because newer versions were rewritten using an LLM
pipx install os2borgerpc-client --pip-args "chardet<6.0" || sh -c 'printf "\nClient installation failed\n" && exit 1'

# Clean .deb cache to save space
apt-get --assume-yes autoremove
apt-get --assume-yes clean

# OS2borgerPC Kiosk specifics:

# Set Danish timezone
timedatectl set-timezone Europe/Copenhagen
dpkg-reconfigure --frontend=noninteractive tzdata

# Update the time accordingly
ntpdate pool.ntp.org
