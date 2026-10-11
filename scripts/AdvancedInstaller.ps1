#requires -Version 5.1

param(
    [switch]$InstallWSL,
    [switch]$InstallUbuntu,
    [switch]$InstallDocker,
    [switch]$InstallVirtualBox,
    [switch]$InstallGit,
    [switch]$InstallPython,
    [switch]$InstallNode,
    [switch]$InstallVSCode,
    [switch]$OpenMacLinks,
    [switch]$NoPrompt,
    [switch]$SkipLinuxConfig
)

function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Err($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-IsAdministrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-WingetInstall {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    Write-Info "Installing $DisplayName ($PackageId)..."
    & winget install --id $PackageId --exact --silent --accept-source-agreements --accept-package-agreements -e
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Installation of $DisplayName failed or was skipped. You may need to install it manually."
    }
}

function Open-MacLinks {
    $urls = @(
        "https://www.macstadium.com/",
        "https://www.macincloud.com/",
        "https://azure.microsoft.com/en-us/products/virtual-machines/mac/"
    )

    foreach ($url in $urls) {
        try {
            Start-Process $url
        }
        catch {
            Write-Warn "Could not open: $url"
        }
    }
}

function Enable-WSLFeatures {
    Write-Info "Enabling Windows Subsystem for Linux and Virtual Machine Platform..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    Write-Info "Setting WSL default version to 2..."
    wsl --set-default-version 2 2>$null
}

function Install-UbuntuInWSL {
    Write-Info "Ensuring Ubuntu is installed in WSL..."

    $ubuntuInstalled = $false
    try {
        $distros = wsl -l -v 2>$null
        if ($distros -match "Ubuntu") {
            $ubuntuInstalled = $true
        }
    }
    catch {
        $ubuntuInstalled = $false
    }

    if (-not $ubuntuInstalled) {
        try {
            winget install --id Canonical.Ubuntu --exact --silent --accept-source-agreements --accept-package-agreements -e
            if ($LASTEXITCODE -ne 0) {
                Write-Warn "Ubuntu could not be installed via winget. You can install it from the Microsoft Store manually."
            }
        }
        catch {
            Write-Warn "Ubuntu install failed. Please install Ubuntu manually from the Microsoft Store."
        }
    }

    Write-Info "Setting Ubuntu as the default WSL distro..."
    wsl --set-default Ubuntu 2>$null
}

function Configure-WSLUbuntu {
    if ($SkipLinuxConfig) {
        Write-Info "Skipping Linux package configuration."
        return
    }

    Write-Info "Configuring Ubuntu in WSL with common dev tools..."
    $ubuntuCmd = @'
set -e
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential curl git python3 python3-pip python3-venv ca-certificates gnupg lsb-release
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v
npm -v
python3 --version
'@

    try {
        wsl -d Ubuntu -- bash -lc $ubuntuCmd
    }
    catch {
        Write-Warn "WSL configuration step failed. You may need to open Ubuntu manually and run the commands yourself."
    }
}

function Install-OptionalPackages {
    if ($InstallGit) {
        Invoke-WingetInstall -PackageId "Git.Git" -DisplayName "Git"
    }

    if ($InstallPython) {
        Invoke-WingetInstall -PackageId "Python.Python.3.12" -DisplayName "Python"
    }

    if ($InstallNode) {
        Invoke-WingetInstall -PackageId "OpenJS.NodeJS.LTS" -DisplayName "Node.js"
    }

    if ($InstallVSCode) {
        Invoke-WingetInstall -PackageId "Microsoft.VisualStudioCode" -DisplayName "Visual Studio Code"
    }
}

function Install-DesktopApps {
    if ($InstallDocker) {
        Invoke-WingetInstall -PackageId "Docker.DockerDesktop" -DisplayName "Docker Desktop"
    }

    if ($InstallVirtualBox) {
        Invoke-WingetInstall -PackageId "Oracle.VirtualBox" -DisplayName "VirtualBox"
    }
}

Write-Info "Windows Dev Stack Installer"
Write-Info "This installer configures WSL2, Ubuntu, Docker, VirtualBox, Git, Python, Node.js, and VS Code."

if (-not (Test-IsAdministrator)) {
    Write-Err "This script must be run as Administrator. Please re-run from an elevated PowerShell window."
    exit 1
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Err "winget was not found. Please install App Installer / winget and try again."
    exit 1
}

if ($InstallWSL -or $InstallUbuntu -or $InstallDocker -or $InstallVirtualBox -or $InstallGit -or $InstallPython -or $InstallNode -or $InstallVSCode -or $OpenMacLinks) {
    Write-Info "Proceeding with selected installation tasks..."
}
else {
    Write-Info "No installation options were passed. Use switches such as -InstallWSL -InstallDocker -InstallVSCode."
    Write-Info "Example: powershell -ExecutionPolicy Bypass -File .\AdvancedInstaller.ps1 -InstallWSL -InstallUbuntu -InstallDocker -InstallGit -InstallPython -InstallNode -InstallVSCode"
    exit 0
}

if ($InstallWSL) {
    Enable-WSLFeatures
}

if ($InstallUbuntu) {
    Install-UbuntuInWSL
    Configure-WSLUbuntu
}

Install-OptionalPackages
Install-DesktopApps

if ($OpenMacLinks) {
    Open-MacLinks
}

Write-Info "Installation process complete."
Write-Info "Recommended next steps:"
Write-Host "  1. Restart Windows if prompted" -ForegroundColor Green
Write-Host "  2. Open Ubuntu from Start Menu or run: wsl" -ForegroundColor Green
Write-Host "  3. Open Docker Desktop and enable WSL integration" -ForegroundColor Green
Write-Host "  4. Install a real Mac or remote cloud Mac for macOS testing" -ForegroundColor Green
