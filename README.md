## 🛡️ Self-Hosted Vaultwarden on DigitalOcean

This project demonstrates how I deployed and secured a **self-hosted Vaultwarden (Bitwarden-compatible)** password manager on a **DigitalOcean Droplet**, using **Docker**, **Docker Compose**, and **Nginx Proxy Manager** for HTTPS reverse proxying.

---

## ⚙️ Tech Stack

- 🐋 **Docker & Docker Compose** – containerized deployment  
- 🌐 **Nginx Proxy Manager (NPM)** – SSL termination and reverse proxy  
- 🧱 **Vaultwarden** – lightweight Bitwarden-compatible server  
- ☁️ **DigitalOcean Droplet** – Ubuntu 22.04 (1 VCPU / 2GB RAM)  
- 🔐 **Let's Encrypt SSL** – automatic HTTPS certificates  
- 💾 **GitHub** – documentation and version control

---

## Step-by-Step Deployment

### 1. Create Droplet and Connect via SSH

```bash
ssh root@your_droplet_ip
```

### 2. Install Docker and Docker Compose

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

*I originally had my ADMIN_TOKEN written here, however I learned if I commited this I would be exposing my Admin token, so to deal with this I created a .env file and added my Admin Token value in there, then in my compose I used a ADMIN_TOKEN variable.*

Configure ports and volumes

### 4. Start Vaultwarden:

```docker-compose up -d ```

<img width="1301" height="118" alt="docker ps" src="https://github.com/user-attachments/assets/32966396-6311-42a1-9d10-a3bc80ddc9f4" />

*The front end of Vaultwarden wouldn't load without configuring with HTTPS, I had a constant hanging landing page when first accessing through http://localhost:8080*

*I began searching the logs first as I thought it was a config issue, I used `docker logs [containerid]` to check and I found nothing, thats when I moved onto creating HTTPS config*

### 4. Configure Nginx Proxy Manager for HTTPS: 


Added a new Proxy Host for vaultwarden.mydomain.com

*Used Duck DNS for this*

Forwarded traffic to http://localhost:8080

Enabled Force SSL, HTTP/2, and HSTS

<img width="1202" height="228" alt="nginx proxy config" src="https://github.com/user-attachments/assets/0532f4d8-835a-422d-9399-f16441f70445" />


### 5. Access and Test Vaultwarden

https://vaultwarden.mydomain.com

Login was successful, Admin portal was functioning and HTTPS was working meaning the front end now loaded.

<img width="1368" height="562" alt="vaultwardenadmin" src="https://github.com/user-attachments/assets/78a65379-dd8b-4853-85d8-3ff1b65d7819" />

I tested new signups by going through the admin portal and enabling new signups as it was disabled in the compose. I signed up my account using that and once I was happy it was working I disabled new signups again. I tested a dummy entry by saving and then restarting the container to make sure the ./vw-data:/data persisted, which it did. Then I imported all my password data from another password manager which it also passed. 


### 6. Cron setup (automated daily backups):

`0 2 * * * /bin/bash /root/vaultwarden/backup.sh >> /root/vaultwarden/backup.log 2>&1`

In backup.sh:

 Delete backups older than 7 days
```find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -delete```

This simple cron job backed up the data every 24 hours, would rotate the logs weekly and rerstart the container if stopped.

---

## 🧠 What I Learned

Setting up Docker Compose and environment variables securely

Managing reverse proxies and SSL certificates

Troubleshooting container logs and HTTP errors

Simple cron job to back up data, and rotate logs

## 🪄 Next Steps

Implement automated backups using GitHub Actions or Cron

Add monitoring with Grafana + Prometheus

Experiment with CI/CD pipeline integration

