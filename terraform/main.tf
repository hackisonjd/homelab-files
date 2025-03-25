# ------------------------------------------------------------------------------
# Proxmox Kubernetes Cluster Configuration
# ------------------------------------------------------------------------------

# Provider Configuration
terraform {
    required_providers {
        proxmox = {
            source  = "telmate/proxmox"
            version = "3.0.1-rc6"
        }
    }
}

# Configure the Proxmox provider with variables for better security
provider "proxmox" {
    pm_api_url          = var.pm_api_url
    pm_api_token_id     = var.pm_api_token_id
    pm_api_token_secret = var.pm_api_token_secret
}

# ------------------------------------------------------------------------------
# Node Configuration
# ------------------------------------------------------------------------------

# Create local variables for node configs
locals {
    # Master node configurations
    master_nodes = {
        for i in range(1, var.master_config.count + 1) : 
        "k3s-master-${format("%02d", i)}" => {
            vmid       = 200 + i
            cores      = var.master_config.cores
            memory     = var.master_config.memory
            disk_size  = var.master_config.disk_size
            ip_address = "${var.base_ip}${i}${var.subnet_mask}"
            node_type  = "master"
        }
    }

    # Worker node configurations
    worker_nodes = {
        for i in range(1, var.worker_config.count + 1) : 
        "k3s-worker-${format("%02d", i)}" => {
            vmid       = 200 + var.master_config.count + i
            cores      = var.worker_config.cores
            memory     = var.worker_config.memory
            disk_size  = var.worker_config.disk_size
            ip_address = "${var.base_ip}${var.master_config.count + i}${var.subnet_mask}"
            node_type  = "worker"
        }
    }

    # Merge all nodes for unified handling
    all_nodes = merge(local.master_nodes, local.worker_nodes)
}

# ------------------------------------------------------------------------------
# VM Resources
# ------------------------------------------------------------------------------

# Create VM instances for K3s cluster nodes
resource "proxmox_vm_qemu" "k3s_nodes" {
    for_each = local.all_nodes
    
    # VM Identity
    name        = each.key
    vmid        = each.value.vmid
    target_node = var.target_node
    tags        = each.value.node_type

    # VM Base
    clone      = var.template_name
    full_clone = true

    # VM Resources
    cores   = each.value.cores
    memory  = each.value.memory
    scsihw  = "virtio-scsi-pci"
    os_type = "cloud-init"

    # Cloud-init Configuration
    ciuser      = var.user
    cipassword  = var.password
    ciupgrade   = true
    sshkeys     = join("\n", var.ssh_keys)
    ipconfig0   = "ip=${each.value.ip_address},gw=${var.gateway}"

    # Primary Storage
    disk {
        slot    = "scsi0"
        size    = each.value.disk_size
        type    = "disk"
        storage = "local-zfs"
        discard = "true"
    }

    # Cloud-init Drive
    disk {
        slot    = "ide0"
        type    = "cloudinit"
        storage = "local-zfs"
    }

    # Network Configuration
    network {
        id        = 0
        model     = "virtio"
        bridge    = "vmbr0"
        firewall  = false
        link_down = false
        tag       = var.network_tag
    }

    # Console Configuration
    serial {
        id   = 0
        type = "socket"
    }
}