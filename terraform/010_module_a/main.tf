resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-demo"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "subnet-demo"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw-demo"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rt-demo"
  }
}

resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table_association" "rt_vpc_assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}
