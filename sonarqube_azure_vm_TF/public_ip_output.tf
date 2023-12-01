output "public_ip_address" {
  value = azurerm_virtual_machine.main.network_interface_ids[0].virtual_machine_id
}