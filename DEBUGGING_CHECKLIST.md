# Backend Connectivity Debugging Checklist

## Quick Diagnosis Steps

### 1. Get Current Infrastructure IPs
```bash
cd terraform
terraform output
```

### 2. Test Basic Connectivity
```bash
# Replace <WEB_IP> with your web server IP from terraform output
curl -v http://<WEB_IP>
curl -v http://<WEB_IP>/api/status
```

### 3. Check Hard-coded IPs vs Actual IPs
Compare the IPs from terraform output with:
- `roles/webserver/tasks/main.yml` - line with `backend_ip: "x.x.x.x"`
- `roles/backend/tasks/main.yml` - line with `db_ip: "x.x.x.x"`

### 4. Check Service Status on Servers

#### On Web Server:
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@<WEB_IP>
sudo systemctl status nginx
sudo nginx -t
tail -20 /var/log/nginx/error.log
```

#### On App Server (Backend):
```bash  
ssh -i ~/.ssh/your-key.pem ubuntu@<APP_IP>
sudo systemctl status backend
journalctl -u backend -n 20
ps aux | grep node
```

#### Test Internal Connectivity (from Web Server):
```bash
# SSH to web server, then test backend
curl http://<BACKEND_PRIVATE_IP>:3000/api/status
```

### 5. Common Issues and Fixes

#### Issue 1: Outdated Hard-coded IPs
**Symptoms:** "connection refused" or timeouts
**Fix:** Update the hard-coded IPs in Ansible roles to match current infrastructure

#### Issue 2: Backend Service Not Running  
**Symptoms:** Connection refused on port 3000
**Fix:** 
```bash
sudo systemctl start backend
sudo systemctl enable backend
```

#### Issue 3: Database Connection Issues
**Symptoms:** Backend returns 500 errors
**Fix:** Check database connectivity and credentials

#### Issue 4: Security Group Blocking
**Symptoms:** Timeouts when testing direct backend access
**Fix:** This is expected - backend should only be accessible from web server

#### Issue 5: Nginx Misconfiguration
**Symptoms:** 502 Bad Gateway errors
**Fix:** Check nginx config and restart service

## Automated Fixes

### Run Debug Script:
```bash
chmod +x debug_backend.sh
./debug_backend.sh
```

### Run Fix Playbook (dry-run first):
```bash
# Dry run to see what would change
ansible-playbook -i inventory/aws_ec2.yml fix_backend_connectivity.yml -e check_mode=true

# Actually apply fixes  
ansible-playbook -i inventory/aws_ec2.yml fix_backend_connectivity.yml
```

## Expected Architecture Flow

1. **User** → **Web Server (Nginx)** :80
2. **Nginx** → **Backend (Node.js)** :3000 (internal)
3. **Backend** → **Database (PostgreSQL)** :5432 (internal)

## Security Groups Expected Behavior

- **Web Server**: Accepts HTTP (80) from anywhere, SSH from operator
- **Backend**: Accepts port 3000 ONLY from web server security group
- **Database**: Accepts port 5432 ONLY from VPC CIDR (10.0.0.0/16)

If you can access the web server but get "connecting to backend" errors, the issue is likely in steps 2-3 above.