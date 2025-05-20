terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

resource "yandex_storage_bucket" "tf_state_bucket" {
  access_key = yandex_iam_service_account_static_access_key.tf_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf_key.secret_key

  bucket     = var.bucket_name
  default_storage_class = "STANDARD"
  max_size  = 1073741824
  acl       = "private"
  force_destroy = true
  depends_on = [yandex_iam_service_account_static_access_key.tf_key]
}

# Сервисный аккаунт для бакета
resource "yandex_iam_service_account" "storage_sa" {
  name = "tf-storage-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Ключ доступа (static credentials) для использования S3
resource "yandex_iam_service_account_static_access_key" "tf_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  description        = "Key for accessing the S3 bucket from Terraform"
}
