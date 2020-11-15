output "log_group_name" {
  value = aws_flow_log.vpc_flow_log.log_group_name
}

output "support_iam_role_arn" {
  description = "The ARN of the IAM role used for the support user."
  value       = aws_iam_role.support.arn
}

output "support_iam_role_name" {
  description = "The name of the IAM role used for the support user."
  value       = aws_iam_role.support.name
}

output "sns_arn" {
  description = "Arn of the SNS topic"
  value       = concat(aws_sns_topic.sns_topic_default.*.arn, [""])[0]
}