# OpenClaw Deployment - Quick Start Guide

## 🎯 Complete Deployment in 3 Steps

### Step 1: Create Google Cloud VM

```bash
# Create VM (run from your local machine with gcloud CLI)
gcloud compute instances create openclaw-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=http-server

# Optional: Open firewall for web UI (or use SSH tunnel instead)
gcloud compute firewall-rules create openclaw-web \
  --allow=tcp:18789 \
  --target-tags=http-server
```

### Step 2: Deploy OpenClaw

**Option A: Automated (Recommended)**

```bash
# From your local machine in this repo
./scripts/deploy.sh
# Follow the prompts
```

**Option B: Manual**

```bash
# SSH to VM
gcloud compute ssh openclaw-vm --zone=us-central1-a

# Clone this repo (after pushing it to GitHub/GitLab)
git clone <your-repo-url> openclaw
cd openclaw

# Run setup
./setup.sh

# Configure your API key
nano .env  # Add ANTHROPIC_API_KEY=...

# Start services
docker-compose up -d
```

### Step 3: Connect Channels

```bash
# SSH to VM
gcloud compute ssh openclaw-vm --zone=us-central1-a

# Login to WhatsApp (or other channels)
cd openclaw
docker-compose exec openclaw openclaw channels login

# Scan QR code with WhatsApp
```

## 🌐 Access Control UI

**Secure method (SSH tunnel):**

```bash
# From your local machine
gcloud compute ssh openclaw-vm --zone=us-central1-a -- -L 18789:localhost:18789

# Visit: http://localhost:18789
```

**Direct access (if firewall is open):**

```bash
# Get VM IP
gcloud compute instances list

# Visit: http://[VM_IP]:18789
```

## 📋 Daily Management

```bash
# SSH to VM
gcloud compute ssh openclaw-vm

cd openclaw

# View logs
./scripts/manage.sh logs

# Check status
./scripts/manage.sh status

# Restart
./scripts/manage.sh restart

# Update
./scripts/manage.sh update

# Backup
./scripts/manage.sh backup
```

## 🔒 Security Checklist

- [ ] Set up SSH keys for VM access
- [ ] Add ANTHROPIC_API_KEY to `.env`
- [ ] Configure allowlist in OpenClaw config
- [ ] Use SSH tunnel for web UI (don't expose port 18789)
- [ ] Set up regular backups
- [ ] Enable OS auto-updates

## 🆘 Quick Troubleshooting

**Container won't start:**
```bash
docker-compose logs openclaw
docker-compose restart
```

**WhatsApp disconnected:**
```bash
docker-compose exec openclaw openclaw channels login
```

**Out of disk space:**
```bash
docker system prune -a
```

**VM is slow:**
```bash
# Upgrade VM machine type
gcloud compute instances set-machine-type openclaw-vm \
  --machine-type=e2-standard-2 \
  --zone=us-central1-a
```

## 📚 Next Steps

- Read [Full README](README.md) for detailed information
- Check [OpenClaw Docs](https://docs.openclaw.ai/)
- Configure [security settings](https://docs.openclaw.ai/gateway/security)
- Set up [multi-agent routing](https://docs.openclaw.ai/concepts/multi-agent)
