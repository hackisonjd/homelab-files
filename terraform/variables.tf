variable "pm_api_url" {
    description = "The URL of the Proxmox API"
    type = string
}

variable "pm_api_token_id" {
    description = "The Proxmox API token ID"
    type = string
    sensitive = true
}

variable "pm_api_token_secret" {
    description = "The Proxmox API token secret"
    type = string
    sensitive = true
}

variable "user" {
    description = "The username for the cloud-init user"
    type = string
}

variable "password" {
    description = "The password for the cloud-init user"
    type = string
    sensitive = true
}

variable ssh_keys {
    description = "A list of SSH keys to add to the cloud-init user"
    type = list(string)
    default = []
}

variable "target_node" {
    description = "The Proxmox node to deploy the VM on"
    type = string
    default = "homeserver"
}

variable "template_name" {
    description = "The name of the Proxmox template to clone"
    type = string
    default = "talos-cloud"
}

variable "network_tag" {
    description = "The VLAN tag to assign to the VM"
    type = string
    default = 40
}

variable "base_ip" {
    description = "The base IP address for the VM"
    type = string
    default = "10.0.40.10"
}

variable "subnet_mask" {
  description = "Subnet mask"
  type        = string
  default     = "/24"
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "10.0.40.1"
}

# VM configurations
variable "master_config" {
  description = "Configuration for master nodes"
  type = object({
    cores     = number
    memory    = number
    disk_size = string
    count     = number
  })
  default = {
    cores     = 4
    memory    = 4096
    disk_size = "32G"
    count     = 3
  }
}

variable "worker_config" {
  description = "Configuration for worker nodes"
  type = object({
    cores     = number
    memory    = number
    disk_size = string
    count     = number
  })
  default = {
    cores     = 2
    memory    = 2048
    disk_size = "32G"
    count     = 2
  }
}