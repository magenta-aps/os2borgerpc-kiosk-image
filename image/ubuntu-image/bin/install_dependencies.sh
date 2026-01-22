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
pipx install os2borgerpc-client || sh -c 'printf "\nClient installation failed\n" && exit 1'

# Install Danish language package
apt-get -y install language-pack-da language-pack-da-base

# Clean .deb cache to save space
apt-get -y autoremove
apt-get -y clean

# OS2borgerPC Kiosk specifics:

# Set Danish locale and timezone, e.g. for usage
# with Aula and attached/onscreen keyboards
timedatectl set-timezone Europe/Copenhagen
sed -i 's/# \(da_DK.UTF-8 UTF-8\)/\1/'  /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive tzdata
update-locale LANG=da_DK.utf-8

# Update the time accordingly
ntpdate pool.ntp.org
