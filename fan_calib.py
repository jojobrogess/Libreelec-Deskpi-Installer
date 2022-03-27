#!/usr/bin/python

import sys
sys.path.append('/storage/.local/lib/python3.8/site-packages/')
import serial as serial
#import time
#import os

WAIT_TIME = 1

#GPIO.setmode(GPIO.BCM)
#GPIO.setup(FAN_PIN, GPIO.OUT, initial=GPIO.LOW)#

#fan = GPIO.PWM(FAN_PIN, PWM_FREQ)
#fan.start(0)

port = '/dev/ttyUSB0'
baudrate = '9600'
fan = serial.Serial(port, baudrate, timeout=30)

i = 0

hyst = 1
tempSteps = [30, 35]
speedSteps = [70, 100]
cpuTempOld = 0

try:
    while 1:
        fanSpeed = float(input("Fan Speed: "))
        fan.write(b'fanSpeed')


except(KeyboardInterrupt):
    print("Fan ctrl interrupted by keyboard")
    GPIO.cleanup()
    sys.exit()