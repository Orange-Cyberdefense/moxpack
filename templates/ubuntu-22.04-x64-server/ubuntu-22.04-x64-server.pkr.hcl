# Ubuntu 22.04 server
locals {
    template_description = "${var.description}, generated with packer at ${formatdate("YYYY-MM-DD hh:mm:ss", timestamp())}, connection: username:password ${var.vm_username}:${var.vm_password}"
}

source "proxmox-iso" "ubuntu2204-server" {
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
      iso_file          = "${var.iso_file}"
      iso_url           = "${var.iso_url}"
      iso_checksum      = "${var.iso_checksum}"
      iso_storage_pool  = "${var.proxmox_iso_storage_pool}"
      iso_download_pve  = true
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

    # USER
    ssh_password         = "${var.vm_password}"
    ssh_username         = "${var.vm_username}"

    # CONNECTION
    communicator    = "ssh"
    ssh_wait_timeout     = "20m"
    task_timeout         = "20m" // On slow disks the imgcopy operation takes > 1m

    # CLOUD INIT
    cloud_init = true
    cloud_init_storage_pool = "${var.proxmox_storage_pool}"

    # BOOT
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"
    boot_key_interval      = "100ms"
    boot_keygroup_interval = "2s"
    
    # Use templatefile function to process the user-data template with variables
    http_content = {
        "/meta-data" = file("http/meta-data")
        "/user-data" = templatefile("http/user-data.pkrtpl.hcl", {
            user = var.vm_username
            password = var.vm_password
            ssh_public_key = var.ssh_public_key
            timezone = var.timezone
            keymap = var.keymap
            keymap_variant = var.keymap_variant
        })
    }  
}

build {
    sources = ["proxmox-iso.ubuntu2204-server"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "${path.root}/files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}