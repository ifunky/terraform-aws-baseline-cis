resource "aws_cloudtrail" "cloudtrail_default" {
  count                         = var.is_managed_by_control_tower ? 0 : 1
  name                          = var.cloudtrail_name
  is_multi_region_trail         = var.cloudtrail_multi_region
  s3_bucket_name                = aws_s3_bucket.default.id
  enable_logging                = var.cloudtrail_logging
  enable_log_file_validation    = var.cloudtrail_log_file_validation
  cloud_watch_logs_group_arn    = var.create_log_group ? aws_cloudwatch_log_group.log_group_default[count.index].arn : null
  cloud_watch_logs_role_arn     = var.create_log_group ? aws_iam_role.cloudtrail_role[count.index].arn : null
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  is_organization_trail         = "false"
  include_global_service_events = "true"
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }  

  tags = merge({ "Name" = var.cloudtrail_log_group_name }, var.tags)
}

resource "aws_s3_bucket" "default" {
  bucket        = var.cloudtrail_bucket_name
  force_destroy = true
}

data "aws_iam_policy_document" "default" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.default.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.default.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.default.json
}


# --------------------------------------------------------------------------------------------------
# KMS Key to encrypt CloudTrail events.
# The policy was derived from the default key policy descrived in AWS CloudTrail User Guide.
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/default-cmk-policy.html
# --------------------------------------------------------------------------------------------------

resource "aws_kms_key" "cloudtrail" {
  description             = "A KMS key to encrypt CloudTrail events."
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = "true"

  policy = <<END_OF_POLICY
{
    "Version": "2012-10-17",
    "Id": "Key policy created by CloudTrail",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {"AWS": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            ]},
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudTrail to encrypt logs",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:GenerateDataKey*",
            "Resource": "*",
            "Condition": {"StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"}}
        },
        {
            "Sid": "Allow CloudTrail to describe key",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:DescribeKey",
            "Resource": "*"
        },
        {
            "Sid": "Allow principals in the account to decrypt log files",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"}
            }
        },
        {
            "Sid": "Allow alias creation during setup",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": "kms:CreateAlias",
            "Resource": "*",
            "Condition": {"StringEquals": {
                "kms:ViaService": "ec2.${local.region}.amazonaws.com",
                "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
            }}
        },
        {
            "Sid": "Enable cross account log decryption",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"}
            }
        }
    ]
}
END_OF_POLICY
}

resource "aws_cloudwatch_log_group" "log_group_default" {
  count             = var.create_log_group && var.is_managed_by_control_tower ? 0 : 1
  name              = var.cloudtrail_log_group_name
  retention_in_days = var.cloudwatch_logs_retention_in_days

  tags = merge({ "Name" = var.cloudtrail_name }, var.tags)

}

resource "aws_sns_topic" "sns_topic_default" {
  #checkov:skip=CKV_AWS_26:Not required
  count  = var.create_sns_topic ? 1 : 0
  name   = var.cloudtrail_sns_topic
  policy = data.aws_iam_policy_document.cloudtrail_alarm_policy[count.index].json
}

resource "aws_iam_role" "cloudtrail_role" {
  count              = var.is_managed_by_control_tower ? 0 : 1
  name               = "${var.cloudtrail_name}-role"
  description        = "CloudTrail logging role into CloudWatch "
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_policy.json
}

resource "aws_iam_policy" "cloudtrail_access_policy" {
  count  = var.is_managed_by_control_tower ? 0 : 1
  name   = "${var.cloudtrail_name}-policy"
  policy = data.aws_iam_policy_document.cloudtrail_policy.json
}

resource "aws_iam_policy_attachment" "cloudtrail_access_policy_attachment" {
  count      = var.is_managed_by_control_tower ? 0 : 1  
  name       = "${var.cloudtrail_name}-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_access_policy[count.index].arn
  roles      = [aws_iam_role.cloudtrail_role[count.index].name]
}