output "vms_public_id" {
    value = azurerm_public_ip.lng_udacity.id
}

output "vms_public_ip_address0" {
    value = azurerm_linux_virtual_machine.lng_udacity[0]
}

output "vms_private_ip_address0" {
    value = azurerm_linux_virtual_machine.lng_udacity[0]
}

output "vms_public_ip_address1" {
    value = azurerm_linux_virtual_machine.lng_udacity[1]
}

output "vms_private_ip_address1" {
    value = azurerm_linux_virtual_machine.lng_udacity[1]
}