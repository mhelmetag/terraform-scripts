variable "region" {
  default = "us-west-2"
}

variable "vpc_id" {
  default = ""
}

variable "images" {
  type = "map"

  default = {
    "build" = ""
    "prod"  = ""
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "maxworld_zone" {
  type = "map"

  default = {
    "id" = ""
    "name" = "maxworld.tech."
  }
}
