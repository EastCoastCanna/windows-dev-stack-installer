# Windows Dev Stack Installer

This repository contains a PowerShell-based Windows development environment installer for:

- WSL2 + Ubuntu Linux
- Docker Desktop
- VirtualBox
- Git
- Python
- Node.js
- VS Code
- Optional cloud Mac access links for macOS testing

It includes:

1. A simple WinForms GUI installer
2. A more advanced unattended installer
3. A PS2EXE build script to generate a single .exe wrapper

Important note:

A normal macOS VM on Windows is not supported by Apple and is not recommended. The supported ways to access macOS from Windows are:

- a real Mac
- a remote Mac service such as MacStadium, MacInCloud, or Azure Mac VMs
- a cloud Mac instance

This project is meant to help set up the Linux and Windows tooling around that workflow.

## Repository contents

- `scripts/WinFormsInstaller.ps1` - GUI installer using PowerShell WinForms
- `scripts/AdvancedInstaller.ps1` - full automation for the environment
- `scripts/BuildExe.ps1` - compiles the GUI installer into a single `.exe` using PS2EXE
- `README.md` - usage instructions

## Quick start

### Option 1: Use the GUI

From an elevated PowerShell prompt:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\WinFormsInstaller.ps1
```

### Option 2: Use the advanced installer

From an elevated PowerShell prompt:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\AdvancedInstaller.ps1 -InstallWSL -InstallUbuntu -InstallDocker -InstallVirtualBox -InstallGit -InstallPython -InstallNode -InstallVSCode -OpenMacLinks
```

### Option 3: Build a single `.exe`

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\BuildExe.ps1
```

This uses PS2EXE to compile `WinFormsInstaller.ps1` to a standalone `.exe`.

## Requirements

- Windows 10 or Windows 11
- Administrator privileges
- PowerShell 5.1+ (or PowerShell 7)
- Internet access for winget downloads

## Notes

- `winget` is used for app installation where available.
- The script checks whether it is running with Administrator privileges.
- If WSL components are not enabled, they will be enabled automatically.
- If `PowerShellGet` or `PS2EXE` is missing, the build script can install it automatically.

## Example unattended run

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\AdvancedInstaller.ps1 `
  -InstallWSL `
  -InstallUbuntu `
  -InstallDocker `
  -InstallVirtualBox `
  -InstallGit `
  -InstallPython `
  -InstallNode `
  -InstallVSCode `
  -OpenMacLinks
```

## macOS access recommendations

The supported options from a Windows PC are:

- A real Mac machine
- Azure Mac VMs
- MacStadium
- MacInCloud

## License

This project is provided as-is for developer environment automation. It is not affiliated with Microsoft, Docker, Oracle, or Apple.
