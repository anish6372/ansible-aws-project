# Ansible AWS Multi-Tier Project

A complete Infrastructure as Code (IaC) solution using Terraform and Ansible to deploy a multi-tier web application on AWS.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Server    │    │  Backend/API    │    │   Database      │
│     (Nginx)     │────│   (Node.js)     │────│  (PostgreSQL)   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                        │                        │
        └────────────────────────┼────────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Monitoring    │
                    │ (Node Exporter) │
                    └─────────────────┘
```

## 📋 Components

- **Terraform**: Infrastructure provisioning (VPC, EC2 instances, Security Groups)
- **Ansible**: Configuration management and application deployment
- **Nginx**: Web server and reverse proxy
- **Node.js**: Backend API server
- **PostgreSQL**: Database
- **Prometheus Node Exporter**: System monitoring

## 🚀 Quick Start

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **Ansible** >= 2.9
4. **AWS CLI** configured with credentials
5. **SSH Key Pair** for EC2 access

### Deployment Steps

#### 1. Clone and Setup
```bash
git clone <this-repo>
cd ansible-aws-project
```

#### 2. Configure Variables
Update `terraform/variables.tf` with your settings:
```hcl
variable "operator_cidr" {
  description = "Your IP in CIDR notation"
  default     = "YOUR_IP/32"  # Change this to your actual IP
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "your-key-name"  # Change this to your AWS key pair
}
```

#### 3. Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

#### 4. Configure Ansible Inventory
The project uses dynamic AWS EC2 inventory. Ensure AWS credentials are configured:
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

#### 5. Deploy Application Stack
```bash
cd ..
ansible-playbook -i inventory/aws_ec2.yml site.yml
```

#### 6. Test Deployment
```bash
# Get web server IP from terraform output
cd terraform
WEB_IP=$(terraform output -raw web_instance_public_ip)

# Test the application
curl http://$WEB_IP
curl http://$WEB_IP/api/status
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Backend Connectivity Issues
If you see "connecting to backend" errors:

1. **Run the debug script:**
```bash
chmod +x debug_backend.sh
./debug_backend.sh
```

2. **Use the automated fix:**
```bash
ansible-playbook -i inventory/aws_ec2.yml fix_backend_connectivity.yml
```

#### 2. AWS Resource Limits
If you encounter vCPU limit errors:
- Check current usage: `aws ec2 describe-instances`
- Stop unused instances to free up capacity
- Request limit increase from AWS Support
- Use alternative configuration in `terraform/main.tf`

#### 3. Hard-coded IP Issues
The project includes fallback IPs that may need updating:
- Check `roles/webserver/tasks/main.yml`
- Check `roles/backend/tasks/main.yml`
- Update with current infrastructure IPs from `terraform output`

### Debug Tools

#### Debug Script
```bash
./debug_backend.sh
```
Provides comprehensive system diagnostics including:
- Infrastructure IP addresses
- Service connectivity tests
- Configuration validation
- Recommended fixes

#### Fix Playbook
```bash
ansible-playbook -i inventory/aws_ec2.yml fix_backend_connectivity.yml
```
Automatically:
- Updates hard-coded IP addresses
- Restarts services
- Tests connectivity
- Provides detailed status reports

## 📁 Project Structure

```
ansible-aws-project/
├── terraform/                 # Infrastructure as Code
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Variable definitions
│   ├── outputs.tf            # Output definitions
│   └── ssh-key.tf           # SSH key pair creation
├── roles/                    # Ansible roles
│   ├── common/              # Common server setup
│   ├── webserver/           # Nginx configuration
│   ├── backend/             # Node.js API setup
│   ├── database/            # PostgreSQL setup
│   └── monitoring/          # Node Exporter setup
├── inventory/               # Ansible inventory
│   └── aws_ec2.yml         # Dynamic AWS inventory
├── group_vars/             # Ansible group variables
│   └── all/
│       ├── vault.yml       # Encrypted variables
│       └── vault_secrets.yml
├── .github/workflows/      # GitHub Actions
│   └── ansible.yml         # CI/CD pipeline
├── debug_backend.sh        # Debugging script
├── fix_backend_connectivity.yml  # Fix automation
├── SOLUTION.md            # Detailed troubleshooting guide
└── site.yml               # Main Ansible playbook
```

## 🔧 Configuration Files

### Key Configuration Points

#### Security Groups (terraform/main.tf)
- Web server: Ports 80, 443 (public), 22 (restricted)
- Backend: Port 3000 (from web server only), 22 (restricted)
- Database: Port 5432 (from backend only), 22 (restricted)

#### Service Flow
1. **User** → **Nginx** (port 80/443)
2. **Nginx** → **Node.js Backend** (port 3000, internal)
3. **Backend** → **PostgreSQL** (port 5432, internal)

#### Application Endpoints
- `/` - Static web content
- `/api/status` - Backend health check
- `/api/*` - API endpoints (proxied to backend)

## 📊 Monitoring

### Node Exporter Metrics
Available on port 9100 (VPC internal only):
- System metrics (CPU, memory, disk)
- Network statistics
- Process information

### Service Status Commands
```bash
# Check service status on servers
sudo systemctl status nginx
sudo systemctl status backend
sudo systemctl status postgresql
sudo systemctl status node_exporter

# View logs
sudo journalctl -u backend -f
sudo tail -f /var/log/nginx/error.log
```

## 🔒 Security

### Network Security
- VPC with public and private subnets
- Security groups with least privilege access
- SSH access restricted to operator IP only
- Database and backend not directly accessible from internet

### Secrets Management
- Ansible Vault for sensitive variables
- SSH keys generated automatically by Terraform
- Database credentials stored in encrypted vault files

## 🚀 GitHub Actions CI/CD

The project includes a GitHub Actions workflow (`.github/workflows/ansible.yml`) that:
- Validates Ansible playbooks
- Runs syntax checks
- Tests role dependencies
- Provides automated deployment capabilities

## 📝 Additional Resources

- [Detailed Troubleshooting Guide](SOLUTION.md)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible AWS Collections](https://docs.ansible.com/ansible/latest/collections/amazon/aws/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Important Notes

1. **AWS Costs**: This project creates AWS resources that may incur charges
2. **Security**: Update default IPs and credentials before production use
3. **Monitoring**: Check AWS CloudWatch for additional monitoring capabilities
4. **Backups**: Implement database backup strategy for production environments

## 🆘 Support

If you encounter issues:

1. Run the debug script: `./debug_backend.sh`
2. Check the [troubleshooting guide](SOLUTION.md)
3. Review service logs on the servers
4. Create an issue in this repository with:
   - Error messages
   - Debug script output
   - Terraform and Ansible versions
   - AWS region and instance types used