resource "aws_kinesis_stream" "vpc_flow_logs" {
  name        = "VPCFlowLogs"
  shard_count = 1
}

resource "aws_kinesis_analytics_application" "vpc_flow_logs_analytics" {
  name = "VPCFlowLogsAnalytics"

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = aws_kinesis_stream.vpc_flow_logs.arn
      role_arn     = "arn:aws:iam::019115212452:role/service-role/kinesis-analytics-VPCFlowLogsAnalytics-ap-northeast-1"
    }

    parallelism {
      count = 1
    }

    processing_configuration {
      lambda {
        resource_arn = "arn:aws:lambda:ap-northeast-1:019115212452:function:KinesisAnalyticsProcessCompressedRecord:$LATEST"
        role_arn     = "arn:aws:iam::019115212452:role/service-role/kinesis-analytics-VPCFlowLogsAnalytics-ap-northeast-1"
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
