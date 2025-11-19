# ================================================
# Windows Setup Script
# Description: Setup things during Autounattend
# ================================================

# Helper function: Create registry key if it does not exist
function Ensure-RegistryKey {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

# You cannot enable Windows PowerShell Remoting on network connections that are set to Public
# Spin through all the network locations and if they are set to Public, set them to Private
# using the INetwork interface:
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa370750(v=vs.85).aspx
# For more info, see:
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx
function Set-NetworkTypeToPrivate {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPositionalParameters', '')]
  param()
  # Network location feature was only introduced in Windows Vista - no need to bother with this
  # if the operating system is older than Vista
  if ([environment]::OSVersion.version.Major -lt 6) { return }

  # You cannot change the network location if you are joined to a domain, so abort
  if (1, 3, 4, 5 -contains (Get-CimInstance win32_computersystem).DomainRole) { return }

  # Get network connections
  $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
  $connections = $networkListManager.GetNetworkConnections()

  $connections | ForEach-Object {
    Write-Output $_.GetNetwork().GetName() "category was previously set to" $_.GetNetwork().GetCategory()
    #$_.GetNetwork().SetCategory(1)
    Write-Output $_.GetNetwork().GetName() "changed to category" $_.GetNetwork().GetCategory()
  }

}
$ErrorActionPreference = "Continue"

# Log all output to a file
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer"
}
Start-Transcript -path C:\packer\setup-log.txt -append

# ------------------------------------------------
# Disable screen saver
# ------------------------------------------------
Write-Output "Disabling Screensaver"
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -Type DWord
& powercfg -x -monitor-timeout-ac 0
& powercfg -x -monitor-timeout-dc 0

# ------------------------------------------------
# Change all networks to private
# ------------------------------------------------
Set-NetworkTypeToPrivate

# ------------------------------------------------
# Enable Windows Remote Management (WinRM) through the firewall
# ------------------------------------------------
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes

# ------------------------------------------------
# Disable IPV6
# ------------------------------------------------
Get-NetAdapter | foreach { Disable-NetAdapterBinding -InterfaceAlias $_.Name -ComponentID ms_tcpip6 }
netsh interface teredo set state disabled

# ------------------------------------------------
# Allow pings
# ------------------------------------------------
netsh advfirewall firewall add rule name='ICMP Allow incoming V4 echo request' protocol=icmpv4:8,any dir=in action=allow

# ------------------------------------------------
# Disable password expiration
# ------------------------------------------------
wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE

# ------------------------------------------------
# Install QEMU guest agent
# ------------------------------------------------
if ([System.Environment]::Is64BitOperatingSystem) { 
    F:\guest-agent\qemu-ga-x86_64.msi /quiet
} 
else {
    F:\guest-agent\qemu-ga-x86.msi /quiet
}

Write-Host "✅ Configuration completed successfully."
