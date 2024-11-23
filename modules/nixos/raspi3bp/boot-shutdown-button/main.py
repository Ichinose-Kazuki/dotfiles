import os
import sys
import signal
import atexit
import time

def signal_handler(sig, frame):
    print('You pressed Ctrl+C!')
    sys.exit(0)

def cleanup_gpio():
    print('Cleanup')
    GPIO.cleanup()

sys.path.append(os.path.join("/nix/store/n3k295f3cw6dpym210326sjpzjlrjlm4-python3.12-rpi-gpio-0.7.1/lib/python3.12/site-packages/"))

try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")

# Cleanup
signal.signal(signal.SIGINT, signal_handler)
atexit.register(cleanup_gpio)

channel = 24 # Button channel

GPIO.setmode(GPIO.BOARD)

GPIO.setup(channel, GPIO.IN, pull_up_down=GPIO.PUD_UP)

if GPIO.input(channel):
    print('Input was HIGH')
else:
    print('Input was LOW')

print('wait')

def my_callback():
    print('pressed')

GPIO.add_event_detect(channel, GPIO.FALLING, callback=my_callback)

if GPIO.event_detected(channel):
    print('detected')

time.sleep(1)

# GPIO.wait_for_edge(channel + 512, GPIO.FALLING)
# print('pushed')
