resource "aws_lambda_function" "kinesis_analytics_process_compressed_record" {
  function_name = "KinesisAnalyticsProcessCompressedRecord"
  filename         = data.archive_file.kinesis_analytics_process_compressed_record.output_path
  handler       = "index.handler"

  runtime = "nodejs10.x"
  role    = aws_iam_role.kinesis_analytics_process_compressed_record.arn
  timeout = 60
}

data "archive_file" "kinesis_analytics_process_compressed_record" {
  type        = "zip"
  source_dir  = "lambda/KinesisAnalyticsProcessCompressedRecord"
  output_path = "lambda/upload/KinesisAnalyticsProcessCompressedRecord.zip"
}
