# Sample Terraform configuration file to create a new VM instance on Proxmox

# Required Proxmox provider
terraform {
    required_providers {
        proxmox = {
            source  = "telmate/proxmox"
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

# Create local variables for node configs
locals {
    # All Node configurations
    master_nodes = {
        for i in range(1, var.master_config.count + 1) : 
        "k3s-master-${format("%02d", i)}" => {
            vmid = 200 + i
            cores = var.master_config.cores
            memory = var.master_config.memory
            disk_size = var.master_config.disk_size
            ip_address = "${var.base_ip}${i}${var.subnet_mask}"
            node_type = "master"
        }
    }

    worker_nodes = {
        for i in range(1, var.worker_config.count + 1) : 
        "k3s-worker-${format("%02d", i)}" => {
            vmid = 200 + var.master_config.count + i
            cores = var.worker_config.cores
            memory = var.worker_config.memory
            disk_size = var.worker_config.disk_size
            ip_address = "${var.base_ip}${var.master_config.count + i}${var.subnet_mask}"
            node_type = "worker"
        }
    }

    # Merge all nodes
    all_nodes = merge(local.master_nodes, local.worker_nodes)
}

# Create 5 VM instances, 3 master nodes and 2 worker nodes for high availability
resource "proxmox_vm_qemu" "k3s-nodes" {
    for_each = local.all_nodes
    
    # Identification
    name = each.key
    vmid = each.value.vmid
    target_node = var.target_node

    # Clone
    clone = var.template_name
    full_clone = true

    # Resources
    cores = each.value.cores
    memory = each.value.memory

    # Configuration
    os_type = "cloud-init"
    scsihw = "virtio-scsi-pci"

    # Cloud-init
    ciuser = var.user
    cipassword = var.password
    ciupgrade = true
    sshkeys = join("\n", var.ssh_keys)
    ipconfig0 = "ip=${each.value.ip_address},gw=${var.gateway}"

    # Storage
    disk {
        slot = "scsi0"
        size = each.value.disk_size
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
        tag = var.network_tag
    }

    # For console
    serial {
        id = 0
        type = "socket"
    }

    tags = each.value.node_type
}