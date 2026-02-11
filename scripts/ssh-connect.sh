#!/bin/bash

# SSH Connection Helper for OpenClaw VM
# Usage: ./ssh-connect.sh [command]

# Configuration - Edit these values
VM_USER="your-username"
VM_IP="your-vm-ip"
SSH_KEY="~/.ssh/google_compute_engine"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if config is set
if [ "$VM_IP" = "your-vm-ip" ]; then
    echo -e "${RED}Error: Please configure VM_IP in this script${NC}"
    echo "Edit ssh-connect.sh and set VM_USER and VM_IP"
    exit 1
fi

# If no command provided, open interactive shell with port forwarding
if [ $# -eq 0 ]; then
    echo -e "${GREEN}Connecting to OpenClaw VM with port forwarding...${NC}"
    echo "Control UI will be available at: http://localhost:18789"
    echo ""
    ssh -i "$SSH_KEY" -L 18789:localhost:18789 "$VM_USER@$VM_IP"
else
    # Execute command on remote VM
    ssh -i "$SSH_KEY" "$VM_USER@$VM_IP" "$@"
fi
