
# README for the `jupyter_vpn_setup` Terraform Module

## Overview

The `jupyter_vpn_setup` Terraform module sets up a VPN-enabled JupyterHub environment in AWS. This module facilitates secure access to JupyterHub through a VPN, ensuring that users can work in a safe and controlled environment.

## Features

1. **Random Password Generation**: Generates a secure random password for the Jupyter user.
2. **VPN Setup**: Utilizes an external module to set up a VPN client for secure access.
3. **IAM Role and Instance Profile**: Sets up necessary IAM roles and instance profiles for AWS Systems Manager (SSM).
4. **Security Group Configuration**: Creates a security group for JupyterHub to restrict traffic solely from the VPC.

## Usage

Include this module in your Terraform configuration as follows:

```hcl
module "jupyter_vpn_setup" {
  source = "path_to_module_directory"

  # Provide required variables here
  ...
}
```

## Input Variables

- `organization_name`: Name of your organization.
- `project_name`: Name of your project.
- `vpn_user`: Details of the VPN user.
- `vpc_id`: ID of the VPC where resources will be deployed.
- `subnet_id`: ID of the subnet for deployment.
- `vpn_client_cidr_block`: CIDR block for VPN clients (distinct from VPC CIDR).
- `split_tunnel`: Enable/disable split tunnel in the VPN.
- `vpn_inactive_period`: Inactive period for the VPN in seconds.
- `session_timeout_hours`: VPN session timeout in hours.
- `logs_retention_in_days`: Logs retention period in days.
- `instance_type`: AWS EC2 instance type (default: `t2.micro`).
- `key_name`: Key pair name for the EC2 instance.

## Outputs

- `jupyterhub_url`: URL for accessing the JupyterHub server.
- `jupyter_username`: Username for the Jupyter user.
- `retrieve_jupyter_password_command`: Command to retrieve the Jupyter user password.
- `jupyter_user_password`: Randomly generated password for the Jupyter user (sensitive).
- `s3_ovpn_file_location`: S3 location for the OVPN VPN configuration file.

## Dependencies

Ensure you have the following prerequisites before using this module:

- Terraform >= 0.12
- AWS Provider
- `babicamir/vpn-client/aws` module

## License

This module is released under the MIT License. Please refer to the LICENSE file for detailed information.
