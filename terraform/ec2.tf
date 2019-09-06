resource "aws_instance" "vpc_flow_logs_anomary_detection" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.vpc_flow_logs_anomary_detection.id}"

  vpc_security_group_ids = [
    "${aws_security_group.vpc_flow_logs_anomary_detection.id}",
  ]

  associate_public_ip_address = true

  key_name = "aws_mizzy"

  tags = {
    Name = "vpc flow logs anomary detection"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}
