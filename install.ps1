<#
  Installa (o rimuove) i sottotitoli italiani di Phantasmagoria 2 per ScummVM.
  Uso:  .\install.ps1 [-GamePath <cartella del gioco>] [-Uninstall]
  Senza -GamePath cerca il gioco nelle librerie Steam.
#>
param(
    [string]$GamePath,
    [switch]$Uninstall
)
$ErrorActionPreference = 'Stop'

function Find-DukDir([string]$root) {
    # Accetta la cartella del gioco, Phant2 o direttamente DUK
    foreach ($c in @($root, (Join-Path $root 'DUK'), (Join-Path $root 'Phant2\DUK'))) {
        if ((Test-Path $c) -and (Get-ChildItem $c -Filter '*.DUK' -ErrorAction SilentlyContinue | Select-Object -First 1)) {
            return (Resolve-Path $c).Path
        }
    }
    return $null
}

function Find-SteamGame {
    $steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
    if (-not $steam) { return $null }
    $libs = @($steam)
    $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
    if (Test-Path $vdf) {
        $libs += Select-String -Path $vdf -Pattern '"path"\s+"([^"]+)"' | ForEach-Object { $_.Matches[0].Groups[1].Value -replace '\\\\', '\' }
    }
    foreach ($lib in $libs) {
        $d = Find-DukDir (Join-Path $lib 'steamapps\common\Phantasmagoria 2')
        if ($d) { return $d }
    }
    return $null
}

$duk = if ($GamePath) { Find-DukDir $GamePath } else { Find-SteamGame }
if (-not $duk) {
    $GamePath = Read-Host 'Gioco non trovato. Incolla il percorso della cartella di Phantasmagoria 2'
    $duk = Find-DukDir $GamePath.Trim('"')
}
if (-not $duk) { throw "Nessun file .DUK trovato in '$GamePath'." }

$srtDir = Join-Path $PSScriptRoot 'srt'
$files = Get-ChildItem $srtDir -Filter '*.srt'

if ($Uninstall) {
    $n = 0
    foreach ($f in $files) {
        $t = Join-Path $duk $f.Name
        if (Test-Path $t) { Remove-Item $t; $n++ }
    }
    Write-Host "Rimossi $n sottotitoli da $duk"
} else {
    Copy-Item $files.FullName -Destination $duk -Force
    Write-Host "Installati $($files.Count) sottotitoli in $duk"
    Write-Host 'In ScummVM (Opzioni del gioco > Motore): lascia attivo "Use high-quality video scaling" e spento "Enable black-lined video".'
}
