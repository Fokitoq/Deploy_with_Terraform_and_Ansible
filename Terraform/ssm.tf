resource "aws_iam_role_policy_attachment" "Terraform-ansible-ssm-policy" {
role       = aws_iam_role.Terraform-ansible-ssm-iam-role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
