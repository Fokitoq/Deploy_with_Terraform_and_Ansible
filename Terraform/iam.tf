
resource "aws_iam_instance_profile" "Terraform-ansible-ssm-iam-profile" {
name = "ec2_profile"
role = aws_iam_role.Terraform-ansible-ssm-iam-role.name
}


resource "aws_iam_role" "Terraform-ansible-ssm-iam-role" {
name        = "Terraform-ansible-role"
description = "The role for the developer resources EC2"
assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
tags = {
stack = "test"
}
}




