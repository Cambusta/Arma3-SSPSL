param(
    [string]
    $PresetFileName,

    [switch]
    $NoKeyCopying
)

$ErrorActionPreference = "Stop"

$a3RootPath = 'D:\SteamLibrary\steamapps\common\Arma 3\'
$serverExePath = Join-Path $a3RootPath 'arma3server_x64.exe'
$presetsFolder = "..\presets\"
$serverConfigPath = "..\config\server.cfg"
$basicConfigPath = "..\config\basic.cfg"
$profileConfigPath = "..\config\Users\serverProfile\"
$port = 2302

# Include utility functions
. '.\functions.ps1'

function Launch()
{
    Write-Host
    Write-Host "Reading presets..."
    
    Write-Host
    $presets = Read-Presets

    if ($PresetFileName)
    {
        $preset = $presets | Where-Object { $_.Name -eq $PresetFileName }

        if ($null -eq $preset)
        {
            throw "Invalid preset name '$PresetFileName'"
        }
    }
    else
    {
        Print-Presets $presets

        Write-Host
        $preset = Prompt-PresetSelection $presets
    }
    
    Write-Host
    $mods = Read-PresetFile $($preset.Path)
    $modsParameter = Compile-ModsParameter -ModNames $mods
    
    if ($NoKeyCopying -ne $true)
    {
        Write-Host
        Clear-KeysFolder
        Copy-Keys -ModNames $mods
    }
    
    Write-Host
    Start-Server -ModsParameter $modsParameter
}

try {
    Launch
}
catch {
    Write-Host "An error has occured" -ForegroundColor White -BackgroundColor Red
    Write-Host "$($_.Exception.GetType().FullName): " -ForegroundColor White -BackgroundColor Red -NoNewline
    Write-Host $_.Exception.Message
}
