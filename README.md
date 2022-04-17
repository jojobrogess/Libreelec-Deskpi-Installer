# Libreelec-Deskpi-Installer
This is a single installer script for the Deskpi Pro case.

ADDON VERSION HERE: https://github.com/jojobrogess/script.deskpifanservice
************************************************************************************************************************************
## !!!PREFACE!!!:
I have absolutely **NO** idea what I'm doing. 
Use all of this at **your own risk**!

************************************************************************************************************************************

## How to install DeskPi Pro script for Power Button and Fan Control:

************************************************************************************************************************************
### Requirements:

You MUST be on at least `LibreELEC-RPi4.arm-9.95.4`
And you need an ssh terminal

Connect LibreElec to the internet. This can be done with either ethernet or WiFi.
To check if the Ethernet or WiFi adapters are enabled, go to Settings>LibreElec>Network

Enable SSH. 
You need another computer to access the terminal of LibreElec. This can be done upon installation during wiki. 
Default Username= root Password=libreelec To check if SSH is enabled, go to Settings>LibreElec> Services

You might also want to make sure to allow addons/updates from any source. Settings> System> Addons

Install Raspberry Pi Tools and System Tools These can be installed by going to Addons>Install from Repository>LibreElec Addons>Program Addons

Connect via SSH. The default username for LibreElec is root while the default password is libreelec For Windows users, the best way to use SSH is through Putty using the IP address of the Pi and port 22. Linux users ssh root@[ip address of device]. If connecting to the device for the first time, you will be asked if you're sure you want to connect to the device. Confirm by typing yes FULLY, typing y will NOT suffice.

************************************************************************************************************************************ 
   
### After you've installed the required libraries, Connect into Libreelec through SSH:

************************************************************************************************************************************

`ssh root@IP.TO.YOUR.LIBREELEC`

Type this:

`wget https://github.com/jojobrogess/Libreelec-Deskpi-Installer/archive/refs/heads/main.zip`

`unzip main.zip`

`chmod +x Libreelec-Deskpi-Installer-main/install.sh`

`./Libreelec-Deskpi-Installer-main/install.sh`

************************************************************************************************************************************ 
   
### After the device reboots:

************************************************************************************************************************************

Reconnect through SSH and run this:
`./user/bin/deskpi-config`


*************************************************************************************************************************************

# Please go check out the AuraMod skin being developed by SerpentDrago and others:
AuraMod is a Heavily Modified version of Aura by jurialmunkey. Combining parts and code of Aura, Artic Zephyr 2, Titan Bingie and many others!
https://github.com/SerpentDrago/skin.auramod/tree/Matrix

*************************************************************************************************************************************
