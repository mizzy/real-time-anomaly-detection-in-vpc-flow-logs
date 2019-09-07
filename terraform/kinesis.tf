resource "aws_kinesis_stream" "vpc_flow_logs" {
  name        = "VPCFlowLogs"
  shard_count = 1
}

resource "aws_kinesis_analytics_application" "vpc_flow_logs_analytics" {
  name = "VPCFlowLogsAnalytics"

  code = file("analytics.sql")

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = aws_kinesis_stream.vpc_flow_logs.arn
      role_arn     = aws_iam_role.kinesis_analytics.arn
    }

    parallelism {
      count = 1
    }

    processing_configuration {
      lambda {
        resource_arn = "${aws_lambda_function.kinesis_analytics_process_compressed_record.arn}:$LATEST"
        role_arn     = aws_iam_role.kinesis_analytics.arn
      }
    }

    schema {
      record_encoding = "UTF-8"

      record_format {
        mapping_parameters {

          json {
            record_row_path = "$"
          }
        }
      }

      record_columns {
        name     = "messageType"
        mapping  = "$.messageType"
        sql_type = "VARCHAR(16)"
      }

      record_columns {
        name     = "owner"
        mapping  = "$.owner"
        sql_type = "BIGINT"
      }

      record_columns {
        name     = "logGroup"
        mapping  = "$.logGroup"
        sql_type = "VARCHAR(16)"
      }

      record_columns {
        name     = "logStream"
        mapping  = "$.logStream"
        sql_type = "VARCHAR(32)"
      }

      record_columns {
        name     = "subscriptionFilters"
        mapping  = "$.subscriptionFilters[0:]"
        sql_type = "VARCHAR(32)"
      }

      record_columns {
        name     = "id"
        mapping  = "$.logEvents[0:].id"
        sql_type = "DOUBLE"
      }

      record_columns {
        name     = "COL_timestamp"
        mapping  = "$.logEvents[0:].timestamp"
        sql_type = "BIGINT"
      }

      record_columns {
        name     = "message"
        mapping  = "$.logEvents[0:].message"
        sql_type = "VARCHAR(128)"
      }

      record_columns {
        name     = "srcaddr"
        mapping  = "$.logEvents[0:].extractedFields.srcaddr"
        sql_type = "VARCHAR(16)"
      }

      record_columns {
        name     = "dstport"
        mapping  = "$.logEvents[0:].extractedFields.dstport"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.start"
        name     = "COL_start"
        sql_type = "INTEGER"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.dstaddr"
        name     = "dstaddr"
        sql_type = "VARCHAR(16)"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.version"
        name     = "version"
        sql_type = "INTEGER"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.packets"
        name     = "packets"
        sql_type = "INTEGER"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.protocol"
        name     = "protocol"
        sql_type = "INTEGER"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.account_id"
        name     = "account_id"
        sql_type = "BIGINT"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.interface_id"
        name     = "interface_id"
        sql_type = "VARCHAR(32)"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.log_status"
        name     = "log_status"
        sql_type = "VARCHAR(4)"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.bytes"
        name     = "bytes"
        sql_type = "INTEGER"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.srcport"
        name     = "srcport"
        sql_type = "INTEGER"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.action"
        name     = "action"
        sql_type = "VARCHAR(8)"
      }
      record_columns {
        mapping  = "$.logEvents[0:].extractedFields.end"
        name     = "COL_end"
        sql_type = "INTEGER"
      }
    }
  }
}

resource "aws_iam_role" "kinesis_analytics" {
  name                  = "kinesis-analytics-VPCFlowLogsAnalytics"
  assume_role_policy    = data.aws_iam_policy_document.kinesis_analytics_assume_role_policy.json
  path                  = "/service-role/"
  force_detach_policies = true
}

resource "aws_iam_role_policy" "kinesis_analytics" {
  name   = "KinesisAnalyticsVPCFlowLogsAnalyticsRolePolicy"
  role   = aws_iam_role.kinesis_analytics.id
  policy = data.aws_iam_policy_document.kinesis_analytics.json
}

data "aws_iam_policy_document" "kinesis_analytics_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kinesis_analytics" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "${aws_lambda_function.kinesis_analytics_process_compressed_record.arn}:$LATEST",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords"
    ]

    resources = [
      aws_kinesis_stream.vpc_flow_logs.arn
    ]
  }
}
