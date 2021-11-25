terraform {
  backend "s3" {
    bucket = "backend-terraform-ldaniav2new" # nombre del bucket que ya tengas creado, aqui es donde se guardará el archivo de estado
    key    = "dev"
    region = "us-west-2"

    encrypt = true
    # Enviar ARN del recurso que creó al archivo de estado
    kms_key_id = "arn:aws:kms:us-west-2:122134586136:key/b8c1f686-30d7-4938-bfaa-954f77a84fe4"
    #force_destroy = true
  }
}