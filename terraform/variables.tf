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