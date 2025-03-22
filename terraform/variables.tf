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