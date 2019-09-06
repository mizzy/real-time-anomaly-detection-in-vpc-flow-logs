resource "aws_lambda_function" "kinesis_analytics_process_compressed_record" {
  function_name = "KinesisAnalyticsProcessCompressedRecord"
  handler       = "index.handler"

  runtime = "nodejs10.x"
  role    = aws_iam_role.kinesis_analytics_process_compressed_record.arn
  timeout = 60
}
