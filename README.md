# V Rising Dedicated Server via SteamCMD
This will download, install, and run V Rising Dedicated Server via SteamCMD.

Optionally it will download the latest [BepInEx Pack for V Rising](https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/), and enable it.

**Save Files:** The save files are located in: `${SERVER_DIR}/save-data/Saves`

**Config Files:** The config files are located in: `${SERVER_DIR}/save-data/Settings`

**ATTENTION:** First Startup can take very long since it downloads the game server files!

## Example Env variables

Environment variables are in /opt/scripts/.env

| Name | Value | Example/Default |
| --- | --- | --- |
| DATA_DIR | Base data directory | /serverdata |
| STEAMCMD_DIR | Folder for SteamCMD | ${DATA_DIR}/steamcmd |
| SERVER_DIR | Folder for game files | ${DATA_DIR}/serverfiles |
| GAME_ID | The GAME_ID that is downloaded at startup. If you want to install a static or beta version of the game change the value to: '1829350 -beta YOURBRANCH' (without quotes, replace YOURBRANCH with the branch or version you want to install). | 1829350 |
| SERVER_NAME | Enter your preferred server name. A unique server name will be generated upon first run | empty |
| WORLD_NAME | Enter your prefered world name. Defaults to `world1` from `${SERVER_DIR}/save-data/Settings/ServerHostSettings.json` | empty |
| GAME_PARAMS | Enter additional game startup parameters if needed, otherwise leave empty. | empty |
| ENABLE_BEPINEX | If you want to enable BepInEx for V Rising set this variable to 'true' (without quotes). For more help please refer to this site: [Click](https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/) | empty |
| UID | User Identifier | 1001 |
| GID | Group Identifier | 1001 |
| VALIDATE | Validates the game data | true |
| USERNAME | Leave blank for anonymous login | blank |
| PASSWRD | Leave blank for anonymous login | blank |


## Setup

**Debian/Ubuntu supported**

Run `scripts/setup.sh` to prepare the server.

## Running

Run `/opt/scripts/start.sh` to start the server.

A unique server name and password will be generated upon first run. 
You can change them in `${SERVER_DIR}/save-data/Settings/ServerHostSettings.json`

## TODO

- Use a systemd service


---
This is a modification of https://github.com/ich777/docker-steamcmd-server/tree/vrising to run without docker
