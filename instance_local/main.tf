#path.module is the filesystem path of the module where the expression is placed.
#path.root is the filesystem path of the root module of the configuration.
#path.cwd is the filesystem path of the current working directory.
#In normal use of Terraform this is the same as path.root,
#but some advanced uses of Terraform run it from a directory other than 
#the root module directory, causing these paths to be different.



##  Region
provider "aws" {
  region = "us-west-2"
}

##Encriptacion
resource "aws_kms_key" "mykey" {
  description             = "Key State"
  deletion_window_in_days = 10
}
## Creacion de  s3 para guardar State
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
## Crear Output
output  arn {
  value       = aws_kms_key.mykey.arn
  
}


## Crear Grupo de Seguridad
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

## Crear instancia
resource "aws_instance" "platzi-instance"{
    #ami = "ami-06fddf8d55d5ab5df"
    ami = var.ami_id
    instance_type = var.instance_type
    tags = var.tags
    security_groups = ["${aws_security_group.ssh_conection.name}"]


## Mover Archivo  Docker-Compose
  provisioner "file" {
  source      = "${path.cwd}/module/util/docker-compose.yml"
  destination = "/home/centos/docker-compose.yml"

  connection {
      type     = "ssh"
      user     = "centos"
      #private_key = "${file("~/.ssh/AMI_KEY.pem")}"
      private_key = "${file("${path.cwd}/module/util/AMI_KEY.pem")}"
      host = self.public_ip
  }
}

## Mover Archivo  Nodejs
  provisioner "file" {
  source      = "${path.cwd}/module/util/index.js"
  destination = "/home/centos/index.js"

  connection {
      type     = "ssh"
      user     = "centos"
      #private_key = "${file("~/.ssh/AMI_KEY.pem")}"
      private_key = "${file("${path.cwd}/module/util/AMI_KEY.pem")}"
      host = self.public_ip
  }
}

## Activar Docker Compose
    connection {
      type     = "ssh"
      user     = "centos"
     # private_key = "${file("~/.ssh/AMI_KEY.pem")}"
     private_key = "${file("${path.cwd}/module/util/AMI_KEY.pem")}"
      
      host = self.public_ip
    }


    provisioner "remote-exec" {
      inline = [
       "sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
       "sudo chmod +x /usr/local/bin/docker-compose",
       "sudo groupadd docker",
       "sudo usermod -aG docker $USER",
       "sudo chmod 666 /var/run/docker.sock",
       "sudo chmod 777 docker-compose.yml",
       "echo $USER",
       "docker-compose up -d"
      ]
      

}



  
}