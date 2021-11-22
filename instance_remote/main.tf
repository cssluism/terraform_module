provider "aws" {
  region = "us-west-2"
}

/* resource "aws_launch_configuration" "as_conf" {
  name_prefix   = var.name_prefix
  image_id      = var.ami_id
  instance_type = var.instance_type
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = var.autoscaling_name
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = var.min_size
  max_size             = var.max_size
  availability_zones = var.availability_zones
  lifecycle {
    create_before_destroy = true
  }
} */





/* resource "aws_instance" "platzi-instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  tags            = var.tags
  security_groups = ["${aws_security_group.ssh_conection.name}"]
} */


resource "aws_kms_key" "mykey" {
  description             = "Key State"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "terraform_backend" {
  bucket = var.bucket_name
  acl    = var.acl
  tags   = var.tags
   server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

output  arn {
  value       = aws_kms_key.mykey.arn
  
}



resource "aws_security_group" "ssh_conection" {
  name            = var.sg_name
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value.from_port
      to_port =   ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    } 
  }
   dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port = egress.value.from_port
      to_port =   egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    } 
  }


  

}


resource "aws_instance" "platzi-instance"{
    #ami = "ami-06fddf8d55d5ab5df"
    ami = var.ami_id
    instance_type = var.instance_type
    tags = var.tags
    security_groups = ["${aws_security_group.ssh_conection.name}"]
    connection {
      type     = "ssh"
      user     = "centos"
      private_key = "~/.ssh/AMI_KEY.pem"
      host = self.public_ip
    }
    provisioner "remote-exec" {
      inline = [
        "docker run -it -d -p 3000:3000 cssluism/youtube_app_v2:v1"
      ]
    }
}
