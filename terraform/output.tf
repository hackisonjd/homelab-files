output "master_nodes" {
    description = "Master node details"
    value = {
        for name, node in proxmox_vm_qemu.k3s-nodes : name => {
            id         = node.id
            ip_address = node.ipconfig0
            vmid       = node.vmid
        } if node.tags == "master"
    }
}

output "worker_nodes" {
    description = "Worker node details"
    value = {
        for name, node in proxmox_vm_qemu.k3s-nodes : name => {
            id         = node.id
            ip_address = node.ipconfig0
            vmid       = node.vmid
        } if node.tags == "worker"
    }
}

output "all_node_ips" {
    description = "IP addresses of all nodes"
    value = [
        for node in proxmox_vm_qemu.k3s-nodes : 
        split(",", split("=", node.ipconfig0)[1])[0]
    ]
}
