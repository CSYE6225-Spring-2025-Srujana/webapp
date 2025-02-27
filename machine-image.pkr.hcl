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
  default = "t2.micro"
}

variable "aws_vpc" {
  type    = string
  default = "t2.micro"
}

variable "aws_subnet" {
  type    = string
  default = "t2.micro"
}

variable "aws_ami_users" {
  type    = list(string)
  default = ["794038250804", "796973511897"]
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

# GCP Variables
variable "gcp_project_id" {
  type    = string
  default = "branded-coder-451905-s9"
}

variable "gcp_source_image" {
  type    = string
  default = "ubuntu-2404-noble-amd64-v20250214"
}

variable "gcp_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "gcp_zone" {
  type    = string
  default = "us-central1-a"
}

variable "gcp_image_prefix" {
  type    = string
  default = "webapp-gcp"
}

variable "gcp_storage" {
  type    = number
  default = 25
}

variable "gcp_disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "gcp_demo_project" {
  type    = string
  default = "vast-collective-452106-k3"
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
  # Use the default VPC subnet
  vpc_id    = var.aws_vpc
  subnet_id = var.aws_subnet
}

source "googlecompute" "gcp_image" {
  project_id   = var.gcp_project_id
  source_image = var.gcp_source_image
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone
  image_name   = "${var.gcp_image_prefix}-{{timestamp}}"
  ssh_username = var.ssh_username
  image_labels = {
    created_by = "packer"
  }
  disk_size = var.gcp_storage
  disk_type = var.gcp_disk_type
}


build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.gcp_image",
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
      "sudo apt install -y unzip nodejs npm mysql-server",
      "sudo systemctl enable mysql",
      "sudo systemctl start mysql"
    ]
  }

  provisioner "file" {
    source      = "${var.project_path}"
    destination = "/tmp/webapp.zip"
  }

  provisioner "file" {
    source      = "deploy_webapp.sh"
    destination = "/tmp/deploy_webapp.sh"
  }

  provisioner "file" {
    source      = "setup_db.sh"
    destination = "/tmp/setup_db.sh"
  }

  # Move and set permissions for scripts
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/deploy_webapp.sh /opt/csye6225/deploy_webapp.sh",
      "sudo chown csye6225:csye6225 /opt/csye6225/deploy_webapp.sh",
      "sudo chmod 755 /opt/csye6225/deploy_webapp.sh",
      "sudo mv /tmp/setup_db.sh /opt/csye6225/setup_db.sh",
      "sudo chown csye6225:csye6225 /opt/csye6225/setup_db.sh",
      "sudo chmod 755 /opt/csye6225/setup_db.sh"
    ]
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
      "sudo -E bash /opt/csye6225/setup_db.sh",
      "sudo -E bash /opt/csye6225/deploy_webapp.sh"
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

  post-processor "shell-local" {
    only = ["googlecompute.gcp_image"]
    inline = [
      "echo 'Fetching the latest created image...'",
      "IMAGE_NAME=$(gcloud compute images list --filter='name~${var.gcp_image_prefix}-.*' --sort-by=~creationTimestamp --limit=1 --format='value(name)')",
      "if [[ -z \"$IMAGE_NAME\" ]]; then echo 'No image found!'; exit 1; fi",
      "echo 'Creating a new image in ${var.gcp_demo_project} from ' $IMAGE_NAME",
      "gcloud compute images create $IMAGE_NAME --project=${var.gcp_demo_project} --source-image=$IMAGE_NAME --source-image-project=${var.gcp_project_id}"
    ]
  }

}
