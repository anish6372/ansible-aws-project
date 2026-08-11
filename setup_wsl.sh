#!/bin/bash
# This script sets up your WSL environment and copies the project
# to the Linux filesystem to avoid the world-writable warning from Ansible.

PROJECT_SRC="/mnt/c/Users/anish.panda/ansible-aws-project"
PROJECT_DEST="$HOME/ansible-aws-project"

echo "=== Copying project to Linux filesystem ==="
cp -r "$PROJECT_SRC" "$PROJECT_DEST"
chmod 700 "$PROJECT_DEST"
echo "Project copied to: $PROJECT_DEST"

echo ""
echo "=== Setting up SSH key ==="
mkdir -p ~/.ssh
# Copy the key if it exists on Windows side
if [ -f "/mnt/c/Users/anish.panda/.ssh/demo-key.pem" ]; then
    cp /mnt/c/Users/anish.panda/.ssh/demo-key.pem ~/.ssh/demo-key.pem
    chmod 600 ~/.ssh/demo-key.pem
    echo "SSH key copied and permissions set."
else
    echo "SSH key not found at /mnt/c/Users/anish.panda/.ssh/demo-key.pem"
    echo "You will need to copy it manually after downloading from AWS."
fi

echo ""
echo "=== Configuring AWS credentials ==="
echo "Run this next: aws configure"
echo "  AWS Access Key ID:     <your key>"
echo "  AWS Secret Access Key: <your secret>"
echo "  Default region:        us-east-1"
echo "  Default output format: json"

echo ""
echo "=== Ready! Here are your next steps ==="
echo ""
echo "1. Open WSL terminal and run:"
echo "   cd ~/ansible-aws-project"
echo ""
echo "2. Configure AWS:"
echo "   aws configure"
echo ""
echo "3. Go to terraform/ and provision infrastructure:"
echo "   cd ~/ansible-aws-project/terraform"
echo "   terraform init"
echo "   terraform apply"
echo ""
echo "4. Come back to project root and set vault password:"
echo "   cd ~/ansible-aws-project"
echo "   echo 'your-vault-password' > .vault_pass"
echo "   chmod 600 .vault_pass"
echo "   ansible-vault encrypt group_vars/all/vault_secrets.yml"
echo ""
echo "5. Verify Ansible can see EC2s (wait 2 min after terraform apply):"
echo "   ansible-inventory --list | grep tag_Role"
echo ""
echo "6. Run the playbook:"
echo "   ansible-playbook site.yml"
