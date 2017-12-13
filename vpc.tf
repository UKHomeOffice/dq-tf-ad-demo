resource "aws_vpc" "vpc_myapp" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw_main" {
  vpc_id = "${aws_vpc.vpc_myapp.id}"
}

resource "aws_nat_gateway" "natgw_az1" {
  allocation_id = "${aws_eip.eip_natgw_az1.id}"
  subnet_id     = "${aws_subnet.subnet_dmz_az1.id}"
}

resource "aws_nat_gateway" "natgw_az2" {
  allocation_id = "${aws_eip.eip_natgw_az2.id}"
  subnet_id     = "${aws_subnet.subnet_dmz_az2.id}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = [
    "${aws_directory_service_directory.myapp_ad.dns_ip_addresses}",
  ]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.vpc_myapp.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}
