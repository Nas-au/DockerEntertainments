

# Installing Docker and Entertainments containers with Telegram Notifications and NTFS Volume shares



## 1. install Docker on Ubuntu:

### Install using the repository

Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.

#### Set up the repository

1. Update the `apt` package index and install packages to allow `apt` to use a repository over HTTPS:

   ```sh
   $ sudo apt-get update
   
   $ sudo apt-get install \
       ca-certificates \
       curl \
       gnupg \
       lsb-release
   ```

2. Add Docker’s official GPG key:

   ```sh
   $ sudo mkdir -p /etc/apt/keyrings
   $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   ```

3. Use the following command to set up the repository:

   ```sh
   $ echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

#### Install Docker Engine

1. Update the `apt` package index, and install the *latest version* of Docker Engine, contained, and Docker Compose, or go to the next step to install a specific version:

   ```sh
    $ sudo apt-get update
    $ sudo apt-get install docker-ce docker-ce-cli containerd.
   ```



### Installing Docker Compose
```bash
$ sudo apt  install docker-compose
```




## 2. Setup Notification system:

Telegram Notification 

```shell
 $ sudo nano telegram-send.sh
```

**telegram-send.sh**

```bash
#!/bin/bash
# Your chat id
CHAT_ID=xxxx
# Bot token
BOT_TOKEN=xxxx
# this 3 checks (if) are not necessary but should be convenient
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` \"text message\""
  exit 0
fi
if [ -z "$1" ]
  then
    echo "Add message text as second arguments"
    exit 0
fi
if [ "$#" -ne 1 ]; then
    echo "You can pass only one argument. For string with spaces put it on quotes"
    exit 0
fi
curl -s --data "text=$1&parse_mode=HTML" --data "chat_id=$CHAT_ID" 'https://api.telegram.org/bot'$BOT_TOKEN'/sendMessage' > /dev/null
```

Telegram Notifications on login

```sh
 $ sudo nano login-notify.sh
```

 **login-notify.sh**

```bash
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
```

System Status Notifications

```sh
 $ sudo nano system-status.sh
```

**system-status.sh**

```sh
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
```

​	Moving and testing scripts

```sh
$ sudo chmod +x telegram-send.sh
$ sudo mv telegram-send.sh /usr/bin/telegram-send
$ sudo chown root:root /usr/bin/telegram-send
$ telegram-send "Test message"
$ sudo chmod +x login-notify.sh
$ sudo mv login-notify.sh /etc/profile.d/login-notify.sh
$ sudo chmod +x system-status.sh
$ sudo mv system-status.sh /usr/bin/system-status
$ sudo chown root:root /usr/bin/system-status
```

​	System Status Notification setup

```sh
$ sudo 
```

​	Sending Notification every day at 9 AM
```sh
**0 9 * * *  /bin/bash -c system-status**
```




## 3. Install Required Containers



### 1. Portainer CE

​	First, create the volume that Portainer Server will use to store its database

```sh
$ sudo docker volume create portainer_data
```

​	Then, download and install the Portainer Server container

```sh
$ sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:2.9.3
```



### 2. Transmission Container

```sh
$ sudo docker run -d \
  --name=transmission \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Riyadh \
  -e USER=admin \
  -e PASS=admin \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v "$(pwd)"/transmission/data:/config \
  -v "$(pwd)"/transmission/downloads:/downloads \
  -v "$(pwd)"/transmission/watch:/watch \
  --restart unless-stopped \
  ghcr.io/linuxserver/transmission
```



### 3. Jackett Container

```sh
$ sudo docker run -d \
  --name=jackett \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Riyadh \
  -p 9117:9117 \
  -v "$(pwd)"/jackett/data:/config \
  -v "$(pwd)"/jackett/downloads:/downloads \
  --restart unless-stopped \
  ghcr.io/linuxserver/jackett
```



### 4. Sonarr Container

```sh
$ sudo docker run -d \
  --name=sonarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Riyadh \
  -p 8989:8989 \
  -v "$(pwd)"/sonarr/data:/config \
  -v "$(pwd)"/sonarr/tv:/tv \
  -v "$(pwd)"/sonarr/downloads:/downloads \
  --restart unless-stopped \
  ghcr.io/linuxserver/sonarr
```



### 5. Radarr Container

```sh
$ sudo docker run -d \
  --name=radarr \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Riyadh \
  -p 7878:7878 \
  -v "$(pwd)"/radarr/data:/config \
  -v "$(pwd)"/radarr/movies:/movies \
  -v "$(pwd)"/radarr/downloads:/downloads \
  --restart unless-stopped \
  ghcr.io/linuxserver/radarr
```



### 6. Nginx Proxy Manager compose

```sh
$ sudo nano docker-compose.yml
```

***docker-compose.yml***

```dockerfile
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - "$(pwd)"/NPM:/data
      - "$(pwd)"/letsencrypt:/etc/letsencrypt
```

```bash
$ sudo docker-compose up -d
```

 

## 4. Setup NTFS Volume:

​	add permenet connection to YOUR NTFS volume 

```bash
$ sudo apt install nfs-common -y
```

```bash
$ sudo nano /etc/fstab
```

```bash
$ sudo mkdir "$(pwd)"/test
```

​ add to /etc/fstab and change YOU IP and PATH

```bash
192.168.x.x:/path/to/your/share "$(pwd)"/nfs_share nfs nouser,rsize=8192,wsize=8192,atime,auto,defaults
```

```bash
$ sudo mount -a
```

​	Move downloaded content to YOUR NTFS volume share 

```bash
$ sudo nano /root/move_MOVIES.sh
```

​	Moving Movies after download script

```bash
#!/bin/bash

# Bot token
BOT_TOKEN="xxx"
# Your chat id
CHAT_ID="xxx"
# Notification message
# If you need a line break, use "%0A" instead of "\n".
MESSAGE="<strong> **Movie** Download Completed</strong>%0A- ${1}%0A"
# Prepares the request payload
PAYLOAD="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MESSAGE}&parse_mode=HTML"
curl -S -X POST "${PAYLOAD}" -w "\n\n" | sudo tee -a notificationsLog.txt
mv "$(pwd)"/transmission/downloads/complete/Movies/* "$(pwd)"/nfs_share/Movies
MESSAGE2="<strong> Moved to NTFS Share </strong>%0A- ${1}%0A"
PAYLOAD="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${MESSAGE2}&parse_mode=HTML"
curl -S -X POST "${PAYLOAD}" -w "\n\n" | sudo tee -a notificationsLog.txt
```

​	Move downloaded content to YOUR NTFS volume share 

```bash
$ sudo nano /root/move_TV.sh
```

​	Moving TV Shows after download script

```bash
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
```

​	install incrontab 

```bash
$ sudo apt install incron
```

​	add moving scripts to incrontab

```bash
$ sudo apt install incron
```

```bash
$ sudo incrontab -e
```

```bash
"$(pwd)"/transmission/downloads/complete/Tv IN_CREATE,IN_MOVED_TO   /root/move_TV.sh $#
"$(pwd)"/transmission/downloads/complete/Movies	IN_CREATE,IN_MOVED_TO   /root/move_MOVIES.sh "\$#"
```

