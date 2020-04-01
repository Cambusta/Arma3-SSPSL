function Start-Server()
{
    param(
        $ModParameter,
        $ServerModParameter
    )

    $serverNameParameter = "-name=$profileName"
    $portParameter = "-port=$port"

    $serverExePath = Join-Path $a3RootPath $serverExeName
    $serverConfigParameter = '"-config=' + $(Resolve-Path $serverConfigPath) + '"'
    $basicConfigParameter = '"-cfg=' + $(Resolve-Path $basicConfigPath) +'"'
    $profilesParameter = '"-profiles=' + $(Resolve-Path $profilesPath) + '"'

    Write-Host "Starting server at $port..."

    $argumentList = @($serverNameParameter, $portParameter, $basicConfigParameter, $serverConfigParameter, $profilesParameter)

    if ($ModParameter)
    {
        $argumentList += $ModParameter
    }

    if ($ServerModParameter)
    {
        $argumentList += $ServerModParameter
    }

    Start-Process -FilePath $serverExePath -ArgumentList $argumentList

    Write-Host "Server started." -ForegroundColor Black -BackgroundColor Green
    Write-Host
}

function Read-LauncherParametersFile {
    param (
        [Parameter(Mandatory=$true)]
        $FilePath
    )
    
    if (!(Test-Path $FilePath))
    {
        throw "Expected launcher parameters file at $FilePath, but none found."
    }

    $parameters = ConvertFrom-Json $(Get-Content $FilePath -Raw)

    if (!($parameters.Arma3RootPath) -or !(Test-Path $parameters.Arma3RootPath))
    {
        throw "Launcher parameters: Arma3RootPath not set or invalid."
    }

    if (!($parameters.ServerExeName) -or !(Test-Path $(Join-Path $parameters.Arma3RootPath $parameters.ServerExeName)))
    {
        throw "Launcher parameters: ServerExeName not set or invalid."
    }

    if (!($parameters.Port) -or ($parameters.Port -isnot [int]))
    {
        throw "Launcher parameters: Port value not set or invalid."
    }

    return $parameters
}
function Clear-KeysFolder()
{
    Write-Host "Purging keys folder..."

    $keysPath = Join-Path $a3RootPath "\Keys\"
    $keys = Get-ChildItem $keysPath -Exclude @('a3.bikey', 'a3c.bikey', 'gm.bikey')

    if ($keys.Length -eq 0)
    {
        return
    }

    foreach($keyfile in $keys)
    {
        Remove-Item $keyfile.FullName -Force
    }
}

function Copy-Keys()
{
    param(
        [Parameter(Mandatory=$true)]
        $ModNames
    )

    Write-Host "Copying mod keys..."

    $duplicateId = 1;
    $keysPath = Join-Path $a3RootPath "\Keys\"

    foreach($mod in $mods)
    {
        $relativePath = "!Workshop\@$mod"
        $absolutePath = (Join-Path $a3RootPath $relativePath)

        if (Test-Path $absolutePath)
        {
            $bikey = Get-ChildItem -Path $absolutePath -Filter "*.bikey" -Recurse

            if($bikey)
            {
                $name = $bikey.Name
                $destinationHasKey = Get-ChildItem -Path $keysPath -Filter $bikey.Name -Recurse

                if ($destinationHasKey)
                {
                    $name = $bikey.BaseName + "_$duplicateId" + $bikey.Extension
                    $duplicateId++
                }

                $destination = Join-Path $keysPath $name

                Copy-Item -Path $bikey.FullName -Destination $destination | Out-Null
            }
            else 
            {
                Write-Host "[Invalid bikey path]: unable to find .bikey file for $mod."
            }
        }
    }
}

function Initialize-GlobalModParameter()
{
    param(
        [Parameter(Mandatory=$true)]
        $ModNames
    )

    if ($ModNames)
    {
        $modPaths = Initialize-ModList $ModNames
        return "-mod=$modPaths"
    }

    return $null
}

function Initialize-ServerModParameter()
{
    param(
        [Parameter(Mandatory=$true)]
        $ModNames
    )

    if ($ModNames)
    {
        $modPaths = Initialize-ModList $ModNames -ServerMods
        return "-servermod=$modPaths"
    }

    return $null
}

