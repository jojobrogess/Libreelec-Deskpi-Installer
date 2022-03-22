#!/bin/bash
################################################################
################################################################
########## Deskpi Fan And Power Button Install Script ##########
################################################################
################################################################
daemonname="deskpi"
userlibrary=/storage/user/
daemonconfig=/storage/user/bin/$daemonname-config
daemonspowerervice=/storage/.config/system.d/$daemonname-poweroff.service
daemonfanservice=/storage/.config/system.d/$daemonname.service
powerbutton=/storage/user/bin/$daemonname-poweroff.py
defaultdriver=/storage/user/bin/$daemonname-fancontrol.py
uninstall=/storage/user/bin/$daemonname-uninstall
################################################################
################################################################

deskpi_create_file() {
	if [ -f $1 ]; then
        rm $1
    fi
	touch $1
}

############################
#### Create User Lib/Bin Directory
############################

echo "DeskPi Fan control script installation Start." 

if [ ! -d "/storage/user" ] ; then
	mkdir -p $userlibrary
	mkdir -p $userlibrary/lib
	mkdir -p $userlibrary/bin
fi

############################
######Check Boot Mode######
############################

echo "Check Boot Mode"

PIINFO=$(cat /flash/config.txt | grep 'otg_mode=1,dtoverlay=dwc2,dr_mode=host,dtoverlay=gpio-ir,gpio_pin=17')
if [ -z "$PIINFO" ]
then
	mount -o remount,rw /flash
	echo "otg_mode=1,dtoverlay=dwc2,dr_mode=host,dtoverlay=gpio-ir,gpio_pin=17" >> /flash/config.txt
	mount -o remount,ro /flash
fi

echo "Successfully Checked and Created the Boot Mode"

############################
####Create deskpi-config####
############################

echo "Create deskpi-config"

deskpi_create_file $daemonconfig

