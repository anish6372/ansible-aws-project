#!/bin/bash

echo "=== BACKEND CONNECTIVITY DEBUG SCRIPT ==="
echo "Timestamp: $(date)"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
echo "1. CHECKING REQUIRED TOOLS..."
for tool in terraform ansible aws curl; do
    if command_exists $tool; then
        echo "✓ $tool is installed"
    else
        echo "✗ $tool is not installed or not in PATH"
    fi
done
echo ""

# Get current Terraform state
echo "2. GETTING CURRENT INFRASTRUCTURE IPs..."
cd terraform 2>/dev/null || echo "Warning: Not in terraform directory"

if [ -f "terraform.tfstate" ]; then
    echo "Web Server IP:      $(terraform output -raw web_instance_public_ip 2>/dev/null || echo 'Not available')"
    echo "App Server IP:      $(terraform output -raw app_instance_public_ip 2>/dev/null || echo 'Not available')"
    echo "Database Server IP: $(terraform output -raw db_instance_public_ip 2>/dev/null || echo 'Not available')"
else
    echo "No terraform.tfstate found. Run 'terraform apply' first."
fi
echo ""

cd .. 2>/dev/null

# Check Ansible inventory
echo "3. CHECKING ANSIBLE INVENTORY..."
if command_exists ansible-inventory; then
    echo "Ansible inventory hosts:"
    ansible-inventory --list -i inventory/aws_ec2.yml 2>/dev/null | jq -r '.["tag_Role_webserver"]["hosts"][]? // empty' | head -5
    ansible-inventory --list -i inventory/aws_ec2.yml 2>/dev/null | jq -r '.["tag_Role_backend"]["hosts"][]? // empty' | head -5
else
    echo "ansible-inventory command not available"
fi
echo ""

# Check current hard-coded IPs in playbooks
echo "4. CHECKING HARD-CODED IPs IN PLAYBOOKS..."
echo "Backend IP in webserver role:"
grep -n "backend_ip:" roles/webserver/tasks/main.yml 2>/dev/null || echo "Not found"
echo "Database IP in backend role:"
grep -n "db_ip:" roles/backend/tasks/main.yml 2>/dev/null || echo "Not found"
echo ""

# Test connectivity to services
echo "5. TESTING SERVICE CONNECTIVITY..."

# Get the web server IP for testing
WEB_IP=""
if [ -f "terraform/terraform.tfstate" ]; then
    WEB_IP=$(cd terraform && terraform output -raw web_instance_public_ip 2>/dev/null)
fi

if [ -n "$WEB_IP" ] && [ "$WEB_IP" != "null" ]; then
    echo "Testing web server at $WEB_IP..."
    
    # Test direct web access
    echo -n "  HTTP (port 80): "
    if curl -s --connect-timeout 5 "http://$WEB_IP" > /dev/null; then
        echo "✓ Accessible"
    else
        echo "✗ Not accessible"
    fi
    
    # Test API endpoint through web server
    echo -n "  API via web server: "
    API_RESPONSE=$(curl -s --connect-timeout 10 "http://$WEB_IP/api/status" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$API_RESPONSE" ]; then
        echo "✓ Accessible"
        echo "    Response: $API_RESPONSE"
    else
        echo "✗ Not accessible or no response"
    fi
else
    echo "Web server IP not available for testing"
fi

# Get backend IP for direct testing
BACKEND_IP=""
if [ -f "terraform/terraform.tfstate" ]; then
    BACKEND_IP=$(cd terraform && terraform output -raw app_instance_public_ip 2>/dev/null)
fi

if [ -n "$BACKEND_IP" ] && [ "$BACKEND_IP" != "null" ]; then
    echo ""
    echo "Testing backend server directly at $BACKEND_IP..."
    
    # Test direct backend access (this might fail due to security groups)
    echo -n "  Direct API (port 3000): "
    if curl -s --connect-timeout 5 "http://$BACKEND_IP:3000/api/status" > /dev/null 2>&1; then
        echo "✓ Accessible (security groups allow direct access)"
    else
        echo "✗ Not accessible (likely blocked by security groups - this is expected)"
    fi
else
    echo "Backend server IP not available for testing"
fi

echo ""
echo "6. CHECKING SERVICE STATUS ON SERVERS..."
echo "To check backend service status on the app server, run:"
echo "  ssh -i ~/.ssh/your-key.pem ubuntu@$BACKEND_IP 'sudo systemctl status backend'"
echo ""
echo "To check nginx status on the web server, run:"
echo "  ssh -i ~/.ssh/your-key.pem ubuntu@$WEB_IP 'sudo systemctl status nginx'"
echo ""

echo "7. RECOMMENDED DEBUGGING STEPS:"
echo ""
echo "a) Verify current IPs match the hard-coded fallbacks in Ansible roles"
echo "b) Check if backend service is running: systemctl status backend"
echo "c) Check nginx configuration: cat /etc/nginx/sites-available/default"
echo "d) Check nginx logs: tail -f /var/log/nginx/error.log"
echo "e) Check backend logs: journalctl -u backend -f"
echo "f) Test internal connectivity from web server to backend"
echo ""

echo "=== DEBUG SCRIPT COMPLETE ==="