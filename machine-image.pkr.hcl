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
  default = ""
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
    #"source.googlecompute.gcp_image",
  ]

  provisioner "shell" {
    inline = [
      "sudo groupadd -r csye6225",
      "sudo useradd -r -g csye6225 -s /usr/sbin/nologin csye6225",
      "sudo mkdir -p /home/csye6225",
      "sudo chown -R csye6225:csye6225 /home/csye6225",
      "sudo chmod -R 750 /home/csye6225"
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y unzip nodejs npm mysql-server",
      "sudo systemctl enable mysql",
      "sudo systemctl start mysql"
    ]
  }

  # Copy application artifacts
#   provisioner "file" {
#     source      = "webapp.zip"
#     destination = "/home/csye6225/webapp.zip"
#   }

  # Set ownership & permissions
#   provisioner "shell" {
#     inline = [
#       "sudo chown -R csye6225:csye6225 /home/csye6225",
#       "sudo chmod -R 750 /home/csye6225"
#     ]
#   }

  # Deploy WebApp
  provisioner "file" {
    source      = "deploy_webapp.sh"
    destination = "/home/csye6225/deploy_webapp.sh"
  }

  provisioner "file" {
    source      = "setup_db.sh"
    destination = "/home/csye6225/setup_db.sh"
  }

  provisioner "shell" {
    inline = [
      "export DB_HOST='${var.DB_HOST}'",
      "export DB_USER='${var.DB_USER}'",
      "export DB_PASSWORD='${var.DB_PASSWORD}'",
      "export DB_NAME='${var.DB_NAME}'",
      "export DB_PORT='${var.DB_PORT}'",
      "export DB_DIALECT='${var.DB_DIALECT}'",
      "export DB_FORCE_CHANGES='${var.DB_FORCE_CHANGES}'",
      "sudo chmod +x /home/csye6225/*.sh",
      "sudo bash /home/csye6225/setup_db.sh",
      "sudo bash /home/csye6225/deploy_webapp.sh"
    ]
  }

  # Add Systemd Service
  provisioner "file" {
    source      = "webapp.service"
    destination = "/etc/systemd/system/webapp.service"
  }

  provisioner "shell" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable webapp.service"
    ]
  }

}
