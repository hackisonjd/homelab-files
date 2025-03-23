# Sample Terraform configuration file to create a new VM instance on Proxmox

# Required Proxmox provider
terraform {
    required_providers {
        proxmox = {
            # Tell Terraform to use this source
            source = "telmate/proxmox"
            version = "3.0.1-rc6"
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
    os_type = "cloud-init"
    scsihw = "virtio-scsi-pci"
    ipconfig0 = "ip=dhcp"
    ciuser = var.user
    cipassword = var.password
    ciupgrade = true
    sshkeys = join("\n", var.ssh_keys)



    disk {
        slot = "scsi0"
        size = "32G"
        type = "disk"
        storage = "local-zfs"
        discard = "true"
    }

    disk {
        slot = "ide0"
        type = "cloudinit"
        storage = "local-zfs"
    }

    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        firewall = false
        link_down = false
    }

    serial {
        id = 0
        type = "socket"
    }
}