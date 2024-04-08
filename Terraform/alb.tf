# Load Balancer Configuration
resource "aws_lb" "terraform_ansible_lb" {
  name               = "Terraform-ansible-LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.public_subnet[0].id,  # Subnet in us-east-1a
    aws_subnet.public_subnet[1].id   # Subnet in us-east-1b
  ]
  security_groups    = [aws_security_group.alb_security_group.id]

  enable_deletion_protection = false
}

# Define Target Group
resource "aws_lb_target_group" "terraform_ansible_target_group" {
  name        = "Terraform-ansible-TG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.terraform_ansible_VPC.id
  target_type = "instance"
}

# Register EC2 Instances to Target Group
resource "aws_lb_target_group_attachment" "app_targets" {
  count             = 2
  target_group_arn  = aws_lb_target_group.terraform_ansible_target_group.arn
  target_id         = aws_instance.app_instance[count.index].id
  port              = 80
}


# Define Listener
resource "aws_lb_listener" "terraform_ansible_listener" {
  load_balancer_arn = aws_lb.terraform_ansible_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform_ansible_target_group.arn
  }
}

resource "aws_security_group" "alb_security_group" {
  vpc_id     = aws_vpc.terraform_ansible_VPC.id
  name        = "alb-security-group"
  description = "Security group for alb   allowing inbound traffic on ports 80 and 443"

  // Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
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