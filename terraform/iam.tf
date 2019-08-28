resource "aws_iam_role" "cloudwatch_to_kinesis_role" {
  name = "CloudWatchToKinesisRole"

  assume_role_policy = "${data.aws_iam_policy_document.logs_policy_document.json}"
}

resource "aws_iam_role_policy" "cloudwatch_to_kinesis_role_policy" {
  name   = "CloudWatchToKinesisRolePolicy"
  role   = "${aws_iam_role.cloudwatch_to_kinesis_role.id}"
  policy = "${data.aws_iam_policy_document.cloudwatch_to_kinesis_role_policy_document.json}"
}

data "aws_iam_policy_document" "logs_policy_document" {
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

data "aws_iam_policy_document" "cloudwatch_to_kinesis_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "kinesis:PutRecord",
    ]

    resources = [
      "${aws_kinesis_stream.vpc_flow_logs.arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "${aws_iam_role.cloudwatch_to_kinesis_role.arn}",
    ]
  }
}

output "foo" {
  value = "${aws_iam_role.cloudwatch_to_kinesis_role.arn}"
}

output "bar" {
  value = "${aws_kinesis_stream.vpc_flow_logs.arn}"
}
