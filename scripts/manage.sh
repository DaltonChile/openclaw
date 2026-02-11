#!/bin/bash

# OpenClaw Management Script
# Helper commands for managing OpenClaw on the VM

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$PROJECT_DIR"

show_help() {
    echo "OpenClaw Management Script"
    echo ""
    echo "Usage: ./manage.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start       - Start OpenClaw services"
    echo "  stop        - Stop OpenClaw services"
    echo "  restart     - Restart OpenClaw services"
    echo "  logs        - Show OpenClaw logs (follow mode)"
    echo "  status      - Show service status"
    echo "  update      - Pull latest changes and rebuild"
    echo "  login       - Login to channels (WhatsApp, Telegram, etc)"
    echo "  shell       - Open shell in OpenClaw container"
    echo "  backup      - Backup OpenClaw data"
    echo "  restore     - Restore OpenClaw data from backup"
    echo ""
}

case "${1:-help}" in
    start)
        echo -e "${GREEN}Starting OpenClaw...${NC}"
        docker-compose up -d
        echo "OpenClaw started. Check status with: ./manage.sh status"
        ;;
    
    stop)
        echo -e "${YELLOW}Stopping OpenClaw...${NC}"
        docker-compose down
        ;;
    
    restart)
        echo -e "${YELLOW}Restarting OpenClaw...${NC}"
        docker-compose restart
        ;;
    
    logs)
        echo -e "${GREEN}Showing OpenClaw logs (Ctrl+C to exit)...${NC}"
        docker-compose logs -f openclaw
        ;;
    
    status)
        echo -e "${GREEN}OpenClaw Status:${NC}"
        docker-compose ps
        echo ""
        echo "Resource usage:"
        docker stats --no-stream openclaw-gateway
        ;;
    
    update)
        echo -e "${GREEN}Updating OpenClaw...${NC}"
        git pull
        docker-compose build
        docker-compose up -d
        echo "Update complete!"
        ;;
    
    login)
        echo -e "${GREEN}Opening channel login...${NC}"
        docker-compose exec openclaw openclaw channels login
        ;;
    
    shell)
        echo -e "${GREEN}Opening shell in OpenClaw container...${NC}"
        docker-compose exec openclaw /bin/bash
        ;;
    
    backup)
        BACKUP_DIR="$HOME/openclaw-backups"
        mkdir -p "$BACKUP_DIR"
        BACKUP_FILE="$BACKUP_DIR/openclaw-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
        echo -e "${GREEN}Creating backup...${NC}"
        docker-compose exec -T openclaw tar czf - /root/.openclaw > "$BACKUP_FILE"
        echo "Backup created: $BACKUP_FILE"
        ;;
    
    restore)
        if [ -z "$2" ]; then
            echo "Usage: ./manage.sh restore <backup-file>"
            exit 1
        fi
        echo -e "${YELLOW}Restoring from backup...${NC}"
        cat "$2" | docker-compose exec -T openclaw tar xzf - -C /
        docker-compose restart
        echo "Restore complete!"
        ;;
    
    help|*)
        show_help
        ;;
esac
