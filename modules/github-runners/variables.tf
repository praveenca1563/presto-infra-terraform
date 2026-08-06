variable "vmss_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "identity_name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for the runner VMs' admin user"
  type        = string
}

variable "image_publisher" {
  type    = string
  default = "canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts-gen2"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "os_disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "subnet_id" {
  description = "Subnet ID the runner VMSS NICs attach to (private networking)"
  type        = string
}

variable "upgrade_mode" {
  type    = string
  default = "Manual"
}

variable "github_owner" {
  description = "GitHub org or user that owns the repository"
  type        = string
}

variable "github_repo" {
  type = string
}

variable "runner_version" {
  description = "actions/runner release version to install, without the leading 'v'"
  type        = string
  default     = "2.319.1"
}

variable "runner_labels" {
  type    = list(string)
  default = ["self-hosted", "azure", "presto-dataeng"]
}

variable "runner_group" {
  type    = string
  default = "Default"
}

variable "runners_per_vm" {
  type    = number
  default = 1
}

variable "runner_registration_token" {
  description = "Short-lived GitHub Actions runner registration token (see README for how to generate/refresh this — it expires roughly 1 hour after issue). Never commit a real value."
  type        = string
  sensitive   = true
}

variable "enable_autoscale" {
  type    = bool
  default = true
}

variable "autoscale_min" {
  type    = number
  default = 1
}

variable "autoscale_max" {
  type    = number
  default = 5
}

variable "scale_out_cpu_threshold" {
  type    = number
  default = 75
}

variable "scale_in_cpu_threshold" {
  type    = number
  default = 20
}

variable "tags" {
  type    = map(string)
  default = {}
}
