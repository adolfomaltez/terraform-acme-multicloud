variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}


variable "prefix" {
  type        = string
  default     = "win-vm-iis"
  description = "Prefix of the resource name"
}