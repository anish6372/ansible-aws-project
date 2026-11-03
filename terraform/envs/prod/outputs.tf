output "alb_dns_name" {
  description = "Public entry point"
  value       = module.web.alb_dns_name
}

output "app_url" {
  value = "${module.web.https_enabled ? "https" : "http"}://${module.web.alb_dns_name}"
}

output "asg_name" {
  value = module.web.asg_name
}

output "rds_endpoint" {
  value = module.database.endpoint
}

output "dashboard_name" {
  value = module.observability.dashboard_name
}
