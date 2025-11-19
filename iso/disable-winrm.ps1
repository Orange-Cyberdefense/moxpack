$winrmService = Get-Service -Name WinRM
if ($winrmService.Status -eq "Running") {
  Disable-PSRemoting -Force
}
Stop-Service winrm
Set-Service -Name winrm -StartupType Disabled
