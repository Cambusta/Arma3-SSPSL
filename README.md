# Arma 3 Server Simple PowerShell Launcher

This is a simple tool that helps to start an Arma 3 Dedicated server and manage its mod presets.

## First-Time Configuration
The basic configuration requires updating several values in the following configuration files:

### .\parameters.json
1. `Arma3RootPath` should point to the directory in which Arma 3 is installed. Backslashes in the path must be doubled (e.g. 'C:\\\\Games\\\\Arma')
2. `ServerExeName` should contain the name of the server executable (e.g. 'arma3server_x64.exe')
3. `Port` should contain the port number which will be used by the server

### .\config\server.cfg
See [server.cfg description](https://community.bistudio.com/wiki/server.cfg) for details.
1. `hostname`
2. `passwordAdmin`
3. `password`

## Server Difficulty Configuration
Server difficulty settings can be configured by editing the `.\profiles\Users\serverProfile\serverProfile.Arma3Profile` file. See [server.armaprofile](https://community.bistudio.com/wiki/server.armaprofile) description for details.

View Distance and Object View Distance parameters are also configured in this file. The default values are `viewDistance=1000;` and `preferredObjectViewDistance=800;` respectively.

## Running the tool
Simply run `start.cmd` file. 

Alternatively, if you want to make use of `-PresetName` and `-NoKeyCopying` parameters, run `.\scripts\launch.ps1` file.

## Presets
Presets are simple text files placed into `.\presets\` folder. Presets contain names of the mods from Arma 3's `!Workshop` folder, without the `@` sign. Only one mod per line is allowed. For convenience, individual mods can be disabled from loading by putting the `#` sign in front of their names.

See `.\presets\CUP.txt` for an example of a preset.

## Note on Signature Verification (Key Checks)
Addon signature verification is **enabled** by default. To disable, set `verifySignatures` value to `0` at `.\config\server.cfg`. See [server.cfg description](https://community.bistudio.com/wiki/server.cfg) for details.