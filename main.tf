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