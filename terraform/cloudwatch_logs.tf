resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "VPCFlowLogs"
}

resource "aws_cloudwatch_log_subscription_filter" "vpc_flow_logs_all_filter" {
  name            = "VPCFlowLogsAllFilter"
  log_group_name  = "${aws_cloudwatch_log_group.vpc_flow_logs.name}"
  filter_pattern  = "[version, account_id, interface_id, srcaddr != -, dstaddr != -, srcport != -, dstport != -, protocol, packets, bytes, start, end, action, log_status]"
  destination_arn = "${aws_kinesis_stream.vpc_flow_logs.arn}"
  role_arn        = "${aws_iam_role.cloudwatch_to_kinesis_role.arn}"
}
