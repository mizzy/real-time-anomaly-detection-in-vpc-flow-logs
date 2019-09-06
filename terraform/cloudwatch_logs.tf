resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "VPCFlowLogs"
}

resource "aws_cloudwatch_log_subscription_filter" "vpc_flow_logs_all_filter" {
  name            = "VPCFlowLogsAllFilter"
  log_group_name  = aws_cloudwatch_log_group.vpc_flow_logs.name
  filter_pattern  = "[version, account_id, interface_id, srcaddr != -, dstaddr != -, srcport != -, dstport != -, protocol, packets, bytes, start, end, action, log_status]"
  destination_arn = aws_kinesis_stream.vpc_flow_logs.arn
  role_arn        = aws_iam_role.cloudwatch_to_kinesis_role.arn
}

resource "aws_flow_log" "anomary_detection" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc_flow_logs_anomary_detection.id
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "VPCFlowLogsRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_logs_role_policy" {
  name = "VPCFlowLogsRolePolicy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
