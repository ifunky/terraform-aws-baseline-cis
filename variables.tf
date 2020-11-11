# S3 Access log Variables
variable "s3_logging_bucket_name" {
  description = "Bucket name used for S3 access logging"
}

# Logic flow options
variable is_managed_by_control_tower {
  type        = bool
  description = "Set to true if managed by Control Tower, includes CloudTrail"
  default     = false
}

# IAM Base Account Variables
variable "iam_minimum_password_length" {
  description = "Minimum password length.  CIS recommends a minimum of 14."
  default     = 14
}
variable "iam_password_reuse_prevention" {
  description = "Prevent reuse of passwords.  CIS recommends a minimum of 24."
  default     = 24
}
variable "iam_max_password_age" {
  description = "Maximum password age allowed.  CIS recommends to set 90 days or less."
  default     = 90
}
variable "iam_require_uppercase_characters" {
  description = "Require password to contain uppercase letters.  CIS recommends this to be enabled."
  default     = true
}
variable "iam_require_lowercase_characters" {
  description = "Require password to contain lowercase letters.  CIS recommends this to be enabled."
  default     = true
}
variable "iam_require_symbols" {
  description = "Require password to contain symbols.  CIS recommends this to be enabled."
  default     = true
}
variable "iam_require_numbers" {
  description = "Require password to contain numbers.  CIS recommends this to be enabled."
  default     = true
}
variable "iam_support_role_name" {
  description = "IAM Support role name."
  default     = "aws-support-role"
}

variable "support_role_principles" {
  description = "List of ARNs (typically from the administration account) that are authorised to assume the suppport role."
  default     = [""]
}

variable "vpc_default_clear" {
  description = "Clear any default settings in VPC and RouteTables."
  default     = true
}

variable "vpc_id" {
  description = "VPC ID to configure flow logs for."
}

variable "vpc_default_network_acl" {
  type        = string
  description = "Optional.  VPC default network ACL, typically set when you have removed the default VPCs in an account"
  default     = ""
}

variable "log_group_name" {
  default = "vpc-flow-log"
  description = "Log group name for flow logs"
}

variable "vpc_log_retention_in_days" {
  description = "Number of days to retain logs for. CIS recommends 365 days.  Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely."
}

variable "prefix" {
  description = "The prefix for the resource names. You will probably want to set this to the name of your VPC, if you have multiple."
  default = "vpc"
}

variable "traffic_type" {
  default = "REJECT"
  description = "https://www.terraform.io/docs/providers/aws/r/flow_log.html#traffic_type"
}

# Cloudtrail vars

variable "cloudwatch_logs_retention_in_days" {
  description = "Cloudwatch retention in days"
  default     = 90
}


variable "region" {
  type        = string
  description = "The AWS regions where resources are created"
}

variable "additional_endpoint_arns" {
  type        = list
  description = "Any alert endpoints, such as autoscaling, or app scaling endpoint arns that will respond to an alert"
  default     = []
}

variable "cloudtrail_name" {
  type        = string
  description = "Specifies the name of the trail"
  default     = "vpc-cloudtrail"
}

variable "cloudtrail_multi_region" {
  default     = true
  description = "Specifies whether the trail is created in the current region or in all regions"
}

variable "cloudtrail_logging" {
  default     = true
  description = "Enables logging for the trail"
}

variable "cloudtrail_log_file_validation" {
  default     = true
  description = "Specifies whether log file integrity validation is enabled"
}

variable "cloudtrail_log_group_name" {
  type        = string
  description = "The name of the log group to be created"
  default     = "vpc-cloudtrail-log"
}

variable "cloudtrail_sns_topic" {
  type        = string
  description = "ARN of SNS topic for sending Cloudwatch alarms to.  Useful if you have a centralised account that handles this."
  default     = ""
}

variable "cloudtrail_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to be created"
}

variable "cloudtrail_metric_namespace" {
  description = "A namespace for grouping all of the metrics together"
  default     = "CISBenchmark"
}
variable "create_dashboard" {
  type        = bool
  description = "When true a dashboard that displays tha statistics as a line graph will be created in CloudWatch"
  default     = true
}

variable "create_sns_topic" {
  type        = bool
  description = "When true an SNS topic will be created with the name specifed in `cloudtrail_sns_topic` "
  default     = false
}

variable "key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 10
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}