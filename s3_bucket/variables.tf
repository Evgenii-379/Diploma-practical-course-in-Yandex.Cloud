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

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}
