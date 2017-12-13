resource "aws_route_table" "rtb_dmz" {
  vpc_id = "${aws_vpc.vpc_myapp.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_main.id}"
  }
}

resource "aws_route_table_association" "rtb_dmz_to_dmz_az1" {
  route_table_id = "${aws_route_table.rtb_dmz.id}"
  subnet_id      = "${aws_subnet.subnet_dmz_az1.id}"
}

resource "aws_route_table_association" "rtb_dmz_to_dmz_az2" {
  route_table_id = "${aws_route_table.rtb_dmz.id}"
  subnet_id      = "${aws_subnet.subnet_dmz_az2.id}"
}

resource "aws_route_table" "rtb_pvt_az1" {
  vpc_id = "${aws_vpc.vpc_myapp.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw_az1.id}"
  }
}

resource "aws_route_table_association" "rtb_dmz_to_priv_az1" {
  route_table_id = "${aws_route_table.rtb_pvt_az1.id}"
  subnet_id      = "${aws_subnet.subnet_priv_az1.id}"
}

resource "aws_route_table_association" "rtb_dmz_to_priv_az2" {
  route_table_id = "${aws_route_table.rtb_pvt_az1.id}"
  subnet_id      = "${aws_subnet.subnet_priv_az2.id}"
}
