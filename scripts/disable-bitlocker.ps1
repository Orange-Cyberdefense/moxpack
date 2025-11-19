# Disable BitLocker on drive C:
Write-Host "Disabling BitLocker on C:..." -ForegroundColor Yellow
Disable-BitLocker -MountPoint "C:"

# Wait for decryption to complete
Write-Host "Monitoring decryption progress every 10 seconds..." -ForegroundColor Cyan

do {
    # Retrieve current BitLocker status
    $status = Get-BitLockerVolume -MountPoint "C:" | Select-Object -ExpandProperty EncryptionPercentage
    $volume = Get-BitLockerVolume -MountPoint "C:" | Select-Object -ExpandProperty VolumeStatus

    # Display current progress
    Write-Host ("Decryption progress: {0}% - Status: {1}" -f $status, $volume)

    # Wait 10 seconds before checking again
    Start-Sleep -Seconds 10
}
while ($volume -ne 'FullyDecrypted')

Write-Host "✅ Drive C: is now fully decrypted." -ForegroundColor Green
