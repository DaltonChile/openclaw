# OpenClaw Docker Image
FROM node:22-slim

# Install dependencies for WhatsApp/Telegram clients (chromium for whatsapp-web.js)
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-sandbox \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    fonts-freefont-ttf \
    libxss1 \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up puppeteer to use installed chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Create app directory
WORKDIR /app

# Create openclaw config directory
RUN mkdir -p /root/.openclaw

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Expose the default port
EXPOSE 18789

# Volume for persistent data (sessions, config, auth)
VOLUME ["/root/.openclaw"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "const http = require('http'); http.get('http://localhost:18789/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }).on('error', () => { process.exit(1); });" || exit 1

# Start the gateway
CMD ["openclaw", "gateway", "--port", "18789", "--host", "0.0.0.0"]
