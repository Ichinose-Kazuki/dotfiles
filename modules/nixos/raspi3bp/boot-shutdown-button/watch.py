#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-FileCopyrightText: 2023 Kent Gibson <warthog618@gmail.com>

"""Minimal example of watching for edges on a single line."""

import gpiod
import subprocess

from datetime import timedelta
from gpiod.line import Bias, Edge

def check_server_status(ip_address='192.168.11.7'):
    # Run the ping command with a timeout of 1 second and 1 packet
    result = subprocess.run(
        ['ping', ip_address, '-c', '1', '-w', '1'], 
    )
    # Check if the command was successful
    if result.returncode == 0:
        return True
    else:
        return False
    
    
def shutdown_server():
    print('Shut down is not supported yet')
    

def  power_on_server(mac_address='50:eb:f6:b9:16:8a'):
    # Send a Wake-on-LAN packet to the server
    print('Powering on the server')
    subprocess.run(
        ['wol', mac_address],
    )


def edge_type_str(event):
    if event.event_type is event.Type.RISING_EDGE:
        return "Rising"
    if event.event_type is event.Type.FALLING_EDGE:
        return "Falling"
    return "Unknown"


def watch_line_value(chip_path, line_offset):
    # Assume a button connecting the pin to ground,
    # so pull it up and provide some debounce.
    with gpiod.request_lines(
        chip_path,
        consumer="watch-line-value",
        config={
            line_offset: gpiod.LineSettings(
                edge_detection=Edge.BOTH,
                bias=Bias.PULL_UP,
                debounce_period=timedelta(milliseconds=10),
            )
        },
    ) as request:
        while True:
            # Blocks until at least one event is available
            for event in request.read_edge_events():
                print(
                    "line: {}  type: {:<7}  event #{}".format(
                        event.line_offset, edge_type_str(event), event.line_seqno
                    )
                )
                is_powered_on = check_server_status()
                if (is_powered_on):
                    print('Server is powered on')
                    if event.event_type is event.Type.FALLING_EDGE:
                        falling_edge_time = event.timestamp_ns
                    else:
                        rising_edge_time = event.timestamp_ns
                        if 'falling_edge_time' in locals() \
                            and (rising_edge_time - falling_edge_time) >= 1 * 1e9:
                            shutdown_server()
                        else:
                            print('Press and hold the button for at least 1 second to shut down the server')
                else:
                    print('Server is powered off')
                    if event.event_type is event.Type.FALLING_EDGE:
                        power_on_server()
                    else:
                        print('Press the button to power on the server')
                

if __name__ == "__main__":
    try:
        watch_line_value("/dev/gpiochip0", 5)
    except OSError as ex:
        print(ex, "\nCustomise the example configuration to suit your situation")
