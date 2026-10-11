#requires -Version 5.1

param(
    [string]$InputFile = "$PSScriptRoot\WinFormsInstaller.ps1",
    [string]$OutputFile = "$PSScriptRoot\..\dist\WindowsDevStackInstaller.exe",
    [switch]$ForceInstallPS2EXE
)

function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Ensure-PS2EXE {
    $module = Get-Module -ListAvailable -Name PS2EXE | Sort-Object Version -Descending | Select-Object -First 1

    if (-not $module -or $ForceInstallPS2EXE) {
        Write-Info "Installing PS2EXE..."
        try {
            Install-Module -Name PS2EXE -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
        }
        catch {
            Write-Warn "PowerShellGet installation failed. Trying to install PS2EXE from PSGallery with NuGet provider..."
            try {
                Install-PackageProvider -Name NuGet -Scope CurrentUser -Force
                Install-Module -Name PS2EXE -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
            }
            catch {
                throw "Unable to install PS2EXE. Please install it manually: Install-Module PS2EXE -Scope CurrentUser -Force"
            }
        }
    }

    Import-Module PS2EXE -Force
}

function Ensure-OutputDirectory {
    $dir = Split-Path -Parent $OutputFile
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Info "Building single .exe from WinForms installer..."

if (-not (Test-Path $InputFile)) {
    throw "Input script not found: $InputFile"
}

Ensure-OutputDirectory
Ensure-PS2EXE

try {
    Invoke-PS2EXE -InputFile $InputFile -OutputFile $OutputFile -NoConsole -NoLogo
    Write-Info "Build complete: $OutputFile"
}
catch {
    throw "PS2EXE build failed. $($_.Exception.Message)"
}
