# vpc.tf

# VPC Configuration
resource "aws_vpc" "terraform_ansible_VPC" {
  cidr_block = var.vpc_cidr_block
}

#Create public_subnets in different AZs for high availability
resource "aws_subnet" "public_subnet" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.terraform_ansible_VPC.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 map_public_ip_on_launch = true
 availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
 
 tags = {
   Name = "Terraform_ansible_Public_Subnet_${var.env}_${count.index + 1}"
 }
}

# Private Subnet Configuration
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.terraform_ansible_VPC.id
  count             = length(var.private_subnet_cidrs)
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
   Name = "Terraform_ansible_Private_Subnet_${var.env}_${count.index + 1}"
 }
}




# Internet Gateway Configuration
resource "aws_internet_gateway" "terraform_ansible_igw" {
  vpc_id = aws_vpc.terraform_ansible_VPC.id
}


# Route Table Configuration
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.terraform_ansible_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_ansible_igw.id
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}



# Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  vpc      = true
}


# NAT Gateway Configuration
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id 
   tags = {
    Name = "Ansible_terraform NAT"
  }
   depends_on = [aws_internet_gateway.terraform_ansible_igw]
}

# Elastic IP Configuration for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Route Table Configuration for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.terraform_ansible_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
