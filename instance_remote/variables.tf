
variable "ami_id" {
}
variable "instance_type" {
  
}

/* variable "autoscaling_name" {
}
variable "min_size" {
}
variable "max_size" {
}
variable "availability_zones" {
  
}
variable "name_prefix" {
}
 */


#variable "tags" {}
variable "sg_name" {}

variable "ingress_rules" {}

variable "egress_rules" {}


variable "bucket_name" {
  default = "backend-terraform-ldaniav2new2" # el nombre del bucket a crear
}

variable "acl" {
  default = "private"
}

variable "tags" {
    default = {Environment = "Dev", CreatedBy = "terraform"}
}







