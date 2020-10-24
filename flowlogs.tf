data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type    = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "log_policy" {
  statement {
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]      
      effect = "Allow"
      resources = ["*"]
  }
}

# --------------------------------------------------------------------------------------------------
# Add IAM roles, log group and flow log.
# --------------------------------------------------------------------------------------------------

resource "aws_iam_role" "iam_log_role" {
  name                = "${var.prefix}-flow-log-role"
  description         = "IAM role used "
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy" "log_policy" {
  name   = "${var.prefix}-flow-log-policy"
  role   = aws_iam_role.iam_log_role.id
  policy = data.aws_iam_policy_document.log_policy.json
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name              = var.log_group_name
  retention_in_days = var.vpc_log_retention_in_days
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  iam_role_arn    = aws_iam_role.iam_log_role.arn
  vpc_id          = var.vpc_id
  traffic_type    = var.traffic_type
}