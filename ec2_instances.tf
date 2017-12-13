resource "aws_instance" "vm_adwriter" {
  instance_type          = "t2.nano"
  ami                    = "${data.aws_ami.win.id}"

  iam_instance_profile   = "${aws_iam_instance_profile.instance_profile_adwriter.name}"
  subnet_id              = "${aws_subnet.subnet_dmz_az1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.secgroup_adwriter.id}",
  ]
}

data "aws_ami" "win" {
  most_recent = true

  filter {
    name   = "name"

    values = [
      "Windows_Server-2012-R2_RTM-English-64Bit-Base-*",
    ]
  }

  owners      = [
    "amazon",
  ]
}

resource "aws_instance" "rhel" {
  instance_type          = "t2.micro"
  ami                    = "${data.aws_ami.rhel.id}"
  subnet_id              = "${aws_subnet.subnet_dmz_az1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.secgroup_adwriter.id}",
  ]

  user_data              = <<EOF
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

resource "aws_instance" "ubuntu" {
  instance_type          = "t2.micro"
  ami                    = "${data.aws_ami.ubuntu.id}"
  subnet_id              = "${aws_subnet.subnet_dmz_az1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.secgroup_adwriter.id}",
  ]

  user_data              = <<EOF
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

data "aws_ami" "rhel" {
  most_recent = true

  filter {
    name   = "name"

    values = [
      "RHEL-7.4*",
    ]
  }

  owners      = [
    "309956199498",
  ]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"

    values = [
      "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-**",
    ]
  }

  filter {
    name   = "root-device-type"

    values = [
      "ebs",
    ]
  }

  filter {
    name   = "virtualization-type"

    values = [
      "hvm",
    ]
  }

  owners      = [
    "099720109477",
  ]
}
