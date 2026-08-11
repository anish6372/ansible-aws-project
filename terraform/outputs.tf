output "all_in_one_public_ip" {
  description = "Public IP of the all-in-one server"
  value       = aws_instance.all_in_one.public_ip
}
