variable "host" {
  type = string
}

variable "client_certificate" {
  type = string
  sensitive = true
}

variable "client_key" {
  type = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type = string
  sensitive = true
}

provider "kubernetes" {
  host = var.host

  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

