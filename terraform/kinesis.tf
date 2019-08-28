resource "aws_kinesis_stream" "vpc_flow_logs" {
  name        = "VPCFlowLogs"
  shard_count = 1
}
