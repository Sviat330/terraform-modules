
/*
terraform {
  backend "s3" {
    bucket = "pekarini-terraformstate"
    key    = "terraform/network/terraform.tfstate"
    region = "eu-north-1"
  }
}
*/
#-------------------------------------------------
# Creating vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc-${data.aws_region.current.name}-${var.env_code}-web-app-stack"
  }
}


#-------------------------------------------------
# Creating public and private subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "subnet-${data.aws_region.current.name}-${element(data.aws_availability_zones.available.zone_ids, count.index)}-public-${var.env_code}-web-app-stack"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "subnet-${data.aws_region.current.name}-${element(data.aws_availability_zones.available.zone_ids, count.index)}-private-${var.env_code}-web-app-stack"
  }
}

#-------------------------------------------------
# Creating Internet Gateway and Route table for public access 
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-${var.env_code}"
  }
}
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "rt-${var.env_code}"
  }
}
#-------------------------------------------------
# Associating public subnets with route table
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.main_rt.id
}


