import os
import sys
import signal
import atexit
import time

try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO!  This is probably because you need superuser privileges.  You can achieve this by using 'sudo' to run your script")
    
def signal_handler(sig, frame):
    print('You pressed Ctrl+C!')
    sys.exit(0)

def cleanup_gpio():
    print('Cleanup')
    GPIO.cleanup()
    
# Cleanup
signal.signal(signal.SIGINT, signal_handler)
atexit.register(cleanup_gpio)

channel = 27 # Button channel

GPIO.setmode(GPIO.BCM)

# for channel in range(1, 41):

    # try:
    #     GPIO.setup(channel, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    # except:
    #     print('Channel {} is not available'.format(channel))
    #     continue
    
GPIO.setup(channel, GPIO.IN, pull_up_down=GPIO.PUD_UP)

time.sleep(0.5)
print('Channel: {}'.format(channel))

# if GPIO.input(channel):
#     print('Input was HIGH')
# else:
#     print('Input was LOW')

channel = GPIO.wait_for_edge(channel, GPIO.FALLING, timeout=2000)
if channel is None:
    print('Timeout occurred')
else:
    print('Edge detected on channel', channel)

print('wait')

def my_callback():
    print('pressed')

# GPIO.add_event_detect(channel, GPIO.FALLING, callback=my_callback)

# if GPIO.event_detected(channel):
#     print('detected')

# time.sleep(1)

# GPIO.wait_for_edge(channel + 512, GPIO.FALLING)
# print('pushed')
