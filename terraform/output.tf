output "portainer_access_key_id" {
  value     = aws_iam_access_key.portainer_hevc.id
  sensitive = true
}

output "portainer_secret_access_key" {
  value     = aws_iam_access_key.portainer_hevc.secret
  sensitive = true
}
