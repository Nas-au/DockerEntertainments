#!/bin/bash

# Bot token
BOT_TOKEN="xxx"
# Your chat id
CHAT_ID="xxx"

# Notification message
# If you need a line break, use "%0A" instead of "\n".
MESSAGE="<strong> **Episode** Download Completed</strong>%0A- ${1}%0A"
# Prepares the request payload
PAYLOAD="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MESSAGE}&parse_mode=HTML"
curl -S -X POST "${PAYLOAD}" -w "\n\n" | sudo tee -a notificationsLog.txt
mv "$(pwd)"/transmission/downloads/complete/Tv/* "$(pwd)"/nfs_share/TvShows
MESSAGE2="<strong>Moved to to NTFS Share</strong>%0A- ${1}%0A"
PAYLOAD="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MESSAGE2}&parse_mode=HTML"
curl -S -X POST "${PAYLOAD}" -w "\n\n" | sudo tee -a notificationsLog.txt