echo '#!/bin/bash' >> $daemonconfig
echo '# This is a Fan Speed control utility tool for user to customize Fan Speed.' >> $daemonconfig
echo '# Priciple: send speed argument to the MCU' >> $daemonconfig
echo '# Technical Part' >> $daemonconfig
echo '# There are four arguments:' >> $daemonconfig
echo '# pwm_025 means sending 25% PWM signal to MCU. The fan will run at 25% speed level.' >> $daemonconfig
echo '# pwm_050 means sending 50% PWM signal to MCU. The fan will run at 50% speed level.' >> $daemonconfig
echo '# pwm_075 means sending 75% PWM signal to MCU. The fan will run at 75% speed level.' >> $daemonconfig
echo '# pwm_100 means sending 100% PWM signal to MCU.The fan will run at 100% speed level.' >> $daemonconfig
echo '#' >> $daemonconfig
echo '# This is the serial port that connects the deskPi mainboard and' >> $daemonconfig
echo '# communicates with the Raspberry Pi to get the signal for Fan Speed adjusting.' >> $daemonconfig
echo 'sys=/storage/.kodi/addons/virtual.rpi.tools/lib' >> $daemonconfig
echo 'serial=/storage/.kodi/addons/script.module.pyserial/lib/' >> $daemonconfig
echo 'serial_port=/dev/ttyUSB0' >> $daemonconfig
echo '' >> $daemonconfig
echo '# Stop deskpi.service so that user can define the speed level.' >> $daemonconfig
echo 'systemctl stop deskpi.service' >> $daemonconfig
echo '' >> $daemonconfig
echo '# Define the function of set_config' >> $daemonconfig
echo 'function set_config() {' >> $daemonconfig
echo '	if [ -e /storage/user/bin/deskpi.conf ]; then' >> $daemonconfig
echo '		sh -c "rm -f /storage/user/bin/deskpi.conf"' >> $daemonconfig
echo '	fi' >> $daemonconfig
echo '	touch /storage/user/bin/deskpi.conf' >> $daemonconfig
echo '	chmod 777 /storage/user/bin/deskpi.conf' >> $daemonconfig
echo '	echo "The following allows you to control the fan speed according to"' >> $daemonconfig
echo '	echo "the temperature and fan speed you define."' >> $daemonconfig
echo '	echo "You  will need to input 4 different temperature thresholds"' >> $daemonconfig
echo '	echo "(for example: 30, 40, 50, 60)"' >> $daemonconfig
echo '	echo "And 4 PWM values of different speeds parameters"' >> $daemonconfig
echo '	echo "(for example 25, 50, 75, 100, these are the default values)"' >> $daemonconfig
echo '  echo "You can define the speed level during 0-100."' >> $daemonconfig
echo '	for i in `seq 1 4`;' >> $daemonconfig
echo '	do' >> $daemonconfig
echo "	echo -e '\e[32;40mCurrent CPU Temperature:\e[0m \e[31;40m`vcgencmd measure_temp|sed -e "s/temp=//" -e "s/\..*'/ /"`\e[0m\n'" >> $daemonconfig
echo '	read -p  "Temperature_threshold_$i:" temp' >> $daemonconfig
echo '        read -p  "Fan_Speed level_$i:" fan_speed_level' >> $daemonconfig
echo '	sh -c "echo $temp" >> /storage/user/bin/deskpi.conf' >> $daemonconfig
echo '	sh -c "echo $fan_speed_level" >> /storage/user/bin/deskpi.conf' >> $daemonconfig
echo '	done ' >> $daemonconfig
echo '	echo "Configuration setting saved to: /storage/user/bin/deskpi.conf"' >> $daemonconfig
echo '}' >> $daemonconfig
echo '' >> $daemonconfig
echo 'echo "-----------------------------------------------------------------"' >> $daemonconfig
echo 'echo "Welcome to the LIBREELEC-Deskpi Fan Speed Configuration File"' >> $daemonconfig
echo 'echo "-----------------------------------------------------------------"' >> $daemonconfig
echo 'echo "Please select the Fan Speed level you want or Enable variable "' >> $daemonconfig
echo 'echo "Fan Speed, to set the Fan Speed according to Cpu Temperature."' >> $daemonconfig
echo 'echo "Or create custom Variables for Fan Speeds according to Cpu Temps."' >> $daemonconfig
echo 'echo "-----------------------------------------------------------------"' >> $daemonconfig
echo 'echo "1 - Set the Fan Speed to 50%"' >> $daemonconfig
echo 'echo "2 - Set the Fan Speed to 65%"' >> $daemonconfig
echo 'echo "3 - Set the Fan Speed to 75%"' >> $daemonconfig
echo 'echo "4 - Set the Fan Speed to 90%"' >> $daemonconfig
echo 'echo "5 - Set the Fan Speed to 100%"' >> $daemonconfig
echo 'echo "6 - Turn off the Fan"' >> $daemonconfig
echo 'echo "7 - Enable default Variable Fan Speed Control"' >> $daemonconfig
echo 'echo "8 - Create custom config Fan Speed according to Cpu Temperature"' >> $daemonconfig
echo 'echo "-----------------------------------------------------------------"' >> $daemonconfig
echo 'echo "Input Number and Press Enter."' >> $daemonconfig
echo 'read -p "Your choice:" levelNumber' >> $daemonconfig
echo 'case $levelNumber in' >> $daemonconfig
echo '	1) ' >> $daemonconfig
echo '	   echo "You have selected 50% fan speed"' >> $daemonconfig
echo '	   sh -c "echo pwm_050 > $serial_port"' >> $daemonconfig
echo '	   echo "Fan speed has been change to 50%"' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	2) ' >> $daemonconfig
echo '	   echo "You have selected 65% fan speed"' >> $daemonconfig
echo '	   sh -c "echo pwm_065 > $serial_port"' >> $daemonconfig
echo '	   echo "Fan speed has been change to 65%"' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	3) ' >> $daemonconfig
echo '	   echo "You have selected 75% fan speed"' >> $daemonconfig
echo '	   sh -c "echo pwm_075 > $serial_port"' >> $daemonconfig
echo '	   echo "Fan speed has been change to 75%"' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	4) ' >> $daemonconfig
echo '	   echo "You have selected 90% fan speed"' >> $daemonconfig
echo '	   sh -c "echo pwm_090 > $serial_port"' >> $daemonconfig
echo '	   echo "Fan speed has been change to 90%"' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	5) ' >> $daemonconfig
echo '	   echo "You have selected 100% fan speed"' >> $daemonconfig
echo '	   sh -c "echo pwm_100 > $serial_port"' >> $daemonconfig
echo '	   echo "Fan speed has been change to 100%"' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	6) ' >> $daemonconfig
echo '	   echo "Turn off fan"' >> $daemonconfig
echo '	   sh -c "echo pwm_000 > $serial_port"' >> $daemonconfig
echo '	   echo "Fan has been turned off."' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	7) ' >> $daemonconfig
echo '	   echo "Enabled default variable fan speed values"' >> $daemonconfig
echo '	   echo "Default values are located at (/storage/user/bin/deskpi-fancontrol.py)"' >> $daemonconfig
echo '	   systemctl stop deskpi.service &' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	8) ' >> $daemonconfig
echo '	   echo "Enabled Custom variable fan speed according to cpu temperature"' >> $daemonconfig
echo '	   systemctl stop deskpi.service & ' >> $daemonconfig
echo '	   set_config' >> $daemonconfig
echo '	   systemctl start deskpi.service & ' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo '	*) ' >> $daemonconfig
echo '	   echo "Looks like you input the wrong number"' >> $daemonconfig
echo '     echo "Please try selecting from the options available!"' >> $daemonconfig
echo '	   . /storage/user/bin/deskpi-config' >> $daemonconfig
echo '	   ;;' >> $daemonconfig
echo 'esac' >> $daemonconfig

