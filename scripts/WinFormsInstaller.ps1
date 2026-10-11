# Windows Dev Stack Installer

# Create GUI installer files through PowerShell WinForms.
# This script is intended to run elevated on Windows 10/11.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Dev Stack Installer"
$form.Size = New-Object System.Drawing.Size(640, 520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MinimizeBox = $false
$form.MaximizeBox = $false
$form.TopMost = $false

$iconLabel = New-Object System.Windows.Forms.Label
$iconLabel.Text = "Windows Dev Environment Setup"
$iconLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$iconLabel.Location = New-Object System.Drawing.Point(20, 20)
$iconLabel.Size = New-Object System.Drawing.Size(500, 34)
$form.Controls.Add($iconLabel)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Choose the tools you want to install on this Windows machine."
$subtitle.Location = New-Object System.Drawing.Point(24, 60)
$subtitle.Size = New-Object System.Drawing.Size(560, 30)
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(70, 70, 70)
$form.Controls.Add($subtitle)

$checkboxes = @()

function Add-CheckBox($name, $text, $y) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Name = $name
    $cb.Text = $text
    $cb.Location = New-Object System.Drawing.Point(30, $y)
    $cb.Size = New-Object System.Drawing.Size(400, 30)
    $cb.Checked = $true
    $form.Controls.Add($cb)
    $checkboxes += $cb
    return $cb
}

$y = 100
$cbWSL = Add-CheckBox "WSL" "WSL2 + Ubuntu Linux" $y; $y += 34
$cbDocker = Add-CheckBox "Docker" "Docker Desktop" $y; $y += 34
$cbVirtualBox = Add-CheckBox "VirtualBox" "VirtualBox (full Linux VM)" $y; $y += 34
$cbGit = Add-CheckBox "Git" "Git" $y; $y += 34
$cbPython = Add-CheckBox "Python" "Python" $y; $y += 34
$cbNode = Add-CheckBox "Node" "Node.js + npm" $y; $y += 34
$cbVSCode = Add-CheckBox "VSCode" "Visual Studio Code" $y; $y += 34
$cbMac = Add-CheckBox "MacAccess" "Open macOS access links for Mac cloud services" $y

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready."
$statusLabel.Location = New-Object System.Drawing.Point(24, 390)
$statusLabel.Size = New-Object System.Drawing.Size(560, 40)
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 96, 160)
$form.Controls.Add($statusLabel)

$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install Selected"
$installButton.Location = New-Object System.Drawing.Point(360, 430)
$installButton.Size = New-Object System.Drawing.Size(120, 32)
$installButton.Add_Click({
    $selected = @()
    if ($cbWSL.Checked) { $selected += "-InstallWSL" }
    if ($cbUbuntu.Checked) { $selected += "-InstallUbuntu" }
    if ($cbDocker.Checked) { $selected += "-InstallDocker" }
    if ($cbVirtualBox.Checked) { $selected += "-InstallVirtualBox" }
    if ($cbGit.Checked) { $selected += "-InstallGit" }
    if ($cbPython.Checked) { $selected += "-InstallPython" }
    if ($cbNode.Checked) { $selected += "-InstallNode" }
    if ($cbVSCode.Checked) { $selected += "-InstallVSCode" }
    if ($cbMac.Checked) { $selected += "-OpenMacLinks" }

    if ($selected.Count -eq 0) {
        $statusLabel.Text = "Please select at least one item."
        return
    }

    $scriptPath = Join-Path $PSScriptRoot "AdvancedInstaller.ps1"

    $installButton.Enabled = $false
    $statusLabel.Text = "Launching installer..."

    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList @(
            "-ExecutionPolicy","Bypass","-NoProfile","-File", $scriptPath
        ) + $selected

        $statusLabel.Text = "Installer launched in elevated PowerShell."
    }
    catch {
        $statusLabel.Text = "Failed to launch installer: $($_.Exception.Message)"
    }
    finally {
        $installButton.Enabled = $true
    }
})
$form.Controls.Add($installButton)

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Location = New-Object System.Drawing.Point(490, 430)
$closeButton.Size = New-Object System.Drawing.Size(100, 32)
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

$cbUbuntu = New-Object System.Windows.Forms.CheckBox
$cbUbuntu.Text = "Install Ubuntu in WSL2"
$cbUbuntu.Location = New-Object System.Drawing.Point(40, 100)
$cbUbuntu.Size = New-Object System.Drawing.Size(300, 30)
$cbUbuntu.Checked = $true
$form.Controls.Add($cbUbuntu)

$form.ShowDialog()
