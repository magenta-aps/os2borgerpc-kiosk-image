# Configuration and advanced topics

## Post registration configuration

:::{danger}
Please change the `superuser` password *immediately* after deploying each
Kiosk!! There's a script in OS2borgerPC Admin to do this.
:::

Once the computer is connected to the OS2borgerPC Admin Portal and activated, the next steps
depend on what you want to use your Kiosk computer for.

You have two options here:
1. Configure the computer to run OpenStream - our software for digital signage.
2. Configure the computer to run Chromium - and select the start page yourself.

### Configure the computer to run OpenStream

This requires running the script "OS2borgerPC Kiosk - OpenStream Electron App Autostart",
which will download a custom Electron App meant to be used with OpenStream and configure
the Electron App to start automatically on boot.

The script requires an API-key for your organization in OpenStream in order for
the App/computer to connect to OpenStream.

For more information about this script, read its description on the OS2borgerPC Admin Portal.

### Configure the computer to run Chromium

There are two scripts needed to do this.

The first is called "OS2borgerPC Kiosk  - Chromium Installér" and will
install the browser and setup minimum GUI capabilities.

When this script has run successfully, you can configure Chromium to
start automatically on boot and configure the start page as needed.
You do this by running the script called "OS2borgerPC Kiosk - Chromium
Autostart".

For more information about these scripts, read their descriptions on the
OS2borgerPC Admin Portal.

## Firewall setup

The OS2borgerPC client **requires** that the outbound firewall is open for the following domains:

| Domain/IP | Port | Protocol | Comment |
| --------- | ---- | -------- | ------- |
| os2borgerpc-admin.magenta.dk | 443 | TCP | Used to check in with the admin portal, run scripts and similar operations |
| os2borgerpc-media.magenta.dk | 443 | TCP | The scripts that involve files fetch the files here |
| pypi.org | 443 | TCP | Used to install and update the client |
| files.pythonhosted.org | 443 | TCP | Used by PyPi to install and update the client |

We also **recommend** that the outbound firewall is open for the following, but it is not a requirement.

| Domain/IP | Port | Protocol | Comment                                            |
| --------- | ---- | -------- |----------------------------------------------------|
| * | 123 | UDP | This will open for Network Time Protocol (NTP)[^1] |

## Advanced topics (not relevant for most people)

### Connect to a hidden SSID

When it's a hidden SSID `nmtui` currently cannot see it, and thus can't activate  a connection to it.

Here follows a workaround:

You will need to exit the installation wizard to perform all of the required steps.

Type `nmtui` in the terminal and press Enter to start it.

You navigate within `nmtui` via the arrow keys, Enter and Escape.

![](nmtui_hidden_ssid_1.png)

Select "Rediger en forbindelse" ("Edit a connection") and press Enter.

![](nmtui_hidden_ssid_2.png)

On this page you may see a list of Wi-Fi SSIDs on the left, that the computer is able to see. Ignore them.

Select "Tilføj" ("Add") and press Enter.

![](nmtui_hidden_ssid_3.png)

Select "Wi-Fi", then "Opret" ("Create") and press Enter.

![](nmtui_hidden_ssid_4.png)

Here you fill out the information about the Wi-Fi.

You need to fill out "Profilnavn" ("Profile name"). This is the *connection name*.

:::{note}
Remember this profile/connection name for later in the guide.
:::

While technically the exact value of this is unimportant, we suggest making it the
name of the hidden SSID.

You also need to fill out "SSID".

You also need to select which type of "Sikkerhed" ("Security") it's using, such as WPA2 Personal, and the password.

You **don't** need to fill out "Enhed" ("Device") unless you have multiple Wireless Ethernet Cards and you want to specify
which of them should connect.

Once all the relevant details have been entered, select "OK" and press Enter.

Select "Tilbage" ("Back") and press Enter.

Select "Afslut" ("Quit") and press Enter.

In this step, you'll need the *connection name* you decided on earlier.

Now type in the following command and afterwards press Enter:
```sh
sudo nmcli con up "NAME-OF-CONNECTION-HERE"
```

:::{note}
If the name of the connection you chose has spaces in the name,
you'll need to write "" around the name in the command above. Otherwise surrounding quotes aren't strictly necessary.
:::

You may additionally want to run the following command, especially if you experience that the computer doesn't connect
to the Wi-Fi after a restart:
```sh
sudo nmcli con mod ”NAME-OF-CONNECTION-HERE” connection.autoconnect yes
```

Now you should have wireless internet access through an AP with a hidden SSID!

### Switching to the HWE kernel (Hardware Enablement Kernel)

:::{note}
The pre-downloaded HWE kernel is not available in our Kiosk images for RPi, as the hardware RPis contain is known
and supported by the default kernel in the image.
:::

In some rare cases, the computer might not be able to connect to the internet via ethernet
or see any existing wireless networks because the standard kernel does not have the correct
drivers for the network card(s). This can potentially be fixed by switching to the HWE kernel.

In order to install the HWE kernel, it is necessary to exit the installation wizard. This can
be done before starting the wizard, as previously described, or by pressing Ctrl + C when the wizard
is asking a question. Once you have exited the wizard, run the following command. You don't need
a network connection to run this command and install the HWE kernel:
```sh
sudo hwe_install
```

Installing the HWE kernel might take some time. After the HWE kernel has been installed, you will
need to reboot the computer to allow it to switch to the HWE kernel. This can be done manually or
by running the following command:
```sh
sudo reboot
```

The computer will now be using the HWE kernel.

### Additional remote access

If you want additional remote access to this system, besides being able to run scripts
on it from the admin system, you can run the script called
"OS2borgerPC Kiosk  - Installer SSH og VNC". After this, you'll
be able to SSH to the machine and to see its display by connecting with
a VNC client.

:::{danger}
You *must* change the standard `superuser` password before or *immediately*
after running this script.
:::

:::{note}
You use `superuser`'s standard UNIX password to SSH. In order to
connect with VNC, you need to supply a specific VNC password as a
parameter for this script.
:::

## Footnotes

[^1]: NTP is used by multiple operating systems for time synchronization. If NTP is blocked, the computer might slowly become desynchronized from the actual time. Incorrect time settings affect the on/off schedules and scripts for planned startup/shutdown among other things.
