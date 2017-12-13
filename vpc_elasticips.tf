resource "aws_eip" "eip_natgw_az1" {
  vpc = true
}

resource "aws_eip" "eip_natgw_az2" {
  vpc = true
}
