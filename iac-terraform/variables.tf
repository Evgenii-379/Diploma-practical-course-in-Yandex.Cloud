variable "yc_token" {
  description = "IAM токен Yandex.Cloud"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Folder ID"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Путь до публичного SSH-ключа"
  default     = "~/.ssh/id_ed25519"
}
