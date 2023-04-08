#!/usr/bin/env bash
# YES/NO Function
## EXAMPLE: yes_or_no "$message" && do_something
function yes_or_no {
	while true; do
		read -pr "$*? [y/N]: " yn
		case $yn in
		[Yy]*) return 0 ;;
		[Nn]*)
			echo "Aborted"
			return 1
			;;
		esac
	done
}

# Script Confirmation
if yes_or_no "Are you sure you want to run this script"; then

	# 0.1 - Make /media/$USER/usb if it does not exist
	[[ ! -d /media/"$USER" ]] && sudo mkdir /media/"$USER"
	[[ ! -d /media/"$USER"/usb ]] && sudo mkdir /media/"$USER"/usb

	# 0.2 - Exit Message and USB drive search
	echo "Searching for a external usb drives..." && echo " "
	sudo fdisk -l | grep -B 1 -A 10 'USB\|Ext' && echo " "

	if [[ ! -e "/dev/sdb1" ]]; then
		echo "If your boot disk is not on sda use the following:"
		sudo fdisk -l | grep -B 1 -A 10 'USB\|Ext' | grep '\/dev\/sd[a-z][0-9]' | awk '{print $1}' && echo " "
	else
		echo "If your boot disk is on sda use the following:"
		sudo fdisk -l | grep -B 1 -A 10 'USB\|Ext' | grep '\/dev\/sd[b-z][0-9]' | awk '{print $1}' && echo " "
	fi

	echo '##### Set $DEV in .env to location of drive containing the init directory. #####'
	echo "##### After that, run the init1.sh script from ~/init.                     #####"
fi
