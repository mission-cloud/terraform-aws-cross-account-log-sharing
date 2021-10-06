output "target_arn" {
  depends_on = [aws_kinesis_firehose_delivery_stream.this]
  value = aws_kinesis_firehose_delivery_stream.this.*.arn
}
