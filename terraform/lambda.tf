resource "aws_lambda_function" "kinesis_analytics_process_compressed_record" {
  function_name = "KinesisAnalyticsProcessCompressedRecord"
  handler       = "index.handler"

  runtime = "nodejs10.x"
  role    = "arn:aws:iam::019115212452:role/service-role/KinesisAnalyticsProcessCompressedRecord-role-utg78psh"
  timeout = 60
}
