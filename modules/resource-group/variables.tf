variable "resource_groups" {
  description = "Map of resource groups to create. Key is a logical name, value contains the actual name/location/tags."
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
}

variable "common_tags" {
  description = "Tags applied to every resource group in addition to per-group tags."
  type        = map(string)
  default     = {}
}
