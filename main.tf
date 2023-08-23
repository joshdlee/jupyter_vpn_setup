provider "random" {}

resource "random_password" "jupyter_user_password" {
  length  = 16
  special = true
}

# Fetch VPC Details
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ssm_parameter" "my-amzn-linux-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Setup VPN Client using the provided module
module "vpn-client" {
  source  = "babicamir/vpn-client/aws"
  version = "0.0.3"

  organization_name      = var.organization_name
  project-name           = var.project_name
  aws-vpn-client-list    = [var.vpn_user]
  vpc_id                 = var.vpc_id
  subnet_id              = var.subnet_id
  client_cidr_block      = var.vpn_client_cidr_block
  split_tunnel           = var.split_tunnel
  vpn_inactive_period    = var.vpn_inactive_period
  session_timeout_hours  = var.session_timeout_hours
  logs_retention_in_days = var.logs_retention_in_days
}

# IAM Role and Instance Profile for SSM
resource "aws_iam_role" "ssm_role" {
  name = "SSMRoleForEC2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfileForEC2"
  role = aws_iam_role.ssm_role.name
}

# Security Group for JupyterHub that allows traffic from the VPC
resource "aws_security_group" "jupyter_sg" {
  name        = "jupyter_sg"
  description = "Allow traffic for JupyterHub from VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS EC2 instance for JupyterHub
resource "aws_instance" "jupyterhub" {
  ami                  = data.aws_ssm_parameter.my-amzn-linux-ami.value
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = "jupyterhub"
  }

  user_data = <<-EOF
              #!/bin/bash

              # As a root user
              sudo -i

              # Install python3
              yum install python3 python3-pip python3-devel python3-setuptools python3-virtualenv -y

              # Create and activate virtual environment
              python3 -m venv /opt/JupyterTeam
              source /opt/JupyterTeam/bin/activate

              # Install essential Python packages
              pip install wheel
              pip install notebook
              pip install jupyterhub jupyterlab ipywidgets
              pip install pandas openpyxl configparser

              # Downgrade URLLIB python library
              pip install urllib3==1.25.11

              # Install Node.js and NPM
              curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
              yum install -y nodejs

              # Install configurable-http-proxy
              npm install -g configurable-http-proxy

              # Create directory for jupyterhub config and generate the default configuration file
              mkdir -p /opt/JupyterTeam/etc/jupyterhub/
              cd /opt/JupyterTeam/etc/jupyterhub/
              /opt/JupyterTeam/bin/jupyterhub --generate-config

              # Append configurations to the jupyterhub configuration file
              echo "c.Spawner.default_url = '/lab'" >> /opt/JupyterTeam/etc/jupyterhub/jupyterhub_config.py

              # Create user for JupyterHub
              adduser ${var.vpn_user}
              echo "${var.vpn_user}:${random_password.jupyter_user_password.result}" | chpasswd

              # Setup jupyterhub as a systemd service
              mkdir -p /opt/JupyterTeam/etc/systemd

              cat > /opt/JupyterTeam/etc/systemd/jupyterhub.service <<EOL
              [Unit]
              Description=JupyterHub
              After=syslog.target network.target

              [Service]
              User=root
              Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/JupyterTeam/bin"
              ExecStart=/opt/JupyterTeam/bin/jupyterhub -f /opt/JupyterTeam/etc/jupyterhub/jupyterhub_config.py

              [Install]
              WantedBy=multi-user.target
              EOL

              # Link the service configuration file to systemd directory
              ln -s /opt/JupyterTeam/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service

              # Reload configuration files, enable and start the service
              systemctl daemon-reload
              systemctl enable jupyterhub.service
              systemctl start jupyterhub.service
              EOF

  vpc_security_group_ids = [aws_security_group.jupyter_sg.id]
}
