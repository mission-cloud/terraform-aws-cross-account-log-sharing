output "kinesis_arn" {
  value = aws_kinesis_firehose_delivery_stream.this.arn
}

output "log_destination_arn" {
  value = aws_cloudwatch_log_destination.this.arn
}
