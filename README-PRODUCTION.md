# Sistema Avícola IoT - Production Deployment Guide

## Overview
This guide helps you deploy the Sistema Avícola IoT project on a Windows laptop using WSL2 and Cloudflare Tunnel for global web access.

## Prerequisites
- Windows 10/11 with WSL2 enabled
- Cloudflare account (free tier is sufficient)
- Domain name (optional but recommended)
- High-resource laptop with stable internet connection

## Step 1: Setup WSL2 Environment

### Install WSL2 (if not already installed)
```powershell
# In PowerShell as Administrator
wsl --install
wsl --set-default-version 2
```

### Install Ubuntu in WSL2
```powershell
# From Microsoft Store or PowerShell
wsl --install -d Ubuntu
```

## Step 2: Setup Production Environment

### Clone and Setup Project
```bash
# In WSL2 Ubuntu terminal
cd /home/your-user
git clone <your-repository-url>
cd sistema-avicola-iot

# Make setup script executable
chmod +x setup-production.sh

# Run setup script
./setup-production.sh
```

### Configure Environment Variables
Edit `.env.production` with secure values:
```bash
nano .env.production
```

**Important: Change these values:**
- `POSTGRES_PASSWORD` - Strong database password
- `SECRET_KEY` - 32+ character random string
- `MQTT_PASSWORD` - MQTT authentication password

## Step 3: Start Services

### Start Docker Services
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Verify Services
```bash
# Check all containers are running
docker-compose -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.prod.yml logs -f
```

## Step 4: Setup Cloudflare Tunnel

### 1. Create Cloudflare Account
- Sign up at https://cloudflare.com
- Add your domain (or use Cloudflare's provided subdomain)

### 2. Create Tunnel
```bash
# Login to Cloudflare
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create avicola-iot

# Note the tunnel UUID and copy credentials file

# Configure tunnel
cp cloudflare-tunnel.yml ~/.cloudflared/config.yml
# Edit the file with your tunnel UUID and domain
```

### 3. Configure DNS
```bash
# Create DNS records
cloudflared tunnel route dns avicola-iot your-domain.com
cloudflared tunnel route dns avicola-iot api.your-domain.com
```

### 4. Start Tunnel
```bash
# Test tunnel
cloudflared tunnel run avicola-iot

# Install as service (Ubuntu)
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

## Step 5: Access Your Application

### Web Access
- **Dashboard**: `https://your-domain.com`
- **API**: `https://your-domain.com/api/`

### Local Development
- **Dashboard**: `http://localhost:5001`
- **API**: `http://localhost:5000`

## Security Considerations

### Firewall Configuration
```bash
# Allow necessary ports through Windows Firewall
# Port 80/443 for web traffic
# Port 1883 for MQTT (if external access needed)
```

### SSL/TLS
- Cloudflare provides free SSL certificates
- Internal Docker communication uses HTTP
- Consider upgrading to HTTPS internally for sensitive data

### Backup Strategy
```bash
# Database backup script
docker exec sistema-avicola-iot-db-1 pg_dump -U avicola_prod_user avicola_prod_db > backup_$(date +%Y%m%d).sql

# Automated backup (add to crontab)
0 2 * * * /path/to/backup-script.sh
```

## Monitoring and Maintenance

### Health Checks
```bash
# Check service health
curl http://localhost:5000/health
curl http://localhost:5001/health

# Container status
docker stats
```

### Log Management
```bash
# View logs
docker-compose -f docker-compose.prod.yml logs api
docker-compose -f docker-compose.prod.yml logs dashboard
docker-compose -f docker-compose.prod.yml logs db
```

### Updates
```bash
# Update application
git pull origin main
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

## Troubleshooting

### Common Issues

1. **Port conflicts**
   - Stop other services using ports 80, 443, 5000, 5001, 1883
   - Check with `netstat -tulpn`

2. **Docker permission issues**
   - Add user to docker group: `sudo usermod -aG docker $USER`
   - Restart WSL2: `wsl --shutdown`

3. **Cloudflare tunnel not working**
   - Verify tunnel configuration
   - Check DNS propagation
   - Review Cloudflare dashboard logs

4. **Database connection issues**
   - Verify environment variables
   - Check database container health
   - Review database logs

### Performance Optimization

1. **Database**
   - Regular VACUUM operations
   - Monitor connection pool
   - Consider read replicas for scaling

2. **Application**
   - Enable Redis caching (future enhancement)
   - Monitor memory usage
   - Optimize database queries

3. **Network**
   - Use Cloudflare caching
   - Enable Gzip compression
   - Monitor bandwidth usage

## Scaling Considerations

### When to Scale Up
- High CPU usage (>80% sustained)
- Memory pressure (>90% usage)
- Database connection limits reached
- Network bandwidth saturation

### Scaling Options
1. **Vertical Scaling**: Increase laptop resources
2. **Horizontal Scaling**: Add more servers
3. **Cloud Migration**: Move to cloud provider

## Cost Analysis

### Free Tier Limitations
- Cloudflare: 100k requests/month free
- Bandwidth considerations
- Database storage limits

### Paid Features
- Cloudflare Pro: Enhanced security features
- Additional domains and subdomains
- Advanced analytics and monitoring

## Support and Documentation

### Resources
- [Docker Documentation](https://docs.docker.com/)
- [Cloudflare Tunnel Guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)

### Emergency Procedures
1. **Service Down**: Check Docker status, restart services
2. **Data Loss**: Restore from database backups
3. **Security Incident**: Change passwords, review logs
4. **Performance Issues**: Check resource usage, scale if needed

## Conclusion

This setup provides a robust, secure, and globally accessible deployment for your Sistema Avícola IoT project. The combination of WSL2, Docker, and Cloudflare Tunnel offers enterprise-grade features while maintaining simplicity and cost-effectiveness.

Regular monitoring, updates, and backups will ensure reliable operation for your IoT monitoring system.
