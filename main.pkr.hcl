packer {
  required_plugins {
    name = {
      version = "~> 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

# global variables
variable "proxmox_api_url" {
    type = string
}
variable "proxmox_api_token_id" {
    type = string
}
variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}
variable "proxmox_node" {
    type = string
}
variable "proxmox_storage_pool" {
  type = string
}
variable "proxmox_storage_format" {
  type = string
}
variable "proxmox_skip_tls_verify" {
  type = bool
}
variable "proxmox_pool" {
  type = string
}
variable "proxmox_iso_storage_pool" {
  type = string
}

# vms variables
variable "timezone" {
    type = string
    description = "Timezone for the VM"
}
variable "keymap" {
    type = string
    default = "fr"
}
variable "keymap_variant" {
    type = string
    default = "latin9"
}
variable "network_bridge" {
  type = string
}
variable "vlan_tag" {
  type = string
}
variable "vm_cpu_cores" {
  type    = string
  default = "2"
}
variable "vm_memory" {
  type    = string
  default = "4096"
}
variable "vm_disk_size" {
  type    = string
  default = "30G"
}
variable "vm_username" {
  type    = string
  default = "vagrant"
}
variable "vm_password" {
  type    = string
  default = "vagrant"
  sensitive = true
}
variable "vm_name" {
  type    = string
  default = null
}
variable "iso_url" {
  type    = string
  default = null
}
variable "iso_file" {
  type    = string
  default = null
}
variable "iso_checksum" {
  type = string
  default = null
}
variable "os" {
  type = string
  default = "win10"
}
variable "vm_id"{
  type = number
  default = null
}
variable "ssh_public_key" {
  type    = string
  default = null
}
variable "iso_download_pve" {
  type    = bool
  default = false
}
variable "uptodate" {
  type    = bool
  default = false
}
variable "description" {
  type    = string
  default = "build with mypacker"
}
variable "product_key" {
  type    = string
  default = ""
}
variable "windows_time_zone" {
  type    = string
  default = "Romance Standard Time"
}
variable "windows_keyboard" {
  type    = string
  default = "US"
}
variable "image_name" {
  type    = string
  default = ""
}