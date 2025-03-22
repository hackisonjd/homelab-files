# Sample Terraform configuration file to create a new VM instance on Proxmox

# Required Proxmox provider
terraform {
    required_providers {
        proxmox = {
            # Tell Terraform to use this source
            source = "telmate/proxmox"
        }
    }
}

# Configure the Proxmox provider, use the tfvars to be safe
provider "proxmox" {
    pm_api_url = var.pm_api_url
    pm_api_token_id = var.pm_api_token_id
    pm_api_token_secret = var.pm_api_token_secret
}

# Create a new VM instance on Proxmox
resource "proxmox_vm_qemu" "vm-instance" {
    name = "vm-instance"
    target_node = "homeserver"
    clone = "ubuntu-cloud"
    full_clone = true
    cores = 2
    memory = 2048

    disk {
        size = "32G"
        type = "scsi"
        storage = "local-zfs"
        discard = "on"
    }

    network {
        model = "virtio"
        bridge = "vmbr0"
        firewall = false
        link_down = false
    }
}