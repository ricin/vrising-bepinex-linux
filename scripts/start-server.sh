#!/bin/bash
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

if [ "${ENABLE_BEPINEX}" == "true" ]; then
    export WINEDLLOVERRIDES="winhttp=n,b"
    BEPINEX_VR_TS_URL=https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/
    echo "---BepInEx for V Rising enabled!---"
    CUR_V="$(find ${SERVER_DIR} -maxdepth 1 -name "BepInEx-*" | cut -d '-' -f2)"
    BEPINEX_VR_API_DATA="$(curl -s -X GET https://thunderstore.io/c/v-rising/api/v1/package/b86fcaaf-297a-45c8-82a0-fcbd7806fdc4/ -H "accept: application/json")"
    LAT_V="$(echo ${BEPINEX_VR_API_DATA} | jq -r '.versions[0].version_number')"

    if [ -z "${LAT_V}" ] && [ -z "${CUR_V}" ]; then
        echo "---Can't get latest version of BepInEx for V Rising!---"
        echo "---Please try to run the Container without BepInEx for V Rising, putting Container into sleep mode!---"
        sleep infinity
    fi

    if [ -f ${SERVER_DIR}/BepInEx.zip ]; then
	    rm -rf ${SERVER_DIR}/BepInEx.zip
    fi
    if [ -f ${SERVER_DIR}/doorstop_config.ini ]; then
        sed -i "/enabled=false/c\enabled=true" ${SERVER_DIR}/doorstop_config.ini
    fi

    echo "---BepInEx for V Rising Version Check---"
    echo
    echo "---${BEPINEX_VR_TS_URL}---"
    echo

    BEPINEX_VR_TS_DOWNLOAD_URL="$(echo ${BEPINEX_VR_API_DATA} | jq -r '.versions[0].download_url')"
    if [ -z "${CUR_V}" ]; then
        echo "---BepInEx for V Rising not found, downloading and installing v${LAT_V}...---"
        cd ${SERVER_DIR}
        rm -rf ${SERVER_DIR}/BepInEx-*
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${BEPINEX_VR_TS_DOWNLOAD_URL}" ; then
            echo "---Successfully downloaded BepInEx for V Rising v${LAT_V}---"
        else
            echo "---Something went wrong, can't download BepInEx for V Rising v${LAT_V}, putting container into sleep mode!---"
            sleep infinity
        fi
        mkdir -p /tmp/BepInEx
        unzip -o ${SERVER_DIR}/BepInEx.zip -d /tmp/BepInEx
        if [ $? -eq 0 ];then
            touch ${SERVER_DIR}/BepInEx-${LAT_V}
            cp -rf /tmp/BepInEx/BepInEx*/* ${SERVER_DIR}/
            cp /tmp/BepInEx/README* ${SERVER_DIR}/README_BepInEx_for_VRising.txt
            rm -rf ${SERVER_DIR}/BepInEx.zip /tmp/BepInEx
        else
            echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
            sleep infinity
        fi
    elif [ "$CUR_V" != "${LAT_V}" ]; then
        echo "---Version missmatch, BepInEx v$CUR_V installed, downloading and installing v${LAT_V}...---"
        cd ${SERVER_DIR}
        rm -rf ${SERVER_DIR}/BepInEx-$CUR_V
        mkdir /tmp/Backup
        cp -R ${SERVER_DIR}/BepInEx/config /tmp/Backup/
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/BepInEx.zip --user-agent=Mozilla --content-disposition -E -c "${BEPINEX_VR_TS_DOWNLOAD_URL}" ; then
            echo "---Successfully downloaded BepInEx for V Rising v${LAT_V}---"
        else
            echo "---Something went wrong, can't download BepInEx for V Rising v${LAT_V}, putting container into sleep mode!---"
            sleep infinity
        fi
        unzip -o ${SERVER_DIR}/BepInEx.zip -d /tmp/BepInEx 
        if [ $? -eq 0 ];then
            cp -rf /tmp/BepInEx/BepInEx*/* ${SERVER_DIR}/
            cp /tmp/BepInEx/README* ${SERVER_DIR}/README_BepInEx_for_VRising.txt
            touch ${SERVER_DIR}/BepInEx-${LAT_V}
            cp -R /tmp/Backup/config ${SERVER_DIR}/BepInEx/
            rm -rf ${SERVER_DIR}/BepInEx.zip /tmp/BepInEx /tmp/Backup
        else
            echo "---Unable to unzip BepInEx archive! Putting container into sleep mode!---"
            sleep infinity
        fi
    elif [ "${CUR_V}" == "${LAT_V}" ]; then
        echo "---BepInEx v$CUR_V up-to-date---"
    fi
else
    if [ -f ${SERVER_DIR}/doorstop_config.ini ]; then
        sed -i "/enabled=true/c\enabled=false" ${SERVER_DIR}/doorstop_config.ini
    fi
    echo "---BepInEx for V Rising disabled!---"
fi

export WINEARCH=win64
export WINEPREFIX=/serverdata/serverfiles/WINE64
echo "---Checking if WINE workdirectory is present---"
if [ ! -d ${SERVER_DIR}/WINE64 ]; then
	echo "---WINE workdirectory not found, creating please wait...---"
    mkdir ${SERVER_DIR}/WINE64
else
	echo "---WINE workdirectory found---"
fi
echo "---Checking if WINE is properly installed---"
if [ ! -d ${SERVER_DIR}/WINE64/drive_c/windows ]; then
	echo "---Setting up WINE---"
    cd ${SERVER_DIR}
    winecfg > /dev/null 2>&1
    sleep 15
else
	echo "---WINE properly set up---"
fi
if [ ! -d ${SERVER_DIR}/save-data/Settings ]; then
  mkdir -p ${SERVER_DIR}/save-data
  cp -R ${SERVER_DIR}/VRisingServer_Data/StreamingAssets/Settings ${SERVER_DIR}/save-data
fi
echo "---Checking for old display lock files---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine64 ${SERVER_DIR}/VRisingServer.exe -persistentDataPath ${SERVER_DIR}/save-data -serverName "${SERVER_NAME}" -saveName "${WORLD_NAME}" -logFile ${SERVER_DIR}/logs/VRisingServer.log ${GAME_PARAMS} >/dev/null 2>&1 &
sleep 5
/opt/scripts/start-watchdog.sh &
tail -n +0 -f ${SERVER_DIR}/logs/VRisingServer.log
