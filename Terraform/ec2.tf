
# EC2 Instances for APP Configuration
resource "aws_instance" "app_instance" {
  count          = 2
  ami            = var.aws_ami
  instance_type  = var.aws_instance_type
  subnet_id      = aws_subnet.private_subnet[count.index].id
  security_groups = [aws_security_group.ec2_security_group_app.id]
  tags = {
    Name = "Ansible_Terraform_EC2_App"
  }
  # For SSM
  iam_instance_profile = aws_iam_instance_profile.Terraform-ansible-ssm-iam-profile.name 
}

# EC2 Instances for DB Configuration
resource "aws_instance" "db_instance" {
  count          = 1
  ami            = var.aws_ami
  instance_type  = var.aws_instance_type
  subnet_id      = aws_subnet.private_subnet[count.index].id
  security_groups = [aws_security_group.ec2_security_group_db.id]

  # For SSM
   iam_instance_profile = aws_iam_instance_profile.Terraform-ansible-ssm-iam-profile.name 
  
  tags = {
    Name = "Ansible_Terraform_EC2_DB"
  }
}

/*
resource "aws_instance" "bastion_instance" {
  count          = 1
  ami            = var.aws_ami
  instance_type  = var.aws_instance_type
  subnet_id      = aws_subnet.public_subnet[count.index].id
  security_groups = [aws_security_group.ec2_security_group_app.id]

  # For SSM
  #iam_instance_profile = "arn:aws:iam::${var.aws_account_id}:instance-profile/AmazonSSMManagedInstanceCore"
  
  tags = {
    Name = "Ansible_Terraform_EC2_bastion"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1
              sudo service nginx start
              sudo chkconfig nginx on
              sudo sh -c 'echo "<h3> Welcome to the Internet, I will be your guide </h3>" > /usr/share/nginx/html/index.html'
              EOF
}
*/



# Generate Ansible Inventory File
data "template_file" "ansible_inventory" {
  template = <<EOF
[app_servers]
${join("\n", aws_instance.app_instance.*.private_ip)}

[postgresql_servers]
${join("\n", aws_instance.db_instance.*.private_ip)}
EOF
}








resource "aws_security_group" "ec2_security_group_app" {
  vpc_id     = aws_vpc.terraform_ansible_VPC.id
  name        = "ec2-security-group-app"
  description = "Security group for EC2 instances allowing inbound traffic on ports 80, 22, 443, and ICMP"

  // Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ec2_security_group_db" {
  vpc_id     = aws_vpc.terraform_ansible_VPC.id
  name        = "ec2-security-group-DB"
  description = "Security group for DB instance allowing inbound traffic on ports 80, 22, 443, 5432  and ICMP"

  // Inbound rules
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


   ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 // ICMP Type 8 corresponds to echo request (ping)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}