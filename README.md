# Arma 3 Server Simple PowerShell Launcher

![Arma 3 Server Simple PowerShell Launcher screenshot](https://raw.githubusercontent.com/Cambusta/Arma3-SSPSL/master/screenshot.png)

This is a simple tool that helps to start an Arma 3 Dedicated server and manage its mod presets.

SSPSL comes complete with configuration files so running a dedicated server is as simple as downloading the tool, adjusting few values in two files and double-clicking the `start.cmd`.

## Installation
1. Click "Clone or download" button at the top right corner to download this repository as a ZIP archive.
2. Unarchive `Arma3SSPSL` folder to location of your choice.

## Сonfiguration
The basic configuration requires updating several values in the following configuration files:

### .\parameters.json
1. `Arma3RootPath` should point to the directory in which Arma 3 is installed. Backslashes in the path must be doubled (e.g. 'C:\\\\Games\\\\Arma')
2. `ServerExeName` should contain the name of the server executable (e.g. 'arma3server_x64.exe')
3. `Port` should contain the port number which will be used by the server (default `2302` value will work most of the time)
4. (optional) `Webhook` section contains [Discord webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)'s `Id` and `Token`. This will be used to post Arma server address, port and list of mods to the Discord channel to which webhook is attached to. `Enabled` parameter determines if the webhook gets executed. 

### .\config\server.cfg
See [server.cfg description](https://community.bistudio.com/wiki/server.cfg) for details.
1. `hostname` - name of the server visible in the game browser 
2. `passwordAdmin` - password to protect admin access (protip: type `#login <passwordAdmin>` in game chat to login as admin and then `#missions` to open the mission selection screen) 
3. `password` - password required to connect to server

## Running the tool
Simply run `start.cmd` file. 

> ⚠ **Note on Windows security**
>
> Upon running the `start.cmd` for the first time, a "Windows protected your PC" dialog may appear. If it does, click "More info" and then "Run anyway" button.
>
> You may also get a "Security warning" in the console output. If you do, close the console window, navigate to `.\scripts\` folder and open Properties of `launch.ps1` and `functions.ps1` files. For both files, on the "General" tab under "Security" category check the "Unblock" check box and click "Ok". 
>
> Run the `start.cmd` again.

Alternatively, if you want to make use of `-PresetName` and `-NoKeyCopying` parameters, run `.\scripts\launch.ps1` file.

## Presets
Presets are simple text files placed into `.\presets\` folder. Presets contain names of the mods from Arma 3's `!Workshop` folder, without the `@` sign. Only one mod per line is allowed, empty lines are ignored. 
* Use `$` at the beginning of a line to indicate that a mod is server-side.
* Use `*` at the beginning of a line to indicate that a mod is optional.
* Use `#` for comments or disabling mods.

See `.\presets\CUP.txt` for an example of a preset.

## Server Difficulty Configuration
Server difficulty settings can be configured by editing the `.\profiles\Users\serverProfile\serverProfile.Arma3Profile` file. See [server.armaprofile](https://community.bistudio.com/wiki/server.armaprofile) description for details.

View Distance and Object View Distance parameters are also configured in this file. The default values are `viewDistance=1000;` and `preferredObjectViewDistance=800;` respectively.

## Note on Signature Verification (Key Checks)
Addon signature verification is **enabled** by default. To disable, set `verifySignatures` value to `0` at `.\config\server.cfg`. See [server.cfg description](https://community.bistudio.com/wiki/server.cfg) for details.
