#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

# only debian 11 for now
run_checks()
{
	_refusetorun=0
	
	if [[ $(id -u) -ne 0 ]];then
		echo "---  Setup must run as root!"
		exit 1
	fi

	if [ -f /etc/debian_version ];then
		debian_version=$(cat /etc/debian_version) 
		if [[ ! "${debian_version}" =~ ^11.* ]];then
			_refusetorun=1
		fi
	else
		_refusetorun=1
	fi
	if [ ${_refusetorun} == "1" ];then
		echo "---  This only supports Debian 11 for now"
		exit 1
	else
		echo "---  Found Debian ${debian_version}"
	fi
}

run_checks

mkdir -p /opt/{scripts,words}

if [ ! -f /opt/scripts/start.sh ] || [ ! -f /opt/scripts/start-server.sh ] || [ ! -f /opt/scripts/start-watchdog.sh ];then
	cp ${SCRIPT_DIR}/start.sh ${SCRIPT_DIR}/start-watchdog.sh ${SCRIPT_DIR}/start-server.sh /opt/scripts/
fi

if [ ! -f /opt/words/bosses ] || [ ! -f /opt/words/adjectives ];then
	cp ${SCRIPT_DIR}/../words/* /opt/words/
fi

if [ ! -f /opt/scripts/.env ];then
	echo "---  Can't find environment file /opt/scripts/.env!"
	echo "---  Creating default"
	cp ${SCRIPT_DIR}/.env.example /opt/scripts/.env
	echo "---  Edit /opt/scripts/.env if you'd like to change the defaults then run setup.sh again." 
	exit
fi

. /opt/scripts/.env
echo "---  Installing packages"
dpkg --add-architecture i386 && \
	apt-get update && \
		apt-get -y install --no-install-recommends gnupg2 software-properties-common && \
	wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
	echo " deb https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/wine.list && \
	apt-get update && \
        apt-get -y install --no-install-recommends winehq-stable \
		curl unzip jq lib32gcc-s1 screen xvfb winbind xauth rsync && \
	apt-get -y --purge remove software-properties-common gnupg2 && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

echo -e "\n\n\n"
echo "---  Creating directories and setting permissions"
mkdir -p $DATA_DIR && \
	mkdir -p $STEAMCMD_DIR && \
	mkdir -p $SERVER_DIR && \
	if ! id "$USER" >/dev/null 2>&1; then useradd -d $DATA_DIR -s /bin/bash $USER;fi && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048


echo -e "\n\n---  Run /opt/scripts/start.sh to start the server\n\n"
