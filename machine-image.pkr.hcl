packer {
  required_plugins {
    amazon = {
      version = ">=1.0.0,<2.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">=0.0.1"
    }
  }
}

variable "project_path" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = "t2.micro"
}

variable "ssh_handshake_attempts" {
  type    = number
  default = 100
}

variable "ssh_timeout" {
  type    = string
  default = "60m"
}

# AWS Variables
#for local testing
variable "aws_profile" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name_prefix" {
  type    = string
  default = "webapp-ami"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "source_ami" {
  type    = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "aws_ami_users" {
  type    = list(string)
  default = []
}

variable "aws_device_name" {
  type    = string
  default = "/dev/sda1"
}

variable "aws_volume_size" {
  type    = number
  default = 20
}

variable "aws_volume_type" {
  type    = string
  default = "gp2"
}

variable "aws_delete_on_termination" {
  type    = bool
  default = true
}

source "amazon-ebs" "ubuntu" {
  profile       = var.aws_profile
  region        = var.aws_region
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  ami_users     = var.aws_ami_users
  instance_type = var.instance_type
  source_ami    = var.source_ami
  ssh_username  = var.ssh_username
  ami_groups    = []
  tags = {
    Name = "My-WebApp-AMI"
  }
  launch_block_device_mappings {
    device_name           = var.aws_device_name
    volume_size           = var.aws_volume_size
    volume_type           = var.aws_volume_type
    delete_on_termination = var.aws_delete_on_termination
  }

  ssh_timeout            = var.ssh_timeout
  ssh_handshake_attempts = var.ssh_handshake_attempts
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu",
  ]

  provisioner "shell" {
    inline = [
      "sudo groupadd -r csye6225",
      "sudo useradd -r -g csye6225 -s /usr/sbin/nologin csye6225",
      "sudo mkdir -p /opt/csye6225",
      "sudo chown -R csye6225:csye6225 /opt/csye6225",
      "sudo chmod -R 755 /opt/csye6225"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y unzip nodejs npm mysql-client"
    ]
  }

  provisioner "file" {
    source      = "${var.project_path}"
    destination = "/tmp/webapp.zip"
    timeout     = "30m"
  }

  provisioner "file" {
    source      = "deploy_webapp.sh"
    destination = "/tmp/deploy_webapp.sh"
  }

  provisioner "file" {
    source      = "cloudwatch-config.json"
    destination = "/tmp/cloudwatch-config.json"
  }

  provisioner "file" {
    source      = "installCloudWatchAgent.sh"
    destination = "/tmp/installCloudWatchAgent.sh"
  }

  # Move and set permissions for scripts
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/deploy_webapp.sh /opt/csye6225/deploy_webapp.sh",
      "sudo chown csye6225:csye6225 /opt/csye6225/deploy_webapp.sh",
      "sudo chmod 755 /opt/csye6225/deploy_webapp.sh",
      "sudo mv /tmp/installCloudWatchAgent.sh /opt/csye6225/installCloudWatchAgent.sh",
      "sudo chown csye6225:csye6225 /opt/csye6225/installCloudWatchAgent.sh",
      "sudo chmod 755 /opt/csye6225/installCloudWatchAgent.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo -E bash /opt/csye6225/deploy_webapp.sh",
      "sudo -E bash /opt/csye6225/installCloudWatchAgent.sh"
    ]
  }

  provisioner "file" {
    source      = "webapp.service"
    destination = "/tmp/webapp.service"
  }

  provisioner "shell" {
    inline = [
      "echo 'Moving webapp.service to /etc/systemd/system/'",
      "sudo mv /tmp/webapp.service /etc/systemd/system/webapp.service",
      "sudo chmod 644 /etc/systemd/system/webapp.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable webapp.service"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
