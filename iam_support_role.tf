data "aws_iam_policy_document" "support_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current_user.account_id}:root"]  #"${var.support_role_principles}"
    }
  }
}

resource "aws_iam_role" "support" {
  name = var.iam_support_role_name
  assume_role_policy = data.aws_iam_policy_document.support_role_policy.json
}

resource "aws_iam_role_policy_attachment" "support_policy" {
  role = aws_iam_role.support.id
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}