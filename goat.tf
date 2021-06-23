/*
 resource "aws_security_group" "ssh2" {
  name        = "sg_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}


resource "aws_s3_bucket" "badbucket" {
  bucket = "qwerty-tf-test-bucket"
  acl    = "public-read"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
*/

resource "aws_iam_user" "benny" {
  name = "benny"
  path = "/system/"

}

resource "aws_iam_access_key" "benny" {
  user = aws_iam_user.benny.name
}

resource "aws_iam_user_policy" "benny_admin" {
  name = "test"
  user = aws_iam_user.benny.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*",
        "s3:*",
        "lambda:*",
        "cloudwatch:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

