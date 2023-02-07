resource "aws_s3_bucket" "s3_bucket" {
  bucket = "whiskey-log-bucket-noabm"
  acl    = "private"
  tags = {
    Name        = "whisky terraform bucket"
  }
}

resource "aws_iam_policy" "allow_access_s3_policy" {
  name = "allow_access_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Put*",
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = [
            aws_s3_bucket.s3_bucket.arn,
            "${aws_s3_bucket.s3_bucket.arn}/*"
        ]
      }
    ]
 })
}

resource "aws_iam_role" "s3_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  policy_arn = aws_iam_policy.allow_access_s3_policy.arn
  role       = aws_iam_role.s3_role.name
}
resource "aws_iam_instance_profile" "web_server" {
  name = "nginx_instance_profile"
  role = aws_iam_role.s3_role.name
}