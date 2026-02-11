# OpenClaw Docker Deployment

🦞 Self-hosted AI agent gateway for WhatsApp, Telegram, Discord, iMessage, and more.

This repository provides a complete, production-ready Docker deployment for [OpenClaw](https://docs.openclaw.ai/) on Google Cloud VM (or any Linux server).

## 📋 Prerequisites

### On Google Cloud
1. **Create a VM instance**:
   ```bash
   gcloud compute instances create openclaw-vm \
     --zone=us-central1-a \
     --machine-type=e2-medium \
     --image-family=ubuntu-2204-lts \
     --image-project=ubuntu-os-cloud \
     --boot-disk-size=20GB \
     --tags=http-server,https-server
   ```

2. **Configure firewall** (for web UI access):
   ```bash
   gcloud compute firewall-rules create openclaw-web \
     --allow=tcp:18789 \
     --target-tags=http-server \
     --description="OpenClaw Web UI"
   ```

### Required
- Google Cloud VM (or any Linux server)
- Ubuntu 20.04+ or Debian 11+
- 2+ GB RAM recommended
- Anthropic API key (get one at https://console.anthropic.com/)

## 🚀 Quick Deploy

### Option 1: Automated Deploy (Recommended)

From your local machine:

```bash
# Make deploy script executable
chmod +x scripts/deploy.sh

# Run the deployment
./scripts/deploy.sh
```

This will:
- Connect to your VM
- Clone this repository
- Install Docker and dependencies
- Build and start OpenClaw
- Configure everything automatically

### Option 2: Manual Deploy

1. **SSH into your VM**:
   ```bash
   gcloud compute ssh openclaw-vm --zone=us-central1-a
   ```

2. **Clone this repository**:
   ```bash
   git clone <your-repo-url> openclaw
   cd openclaw
   ```

3. **Run setup script**:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

4. **Configure environment**:
   ```bash
   cp .env.example .env
   nano .env  # Add your API keys
   ```

5. **Start OpenClaw**:
   ```bash
   docker-compose up -d
   ```

## 🔧 Configuration

### Environment Variables

Edit `.env` file:

```bash
# Required: Your Anthropic API key
ANTHROPIC_API_KEY=sk-ant-...

# Optional: OpenAI API key
OPENAI_API_KEY=sk-...
```

### OpenClaw Configuration

Configuration lives at `/root/.openclaw/openclaw.json` inside the container.

Example config for WhatsApp with allowlist:

```json
{
  "channels": {
    "whatsapp": {
      "allowFrom": ["+1234567890"],
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    }
  },
  "messages": {
    "groupChat": {
      "mentionPatterns": ["@openclaw"]
    }
  }
}
```

## 📱 Connecting Channels

### WhatsApp

```bash
# Open the channel login interface
docker-compose exec openclaw openclaw channels login

# Follow the QR code prompts to authenticate
```

### Other Channels

See the [official documentation](https://docs.openclaw.ai/channels/telegram) for:
- Telegram
- Discord
- iMessage
- Mattermost

## 🌐 Accessing the Control UI

### From your local machine (SSH tunnel):

```bash
# Connect with port forwarding
ssh -L 18789:localhost:18789 username@your-vm-ip

# Then visit in your browser:
# http://localhost:18789
```

### Direct access (if firewall is configured):

```
http://your-vm-ip:18789
```

### Using the helper script:

```bash
# Edit ssh-connect.sh with your VM details
nano scripts/ssh-connect.sh

# Connect
./scripts/ssh-connect.sh
```

## 🛠️ Management Commands

Use the management script for common operations:

```bash
cd openclaw
./scripts/manage.sh [command]
```

### Available Commands

- `start` - Start OpenClaw services
- `stop` - Stop OpenClaw services
- `restart` - Restart OpenClaw services
- `logs` - Show logs (follow mode)
- `status` - Show service status and resource usage
- `update` - Pull latest changes and rebuild
- `login` - Login to channels (WhatsApp, etc)
- `shell` - Open shell in container
- `backup` - Backup OpenClaw data
- `restore <file>` - Restore from backup

### Manual Docker Commands

```bash
# View logs
docker-compose logs -f openclaw

# Check status
docker-compose ps

# Restart service
docker-compose restart

# Stop and remove containers
docker-compose down

# Rebuild after changes
docker-compose build
docker-compose up -d
```

## 🔒 Security Best Practices

1. **Restrict access** with allowlists in config
2. **Use SSH tunneling** instead of exposing port 18789 publicly
3. **Keep system updated**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
4. **Monitor logs** regularly:
   ```bash
   ./scripts/manage.sh logs
   ```
5. **Set up backups**:
   ```bash
   ./scripts/manage.sh backup
   ```

## 💾 Backup and Restore

### Create Backup

```bash
./scripts/manage.sh backup
```

Backups are saved to `~/openclaw-backups/`

### Restore Backup

```bash
./scripts/manage.sh restore ~/openclaw-backups/openclaw-backup-YYYYMMDD-HHMMSS.tar.gz
```

## 🐛 Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs openclaw

# Check if port is in use
sudo lsof -i :18789
```

### WhatsApp connection issues

```bash
# Restart container
docker-compose restart

# Clear session and re-login
docker-compose exec openclaw rm -rf /root/.openclaw/.wwebjs_auth
docker-compose exec openclaw openclaw channels login
```

### Out of memory

```bash
# Increase swap space
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Update to latest version

```bash
./scripts/manage.sh update
```

## 📚 Documentation

- [Official OpenClaw Docs](https://docs.openclaw.ai/)
- [Configuration Guide](https://docs.openclaw.ai/gateway/configuration)
- [Channel Setup](https://docs.openclaw.ai/channels/telegram)
- [Troubleshooting](https://docs.openclaw.ai/gateway/troubleshooting)

## 📁 Repository Structure

```
openclaw/
├── Dockerfile              # OpenClaw container definition
├── docker-compose.yml      # Service orchestration
├── setup.sh                # VM setup script
├── .env.example            # Environment template
├── scripts/
│   ├── deploy.sh           # Automated deployment
│   ├── ssh-connect.sh      # SSH connection helper
│   └── manage.sh           # Management commands
└── README.md               # This file
```

## 🔄 Updates and Maintenance

### Update OpenClaw

```bash
cd ~/openclaw
./scripts/manage.sh update
```

### Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```

### Monitor Resources

```bash
./scripts/manage.sh status
```

## 📝 License

This deployment configuration is provided as-is. OpenClaw itself is MIT licensed.

## 🤝 Contributing

Issues and PRs welcome! This is a community-maintained deployment template.

---

**Need help?** Check the [OpenClaw documentation](https://docs.openclaw.ai/) or open an issue.
