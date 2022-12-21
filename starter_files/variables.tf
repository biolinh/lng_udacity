variable "packer_resource_group_name" {
   description = "Name of the resource group in which the Packer image will be created"
   default     = "ODL-clouddevops-219516"
}

variable "packer_image_name" {
   description = "Name of the Packer image"
   default     = "lng_udacity_image_ubuntu_18.04_LTS"
}

variable "resource_group_name" {
   description = "Name of the resource group in which the resources will be created"
   default     = "ODL-clouddevops-219516"
}

variable "location" {
   default = "eastus"
   description = "Location where resources will be created"
}

variable "tags" {
   description = "Tags of AZ esources"
   type        = map(string)
   default = {
    source = "lng_udacity",
    deployby = "linhnt58"
   }
}

variable "vnet_address_prefixes" {
   type = list(string)
   default = ["10.0.0.0/16"]
   description = "CDIR of VNET"
}

variable "vms_min" {
   default = 2
   description = "The  number of Virtual machine"
}

variable "admin_username" {
   default = "lng_udacity_admin"
   description = "admin username"
  
}
variable "admin_password" {
   default = "Password1234!"
   description = "password"
  
}

variable "computer_name" {
   default = "lng_udacity"
   description = "coputer name"
  
}