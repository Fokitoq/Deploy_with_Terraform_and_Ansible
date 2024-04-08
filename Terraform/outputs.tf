# outputs.tf

output "ansible_inventory" {
  value = data.template_file.ansible_inventory.rendered
}


# Output the rendered inventory to a file
resource "local_file" "ansible_inventory_file" {
   filename = "${path.module}/../ansible/inventory"  # Define the path and filename for the inventory file
  content  = data.template_file.ansible_inventory.rendered  # Use the rendered content of the Ansible inventory
}