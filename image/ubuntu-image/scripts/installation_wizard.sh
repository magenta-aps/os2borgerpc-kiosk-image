#!/bin/sh

# checks connection to our site 
checkPing() {
  curl --head --silent --fail http://os2borgerpc-admin.magenta.dk > /dev/null 2>&1
}

# Can run nmtui until a connection is established
manualWifiSetup() {
 connection=false

 while [ "$connection" = "false" ]; do 
  nmtui

  if checkPing; then
    printf "\n%s" "Your kiosk machine has connection to the internet."
    connection=true
  else
    printf "\n%s\n%s" "Your kiosk machine has no connection to the internet." "Try again? (y/n)"
    read -r answer
    if [ "$answer" = "n" ]; then
      break
    fi
  fi
 done 
}

while true; do
  clear
  printf "%s" "This is the wifi-setup process for the OS2borgerPC Kiosk image."
  
  printf "\n%s" "Do you want to run the wifi-setup? (y/n)"
  read -r answer
  if [ "$answer" = "n" ]; then
    printf "\n%s" "Exiting installation wizzard."
    exit 0
  fi

  # Does the user want to run the wifi_setup?
  printf "\n%s" "Do you want to install Wi-Fi drivers? (y/n)"
  read -r wifi_answer

  if [ "$wifi_answer" = "y" ] || [ -z "$wifi_answer" ]; then
    sudo wifi_setup
  else
    printf "\n%s" "Skipping Wi-Fi driver installation."
  fi

   # Does the user want to manually configure Wi-Fi (nmtui)?
  printf "\n%s" "Do you want to manually configure Wi-Fi? (y/n)"
  read -r answerNmtui

  if [ "$answerNmtui" = "y" ] || [ -z "$anserNmtui" ]; then
    manualWifiSetup
  else
    printf "\n%s" "Skipping manual Wi-Fi configuration."
  fi

  #If connected instuall the kiosk setup
  if [ "$connection" = true ] ; then
    sudo os2borgerpc_kiosk_setup
    printf "\n%s\n" "We recommend you change the password for the superuser via the script on the website."
    exit 0  
  else
    printf "\n%s\n" "Internet connectivity check failed, and the installation requires internet. 
    Press 'y' to restart the installation wizard, or press 'n' to exit to the shell, if you want to finish the installation manually."
    read -r answerRestart
    if [ "$answerRestart" = "n" ]; then
      exit 0
    fi
  fi
done

