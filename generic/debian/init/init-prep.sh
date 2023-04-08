#!/usr/bin/env bash

# 0.1 - Make /media/$USER/usb
sudo mkdir /media/"$USER"/usb

# 0.2 - Mount $DEV to /media/$USER/usb
sudo mount "$DEV" /media/"$USER"/usb

# Exit Message
echo 'Set $DEV in .env to location of drive containing the init directory.'
echo 'Run the following to search for a usb drive: $ sudo fdisk -l | grep -B 1 -A 5 USB'