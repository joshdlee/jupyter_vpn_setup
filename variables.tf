variable "organization_name" {
  description = "Organization name for the VPN client."
  type        = string
}

variable "project_name" {
  description = "Project name for the VPN client."
  type        = string
}

variable "vpn_user" {
  description = "Name of the VPN user."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the EC2 instance and VPN will be deployed."
  type        = string
}

variable "vpn_client_cidr_block" {
  description = "CIDR block for the VPN clients. It must be different from the primary VPC CIDR."
  type        = string
}

variable "split_tunnel" {
  description = "Whether to enable split tunnel in the VPN."
  type        = bool
}

variable "vpn_inactive_period" {
  description = "Inactive period for the VPN in seconds."
  type        = number
}

variable "session_timeout_hours" {
  description = "Session timeout for the VPN in hours."
  type        = number
}

variable "logs_retention_in_days" {
  description = "Logs retention period for the VPN in days."
  type        = number
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key pair name to associate with the EC2 instance."
  type        = string
}