chmod 755 $daemonconfig

echo "Successfully Created deskpi-config"

#############################
#Create Default Driver Daemon
#############################

echo "Create Fan Default Driver Daemon"

deskpi_create_file $defaultdriver

echo 'import sys' >> $defaultdriver
echo "sys.path.append('/storage/.local/lib/python3.8/site-packages/')" >> $defaultdriver
echo 'import serial as serial' >> $defaultdriver
echo 'import time' >> $defaultdriver
echo 'import subprocess' >> $defaultdriver
echo '' >>$defaultdriver
echo "port = '/dev/ttyUSB0'" >>$defaultdriver
echo "baudrate = '9600'" >>$defaultdriver
echo 'ser = serial.Serial(port, baudrate, timeout=30)' >>$defaultdriver
echo '' >>$defaultdriver
echo 'try:' >> $defaultdriver
echo '    while True:' >> $defaultdriver
echo '        if ser.isOpen():' >> $defaultdriver
echo "            cpu_temp = subprocess.getoutput('vcgencmd measure_temp|awk -F\'=\' \'{print \$2\'}')" >> $defaultdriver
echo "            cpu_temp=int(cpu_temp.split('.')[0])" >> $defaultdriver
echo '' >>$defaultdriver
echo '            if cpu_temp < 35:' >> $defaultdriver
echo "                ser.write(b'pwm_000')" >> $defaultdriver
echo '            elif cpu_temp > 35 and cpu_temp < 40:' >> $defaultdriver
echo "                ser.write(b'pwm_065')" >> $defaultdriver
echo '            elif cpu_temp > 40 and cpu_temp < 45:' >> $defaultdriver
echo "                ser.write(b'pwm_075')" >> $defaultdriver
echo '            elif cpu_temp > 45 and cpu_temp < 50:' >> $defaultdriver
echo "                ser.write(b'pwm_085')" >> $defaultdriver
echo '            elif cpu_temp > 50:' >> $defaultdriver
echo "                ser.write(b'pwm_100')" >> $defaultdriver
echo '' >>$defaultdriver
echo 'except KeyboardInterrupt:' >> $defaultdriver
echo "    ser.write(b'pwm_000')" >> $defaultdriver
echo '    ser.close()' >> $defaultdriver
echo ' ' >> $defaultdriver

