#!/bin/sh

# Checks connection to the internet
check_ping() {
  curl --head --silent --fail https://www.google.com > /dev/null 2>&1
}

# Can run nmtui until a connection is established
manual_wifi_setup() {
 CONNECTION=false

 while [ "$CONNECTION" = "false" ]; do
  nmtui

  if check_ping; then
    printf "\nYour kiosk machine is connected to the internet.\n"
    CONNECTION=true
  else
    printf "\nYour kiosk machine is not connected to the internet.\nRetry manual Wi-Fi configuration? (Y/n)"
    read -r answer
    if [ "$answer" = "n" ]; then
      break
    fi
  fi
 done 
}

# If automatic registration is configured, run setup noninteractively
# and assume that Wi-Fi drivers do not need to be installed
AUTOMATIC_REGISTRATION_CONFIG="/etc/os2borgerpc/automatic_registration_config"
if [ -f "$AUTOMATIC_REGISTRATION_CONFIG" ]; then
  SITE_UID=$(grep "site_uid" "$AUTOMATIC_REGISTRATION_CONFIG" | cut --delimiter ":" --fields 2 | xargs)
  PC_NAME=$(grep "pc_name" "$AUTOMATIC_REGISTRATION_CONFIG" | cut --delimiter ":" --fields 2 | xargs)
  if [ ! -z "$SITE_UID" ] && [ ! -z "$PC_NAME" ]; then
    if sudo os2borgerpc_kiosk_setup "True"; then
      exit 0
    fi
  fi
fi

while true; do
  clear
  printf "This is the initial setup process for the OS2borgerPC Kiosk image."
  
  printf "\nDo you want to run the setup? (Y/n)"
  read -r answer
  if [ "$answer" = "n" ]; then
    printf "\n%s\n" "Exiting installation wizard."
    break
  fi

  clear
  printf "OS2borgerPC Kiosk initial setup starting."

  # Only offer to run wifi_setup if it has not already been done
  if [ ! -f "/etc/wifi-setup-done" ]; then
    # Does the user want to run the wifi_setup?
    printf "\n%s" "Do you want to install Wi-Fi drivers? (Y/n)"
    read -r wifi_answer

    if [ "$wifi_answer" = "Y" ] || [ "$wifi_answer" = "y" ] || [ -z "$wifi_answer" ]; then
      sudo wifi_setup
    else
      printf "\nSkipping Wi-Fi driver installation.\n"
    fi
  fi

  # Only offer to run nmtui if it has actually been installed
  if [ -f "/etc/wifi-setup-done" ]; then
    # Does the user want to manually configure Wi-Fi (nmtui)?
    printf "\n%s" "Do you want to manually configure Wi-Fi? (Y/n)"
    read -r answerNmtui

    if [ "$answerNmtui" = "Y" ] || [ "$answerNmtui" = "y" ] || [ -z "$answerNmtui" ]; then
      manual_wifi_setup
    else
      printf "\nSkipping manual Wi-Fi configuration.\n"
    fi
  fi

  printf "\nStarting final setup.\n"

  if sudo os2borgerpc_kiosk_setup; then
    printf "\nSetup complete.\n\nRemember to change the superuser password via the script on the admin-site.\n\n"
    break
  else
    printf "\n%s\n%s\n" "Final setup failed." \
    "Enter 'y' to restart the installation wizard, or enter 'n' to exit to the shell, if you want to finish the installation manually."
    read -r answerRestart
    if [ "$answerRestart" = "n" ]; then
      break
    fi
  fi
done

