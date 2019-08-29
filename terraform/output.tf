output "instance public dns" {
  value = "${aws_instance.vpc_flow_logs_anomary_detection.public_dns}"
}
