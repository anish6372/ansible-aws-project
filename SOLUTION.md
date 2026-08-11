# Backend Connectivity Issue - Solution

## Problem Summary
You're experiencing "connecting to backend" errors when accessing your application. Based on the analysis, this is because:

1. **No infrastructure is currently deployed** - Terraform state shows no resources
2. **Hard-coded IP addresses** in Ansible roles that don't match current infrastructure
3. **AWS account limitations** preventing deployment of t2.micro/t3.micro instances

## Immediate Fix Options

### Option 1: Deploy with Alternative Instance Types (Recommended)

Since your AWS account has limitations, let's try with different instance types:

1. **Check your current AWS usage:**
```bash
# Check current running instances (if you have AWS CLI)
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' --output table
```

2. **Use t2.micro with existing instances stopped:**
If you have running instances, stop them temporarily:
```bash
aws ec2 stop-instances --instance-ids i-xxxxxxxxx
```

3. **Deploy minimal infrastructure:**
```bash
cd terraform
terraform apply -var="instance_type=t2.micro" -var="db_instance_type=t2.micro"
```

### Option 2: Request AWS Limit Increase

1. Go to AWS Support Center
2. Create a case for "Service Limit Increase"
3. Select EC2 Instances
4. Request increase for "Running On-Demand All Standard (A, C, D, H, I, M, R, T, Z) instances" to 16 vCPUs

### Option 3: Use Existing Server (If Available)

If you have an existing EC2 instance, you can deploy everything on one server:

1. **Update Ansible inventory to point to your existing server:**
```yaml
# inventory/existing_server.yml  
all:
  hosts:
    existing-server:
      ansible_host: YOUR_EXISTING_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/your-key.pem
  children:
    tag_Role_webserver:
      hosts:
        existing-server:
    tag_Role_backend:
      hosts:
        existing-server:
    tag_Role_database:
      hosts:
        existing-server:
```

2. **Run Ansible playbook:**
```bash
ansible-playbook -i inventory/existing_server.yml site.yml
```

## Step-by-Step Debugging Process

### 1. First, get your infrastructure deployed:

```bash
cd terraform

# Try with t2.micro first
terraform plan
terraform apply

# If that fails, get the current outputs
terraform output
```

### 2. Update hard-coded IPs in Ansible:

Once you have terraform outputs, update these files:

**roles/webserver/tasks/main.yml:**
```yaml
- name: Set backend IP from dynamic inventory
  set_fact:
    backend_ip: "{{ hostvars[groups['tag_Role_backend'][0]]['ansible_host'] }}"
  when: groups['tag_Role_backend'] is defined and groups['tag_Role_backend'] | length > 0
  ignore_errors: true

- name: Set backend IP to app server if dynamic lookup failed
  set_fact:
    backend_ip: "YOUR_ACTUAL_APP_SERVER_IP"  # <-- Update this
  when: backend_ip is not defined
```

**roles/backend/tasks/main.yml:**
```yaml
- name: Set database IP to DB server if dynamic lookup failed
  ansible.builtin.set_fact:
    db_ip: "YOUR_ACTUAL_DB_SERVER_IP"  # <-- Update this
  when: db_ip is not defined
```

### 3. Deploy with Ansible:

```bash
# Update Ansible inventory and deploy
ansible-playbook -i inventory/aws_ec2.yml site.yml
```

### 4. Test connectivity:

```bash
# Get the web server IP from terraform output
WEB_IP=$(terraform output -raw web_instance_public_ip)

# Test the application
curl http://$WEB_IP
curl http://$WEB_IP/api/status
```

## Common Issues and Fixes

### Issue 1: "Connection Refused" 
- **Cause:** Service not running
- **Fix:** SSH to server and check service status:
```bash
sudo systemctl status nginx
sudo systemctl status backend
sudo systemctl restart nginx backend
```

### Issue 2: "502 Bad Gateway"
- **Cause:** Nginx can't reach backend
- **Fix:** Check nginx configuration:
```bash
sudo nginx -t
cat /etc/nginx/sites-available/default
# Check if backend IP in nginx config matches actual backend IP
```

### Issue 3: "Database Connection Error"
- **Cause:** Backend can't reach database
- **Fix:** Check database connectivity:
```bash
# On backend server
psql -h DATABASE_IP -U db_admin -d postgres
```

## Quick Test Script

Here's a script to test your setup quickly:

```bash
#!/bin/bash
# test_stack.sh

echo "=== Testing Full Stack ==="

# Get IPs from terraform
cd terraform
WEB_IP=$(terraform output -raw web_instance_public_ip 2>/dev/null)
APP_IP=$(terraform output -raw app_instance_public_ip 2>/dev/null)
DB_IP=$(terraform output -raw db_instance_public_ip 2>/dev/null)

echo "Web Server: $WEB_IP"
echo "App Server: $APP_IP" 
echo "DB Server: $DB_IP"

if [ -n "$WEB_IP" ]; then
    echo "Testing web server..."
    curl -v http://$WEB_IP/api/status
fi
```

## Next Steps

1. Choose one of the deployment options above
2. Get infrastructure running
3. Update the hard-coded IP addresses
4. Test the full stack
5. If still having issues, run the debug script I created earlier

The main issue is that you need to either:
- Get your AWS limits increased, OR  
- Deploy to existing infrastructure, OR
- Use a different AWS region/account with available capacity

Would you like me to help you with any of these specific approaches?