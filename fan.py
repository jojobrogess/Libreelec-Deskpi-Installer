#!/usr/bin/python

import sys
sys.path.append('/storage/.local/lib/python3.8/site-packages/')
import serial as serial
import json
import time
import os

# Configuration
with open(os.path.join(sys.path[0], 'fan.json')) as f:
    data = json.load(f)

WAIT_TIME = data['args']['wait_time']
FAN_MIN = data['args']['fan_min']
tempSteps = data['args']['temp_steps']
speedSteps = data['args']['speed_steps']
hyst = data['args']['hysteresis']

# WAIT_TIME = 1           # [s] Time to wait between each refresh
# FAN_MIN = 20            # [%] Fan minimum speed.
# PWM_FREQ = 25           # [Hz] Change this value if fan has strange behavior

# Configurable temperature and fan speed steps
# tempSteps = [30, 35]    # [°C]
# speedSteps = [70, 100]   # [%]

# Fan speed will change only if the difference of temperature is higher than hysteresis
# hyst = 1

# Setup GPIO pin
#GPIO.setmode(GPIO.BCM)
#GPIO.setup(FAN_PIN, GPIO.OUT, initial=GPIO.LOW)
#fan = GPIO.PWM(FAN_PIN, PWM_FREQ)
#fan.start(0)
port = '/dev/ttyUSB0'
baudrate = '9600'
fan = serial.Serial(port, baudrate, timeout=30)

i = 0
cpuTempOld = 0
fanSpeedOld = 0

# We must set a speed value for each temperature step
if(len(speedSteps) != len(tempSteps)):
    print("Numbers of temp steps and speed steps are different")
    exit(0)

try:
    while (1):
        if ser.isOpen():
        # Read CPU temperature
        cpuTempFile = open("/sys/class/thermal/thermal_zone0/temp", "r")
        cpuTemp = float(cpuTempFile.read()) / 1000
        cpuTempFile.close()

        # Calculate desired fan speed
        if(abs(cpuTemp-cpuTempOld > hyst)):

            # Below first value, fan will run at min speed.
            if(cpuTemp < tempSteps[0]):
                fanSpeed = speedSteps[0]

            # Above last value, fan will run at max speed
            elif(cpuTemp >= tempSteps[len(tempSteps)-1]):
                fanSpeed = speedSteps[len(tempSteps)-1]

            # If temperature is between 2 steps, fan speed is calculated by linear interpolation
            else:
                for i in range(0, len(tempSteps)-1):
                    if((cpuTemp >= tempSteps[i]) and (cpuTemp < tempSteps[i+1])):
                        fanSpeed = round((speedSteps[i+1]-speedSteps[i])/(tempSteps[i+1]-tempSteps[i])*(cpuTemp-tempSteps[i])+speedSteps[i],1)

            if((fanSpeed != fanSpeedOld)):
                if((fanSpeed != fanSpeedOld) and ((fanSpeed >= FAN_MIN) or (fanSpeed == 0))):
                    #fan.ChangeDutyCycle(fanSpeed)
                    fan.write(b'fanSpeed')                    
                    fanSpeedOld = fanSpeed

        # Wait until next refresh
        time.sleep(WAIT_TIME)

# If a keyboard interrupt occurs (ctrl + c)
except(KeyboardInterrupt):
    print("Fan ctrl interrupted by keyboard")
    ser.write(b'pwm_000')
    ser.close()