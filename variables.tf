variable "az1" {
  default = "eu-west-2a"
}

variable "az2" {
  default = "eu-west-2b"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "subnet_dmz_cidr_az1" {
  default = "10.1.3.0/24"
}
variable "subnet_dmz_cidr_az2" {
  default = "10.1.4.0/24"
}

variable "subnet_priv_cidr_az1" {
  default = "10.1.1.0/24"
}
variable "subnet_priv_cidr_az2" {
  default = "10.1.2.0/24"
}