# ================================================
# Windows Configuration Script
# Description: Sets common Explorer and Console preferences,
# enables auto logon, and allows WinRM through the firewall.
# ================================================

# Helper function: Create registry key if it does not exist
function Ensure-RegistryKey {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

$ErrorActionPreference = "Continue"

# Log all output to a file
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer"
}
Start-Transcript -path C:\packer\config-log.txt -append

# ------------------------------------------------
# Show file extension in explorer
# ------------------------------------------------
$showExtensionPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Ensure-RegistryKey $showExtensionPath
Set-ItemProperty -Path $showExtensionPath -Name "HideFileExt" -Value 0 -Type DWord -Force

# ------------------------------------------------
# Enable QuickEdit mode in the console
# ------------------------------------------------
$consolePath = "HKCU:\Console"
Ensure-RegistryKey $consolePath
Set-ItemProperty -Path $consolePath -Name "QuickEdit" -Value 1 -Type DWord -Force

# ------------------------------------------------
# Show "Run" command in the Start menu
# ------------------------------------------------
$explorerAdvanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Ensure-RegistryKey $explorerAdvanced
Set-ItemProperty -Path $explorerAdvanced -Name "Start_ShowRun" -Value 1 -Type DWord -Force

# ------------------------------------------------
# Show Administrative Tools in the Start menu
# ------------------------------------------------
Set-ItemProperty -Path $explorerAdvanced -Name "StartMenuAdminTools" -Value 1 -Type DWord -Force

# ------------------------------------------------
# Set default password for automatic logon
# ------------------------------------------------
$winlogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Ensure-RegistryKey $winlogonPath
Set-ItemProperty -Path $winlogonPath -Name "DefaultPassword" -Value "vagrant" -Type String -Force

# ------------------------------------------------
# Enable automatic logon
# ------------------------------------------------
Set-ItemProperty -Path $winlogonPath -Name "AutoAdminLogon" -Value "1" -Type String -Force


Write-Host "✅ Configuration completed successfully."
