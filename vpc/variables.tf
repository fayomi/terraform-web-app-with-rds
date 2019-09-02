variable "VPC_CIDR_BLOCK" {
  default = "10.0.0.0/16"
}

variable "PROJECT_NAME" {
  default = "terraform-project"
}


variable "VPC_PUBLIC_SUBNET_1" {
  default = "10.0.1.0/24"
}

variable "VPC_PUBLIC_SUBNET_2" {
  default = "10.0.2.0/24"
}

variable "VPC_PRIVATE_SUBNET_1" {
  default = "10.0.3.0/24"
}
variable "VPC_PRIVATE_SUBNET_2" {
  default = "10.0.4.0/24"
}


