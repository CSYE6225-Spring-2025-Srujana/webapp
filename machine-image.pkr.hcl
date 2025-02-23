packer {
  required_plugins {
    amazon = {
      version = ">=1.0.0,<2.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

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

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "webapp_zip_path" {
  type    = string
  default = "../../Assignment4/webapp.zip"
}

variable "DB_HOST" {
  type    = string
  default = "localhost"
}

variable "DB_USER" {
  type    = string
  default = "srujanaadapa"
}

variable "DB_PASSWORD" {
  type    = string
  default = "mysql"
}

variable "DB_NAME" {
  type    = string
  default = "webapp"
}

variable "DB_PORT" {
  type    = string
  default = "3306"
}

variable "DB_DIALECT" {
  type    = string
  default = "mysql"
}

variable "DB_FORCE_CHANGES" {
  type    = bool
  default = false
}

source "amazon-ebs" "ubuntu" {
  profile       = var.aws_profile
  ami_name      = "${var.ami_name_prefix}-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami    = var.source_ami
  ssh_username  = var.ssh_username
  ami_groups    = [] # Keep the AMI private
  tags = {
    Name = "My-WebApp-AMI"
  }
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu",
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y unzip nodejs npm mysql-server",
      "sudo systemctl enable mysql",
      "sudo systemctl start mysql"
    ]
  }

  # Upload the zipped web application
  provisioner "file" {
    source      = var.webapp_zip_path
    destination = "/home/ubuntu/webapp.zip"
  }

  provisioner "file" {
    source      = "deploy_webapp.sh"
    destination = "/home/ubuntu/deploy_webapp.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /home/ubuntu/deploy_webapp.sh",
      "bash /home/ubuntu/deploy_webapp.sh"
    ]
  }

  # Upload the database setup script
  provisioner "file" {
    source      = "setup_db.sh"
    destination = "/home/ubuntu/setup_db.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DB_HOST=${var.DB_HOST}",
      "DB_USER=${var.DB_USER}",
      "DB_PASSWORD=${var.DB_PASSWORD}",
      "DB_NAME=${var.DB_NAME}",
      "DB_PORT=${var.DB_PORT}",
      "DB_DIALECT=${var.DB_DIALECT}"
    ]
    inline = [
      "chmod +x /home/ubuntu/deploy_webapp.sh",
      "bash /home/ubuntu/deploy_webapp.sh"
    ]
  }

}
