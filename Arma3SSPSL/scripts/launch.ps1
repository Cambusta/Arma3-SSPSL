param(
    [string]
    $PresetFileName,

    [switch]
    $NoKeyCopying
)

$ErrorActionPreference = "Stop"

# Global variables
$launcherParametersFile = "..\parameters.json"

# Default global values, overriden by user in parameters.json file
$a3RootPath = 'C:\Program Files (x86)\Steam\steamapps\common\Arma 3\'
$serverExeName = "arma3server_x64.exe"
$port = 2302

# Relative paths to server config files
$presetsFolder = "..\presets\"
$serverConfigPath = "..\config\server.cfg"
$basicConfigPath = "..\config\basic.cfg"
$profileName = "serverProfile"
$profilesPath = "..\profiles\"

# Arma 3 Server process names
$arma3server64ProcessName = "arma3server_x64"
$arma3serverProcessName = "arma3server"

# Include utility functions
. '.\functions.ps1'

function Launch()
{
    Set-WindowTitle

    $launcherParameters = Read-LauncherParametersFile $launcherParametersFile

    $a3RootPath = $launcherParameters.Arma3RootPath
    $serverExeName = $launcherParameters.ServerExeName
    $port = $launcherParameters.Port

    if (!(Confirm-ServerNotRunning))
    {
        Write-Host "Another server instance is already running." -BackgroundColor Yellow -ForegroundColor Black
    }

    Write-Host
    Write-Host "Reading presets..."
    
    Write-Host
    $presets = Get-PresetFiles

    if ($PresetFileName)
    {
        $preset = Select-PresetByName -PresetList $presets -PresetName $PresetFileName
    }
    else
    {
        Write-PresetList $presets

        Write-Host
        $preset = Select-PresetByIndex $presets
    }
    
    Write-Host
    $mods = Read-PresetFile $($preset.Path)
    $modParameter = Initialize-GlobalModParameter -ModNames $mods.global
    $serverModParameter = Initialize-ServerModParameter -ModNames $mods.server
    Write-OptionalMods -ModNames $mods.optional
    
    if ($NoKeyCopying -ne $true)
    {
        Write-Host
        Clear-KeysFolder
        Copy-Keys -ModNames $($mods.global + $mods.server + $mods.optional)
    }
    
    Write-Host
    Start-Server -ModParameter $modParameter -ServerModParameter $serverModParameter

    Read-ExitAction

    Write-Host
    Write-Host "Exiting." -ForegroundColor Black -BackgroundColor DarkGray
    exit
}

try {
    Launch
}
catch {
    Write-Host
    Write-Host "An error has occured" -ForegroundColor White -BackgroundColor Red -NoNewline
    Write-Host " $($_.Exception.Message)"

    Write-Host
    Write-Host "Press any key to exit."
    [console]::ReadKey()
}
