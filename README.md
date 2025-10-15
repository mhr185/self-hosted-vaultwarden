## 🛡️ Self-Hosted Vaultwarden on DigitalOcean

This project demonstrates how I deployed and secured a **self-hosted Vaultwarden (Bitwarden-compatible)** password manager on a **DigitalOcean Droplet**, using **Docker**, **Docker Compose**, and **Nginx Proxy Manager** for HTTPS reverse proxying.

---

## ⚙️ Tech Stack

- 🐋 **Docker & Docker Compose** – containerized deployment  
- 🌐 **Nginx Proxy Manager (NPM)** – SSL termination and reverse proxy  
- 🧱 **Vaultwarden** – lightweight Bitwarden-compatible server  
- ☁️ **DigitalOcean Droplet** – Ubuntu 22.04 (1GB RAM)  
- 🔐 **Let's Encrypt SSL** – automatic HTTPS certificates  
- 💾 **GitHub** – documentation and version control

---

## 🚀 Step-by-Step Deployment

### 1. Create Droplet and Connect via SSH

```bash
ssh root@your_droplet_ip
```

### 2. Instal Dockerr and Docker Compose

```bash
apt update && apt install docker.io docker-compose -y
systemctl enable docker --now
```

### 3. Create docker-compose.yml:**

 ```bash
version: '3'
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      SIGNUPS_ALLOWED: "false"
      ADMIN_TOKEN: ${ADMIN_TOKEN}
    volumes:
      - ./vw-data:/data
    ports:
      - "8080:80"
```

*I originally had my ADMIN_TOKEN written here, however I learned if I commited this I would be exposing my Admin token, so to deal with this I created a .env file and added my Admin Token value in there, then in my compose I used a Admin token variable.*

Configure ports and volumes

### 4. Start Vaultwarden:

```docker-compose up -d ```

### 4. Configure Nginx Proxy Manager for HTTPS: 

*The front end of Vaultwarden wouldn't load without configuring with HTTPS*
Added a new Proxy Host for vaultwarden.mydomain.com

*Used Duck DNS for this*

Forwarded traffic to http://localhost:8080

Enabled Force SSL, HTTP/2, and HSTS

### 5. Access and Test Vaultwarden

https://vaultwarden.mydomain.com

Login was successful, Admin portal was functioning and HTTPS was working meaning the front end now loaded.

### 5. Cron setup (automated daily backups):

`0 2 * * * /bin/bash /root/vaultwarden/backup.sh >> /root/vaultwarden/backup.log 2>&1`

This simple cron job backed up the data every 24 hours, would rotate the logs weekly and rerstart the container if stopped.
