<!-- Auto generated file -->

# AWS CIS Baseline
 [![Build Status](https://circleci.com/gh/ifunky/terraform-aws-baseline-cis.svg?style=svg)](https://circleci.com/gh/ifunky/terraform-aws-baseline-account) [![Latest Version](https://img.shields.io/github/release/ifunky/terraform-aws-baseline-cis.svg)](https://github.com/ifunky/terraform-aws-baseline-account/releases)

This module will set up an AWS account with the a basic secure configuration baseline based on [CIS Amazon Web Services Foundations] v1.2.0.

[CIS Amazon Web Services Foundations]: https://www.cisecurity.org/benchmark/amazon_web_services/

## Features

### Identity and Access Management

- Set up IAM Password complxity policy.
- Creates an IAM role for contacting AWS support for incident handling.
- Enable AWS Config rules to audit root account status (NOT ENABLED).

### Logging & Monitoring

- Enable CloudTrail in all regions and deliver events to CloudWatch Logs.
- CloudTrail logs are encrypted using AWS Key Management Service.
- All logs are stored in the S3 bucket with access logging enabled.
- Logs are automatically archived into Amazon Glacier after the given period(defaults to 90 days).
- Set up CloudWatch alarms to notify you when critical changes happen in your AWS account.
- Creates default CloudWatch dashboards based on the security alarms
- Enable AWS Config in all regions to automatically take configuration snapshots (NOT ENABLED).
- Enable SecurityHub and subscribe CIS benchmark standard.

### Networking

- Remove rules in the default security group.
- Enable AWS Config rules to audit unrestricted common ports in Security Group rules.
- Enable VPC Flow Logs (REJECT) in all regions.

### Cloudwatch Alarms
- Set of alarms for each of the CIS recommended checks
- SNS alerts for alarms
- Clousdwatch dashboards

#### Control Tower
If your management account is managed by Control Tower it will manage CloudTrail and logging so this module 
can be set to ignore these resources with the `is_managed_by_control_tower` setting.

> NOTE: This module doesn't create S3 buckets, this is assumed to be in place already

# How to use this project
usage: |-
  ```hcl
      module "aws_cis_secure_baseline" {
      source = "git::https://github.com/ifunky/terraform-aws-baseline-cis.git?ref=master"
    
     is_managed_by_control_tower     = true 

      vpc_log_retention_in_days       = 90
      vpc_id                          = data.aws_vpc.selected.id
      
      region                          = var.region
      cloudtrail_name                 = var.cloudtrail_name
      cloudtrail_multi_region         = true
      cloudtrail_logging              = true
      cloudtrail_log_file_validation  = true
      cloudtrail_log_group_name       = var.cloudtrail_log_group_name
      cloudtrail_sns_topic            = var.cloudtrail_sns_topic
      cloudtrail_bucket_name          = var.cloudtrail_bucket_name
      
      s3_logging_bucket_name          = var.s3_access_bucket_name
      
      tags = {
        Terraform = "true"
      }
      }
  ```





## Makefile Targets
The following targets are available: 

```
createdocs/help                Create documentation help
polydev/createdocs             Run PolyDev createdocs directly from your shell
polydev/help                   Help on using PolyDev locally
polydev/init                   Initialise the project
polydev/validate               Validate the code
polydev                        Run PolyDev interactive shell to start developing with all the tools or run AWS CLI commands :-)
```
# Module Specifics

Core Version Constraints:
* `>= 1.0`

Provider Requirements:
* **aws (`hashicorp/aws`):** `~> 5.0`

## Input Variables
* `additional_endpoint_arns` (default `[]`): Any alert endpoints, such as autoscaling, or app scaling endpoint arns that will respond to an alert
* `cloudtrail_bucket_name` (default `""`): The name of the S3 bucket to be created.  Leave blank if using Control Tower.
* `cloudtrail_log_file_validation` (default `true`): Specifies whether log file integrity validation is enabled
* `cloudtrail_log_group_name` (default `"/aws/cloudtrail/CloudTrail-logs"`): The name of the log group to be created
* `cloudtrail_logging` (default `true`): Enables logging for the trail
* `cloudtrail_metric_namespace` (default `"CISBenchmark"`): A namespace for grouping all of the metrics together
* `cloudtrail_multi_region` (default `true`): Specifies whether the trail is created in the current region or in all regions
* `cloudtrail_name` (default `"vpc-cloudtrail"`): Specifies the name of the trail
* `cloudtrail_sns_topic` (default `""`): ARN of SNS topic for sending Cloudwatch alarms to.  Useful if you have a centralised account that handles this.
* `cloudwatch_logs_retention_in_days` (default `90`): Cloudwatch retention in days
* `create_dashboard` (default `true`): When true a dashboard that displays tha statistics as a line graph will be created in CloudWatch
* `create_log_group` (default `true`): True if a CloudWatch log group and metrics should be created. False otherwise
* `create_sns_topic` (default `false`): When true an SNS topic will be created with the name specifed in `cloudtrail_sns_topic` 
* `iam_max_password_age` (default `90`): Maximum password age allowed.  CIS recommends to set 90 days or less.
* `iam_minimum_password_length` (default `14`): Minimum password length.  CIS recommends a minimum of 14.
* `iam_password_reuse_prevention` (default `24`): Prevent reuse of passwords.  CIS recommends a minimum of 24.
* `iam_require_lowercase_characters` (default `true`): Require password to contain lowercase letters.  CIS recommends this to be enabled.
* `iam_require_numbers` (default `true`): Require password to contain numbers.  CIS recommends this to be enabled.
* `iam_require_symbols` (default `true`): Require password to contain symbols.  CIS recommends this to be enabled.
* `iam_require_uppercase_characters` (default `true`): Require password to contain uppercase letters.  CIS recommends this to be enabled.
* `iam_support_role_name` (default `"aws-support-role"`): IAM Support role name.
* `is_managed_by_control_tower` (default `false`): Set to true if managed by Control Tower, includes CloudTrail
* `key_deletion_window_in_days` (default `10`): Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.
* `log_group_name` (default `"vpc-flow-log"`): Log group name for flow logs
* `prefix` (default `"vpc"`): The prefix for the resource names. You will probably want to set this to the name of your VPC, if you have multiple.
* `region` (required): The AWS regions where resources are created
* `tags` (default `{}`): A map of tags to add to all resources
* `traffic_type` (default `"REJECT"`): https://www.terraform.io/docs/providers/aws/r/flow_log.html#traffic_type
* `vpc_default_clear` (default `true`): Clear any default settings in VPC and RouteTables.
* `vpc_default_network_acl` (default `""`): Optional.  VPC default network ACL, typically set when you have removed the default VPCs in an account
* `vpc_id` (required): VPC ID to configure flow logs for.
* `vpc_log_retention_in_days` (required): Number of days to retain logs for. CIS recommends 365 days.  Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely.

## Output Values
* `log_group_name`
* `sns_arn`: Arn of the SNS topic
* `support_iam_role_arn`: The ARN of the IAM role used for the support user.
* `support_iam_role_name`: The name of the IAM role used for the support user.

## Managed Resources
* `aws_cloudtrail.cloudtrail_default` from `aws`
* `aws_cloudwatch_dashboard.main` from `aws`
* `aws_cloudwatch_dashboard.main_individual` from `aws`
* `aws_cloudwatch_log_group.flow_log_group` from `aws`
* `aws_cloudwatch_log_group.log_group_default` from `aws`
* `aws_cloudwatch_log_metric_filter.default` from `aws`
* `aws_cloudwatch_metric_alarm.default` from `aws`
* `aws_default_route_table.default` from `aws`
* `aws_default_security_group.default` from `aws`
* `aws_default_vpc.default` from `aws`
* `aws_flow_log.vpc_flow_log` from `aws`
* `aws_iam_account_password_policy.iam_password_policy` from `aws`
* `aws_iam_policy.cloudtrail_access_policy` from `aws`
* `aws_iam_policy_attachment.cloudtrail_access_policy_attachment` from `aws`
* `aws_iam_role.cloudtrail_role` from `aws`
* `aws_iam_role.iam_log_role` from `aws`
* `aws_iam_role.support` from `aws`
* `aws_iam_role_policy.log_policy` from `aws`
* `aws_iam_role_policy_attachment.support_policy` from `aws`
* `aws_kms_key.cloudtrail` from `aws`
* `aws_s3_bucket.default` from `aws`
* `aws_s3_bucket_policy.default` from `aws`
* `aws_sns_topic.sns_topic_default` from `aws`

## Data Resources
* `data.aws_caller_identity.current` from `aws`
* `data.aws_iam_policy_document.assume_role_policy` from `aws`
* `data.aws_iam_policy_document.cloudtrail_alarm_policy` from `aws`
* `data.aws_iam_policy_document.cloudtrail_assume_policy` from `aws`
* `data.aws_iam_policy_document.cloudtrail_kms` from `aws`
* `data.aws_iam_policy_document.cloudtrail_policy` from `aws`
* `data.aws_iam_policy_document.default` from `aws`
* `data.aws_iam_policy_document.log_policy` from `aws`
* `data.aws_iam_policy_document.support_role_policy` from `aws`
* `data.aws_partition.current` from `aws`
* `data.aws_region.current` from `aws`




## Related Projects

Here are some useful related projects.

- [PolyDev](https://github.com/ifunky/polydev) - PolyDev repo and setup guide





## References

For more information please see the following links of interest: 

- [CIS Benchmark](https://d1.awsstatic.com/whitepapers/compliance/AWS_CIS_Foundations_Benchmark.pdf) - v1.2 PDF

