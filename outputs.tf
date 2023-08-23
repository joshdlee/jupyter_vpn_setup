output "jupyterhub_url" {
  value       = "http://${aws_instance.jupyterhub.private_ip}:8000"
  description = "URL to access the JupyterHub server."
}

output "jupyter_username" {
  value       = var.vpn_user
  description = "Username for the Jupyter user."
}

output "retrieve_jupyter_password_command" {
  value       = "To retrieve the Jupyter user password, run: `terraform output jupyter_user_password`"
  description = "Command to retrieve the Jupyter user password."
}

output "jupyter_user_password" {
  value     = random_password.jupyter_user_password.result
  description = "Randomly generated password for the Jupyter user."
  sensitive   = true
}

output "s3_ovpn_file_location" {
  value = module.vpn-client.aws_s3_bucket_vpn_config_files.bucket
  description = "Location of the OVPN file in S3 for VPN configuration."
}
