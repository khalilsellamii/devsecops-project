output "public_ip_address" {
  value = azurerm_linux_virtual_machine.sonarqube.network_interface_ids[0].virtual_machine_id
}