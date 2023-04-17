#!/usr/bin/env bash

# Read a single char from /dev/tty, prompting with "$*"
# Note: pressing enter will return a null string. Perhaps a version terminated with X and then remove it in caller?
# See https://unix.stackexchange.com/a/367880/143394 for dealing with multi-byte, etc.
function get_keypress {
	local REPLY IFS=
	printf >/dev/tty '%s' "$*"
	[[ $ZSH_VERSION ]] && read -rk1 # Use -u0 to read from STDIN
	# See https://unix.stackexchange.com/q/383197/143394 about '\n' -> ''
	[[ $BASH_VERSION ]] && read </dev/tty -rn1
	printf '%s' "$REPLY"
}

# Get a y/n from the user, return yes=0, no=1 enter=$2
# Prompt using $1.
# If set, return $2 on pressing enter, useful for cancel or defualting
function get_yes_keypress {
	local prompt="${1:-Are you sure [y/n]? }"
	local enter_return=$2
	local REPLY
	# [[ ! $prompt ]] && prompt="[y/n]? "
	while REPLY=$(get_keypress "$prompt"); do
		[[ $REPLY ]] && printf '\n' # $REPLY blank if user presses enter
		case "$REPLY" in
		Y | y) return 0 ;;
		N | n) return 1 ;;
		'') [[ $enter_return ]] && return "$enter_return" ;;
		esac
	done
}

# Credit: http://unix.stackexchange.com/a/14444/143394
# Prompt to confirm, defaulting to NO on <enter>
# Usage: confirm "Dangerous. Are you sure?" && rm *
function confirm {
	local prompt="${*:-Are you sure} [y/N]? "
	get_yes_keypress "$prompt" 1
}

# Prompt to confirm, defaulting to YES on <enter>
function confirm_yes {
	local prompt="${*:-Are you sure} [Y/n]? "
	get_yes_keypress "$prompt" 0
}

# Script Confirmation
if confirm "Are you sure you want to run this script"; then

	# 0.1 - Make /media/${USER}/usb if it does not exist
	[[ ! -d /media/"${USER}" ]] && sudo mkdir /media/"${USER}"
	[[ ! -d /media/"${USER}"/usb ]] && sudo mkdir /media/"${USER}"/usb

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
	echo "##### Afterwards, run the init1.sh script from ~/init.                     #####"
fi
