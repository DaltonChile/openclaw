#!/bin/bash
set -e

echo "================================================"
echo "OpenClaw VM Setup Script"
echo "================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run this script as root${NC}"
    exit 1
fi

# Update system
echo -e "${GREEN}[1/7] Updating system packages...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo -e "${GREEN}[2/7] Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${YELLOW}Docker installed. You may need to log out and back in for group changes to take effect.${NC}"
else
    echo "Docker already installed"
fi

# Install Docker Compose
echo -e "${GREEN}[3/7] Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose already installed"
fi

# Install git if not present
echo -e "${GREEN}[4/7] Checking git installation...${NC}"
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
else
    echo "Git already installed"
fi

# Clone repository if not already present
REPO_DIR="$HOME/openclaw"
echo -e "${GREEN}[5/7] Setting up OpenClaw repository...${NC}"
if [ ! -d "$REPO_DIR" ]; then
    echo "Please enter your repository URL:"
    read REPO_URL
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Repository already exists at $REPO_DIR"
    cd "$REPO_DIR"
    git pull
fi

cd "$REPO_DIR"

# Set up environment file
echo -e "${GREEN}[6/7] Setting up environment variables...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}Please edit .env file with your API keys:${NC}"
    echo "  nano .env"
    echo ""
    echo "Press Enter when ready to continue..."
    read
fi

# Build and start services
echo -e "${GREEN}[7/7] Building and starting OpenClaw...${NC}"
docker-compose build
docker-compose up -d

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}OpenClaw Setup Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Next steps:"
echo "1. Connect to OpenClaw gateway:"
echo "   docker-compose exec openclaw openclaw channels login"
echo ""
echo "2. Access the Control UI:"
echo "   http://$(curl -s ifconfig.me):18789"
echo "   or http://localhost:18789 (if using SSH tunnel)"
echo ""
echo "3. View logs:"
echo "   docker-compose logs -f openclaw"
echo ""
echo "4. Check status:"
echo "   docker-compose ps"
echo ""
echo "For SSH tunnel access (from your local machine):"
echo "   ssh -L 18789:localhost:18789 $USER@$(curl -s ifconfig.me)"
echo ""
