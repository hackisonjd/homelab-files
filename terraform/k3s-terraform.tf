# Terraform configuration file to create a highly available setup for K3S (3 masters, 2 workers)

# Required Proxmox provider
terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
        }
    }
}
