resource "aws_vpc" "vpc_flow_logs_anomary_detection" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc flow logs anomary detection"
  }
}

resource "aws_security_group" "vpc_flow_logs_anomary_detection" {
  name   = "VPCFlowLogsAnomaryDetection"
  vpc_id = "${aws_vpc.vpc_flow_logs_anomary_detection.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "vpc_flow_logs_anomary_detection" {
  vpc_id     = aws_vpc.vpc_flow_logs_anomary_detection.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "vpc flow logs anomary detection"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_flow_logs_anomary_detection.id

  tags = {
    Name = "vpc flow logs anomary detection"
  }
}

resource "aws_route_table" "vpc_flow_logs_anomary_detection" {
  vpc_id = aws_vpc.vpc_flow_logs_anomary_detection.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "VPC flow logs anomary detection"
  }
}

resource "aws_route_table_association" "vpc_flow_logs_anomary_detection" {
  subnet_id      = aws_subnet.vpc_flow_logs_anomary_detection.id
  route_table_id = aws_route_table.vpc_flow_logs_anomary_detection.id
}
