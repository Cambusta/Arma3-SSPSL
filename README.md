# Arma 3 Server Simple PowerShell Launcher

![Arma 3 Server Simple PowerShell Launcher screenshot](https://raw.githubusercontent.com/Cambusta/Arma3-SSPSL/master/screenshot.png)

This is a no-nonsense script that just starts your Arma 3 Dedicated server and helps to manage its mod presets.

It comes complete with configuration files so running a dedicated server is as simple as downloading the tool, adjusting few values in two files and double-clicking the `start.cmd`.

## Installation
1. [Download](https://github.com/Cambusta/Arma3-SSPSL/archive/master.zip) this repository as a ZIP archive.
2. Open the archive and unpack the `Arma3SSPSL` folder to a location of your choice.
3. Open PowerShell console and execute `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser` command to allow script execution.

## Сonfiguration
The basic configuration requires updating six values in the two following configuration files:

### [\parameters.json](https://github.com/Cambusta/Arma3-SSPSL/blob/master/Arma3SSPSL/parameters.json)
1. `Arma3RootPath` should point to the directory in which Arma 3 is installed. Backslashes in the path must be doubled (e.g. `C:\\Games\\Arma`)
2. `ServerExeName` should contain the name of the server executable (e.g. `arma3server_x64.exe`)
3. `Port` should contain the port number which will be used by the server (default `2302` value will work most of the time)

> 🎣 **Discord Webhook (optional)**
>
> `Webhook` section contains [Discord webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) `Id` and `Token` configuration. If `Enabled` is set to `true`, the launcher will post server's address, port and list of mods to the Discord channel to which webhook is attached.

### [\config\server.cfg](https://github.com/Cambusta/Arma3-SSPSL/blob/master/Arma3SSPSL/config/server.cfg)
1. `hostname` - name of the server visible in the game browser 
2. `passwordAdmin` - password to protect admin access (protip: type `#login <passwordAdmin>` in game chat to login as admin and then `#missions` to open the mission selection screen) 
3. `password` - password required to connect to server

See [biki server.cfg article](https://community.bistudio.com/wiki/server.cfg) for details.

## Mod Presets
Presets are simple text files placed into [`\presets\`](https://github.com/Cambusta/Arma3-SSPSL/tree/master/Arma3SSPSL/presets) folder. Presets contain names of the mods from Arma 3's `!Workshop` folder, without the `@` sign. Only one mod per line is allowed, empty lines are ignored. 
* Use `$` at the beginning of a line to indicate that a mod is server-side.
* Use `*` at the beginning of a line to indicate that a mod is optional.
* Use `#` for comments or disabling mods.

### Creator DLCs
To enable a CDLC simply add its directory name to your preset file, just as you would add a regular mod. The CDLC must be installed for it to be enabled. Following CDLCs are supported:
1. `gm` - Global Mobilization
2. `vn` - S.O.G. Paire Fire
3. `ws` - Western Sahara
4. `cslr` - CLSA Iron Curtain

See [`\presets\CUP.txt`](https://github.com/Cambusta/Arma3-SSPSL/blob/master/Arma3SSPSL/presets/CUP.txt) for an example of a preset.

## Launching the server
Simply run the `start.cmd` file and follow prompts.

> ⚠ **Note on Windows security**
>
> Upon running the `start.cmd` for the first time, a "Windows protected your PC" dialog may appear. If it does, click **More info** and then **Run anyway** button.
>
> You may also get a "Security warning" message in the console output. If you do, close the console window, navigate to `\scripts\` folder and open **Properties** window from the context menu of `launch.ps1` and `functions.ps1` files. In **Properties** windows of both files, on the **General** tab under **Security** category check the **Unblock** check box and click "Ok". 
>
> Run the `start.cmd` again.

Alternatively, if you want to make use of `-PresetName` and `-NoKeyCopying` parameters, run `\scripts\launch.ps1` file manually. Note that `-PresetName` parameter requires file name with an extension.

## Server Difficulty Configuration
Server difficulty settings can be configured by editing the [`\profiles\Users\serverProfile\serverProfile.Arma3Profile`](https://github.com/Cambusta/Arma3-SSPSL/blob/master/Arma3SSPSL/profiles/Users/serverProfile/serverProfile.Arma3Profile) file. See [biki server.armaprofile article](https://community.bistudio.com/wiki/server.armaprofile) description for details.

View Distance and Object View Distance parameters are also configured in this file. The default values are `viewDistance=1000;` and `preferredObjectViewDistance=800;` respectively.

## Note on Signature Verification (Key Checks)
Addon signature verification is **enabled** by default. This means everyone connecting to the server will be required to have the exact mods as the preset which server is running, aside from the mods that are indicated as optional in the preset. People running mods that aren't listed in the preset or mods that are listed but outdated will not be allowed to connect.

To disable this, set `verifySignatures` value to `0` at [`\config\server.cfg`](https://github.com/Cambusta/Arma3-SSPSL/blob/master/Arma3SSPSL/config/server.cfg). See [biki server.cfg article](https://community.bistudio.com/wiki/server.cfg) for details.
