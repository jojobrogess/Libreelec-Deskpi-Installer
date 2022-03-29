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

port = '/dev/ttyUSB0'
baudrate = '9600'
fan = serial.Serial(port, baudrate, timeout=30)

i = 0
cpuTempOld = 0
fanSpeedOld = 0

if(len(speedSteps) != len(tempSteps)):
    print("Numbers of temp steps and speed steps are different")
    exit(0)

try:
    while (1):
        if fan.isOpen():
            cpu_temp = subprocess.getoutput('vcgencmd measure_temp|awk -F\'=\' \'{print \$2\'}')
            cpu_temp=int(cpu_temp.split('.')[0])

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
                        fanSpeed = bytes(str("pwm_%03d" % fanSpeed), 'utf-8')
                        fan.write(fanSpeed)                    
                        fanSpeedOld = fanSpeed

            # Wait until next refresh
            time.sleep(WAIT_TIME)

# If a keyboard interrupt occurs (ctrl + c)
except(KeyboardInterrupt):
    print("Fan ctrl interrupted by keyboard")
    fan.write(b'pwm_000')
    fan.close()