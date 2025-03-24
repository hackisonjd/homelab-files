# Sample Terraform configuration file to create a new VM instance on Proxmox

# Required Proxmox provider
terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "3.0.1-rc6"
        }
    }
}

# Configure the Proxmox provider, use the tfvars to be safe
provider "proxmox" {
    pm_api_url          = var.pm_api_url
    pm_api_token_id     = var.pm_api_token_id
    pm_api_token_secret = var.pm_api_token_secret
}

# Create 5 VM instances, 3 master nodes and 2 worker nodes for high availability
resource "proxmox_vm_qemu" "vm-instance" {
    count = 5
    
    # Identification
    name = count.index < 3 ? "k3s-master-0${count.index + 1}" : "k3s-worker-0${count.index - 2}"
    vmid = 200 + count.index
    target_node = "homeserver"

    # Clone
    clone = "talos-cloud"
    full_clone = true

    # Resources
    cores = count.index < 3 ? 4 : 2
    memory = count.index < 3 ? 4096 : 2048

    # Configuration
    os_type = "cloud-init"
    scsihw = "virtio-scsi-pci"

    # Cloud-init
    ciuser = var.user
    cipassword = var.password
    ciupgrade = true
    sshkeys = join("\n", var.ssh_keys)
    ipconfig0 = "ip=10.0.40.10${count.index + 1}/24,gw=10.0.40.1"

    # Storage
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

    # Network
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        firewall = false
        link_down = false
        tag = 40
    }

    # For console
    serial {
        id = 0
        type = "socket"
    }
}