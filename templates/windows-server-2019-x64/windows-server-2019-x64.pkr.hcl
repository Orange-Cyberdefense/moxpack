# windows server 2019 template
locals {
    template_description = "${var.description}, generated with packer at ${formatdate("YYYY-MM-DD hh:mm:ss", timestamp())}, connection: username:password ${var.vm_username}:${var.vm_password}"
}

source "proxmox-iso" "windows2019-x64" {
   # PROXMOX infos
    proxmox_url = "${var.proxmox_api_url}"
    username    = "${var.proxmox_api_token_id}"
    token       = "${var.proxmox_api_token_secret}"
    node        = "${var.proxmox_node}"
    insecure_skip_tls_verify = "${var.proxmox_skip_tls_verify}"

    # VM MAIN INFOS
    vm_name              = "${var.vm_name}"
    vm_id                = "${var.vm_id}"
    os                   = "${var.os}"
    template_description = "${local.template_description}"
    pool                 = "${var.proxmox_pool}"
    cores                = "${var.vm_cpu_cores}"
    cpu_type             = "host"
    memory               = "${var.vm_memory}"
    qemu_agent           = true

    # ISO
    boot_iso {
      iso_url           = "${var.iso_url}"
      iso_checksum      = "${var.iso_checksum}"
      iso_file          = "${var.iso_file}"
      iso_storage_pool  = "${var.proxmox_iso_storage_pool}"
      iso_download_pve  = "${var.iso_download_pve}"
      unmount = true
    }

    # NETWORK
    network_adapters {
      bridge   = "${var.network_bridge}"
      model    = "virtio"
      vlan_tag = "${var.vlan_tag}"
    }

    # DISK
    scsi_controller = "virtio-scsi-single"
    disks {
      disk_size         = "${var.vm_disk_size}"
      format            = "${var.proxmox_storage_format}"
      storage_pool      = "${var.proxmox_storage_pool}"
      type              = "virtio"
      discard           = true
      io_thread         = true
    }

    # CONNECTION
    winrm_username       = "${var.vm_username}"
    winrm_password       = "${var.vm_password}"
    communicator         = "winrm"
    winrm_insecure       = true
    winrm_use_ssl        = true
    winrm_timeout        = "180m"
    task_timeout         = "20m"

    # iso creation from files E:\
    additional_iso_files {
      type              = "sata"
      index             = "3"
      iso_storage_pool = "${var.proxmox_iso_storage_pool}"
      unmount          = true
      cd_label         = "PROVISION"
      cd_files = [
        "${path.cwd}/iso/*",
      #  "${path.root}/Autounattend.xml"
      ]
      cd_content = {
        "Autounattend.xml" = templatefile("Autounattend.xml.tpl", { 
            version         = "2k19"
            computer_name   = "WIN2019-SRV-X64"
            image_name      = "${var.image_name}"
            product_key     = "${var.product_key}"
            time_zone       = "${var.windows_time_zone}"
            username        = "${var.vm_username}"
            password        = "${var.vm_password}"
            admin_password  = "${var.vm_password}"
            keyboard        = "${var.windows_keyboard}"
         }),
         "FinalUnattend.xml" = templatefile("FinalUnattend.xml.tpl", { 
            time_zone       = "${var.windows_time_zone}"
            username        = "${var.vm_username}"
            password        = "${var.vm_password}"
            admin_password  = "${var.vm_password}"
            keyboard        = "${var.windows_keyboard}"
         })
      }
    }

    # virtio drivers iso F:\
    additional_iso_files {
      type              = "sata"
      index             = "4"
      iso_checksum     = "sha256:c88a0dde34605eaee6cf889f3e2a0c2af3caeb91b5df45a125ca4f701acbbbe0"
      iso_url          = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.229-1/virtio-win-0.1.229.iso"
      iso_storage_pool = "${var.proxmox_iso_storage_pool}"
      unmount          = true
    }
}

build {
  sources = ["source.proxmox-iso.windows2019-x64"]

  provisioner "ansible" {
    playbook_file = var.uptodate ? "${path.cwd}/ansible/windows_update_security_updates.yml" : "${path.cwd}/ansible/windows_disable_update.yml"
    use_proxy     = false
    user          = "${var.vm_username}"
    extra_arguments = [
      "-e", "ansible_winrm_server_cert_validation=ignore",
      "-e", "ansible_winrm_connection_timeout=300",
      "-e", "ansible_winrm_read_timeout_sec=600",
      "-e","ansible_winrm_operation_timeout_sec=300"
    ]
    skip_version_check = true
  }

  provisioner "powershell" {
    scripts  = [
                "${path.cwd}/scripts/win-config.ps1",
                "${path.cwd}/scripts/install-virtio-drivers.ps1"]
  }

  provisioner "powershell" {
    scripts  = ["${path.cwd}/scripts/cloud-init.ps1"]
  }
}