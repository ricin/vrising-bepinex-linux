# SteamCMD install of V Rising
This will download and install SteamCMD. It will also install V Rising and run it.

**Save Files:** The save files are located in: .../save-data/Saves

**Config Files:** The config files are located in: .../save-data/Settings

**ATTENTION:** First Startup can take very long since it downloads the gameserver files!



## Example Env params

Environment variables are in /opt/scripts/.env

| Name | Value | Example |
| --- | --- | --- |
| STEAMCMD_DIR | Folder for SteamCMD | /serverdata/steamcmd |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| GAME_ID | The GAME_ID that the container downloads at startup. If you want to install a static or beta version of the game change the value to: '1829350 -beta YOURBRANCH' (without quotes, replace YOURBRANCH with the branch or version you want to install). | 1829350 |
| SERVER_NAME | Enter your preferred server name. | V Rising Docker |
| WORLD_NAME | Enter your prefered world name. | world1 |
| GAME_PARAMS | Enter additional game startup parameters if needed, otherwise leave empty. | empty |
| ENABLE_BEPINEX | If you want to enable BepInEx for V Rising set this variable to 'true' (without quotes). For more help please refer to this site: [Click](https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/) | empty |
| UID | User Identifier | 1001 |
| GID | Group Identifier | 1001 |
| GAME_PORT | Port the server will be running on | 27015 |
| VALIDATE | Validates the game data | true |
| USERNAME | Leave blank for anonymous login | blank |
| PASSWRD | Leave blank for anonymous login | blank |


## Setup

**This is for Debian 11 only for now.**

Run `scripts/setup.sh` to prepare the server.

Copy `scripts/.env.example` to `/opt/scripts/.env` and edit with your desired settings.

## Running

Run `/opt/scripts/start.sh` to start the server. It's recommended to run this within screen, or tmux.

V Rising configuration files will be in `/serverdata/serverfiles/save-data/Settings`.

## TODO

- Use a systemd service


---
This is a modification of https://github.com/ich777/docker-steamcmd-server/tree/vrising to run without docker
