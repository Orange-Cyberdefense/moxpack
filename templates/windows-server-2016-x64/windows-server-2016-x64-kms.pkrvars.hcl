vm_id = 201602
vm_name = "windows-server-2016-x64-template"
# iso_url = "https://software-static.download.prss.microsoft.com/pr/download/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
# iso_checksum = "sha256:1ce702a578a3cb1ac3d14873980838590f06d5b7101c5daaccbac9d73f1fb50f"
# iso_download_pve = true
iso_file = "local:iso/windows2016-x64.iso"
os = "win10"
uptodate = true
vm_disk_size = "60G"
description = "Windows Server 2016 64-bit with security update"

# Generic key to allow install without activation
# https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys
product_key = "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
image_name = "Windows Server 2016 SERVERSTANDARD"

# Windows Server 2019 Datacenter Evaluation
#product_key = "CB7KF-BWN84-R7R2Y-793K2-8XDDG"
#image_name = "Windows Server 2016 SERVERDATACENTER"