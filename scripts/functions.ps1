function Start-Server()
{
    param(
        [Parameter(Mandatory=$true)]
        $ModsParameter
    )

    $serverNameParameter = "-name=serverProfile"
    $portParameter = "-port=$port"

    $serverConfigParameter = '"-config=' + $(Resolve-Path $serverConfigPath) + '"'
    $basicConfigParameter = '"-cfg=' + $(Resolve-Path $basicConfigPath) +'"'
    $profilesParameter = '"-profiles=' + $(Resolve-Path $profileConfigPath) + '"'

    Write-Host "Starting server at $port..."

    $argumentList = @($serverNameParameter, $portParameter, $basicConfigParameter, $serverConfigParameter, $profilesParameter, $ModsParameter)
    Start-Process -FilePath $ServerExePath -ArgumentList $argumentList

    Write-Host "Server started." -ForegroundColor Black -BackgroundColor Green
    Write-Host
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

function Compile-ModsParameter()
{
    param(
        [Parameter(Mandatory=$true)]
        $ModNames
    )

    $parameter = '"-mod='

    foreach($mod in $mods)
    {
        $relativePath = "!Workshop\@$mod"

        if (Test-Path (Join-Path $a3RootPath $relativePath))
        {
            Write-Host "$mod" -ForegroundColor Green
            $parameter = $parameter + "!Workshop\@$mod;"
        }
        else 
        {
            Write-Host "[Invalid mod path]: $mod expected folder at $relativePath but none found. Skipping." -ForegroundColor Yellow
        }
    }

    $parameter = $parameter + '"'

    return $parameter
}

function Read-Presets()
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

function Print-Presets()
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

function Prompt-PresetSelection()
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

function Read-PresetFile()
{
    param(
        [Parameter(Mandatory=$true)]
        $Modfile 
    )

    $skipped = 0
    $mods = @()
    $content = Get-Content -Path $Modfile

    foreach ($line in $content)
    {
        if ([string]::IsNullOrEmpty($line))
        {
            continue
        }

        if ($line[0] -ne '#')
        {
            $mods += @($line)
        }
        else
        {
            $skipped++
        }
    }

    Write-Host "Read $($mods.Count) mods, $skipped skipped."

    return $mods
}
