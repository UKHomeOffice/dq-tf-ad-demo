resource "aws_vpc" "another" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw_another" {
  vpc_id = "${aws_vpc.another.id}"
}

resource "aws_subnet" "another_subnet_dmz_az1" {
  vpc_id                  = "${aws_vpc.another.id}"
  availability_zone       = "${var.az1}"
  cidr_block              = "10.2.3.0/24"
  map_public_ip_on_launch = true
}

resource "aws_vpc_dhcp_options_association" "another_dns_resolver" {
  vpc_id          = "${aws_vpc.another.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

resource "aws_route_table" "another_rtb_pvt_az1" {
  vpc_id = "${aws_vpc.another.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_another.id}"
  }

  route {
    cidr_block                = "${aws_vpc.vpc_myapp.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
  }
}

resource "aws_route_table_association" "another" {
  route_table_id = "${aws_route_table.another_rtb_pvt_az1.id}"
  subnet_id      = "${aws_subnet.another_subnet_dmz_az1.id}"
}

resource "aws_security_group" "another" {
  vpc_id = "${aws_vpc.another.id}"

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_instance" "another_rhel" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.rhel.id}"
  subnet_id     = "${aws_subnet.another_subnet_dmz_az1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.another.id}",
  ]

  user_data = <<EOF
#!/bin/bash
yum -y install sssd realmd krb5-workstation adcli samba-common-tools expect
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl reload sshd
systemctl start sssd.service
echo "%Domain\\ Admins@myapp.com ALL=(ALL:ALL) ALL" >>  /etc/sudoers
expect -c "spawn realm join -U admin@MYAPP.COM MYAPP.COM; expect \"*?assword for admin@MYAPP.COM:*\"; send -- \"${random_string.AdminPassword.result}\r\" ; expect eof"
reboot
EOF

  depends_on = [
    "aws_directory_service_directory.myapp_ad",
  ]
}

resource "aws_instance" "another_ubuntu" {
  instance_type = "t2.micro"
  ami           = "${data.aws_ami.ubuntu.id}"
  subnet_id     = "${aws_subnet.another_subnet_dmz_az1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.another.id}",
  ]

  user_data = <<EOF
#!/bin/bash
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install sssd realmd krb5-user samba-common expect adcli sssd-tools  packagekit
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl reload sshd
systemctl start sssd.service
echo "%Domain\\ Admins@myapp.com ALL=(ALL:ALL) ALL" >>  /etc/sudoers
expect -c "spawn realm join -U admin@MYAPP.COM MYAPP.COM; expect \"*?assword for admin@MYAPP.COM:*\"; send -- \"${random_string.AdminPassword.result}\r\" ; expect eof"
reboot
EOF

  depends_on = [
    "aws_directory_service_directory.myapp_ad",
  ]
}

resource "aws_instance" "another_win" {
  instance_type = "t2.nano"
  ami           = "${data.aws_ami.win.id}"

  iam_instance_profile = "${aws_iam_instance_profile.instance_profile_adwriter.name}"
  subnet_id            = "${aws_subnet.another_subnet_dmz_az1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.another.id}",
  ]
}

resource "aws_ssm_association" "another_win" {
  name        = "${aws_ssm_document.myapp_dir_default_doc.name}"
  instance_id = "${aws_instance.another_win.id}"
}

output "Red Hat in another VPC Address" {
  value = "${aws_instance.another_rhel.public_dns}"
}

output "Ubuntu in another VPC Address" {
  value = "${aws_instance.another_ubuntu.public_dns}"
}

output "Windows in another VPC Address" {
  value = "${aws_instance.another_win.public_dns}"
}

resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = "${aws_vpc.vpc_myapp.id}"
  vpc_id      = "${aws_vpc.another.id}"
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}
