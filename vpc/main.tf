
# decalre data source
data "aws_availability_zones" "available" {}

# main vpc

resource "aws_vpc" "main" {
  cidr_block           = "${var.VPC_CIDR_BLOCK}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.PROJECT_NAME}-vpc"
  }
}



# public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.VPC_PUBLIC_SUBNET_1}"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.PROJECT_NAME}-vpc-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.VPC_PUBLIC_SUBNET_2}"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.PROJECT_NAME}-vpc-public-subnet-2"
  }
}

# private subnets

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.VPC_PRIVATE_SUBNET_1}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "${var.PROJECT_NAME}-vpc-private-subnet-1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.VPC_PRIVATE_SUBNET_2}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "${var.PROJECT_NAME}-vpc-private-subnet-2"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "${var.PROJECT_NAME}-vpc-igw"
  }
}

# elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.igw"]
}

# NAT gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet_1.id}"
  depends_on    = ["aws_internet_gateway.igw"]
  tags = {
    Name = "${var.PROJECT_NAME}-vpc-ngw"
  }
}




# public route table

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name = "${var.PROJECT_NAME}-public-route-table"
  }
}

# route table associations with public subnets
resource "aws_route_table_association" "to_public_subnet_1" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "to_public_subnet_2" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public.id}"
}


# private route table
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }
  tags = {
    Name = "${var.PROJECT_NAME}-private-route-table"
  }
}

# route table associations with private subnets
resource "aws_route_table_association" "to_private_subnet_1" {
  subnet_id      = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "to_private_subnet_2" {
  subnet_id      = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.private.id}"
}
