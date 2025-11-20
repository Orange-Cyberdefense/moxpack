vm_id = 202202
vm_name = "windows-server-2022-x64-template"
#iso_url = "https://drive.massgrave.dev/en-us_windows_server_2022_updated_nov_2025_x64_dvd_2fa82c06.iso"
#iso_checksum = "sha256:F0EE4FB38B2F2DA57E2F7DE96FB485439E72F455CFE071ED1C8E967077515532"
#iso_download_pve = true
iso_file = "local:iso/en-us_windows_server_2022_updated_nov_2025_x64_dvd_2fa82c06.iso"
os = "win10"
vm_disk_size = "60G"
uptodate = true
description = "Windows Server 2022 64-bit"

# Generic key to allow install without activation
# https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys
# Windows Server 2019 Standard Evaluation
product_key = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
image_name = "Windows Server 2022 SERVERSTANDARD"

# Windows Server 2022 Datacenter Evaluation
#product_key = "WX4NM-KYWYW-QJJR4-XV3QB-6VM33"
#image_name = "Windows Server 2022 SERVERDATACENTER"