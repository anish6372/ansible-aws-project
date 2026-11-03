output "app_public_ip" {
  description = "Public IP of the app server"
  value       = module.compute.public_ip
}

output "app_url" {
  value = "http://${module.compute.public_ip}"
}

output "instance_id" {
  description = "Use with: aws ssm start-session --target <id>"
  value       = module.compute.instance_id
}

output "rds_endpoint" {
  value = var.enable_rds ? module.database[0].endpoint : null
}
