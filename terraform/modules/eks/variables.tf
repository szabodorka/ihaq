variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}