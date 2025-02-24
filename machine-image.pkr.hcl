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

#aws variables
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

#gcp vars
variable "gcp_project_id" {
  type    = string
  default = ""
}

variable "gcp_zone" {
  type    = string
  default = "us-central1-a"
}

variable "gcp_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "gcp_source_image" {
  type    = string
  default = "ubuntu-2404-lts" # Ubuntu 24.04 LTS
}

variable "gcp_service_account" {
  type    = string
  default = ""
}

#db variables
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

source "googlecompute" "gcp_image" {
  project_id   = var.gcp_project_id
  zone         = var.gcp_zone
  machine_type = var.gcp_machine_type
  source_image = var.gcp_source_image
  image_name   = "custom-webapp-image-{{timestamp}}"
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    # "source.amazon-ebs.ubuntu",
    "source.googlecompute.gcp_image",
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y unzip nodejs npm mysql-server nginx",
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
