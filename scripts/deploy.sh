#!/bin/bash

# Quick Deploy Script
# Deploys OpenClaw to a fresh Google Cloud VM

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}OpenClaw Quick Deploy${NC}"
echo "================================"
echo ""

# Get VM details
read -p "Enter VM IP address: " VM_IP
read -p "Enter VM username: " VM_USER
read -p "Enter SSH key path (default: ~/.ssh/google_compute_engine): " SSH_KEY
SSH_KEY=${SSH_KEY:-~/.ssh/google_compute_engine}

# Get repository URL
read -p "Enter repository URL (git clone): " REPO_URL

echo ""
echo -e "${YELLOW}Connecting to VM and running setup...${NC}"
echo ""

# Copy the repository to the VM
ssh -i "$SSH_KEY" "$VM_USER@$VM_IP" << EOF
    set -e
    
    # Clone repository
    if [ -d "openclaw" ]; then
        echo "Repository already exists, pulling latest..."
        cd openclaw
        git pull
    else
        echo "Cloning repository..."
        git clone "$REPO_URL" openclaw
        cd openclaw
    fi
    
    # Make scripts executable
    chmod +x setup.sh
    chmod +x scripts/*.sh
    
    # Run setup
    ./setup.sh
EOF

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Your OpenClaw instance is now running on:"
echo "  http://$VM_IP:18789"
echo ""
echo "To connect with SSH tunnel:"
echo "  ssh -i $SSH_KEY -L 18789:localhost:18789 $VM_USER@$VM_IP"
echo "  Then visit: http://localhost:18789"
echo ""
echo "To manage your deployment:"
echo "  ssh -i $SSH_KEY $VM_USER@$VM_IP"
echo "  cd openclaw"
echo "  ./scripts/manage.sh [command]"
echo ""
