terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20200407",
    ]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "REPLACE ME WITH YOUR PUBLIC KEY"
}

resource "aws_security_group" "security_group" {
  name = "sec_group_github_runner"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my-instance" {
  vpc_security_group_ids = [aws_security_group.security_group.id]
  ami           = data.aws_ami.ubuntu_server.id
  instance_type = "t2.micro" ## Free tier
  associate_public_ip_address = true
  key_name="ssh-key"
  user_data = base64encode(templatefile("${path.module}/scripts/ec2.tpl", {personal_access_token=var.personal_access_token}))
  #user_data = "${file("scripts/ec2.sh")}"	
	tags = {
		Name = "GitHub-Runner"	
		Type = "terraform"
	}
}
