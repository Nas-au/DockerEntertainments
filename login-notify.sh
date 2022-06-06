#!/bin/bash
SYSTEM_NAME="$(hostname)"
SYSTEM_IP="$(hostname -I |  cut -d " " -f 1)"
# prepare any message you want
login_ip="$(echo $SSH_CONNECTION | cut -d " " -f 1)"
login_date="$(date +"%e %b %Y, %a %r")"
login_name="$(whoami)"
# For new line I use $'\n' here
message="<strong>*** New login to $SYSTEM_NAME @ $SYSTEM_IP *** </strong> "$'\n'"- $login_name"$'\n'"- $login_ip"$'\n'"- $login_date"
#send it to telegram
telegram-send "$message"