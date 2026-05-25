<#
.SYNOPSIS
    Deploy Windows Terminal settings for the current user.
#>

$ErrorActionPreference = 'Stop'

function Test-FontInstalled {
    param(
        [Parameter(Mandatory)]
        [string]$Face
    )

    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts',
        'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Fonts'
    )

    foreach ($path in $registryPaths) {
        if (-not (Test-Path $path)) {
            continue
        }

        $fontEntries = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        foreach ($prop in $fontEntries.PSObject.Properties) {
            if ($prop.Name -like "*$Face*" -or ($prop.Value -is [string] -and $prop.Value -like "*$Face*")) {
                return $true
            }
        }
    }

    return $false
}

function Test-ModuleInstalled {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    return [bool](Get-Module -ListAvailable -Name $Name -ErrorAction SilentlyContinue)
}

function Set-PSGalleryTrusted {
    $repository = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
    if (-not $repository) {
        throw "PSGallery is not configured. Configure PSGallery before installing modules."
    }

    if ($repository.InstallationPolicy -ne 'Trusted') {
        Write-Host 'Trusting PSGallery for module installation...'
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null
    }
}

function Install-OhMyPosh {
    if (Test-ModuleInstalled -Name 'oh-my-posh') {
        Write-Host "Verified oh-my-posh module is installed."
        return
    }

    Set-PSGalleryTrusted

    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing NuGet package provider...'
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
    }

    Write-Host 'Installing oh-my-posh module...'
    Install-Module -Name oh-my-posh -Scope CurrentUser -Force -AllowClobber -Repository PSGallery

    if (-not (Test-ModuleInstalled -Name 'oh-my-posh')) {
        throw "Unable to install 'oh-my-posh'. Install it manually with 'Install-Module oh-my-posh -Scope CurrentUser'."
    }

    Write-Host "Installed oh-my-posh module."
}

function Install-CaskaydiaCoveNerdFont {
    param(
        [Parameter(Mandatory)]
        [string]$Face
    )

    if ($Face -notmatch 'CaskaydiaCove') {
        throw "Automatic font installation only supports CaskaydiaCove NF. Install '$Face' manually."
    }

    $downloadUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CaskaydiaCove.zip'
    $tempDir = Join-Path $env:TEMP 'windows-terminal-nerdfont'
    $archivePath = Join-Path $tempDir 'CaskaydiaCove.zip'
    $extractDir = Join-Path $tempDir 'extracted'
    $fontInstallDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'

    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    Write-Host "Downloading CaskaydiaCove Nerd Font from GitHub..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath -UseBasicParsing -ErrorAction Stop

    Write-Host 'Extracting Nerd Font files...'
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractDir -Force

    $fontFiles = Get-ChildItem -Path $extractDir -Include '*.ttf','*.otf' -Recurse -File
    if (-not $fontFiles) {
        throw 'Could not find font files in the downloaded archive.'
    }

    if (-not (Test-Path $fontInstallDir)) {
        New-Item -ItemType Directory -Path $fontInstallDir -Force | Out-Null
    }

    Write-Host 'Installing Nerd Font files to user font folder...'
    foreach ($fontFile in $fontFiles) {
        Copy-Item -Path $fontFile.FullName -Destination $fontInstallDir -Force
    }

    Write-Host 'Font files copied into user font folder. Windows may require a restart for the font to become available.'
}

$source = Join-Path $PSScriptRoot 'settings.json'
$targetDir = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
$target = Join-Path $targetDir 'settings.json'

if (-not (Test-Path $source)) {
    Write-Error "Source settings.json not found: $source"
    exit 1
}

$settings = Get-Content -Path $source -Raw | ConvertFrom-Json
$fontFace = $settings.profiles.defaults.font.face

if ($fontFace) {
    if (-not (Test-FontInstalled -Face $fontFace)) {
        Write-Host "Required Nerd Font '$fontFace' is not installed. Attempting automatic installation..."
        try {
            Install-CaskaydiaCoveNerdFont -Face $fontFace
        } catch {
            Write-Error "Automatic Nerd Font installation failed: $_"
            exit 1
        }

        if (-not (Test-FontInstalled -Face $fontFace)) {
            Write-Error "Required Nerd Font '$fontFace' is still not installed after automatic installation. Install it manually and rerun this script."
            exit 1
        }
    }
    Write-Host "Verified Nerd Font installed: $fontFace"
}

Install-OhMyPosh

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Copy-Item -Path $source -Destination $target -Force
Write-Host "Deployed Windows Terminal settings to $target"
