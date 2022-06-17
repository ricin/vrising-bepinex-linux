#!/bin/bash

# only debian 11 for now

version_check()
{
	_refusetorun=0
	if [ -f /etc/debian_version ];then
		debian_version=$(cat /etc/debian_version) 
		if [[ ! "${debian_version}" =~ ^11.* ]];then
			_refusetorun=1
		fi
	else
		_refusetorun=1
	fi
	if [ ${_refusetorun} == "1" ];then
		echo "-- This only supports Debian 11 for now"
		exit 1
	else
		echo "--- Found Debian ${debian_version}"
	fi
}

version_check

mkdir -p /opt/scripts/

if [ ! -f /opt/scripts/start.sh ] || [ ! -f /opt/scripts/start-server.sh ] || [ ! -f /opt/scripts/start-watchdog.sh ];then
	cp ../scripts/start.sh ../scripts/start-watchdog.sh ../scripts/start-server.sh /opt/scripts/
fi

if [ ! -f /opt/scripts/.env ];then
	echo "---  Can't find environment file /opt/scripts/.env!"
	echo "---  Copy scripts/.env.example to /opt/scripts/.env and make the appropriate changes." 
	exit
fi

. /opt/scripts/.env

echo "--- Installing packages"
dpkg --add-architecture i386 && \
	apt-get update && \
        apt-get -y install --no-install-recommends winehq-stable \
		curl unzip jq lib32gcc-s1 screen xvfb winbind xauth \
		gnupg2 software-properties-common && \
	wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
	echo " deb https://dl.winehq.org/wine-builds/debian/ bullseye main" >> /etc/apt/sources.list.d/wine.list && \
	apt-get -y --purge remove software-properties-common gnupg2 && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

echo "-- Creating directories and setting permissions"
mkdir -p $DATA_DIR && \
	mkdir -p $STEAMCMD_DIR && \
	mkdir -p $SERVER_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048
