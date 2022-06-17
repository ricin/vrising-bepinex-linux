#!/bin/bash

if [ ! -f /opt/scripts/.env ];then
	echo "---  Can't find environment file /opt/scripts/.env!"
	echo "---  Copy scripts/.env.example to /opt/scripts/.env and make the appropriate changes." 
	exit
fi

. /opt/scripts/.env

dpkg --add-architecture i386 && \
	apt-get update && \
	apt -y install gnupg2 software-properties-common && \
	wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
	echo " deb https://dl.winehq.org/wine-builds/debian/ bullseye main" >> /etc/apt/sources.list.d/wine.list && \
	apt-get update && \
        apt-get -y install --no-install-recommends winehq-stable curl unzip jq lib32gcc-s1 screen xvfb winbind xauth && \
	apt-get -y --purge remove software-properties-common gnupg2 && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*


mkdir -p $DATA_DIR && \
	mkdir -p $STEAMCMD_DIR && \
	mkdir -p $SERVER_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048
