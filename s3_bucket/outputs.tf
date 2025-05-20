output "access_key" {
  description = "Static access key for the S3-compatible bucket"
  value       = yandex_iam_service_account_static_access_key.tf_key.access_key
}

output "secret_key" {
  description = "Secret access key (sensitive)"
  value       = yandex_iam_service_account_static_access_key.tf_key.secret_key
  sensitive   = true
}