chmod 755 $defaultdriver

echo "Successfully Created Default Driver Daemon"


############################
#####Build Fan Service######
############################

echo "Building Fan Service"

deskpi_create_file $daemonfanservice

echo '[Unit]' >> $daemonfanservice
echo 'Description=DeskPi_Fan_Service' >> $daemonfanservice
echo 'After=multi-user.target' >> $daemonfanservice
echo '[Service]' >> $daemonfanservice
echo 'Type=simple' >> $daemonfanservice
echo 'RemainAfterExit=no' >> $daemonfanservice
echo 'ExecStart=/bin/sh -c ". /etc/profile; exec /usr/bin/python /storage/user/bin/deskpi-fancontrol.py; exec /storage/user/bin/deskpi.conf' >> $daemonfanservice
echo '[Install]' >> $daemonfanservice
echo 'WantedBy=multi-user.target' >> $daemonfanservice

chmod 644 $daemonfanservice

echo "Successfully Built Fan Service"

############################
#####Create Power Button####
############################

echo "Create Power Button Driver"

deskpi_create_file $powerbutton

echo 'import serial' >> $powerbutton
echo 'import time' >> $powerbutton
echo '' >> $powerbutton
echo 'ser=serial.Serial("/dev/ttyUSB0", 9600, timeout=30)' >> $powerbutton
echo '' >> $powerbutton
echo 'try: ' >> $powerbutton
echo '    while True:' >> $powerbutton
echo '        if ser.isOpen():' >> $powerbutton
echo "            ser.write(b'power_off')" >> $powerbutton
echo '            ser.close()' >> $powerbutton
echo '' >> $powerbutton
echo 'except KeyboardInterrupt:' >> $powerbutton
echo "    ser.write(b'power_off')" >> $powerbutton
echo '    ser.close()' >> $powerbutton
echo '    ' >> $powerbutton

chmod 755 $powerbutton

echo "Successfully Created Power Button Driver"

############################
#####Build Power Service####
############################

echo "Building Power Daemon"

deskpi_create_file $daemonspowerervice

echo '[Unit]' >> $daemonspowerervice
echo 'Description=DeskPi_Power_Button_Service' >> $daemonspowerervice
echo 'Conflicts=reboot.target' >> $daemonspowerervice
echo 'Before=halt.target shutdown.target poweroff.target' >> $daemonspowerervice
echo 'DefaultDependencies=no' >> $daemonspowerervice
echo '[Service]' >> $daemonspowerervice
echo 'Type=oneshot' >> $daemonspowerervice
echo 'ExecStart=/bin/sh -c ". /etc/profile; exec /usr/bin/python /storage/user/bin/deskpi-poweroff.py"' >> $daemonspowerervice
echo 'RemainAfterExit=yes' >> $daemonspowerervice
echo 'TimeoutSec=1' >> $daemonspowerervice
echo '[Install]' >> $daemonspowerervice
echo 'WantedBy=halt.target shutdown.target poweroff.target' >> $daemonspowerervice

chmod 644 $daemonspowerervice

echo "Successfully Built Power Service"

############################
##Create Uninstall Script###
############################

echo "Create Uninstall Script"

deskpi_create_file $uninstall

