resource "aws_vpc" "vpc_flow_logs_anomary_detection" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc flow logs anomary detection"
  }
}
