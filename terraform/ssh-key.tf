# Generate SSH private key
resource "tls_private_key" "rootkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "rootkey" {
  key_name   = "rootkey"
  public_key = tls_private_key.rootkey.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.rootkey.private_key_pem
  filename        = "${path.module}/rootkey.pem"
  file_permission = "0600"
}

# Output the private key path
output "private_key_path" {
  description = "Path to the private SSH key"
  value       = abspath(local_file.private_key.filename)
}