function Initialize-ModList
{
    param(
        [Parameter(Mandatory=$true)]
        $ModNames,

        [Switch]
        $ServerMods
    )

    $modlist = '"'

    foreach($mod in $ModNames)
    {
        $relativePath = "!Workshop\@$mod"

        if (Test-Path (Join-Path $a3RootPath $relativePath))
        {

            if ($ServerMods)
            {
                Write-Host "$mod (server-side)" -ForegroundColor DarkGreen
            }
            else 
            {
                Write-Host "$mod" -ForegroundColor Green
            }

            $modPath = Get-SymlinkTarget -SymlinkPath $relativePath
            $modlist = $modlist + "$modPath;"
        }
        else 
        {
            Write-Host "[Invalid mod path]: $mod expected folder at $relativePath but none found. Skipping." -ForegroundColor Yellow
        }
    }

    $modlist = $modlist + '"'

    return $modlist
}

function Get-SymlinkTarget()
{
    param(
        [Parameter(Mandatory=$true)]
        $SymlinkPath
    )

    $targetPath = Get-Item (Join-Path $a3RootPath $SymlinkPath) | Select-Object -ExpandProperty Target

    if (!(Test-Path $targetPath))
    {
        throw "Error while expanding symlink '$SymlinkPath': target path '$targetPath' doesn't exist."
    }

    return $targetPath
}

function Get-PresetFiles()
{
    $index = 1;
    $presets = @()

    $presetFiles = Get-ChildItem -Path $presetsFolder -Filter "*.txt"

    if ($presetFiles.Length -eq 0)
    {
        throw "No preset files found."
    }

    foreach($file in $presetFiles)
    {
        $presets += @{
            Index = $index
            Name = $file.Name
            Path = $file.FullName
        }

        $index++
    }

    return $presets
}

function Write-PresetList()
{
    param(
        [Parameter(Mandatory=$true)]
        $Presets
    )

    foreach($preset in $presets)
    {
        Write-Host "$($preset.Index). $($preset.Name)" -ForegroundColor Green
    }
}

function Read-SelectedPreset()
{
    param(
        [Parameter(Mandatory=$true)]
        $Presets
    )

    if ($Presets.Length -eq 1)
    {
        Write-Host "Auto-selecting $($Presets.Name)..."
        return $Presets
    }

    $indexes = $Presets | ForEach-Object {$_.Index}

    $validIndex = $false;

    do 
    {
        $presetInput = Read-Host -Prompt "Select preset"

        try
        {
            $presetIndex = [int]$presetInput

            if ($indexes.Contains($presetIndex))
            {
                $validIndex = $true
            }
            else 
            {
                Write-Host "Invalid preset index." -ForegroundColor Red
            }
        }
        catch
        {
            Write-Host "Invalid input." -ForegroundColor Red
        }
    } while ($validIndex -ne $true)

    $selectedPreset = $Presets | Where-Object {$_.Index -eq $presetIndex}

    Write-Host
    Write-Host "Selected $($selectedPreset.Name)" -ForegroundColor Green
    return $selectedPreset
}

function Read-ExitAction()
{
    $done = $false

    do {
        Write-Host "Press [Enter] to exit or [R] to open RPT file: " -NoNewline
        $input = [console]::ReadKey()
    
        if ($input.Key -eq 'R')
        {
            Open-LatestRptFile
            $done = $true
        }

        if ($input.Key -eq "Enter")
        {
            $done = $true
        }

        Write-Host

    } until ($done)
}

function Read-PresetFile()
{
    param(
        [Parameter(Mandatory=$true)]
        $Modfile 
    )

    $skipped = 0

    $mods = @{
        global = @()
        server = @()
    }

    $content = Get-Content -Path $Modfile

    foreach ($line in $content)
    {
        if ([string]::IsNullOrEmpty($line))
        {
            continue
        }

        if ($line[0] -eq '#')
        {
            $skipped++
            continue
        }

        if ($line[0] -eq '$')
        {
            $name = $line.substring(1)
            $mods.server += $name.Trim()
        }
        else
        {
            $mods.global += $line.Trim()
        }
    }

    Write-Host "Read $($mods.global.Count) global mods, $($mods.server.Count) server mods, $skipped skipped."

    return $mods
}

function Open-LatestRptFile()
{
    $latestRptFile = Get-ChildItem $profilesPath -Filter "*.rpt" `
                        | Sort-Object LastWriteTime -Descending `
                        | Select-Object -First 1

    Write-Host "Opening $($latestRptFile.FullName)"

    Invoke-Item $($latestRptFile.FullName)
}

function Confirm-ServerNotRunning()
{
    $serverProcesses = @($arma3server64ProcessName, $arma3serverProcessName)

    foreach($p in $serverProcesses)
    {
        $process = Get-Process $p -ErrorAction SilentlyContinue

        if ($process)
        {
            return $false
        }
    }

    return $true
}