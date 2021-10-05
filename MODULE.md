## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.60.0 |
| <a name="provider_aws.sender"></a> [aws.sender](#provider\_aws.sender) | 3.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_destination.this](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/cloudwatch_log_destination) | resource |
| [aws_cloudwatch_log_destination_policy.this](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/cloudwatch_log_destination_policy) | resource |
| [aws_cloudwatch_log_subscription_filter.sender](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_policy.cw_to_kinesis](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.cw_to_kinesis](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cw_kinesis](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_stream.this](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/kinesis_stream) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cwl_to_kinesis](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sender_log_destination_access](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_cwl](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | An IAM policy document (in JSON format, written using IAM policy grammar) that governs the set of users that are allowed to write to your destination. | `string` | `""` | no |
| <a name="input_cw_kinesis_role_name"></a> [cw\_kinesis\_role\_name](#input\_cw\_kinesis\_role\_name) | The name of the role that is allowed to send logs to the Kinesis stream | `string` | `"CWToKinesis"` | no |
| <a name="input_data_stream_shard_count"></a> [data\_stream\_shard\_count](#input\_data\_stream\_shard\_count) | The number of shards that the stream will use. Amazon has guidelines for specifying the Stream size that should be referenced when creating a Kinesis stream. See [Amazon Kinesis Streams](https://docs.aws.amazon.com/streams/latest/dev/amazon-kinesis-streams.html) for more. | `number` | `1` | no |
| <a name="input_destination_name"></a> [destination\_name](#input\_destination\_name) | The name of the destination you want to create. | `string` | `"RecipientStream"` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Tags that are applicable to all resources ie: CreatedBy = MissionCloud | `object({})` | `{}` | no |
| <a name="input_log_data_destination"></a> [log\_data\_destination](#input\_log\_data\_destination) | AWS Account number for the destination. | `string` | n/a | yes |
| <a name="input_log_data_sender"></a> [log\_data\_sender](#input\_log\_data\_sender) | AWS Account number for the data sender. | `string` | n/a | yes |
| <a name="input_log_subscription_filter_name"></a> [log\_subscription\_filter\_name](#input\_log\_subscription\_filter\_name) | The name of the sending account's subscription filter for a log group | `string` | `"All - ' '"` | no |
| <a name="input_log_subscription_filter_pattern"></a> [log\_subscription\_filter\_pattern](#input\_log\_subscription\_filter\_pattern) | Subscription filter pattern to search for and match terms, phrases, or values in log events. | `string` | `" "` | no |
| <a name="input_sender_log_group"></a> [sender\_log\_group](#input\_sender\_log\_group) | The CloudWatch log group associated with the log data sender | `string` | n/a | yes |
| <a name="input_stream_encryption_type"></a> [stream\_encryption\_type](#input\_stream\_encryption\_type) | The encryption type to use. The only acceptable values are NONE or KMS. The default value is NONE. | `string` | `"NONE"` | no |
| <a name="input_stream_kms_key_id"></a> [stream\_kms\_key\_id](#input\_stream\_kms\_key\_id) | The GUID for the customer-managed KMS key to use for encryption. You can also use a Kinesis-owned master key by specifying the alias alias/aws/kinesis. | `string` | `""` | no |
| <a name="input_stream_retention_period"></a> [stream\_retention\_period](#input\_stream\_retention\_period) | Length of time data records are accessible after they are added to the stream. Max is 8760. Min is 24 | `number` | `24` | no |
| <a name="input_stream_timeouts"></a> [stream\_timeouts](#input\_stream\_timeouts) | Nested block argument that allows you to customize how long certain operations are allowed to take before being considered to have failed. | `object({})` | <pre>{<br>  "create": "10m",<br>  "delete": "120m",<br>  "update": "30m"<br>}</pre> | no |
| <a name="input_target_arn"></a> [target\_arn](#input\_target\_arn) | The Amazon Resource Name (ARN) of the AWS resource that you want to use as the destination of the subscription feed. | `string` | `""` | no |

## Outputs

No outputs.
