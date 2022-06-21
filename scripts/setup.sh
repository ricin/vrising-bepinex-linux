#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &> /dev/null && pwd 2> /dev/null)"

pushd() {
    command pushd "$@" > /dev/null
}

popd() {
    command popd "$@" > /dev/null
}

get_release()
{
	WINE_BRANCH="stable"
	LIBGCC="lib32gcc-s1"
	_refusetorun=0

	LSB_RELEASE=$(which lsb_release)
	if [ 0 -eq $? -a -x "${LSB_RELEASE}" ];then
		OS_NAME=$(${LSB_RELEASE} -si)
		OS_VERSION=$(${LSB_RELEASE} -sr)
		OS_CODENAME=$(${LSB_RELEASE} -sc)
	elif [ -f /etc/os-release ];then
		. /etc/os-release
		OS_NAME=${ID}
		OS_VERSION=${VERSION_ID}
		OS_CODENAME=${VERSION_CODENAME}
	fi

	if [ "${OS_CODENAME}" == "jammy" ] && [ ! "${FORCE_WINE_STABLE}" == "1" ];then
		WINE_BRANCH="staging"
	elif [ "${OS_CODENAME}" == "buster" ] || [ "${OS_CODENAME}" == "bionic" ];then
		LIBGCC="lib32gcc1"
	fi
	
	if [ "${OS_NAME}" == "" ] || [ "${OS_VERSION}" == "" ] || [ "${OS_CODENAME}" == "" ];then
		_refusetorun=1
	elif [ "${OS_NAME,,}" != "debian" ] && [ "${OS_NAME,,}" != "ubuntu" ];then
		_refusetorun=1
	fi
	if [ ${_refusetorun} == 1 ];then
		echo "--- Unable to determine OS distro. This will run on recent versions of Debian/Ubuntu"
		exit 1
	fi
}

run_checks()
{
	if [[ $(id -u) -ne 0 ]];then
		echo "---  Setup must run as root!"
		exit 1
	fi

	get_release

	echo "---  Found OS ${OS_NAME} ${OS_VERSION} (${OS_CODENAME})"

}

run_checks

pushd ${SCRIPT_DIR}

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
	exit 1
fi

. /opt/scripts/.env
echo "---  Installing packages"
	wget -nc -q https://dl.winehq.org/wine-builds/winehq.key -O /usr/share/keyrings/winehq-archive.key && \
	wget -nc -q https://dl.winehq.org/wine-builds/${OS_NAME,,}/dists/${OS_CODENAME,,}/winehq-${OS_CODENAME,,}.sources \
		-P /etc/apt/sources.list.d/

echo "samba-common samba-common/dhcp boolean true" | debconf-set-selections
dpkg --add-architecture i386 && \
	apt-get update && \
        apt-get -y install --no-install-recommends winehq-${WINE_BRANCH} \
	curl unzip jq xvfb winbind xauth rsync ${LIBGCC}
	
if [ $? -ne 0 ];then
	echo -e "\n\n---  Package installation failed. Please correct errors and try again.\n"
	if [ "${WINE_BRANCH}" != "stable" ];then
		echo -e "---  Note that the '${WINE_BRANCH}' branch of wine is selected for ${OS_NAME} ${OS_VERSION} (${OS_CODENAME})\n"
		echo -e "---  This means wine may not install or work.\n"
		echo -e "---  See: https://wiki.winehq.org/${OS_NAME}\n\n"
		echo -e "---  Searching for stable ...\n"
		apt-get install -s winehq-stable
		echo -e "\n\n---  If the winehq-stable package is listed above you can rerun this script like the following to force selecting the stable package:\n"
		echo -e "FORCE_WINE_STABLE=1 ${0}\n"
	fi
	exit 1
fi

apt-get -y autoremove && \
rm -rf /var/lib/apt/lists/*

if [ $? -eq 1 ];then
	echo "---  Package installation failed. Please correct errors and try again."
	exit 1
fi

echo -e "\n\n\n"
echo "---  Creating directories and setting permissions"
mkdir -p ${DATA_DIR} && \
	mkdir -p ${STEAMCMD_DIR} && \
	mkdir -p ${SERVER_DIR} && \
	if ! id "${USER}" >/dev/null 2>&1;then groupadd -f -g ${S_GID} ${USER} && useradd -u ${S_UID} -g ${S_GID} -d ${DATA_DIR} -s /bin/bash ${USER};fi && \
	chown -R ${USER} ${DATA_DIR}

popd

echo -e "\n\n---  Run /opt/scripts/start.sh to start the server\n\n"
