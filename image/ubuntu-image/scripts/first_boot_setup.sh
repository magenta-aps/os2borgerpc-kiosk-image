#!/bin/sh

# checks connection to our site 
checkPing() {
    if curl --head --silent --fail http://os2borgerpc-admin.magenta.dk > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
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
    read -n 1 -r answer
    if [ "$answer" = "n" ]; then
      connection=true
    fi
  fi
 done 
}

clear
printf "%s" "This is the wifi-setup process for the OS2borgerPC Kiosk image."

# Does the user want to run the wifi_setup?
printf "\n%s" "Do you want to install Wi-Fi drivers? (y/n)"
read -n 1 -r answer
if [ "$answer" = "y" ]; then
  sudo wifi_setup
else
  printf "\n%s" "Skipping Wi-Fi driver installation."
fi

# clear
if checkPing; then
  printf "\n%s" "Your kiosk machine has connection to the internet."
else
  printf "\n%s" "Your kiosk machine has no connection to the internet"
fi

# Does the user want to manually configure Wi-Fi (nmtui)?
printf "\n%s" "Do you want to manually configure Wi-Fi? (y/n)"
read -n 1 -r answerNmtui

if [ "$answerNmtui" = "y" ]; then
  manualWifiSetup
else
  printf "\n%s" "Skipping manual Wi-Fi configuration."
fi

#If connected instuall the kiosk setup
if checkPing; then
  sudo os2borgerpc_kiosk_setup
  printf "\n%s\n" "We recommend you change the password for the superuser via the script on the website."  
else
  printf "\n%s\n" "Due to no connection to the internet, os2borgerpc_kiosk_setup is skipped. Try again manually."
fi

exit 0
