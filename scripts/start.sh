#!/bin/bash

run_checks()
{
	if [[ $(id -u) -ne 0 ]];then
		echo "---  This must run as root!"
		exit 1
	fi
}

run_checks

pushd /opt/scripts > /dev/null

if [ ! -f /opt/scripts/.env ];then
	echo "---  Can't find environment file /opt/scripts/.env!"
	exit 1
fi

. /opt/scripts/.env

if ! id "${USER}" >/dev/null 2>&1;then
    echo "--- User '${USER}' not found. Did you run setup.sh?"
    exit 1
fi
	
echo "---  Ensuring UID: ${S_UID} matches user"
usermod -u ${S_UID} ${USER}
echo "---  Ensuring GID: ${S_GID} matches user"
groupmod -g ${S_GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${S_GID} ${USER}
echo "---  Setting umask to ${UMASK}"
umask ${UMASK}

echo "---  Checking for optional scripts"
cp -f /opt/custom/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:
cp -f /opt/scripts/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:

if [ -f /opt/scripts/start-user.sh ]; then
    echo "---  Found optional script, executing"
    chmod -f +x /opt/scripts/start-user.sh.sh ||:
    /opt/scripts/start-user.sh || echo "---  Optional Script has thrown an Error"
else
    echo "---  No optional script found, continuing"
fi

echo "---  Taking ownership of data..."
chown -R root:${S_GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${S_UID}:${S_GID} ${DATA_DIR}
mkdir -p ${SERVER_DIR}/logs
chown -R ${S_UID}:${S_GID} ${SERVER_DIR}
chmod -R 750 ${SERVER_DIR}/logs

echo "---  Starting..."

su ${USER} -c "/opt/scripts/start-server.sh"