echo '#!/bin/bash' >> $uninstall
echo '# uninstall deskpi script ' >> $uninstall
echo 'daemonname='deskpi'' >> $uninstall
echo 'daemonconfig=/storage/user/bin/deskpi-config' >> $uninstall
echo '' >> $uninstall
echo 'echo "Uninstalling DeskPi Services."' >> $uninstall
echo 'sleep 1' >> $uninstall
echo 'echo "Remove otg_mode=1,dtoverlay=dwc2,dr_mode=host,dtoverlay=gpio-ir,gpio_pin=17 from /flash/config.txt file"' >> $uninstall
echo '' >> $uninstall
echo 'PIINFO=$(cat /flash/config.txt | grep 'otg_mode=1')' >> $uninstall
echo 'if [ -n "$PIINFO" ]' >> $uninstall
echo 'then' >> $uninstall
echo '	mount -o remount,rw /flash' >> $uninstall
echo "	    sed -i 'otg_mode=1,dtoverlay=dwc2,dr_mode=host,dtoverlay=gpio-ir,gpio_pin=17' /flash/config.txt" >> $uninstall
echo '# Probably not a good idea to just delete the last line rather than find and delete.' >> $uninstall
echo '	mount -o remount,ro /flash' >> $uninstall
echo 'echo "fi"' >> $uninstall
echo 'echo "Removed otg_mode=1 configure from /flash/config.txt file"' >> $uninstall
echo '' >> $uninstall
echo 'echo "Diable DeskPi Fan Control and PowerOff Service."' >> $uninstall
echo 'systemctl disable $daemonname.service 2&>/dev/null' >> $uninstall
echo 'systemctl stop $daemonname.service  2&>/dev/null' >> $uninstall
echo 'systemctl disable $daemonname-poweroff.service 2&>/dev/null' >> $uninstall
echo 'systemctl stop $daemonname-poweroff.service 2&>/dev/null' >> $uninstall
echo 'echo "Successfully Disabled DeskPi Fan Control and PowerOff Service.' >> $uninstall
echo '' >> $uninstall
echo 'echo "Remove DeskPi Fan Control and PowerOff Service."' >> $uninstall
echo 'rm -f  /storage/.config/system.d/$daemonname-poweroff.service 2&>/dev/null' >> $uninstall
echo 'rm -f  /storage/.config/system.d/$daemonname.service  2&>/dev/null' >> $uninstall
echo 'rm -f /storage/user/bin/deskpi-fancontrol.py 2&>/dev/null' >> $uninstall
echo 'rm -f /storage/user/bin/deskpi-poweroff.py 2&>/dev/null' >> $uninstall
echo 'rm -f /storage/user/bin/deskpi-config 2&>/dev/null' >> $uninstall
echo 'rm -f /storage/user/bin/deskpi.conf 2&>/dev/null' >> $uninstall
echo 'echo "Successfully Uninstalled DeskPi Driver."' >> $uninstall
echo '' >> $uninstall
echo 'echo "Remove userfiles"' >> $uninstall
echo 'rm -f $daemonconfig' >> $uninstall
echo 'rm -f /storage/user/bin/deskpi.conf' >> $uninstall
echo 'echo "Removed userfiles"' >> $uninstall
echo 'echo "Try to Remove Install Files"' >> $uninstall
echo 'if [ -d "/storage/deskpi-ERno" ] ; then' >> $uninstall
echo 'rm -f /storage/deskpi-ERno' >> $uninstall
echo 'fi' >> $uninstall
echo 'echo "If Install Files were found, they are deleted"' >> $uninstall
echo 'sleep 5' >> $uninstall
echo 'echo "Going to attempt to kill myself now..."' >> $uninstall
echo 'sleep 2' >> $uninstall
echo 'echo "wish me luck"' >> $uninstall
echo 'sleep 2' >> $uninstall
echo 'echo "?"' >> $uninstall
echo 'rm -- "$0"' >> $uninstall
echo '' >> $uninstall

chmod 755 $uninstall

echo "Successfully Created the Uninstall Script"

################################################################
################### Finish Up Install Script ###################
################################################################

echo "DeskPi Services and Daemons have been built." 
echo "Installation of Deskpi Services and Daemons have Successfully finished"

############################
#######Stop Services########
############################

echo "DeskPi Service Load Modules." 

systemctl daemon-reload
systemctl enable $daemonname.service
systemctl start $daemonname.service 
systemctl daemon-reload
systemctl enable $daemonname-poweroff.service
systemctl start $daemonname-poweroff.service

echo "Deskpi Service Loaded Modules Correctly"

############################
#########Exit Code##########
############################

echo "DeskPi Fan Control and PowerOff Service installed Successfully." 
echo "System requires a reboot for settings to take effect."
echo "After Reboot has finished, reconnect and run"
echo "./user/bin/deskpi-config to finish setting everything up"
sleep 5
sync
