variable "yc_token" {
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "subnet_a" {
  type = string
}

variable "subnet_b" {
  type = string
}

variable "subnet_d" {
  type = string
}

variable "sa_id" {
  description = "ID сервисного аккаунта с ролями editor + k8s.admin"
  type        = string
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_ed25519.pub"
}
