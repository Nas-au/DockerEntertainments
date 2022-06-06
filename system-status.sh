#!/bin/bash
SYSTEM_NAME="$(hostname)"
CPU_USAGE=$(top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}')
DATE=$(date "+%Y-%m-%d %H:%M:")
UPTIME=$(uptime)
MEMORY=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
DESK=$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)\n", $3,$2,$5}')
CPU_USAGE="<strong> *** $SYSTEM_NAME Status on $DATE *** </strong> %0A <strong> UPTIME: </strong> $UPTIME  %0A <strong> CPU Load: </strong> $CPU_USAGE %0A <strong> Memory Usage: </strong> $MEMORY %0A <strong> Disk Usage: </strong> $DESK "

# Bot token
BOT_TOKEN="xxxx"
# Your chat id
CHAT_ID="xxxx"
# Notification message
# If you need a line break, use "%0A" instead of "\n".
MESSAGE=$CPU_USAGE

# Prepares the request payload
PAYLOAD="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MESSAGE}&parse_mode=HTML"
curl -S -X POST "${PAYLOAD}"