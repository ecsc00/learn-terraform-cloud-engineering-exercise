#attempt to recreate the previous assingments infrastructure 
/*Including the use of six subnets: 3 pub, 3 priv

Utilise 3 AZ
Recreate an IG to allow connectivity from within pub subnets 
Recreate the NAT gateway to route traffic from any priv subnet instance  to reach public subnet and if necessary out of VPC.

Restrict SSH in to both subnets only from specified IP.*/



# new vpc with desired cidr range & active dns services
resource "aws_vpc" "main" {
  cidr_block = var.cidr_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}

#vpc internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# elastic IP
resource "aws_eip" "nat_eip" {
  vpc = true
}

#nat gateway, in pub subnet to provide gateway for private subnets 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
}

/* 
create route tables ansd associate subnets to route table to recreate traffic flow as in previous asignments 
*/
#Routing table for public subnets, with internet gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

#Associating the public subnets to the public routing table
resource "aws_route_table_association" "public_route_table_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

#Routing table for private subnets, with nat gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private_route_table"
  }
}

#Associating the private subnets to the private routing table
resource "aws_route_table_association" "private_route_table_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}


/* security group allowing traffic to and from instances in the public subnets
limitting ssh to the ip defined in our designated variable.
*/
resource "aws_security_group" "public_sg" {
  name   = "public_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  
  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  
  
  tags = {
    Name = "public_sg"
  }
}
/*
Solely allowing ssh via the ip defined in our designated variable.
*/
resource "aws_security_group" "private_sg" {
  name   = "private_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_ip]
  }

  tags = {
    Name = "private_sg"
  }

}

/*creating public subnets for our VPC, with cidr block in our variables
assigning CIDR block & assigining public IP  to instances in pub subnets 
*/
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${element(var.availability_zones, count.index)}"
  }
 
}

/*creating private subnets for our VPC, assigning cidr block &  AZ  via variables
assigning CIDR block. 
*/
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-${element(var.availability_zones, count.index)}"
  }
  
}
  
  
  

    
