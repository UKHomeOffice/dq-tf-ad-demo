output "Directory Services" {
  value = "${aws_directory_service_directory.myapp_ad.dns_ip_addresses}"
}

output "Windows 2012r2 Address" {
  value = "${aws_instance.vm_adwriter.public_dns}"
}
output "Red Hat Address" {
  value = "${aws_instance.rhel.public_dns}"
}

output "Ubuntu Address" {
  value = "${aws_instance.ubuntu.public_dns}"
}

output "Admin Password" {
  value = "${random_string.AdminPassword.result}"
}