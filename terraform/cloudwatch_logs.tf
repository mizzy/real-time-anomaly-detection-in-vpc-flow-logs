resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "VPCFlowLogs"
}

resource "aws_cloudwatch_log_subscription_filter" "to_kinesis" {
  name            = "VPCFlowLogsAllFilter"
  log_group_name  = aws_cloudwatch_log_group.vpc_flow_logs.name
  filter_pattern  = "[version, account_id, interface_id, srcaddr != -, dstaddr != -, srcport != -, dstport != -, protocol, packets, bytes, start, end, action, log_status]"
  destination_arn = aws_kinesis_stream.vpc_flow_logs.arn
  role_arn        = aws_iam_role.cloudwatch_to_kinesis.arn
}

resource "aws_flow_log" "anomary_detection" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc_flow_logs_anomary_detection.id
}

resource "aws_iam_role" "vpc_flow_logs" {
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

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "VPCFlowLogsRolePolicy"
  role = aws_iam_role.vpc_flow_logs.id

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

resource "aws_iam_role" "cloudwatch_to_kinesis" {
  name = "CloudWatchToKinesisRole"

  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_assume_role_policy.json
}

resource "aws_iam_role_policy" "cloudwatch_to_kinesis_role_policy" {
  name   = "CloudWatchToKinesisRolePolicy"
  role   = aws_iam_role.cloudwatch_to_kinesis.id
  policy = data.aws_iam_policy_document.cloudwatch_to_kinesis.json
}

data "aws_iam_policy_document" "cloudwatch_logs_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.ap-northeast-1.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "cloudwatch_to_kinesis" {
  statement {
    effect = "Allow"

    actions = [
      "kinesis:PutRecord",
    ]

    resources = [
      aws_kinesis_stream.vpc_flow_logs.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      aws_iam_role.cloudwatch_to_kinesis.arn,
    ]
  }
}
