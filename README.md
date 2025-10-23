# 🐬 MySQL Database with phpMyAdmin

A production-ready Docker Compose setup for MySQL 8.0 with phpMyAdmin web interface, served through nginx reverse proxy. Optimized for Docker Desktop on Windows/WSL2 with automatic container restart capability.

[![Docker](https://img.shields.io/badge/Docker-20.10%2B-blue.svg)](https://www.docker.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)](https://www.mysql.com/)
[![phpMyAdmin](https://img.shields.io/badge/phpMyAdmin-5-green.svg)](https://www.phpmyadmin.net/)
[![nginx](https://img.shields.io/badge/nginx-1.29-brightgreen.svg)](https://nginx.org/)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Volume Management](#-volume-management)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

This project provides a complete MySQL database environment with a web-based administration interface using phpMyAdmin. The setup uses Docker Compose for orchestration and is specifically optimized for Docker Desktop on Windows with WSL2, ensuring all containers automatically restart after system reboots.

### What's Included

- **MySQL 8.0**: Robust relational database with persistent storage
- **phpMyAdmin**: Web-based database management interface
- **nginx**: High-performance reverse proxy serving phpMyAdmin
- **Health checks**: Automated container health monitoring
- **Auto-restart**: Containers restart automatically after system reboot

---

## ✨ Features

### 🚀 Core Features
- **One-command deployment** - Get started with `docker-compose up -d`
- **Persistent data storage** - MySQL data survives container restarts
- **Web-based management** - phpMyAdmin accessible via browser
- **Fast FPM Alpine** - Lightweight phpMyAdmin using PHP-FPM
- **Production-ready nginx** - Optimized reverse proxy configuration

### 🔐 Security Features
- Environment-based configuration (no hardcoded credentials)
- Read-only configuration mounts
- Network isolation with dedicated Docker network
- Root host access control

### 🔄 Reliability Features
- **Automatic container restart** - All services restart on system reboot
- **Health monitoring** - MySQL health checks ensure database availability
- **Graceful dependencies** - Services start in correct order
- **Volume-based configs** - No dependency on host filesystem for auto-restart

### 🛠️ Developer Features
- Easy configuration updates via helper script
- Detailed logging for all services
- Hot-reload capable configuration
- Customizable ports via environment variables

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│                  Host Machine                    │
│  ┌────────────────────────────────────────────┐ │
│  │          Docker Network (db-network)       │ │
│  │                                            │ │
│  │  ┌──────────┐   ┌──────────┐  ┌────────┐ │ │
│  │  │  nginx   │   │   PMA    │  │ MySQL  │ │ │
│  │  │  :80     │──▶│  :9000   │─▶│ :3306  │ │ │
│  │  └──────────┘   └──────────┘  └────────┘ │ │
│  │       │              │             │      │ │
│  │       ▼              ▼             ▼      │ │
│  │  nginx_config   pma_config   mysql-data  │ │
│  │   (volume)       (volume)     (volume)   │ │
│  └────────────────────────────────────────────┘ │
│                      │                          │
│                      ▼                          │
│              Port: ${NGINX_PORT}                │
└─────────────────────────────────────────────────┘
```

### Container Communication
1. **Client** → nginx (port exposed via `NGINX_PORT`)
2. **nginx** → phpMyAdmin (internal, port 9000)
3. **phpMyAdmin** → MySQL (internal, port 3306)

---

## 📦 Prerequisites

- **Docker Desktop** 20.10 or higher
- **Docker Compose** 2.0 or higher
- **Windows with WSL2** (if on Windows)
- **2GB RAM** minimum allocated to Docker
- **5GB disk space** for images and volumes

### Verify Installation

```bash
docker --version
docker-compose --version
```

---

## 🚀 Installation

### 1. Clone or Download

```bash
git clone https://github.com/Efrosine/mysql-compose.git
cd mysql-db
```

### 2. Create Environment File

Create a `.env` file in the project root:

```bash
# MySQL Configuration
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_ROOT_HOST=%

# phpMyAdmin Configuration
PMA_HOST=mysql_db
PMA_USER=root
PMA_PASSWORD=your_secure_password

# nginx Configuration
NGINX_PORT=10002
```

> ⚠️ **Security Note**: Change default passwords and never commit `.env` to version control!

### 3. Initialize Configuration Volumes

```bash
chmod +x update-configs.sh
./update-configs.sh
```

### 4. Start Services

```bash
docker-compose up -d
```

### 5. Verify Deployment

```bash
docker-compose ps
```

All three containers should show as `Up`:
```
NAME        STATUS                  PORTS
mysql-db    Up (healthy)           0.0.0.0:3306->3306/tcp
pma         Up                     9000/tcp
nginx-ui    Up                     0.0.0.0:10002->80/tcp
```

---

## ⚙️ Configuration

### MySQL Configuration

Edit `.env` file to configure MySQL:

```env
MYSQL_ROOT_PASSWORD=your_password    # Root password
MYSQL_ROOT_HOST=%                    # Allow connections from any host (% = wildcard)
MYSQL_PORT=3306                      # Host port to expose MySQL
```

### phpMyAdmin Configuration

**File**: `pma-config.user.inc.php`

```php
<?php
// Custom phpMyAdmin configuration
$cfg['LoginCookieValidity'] = 3600 * 24; // 24 hours
```

After editing, update the volume:

```bash
./update-configs.sh
docker-compose restart pma
```

### nginx Configuration

**File**: `nginx.conf`

Edit nginx configuration for custom settings (proxy timeouts, buffer sizes, etc.).

After editing, update the volume:

```bash
./update-configs.sh
docker-compose restart nginx
```

---

## 📖 Usage

### Starting Services

```bash
# Start all services in detached mode
docker-compose up -d

# Start with logs visible
docker-compose up
```

### Stopping Services

```bash
# Stop containers (keeps volumes)
docker-compose stop

# Stop and remove containers (keeps volumes)
docker-compose down

# Stop, remove containers and volumes (⚠️ deletes data!)
docker-compose down -v
```

### Accessing Services

#### phpMyAdmin Web Interface
- **URL**: `http://localhost:${NGINX_PORT}` (default: `http://localhost:10002`)
- **Username**: `root`
- **Password**: Value from `MYSQL_ROOT_PASSWORD` in `.env`

#### MySQL Direct Connection

```bash
# From host machine
mysql -h 127.0.0.1 -P 3306 -u root -p

# From another Docker container
mysql -h mysql_db -P 3306 -u root -p
```

#### Using MySQL Client in Container

```bash
docker exec -it mysql-db mysql -u root -p
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f mysql_db
docker-compose logs -f phpmyadmin
docker-compose logs -f nginx

# Last 100 lines
docker-compose logs --tail=100
```

### Restarting Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart mysql_db
docker-compose restart phpmyadmin
docker-compose restart nginx
```

### Updating Configuration Files

When you modify `pma-config.user.inc.php` or `nginx.conf`:

```bash
# Update volumes with new configs
./update-configs.sh

# Restart affected services
docker-compose restart pma nginx
```

---

## 💾 Volume Management

### List Volumes

```bash
docker volume ls | grep mysql-db
```

You should see:
- `mysql-db_mysql-data` - MySQL database files
- `mysql-db_pma_files` - phpMyAdmin files
- `mysql-db_pma_config` - phpMyAdmin configuration
- `mysql-db_nginx_config` - nginx configuration

### Backup Database

```bash
# Export all databases
docker exec mysql-db mysqldump -u root -p --all-databases > backup.sql

# Export specific database
docker exec mysql-db mysqldump -u root -p database_name > database_backup.sql

# Backup entire MySQL data volume
docker run --rm -v mysql-db_mysql-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/mysql-data-backup.tar.gz -C /data .
```

### Restore Database

```bash
# Restore from SQL dump
docker exec -i mysql-db mysql -u root -p < backup.sql

# Restore MySQL data volume
docker run --rm -v mysql-db_mysql-data:/data -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/mysql-data-backup.tar.gz"
```

### Backup Configuration Volumes

```bash
# Backup nginx config
docker run --rm -v mysql-db_nginx_config:/data -v $(pwd):/backup \
  alpine tar czf /backup/nginx-config-backup.tar.gz -C /data .

# Backup phpMyAdmin config
docker run --rm -v mysql-db_pma_config:/data -v $(pwd):/backup \
  alpine tar czf /backup/pma-config-backup.tar.gz -C /data .
```

### Clean Up Unused Volumes

```bash
# Remove unused volumes (⚠️ be careful!)
docker volume prune

# Remove specific volume
docker volume rm mysql-db_volume_name
```

---

## 🔧 Troubleshooting

### Containers Don't Start After Reboot

**Symptoms**: Only MySQL starts, nginx and phpMyAdmin remain stopped.

**Cause**: Config files couldn't be mounted from Ubuntu WSL (not running).

**Solution**: Already implemented! This setup uses Docker volumes instead of bind mounts, ensuring all containers auto-restart regardless of WSL state.

**Verify**:
```bash
docker ps -a
```

If containers are stopped, check logs:
```bash
docker logs pma
docker logs nginx-ui
```

### Can't Connect to phpMyAdmin

**Check 1**: Verify nginx is running
```bash
docker ps | grep nginx-ui
```

**Check 2**: Check nginx logs
```bash
docker logs nginx-ui
```

**Check 3**: Verify port mapping
```bash
docker port nginx-ui
```

**Check 4**: Test nginx configuration
```bash
docker exec nginx-ui nginx -t
```

### MySQL Connection Refused

**Check 1**: Verify MySQL is healthy
```bash
docker ps | grep mysql-db
# Should show "Up (healthy)"
```

**Check 2**: Check MySQL logs
```bash
docker logs mysql-db
```

**Check 3**: Test connection from phpMyAdmin container
```bash
docker exec pma ping -c 3 mysql_db
```

### Permission Denied Errors

```bash
# Fix script permissions
chmod +x update-configs.sh

# Fix volume permissions (if needed)
docker-compose down
docker volume rm mysql-db_pma_config mysql-db_nginx_config
./update-configs.sh
docker-compose up -d
```

### phpMyAdmin Shows "Cannot connect to database server"

**Solution 1**: Wait for MySQL to be fully ready
```bash
docker exec mysql-db mysqladmin ping -h localhost -u root -p
```

**Solution 2**: Restart phpMyAdmin
```bash
docker-compose restart phpmyadmin
```

**Solution 3**: Check environment variables
```bash
docker exec pma env | grep PMA
```

### Port Already in Use

```bash
# Check what's using the port
sudo lsof -i :3306
sudo lsof -i :10002

# Change ports in .env file
MYSQL_PORT=3307
NGINX_PORT=10003

# Restart services
docker-compose down
docker-compose up -d
```

---

## 🔄 Auto-Restart Feature

This setup is specifically designed to work with Docker Desktop on Windows/WSL2 with automatic restart capability.

### How It Works

1. **Named Volumes**: Config files are stored in Docker-managed volumes (not bind mounts)
2. **Docker Desktop Storage**: Volumes reside in Docker Desktop's WSL distro
3. **No WSL Dependency**: Containers can start even if Ubuntu WSL isn't running
4. **Restart Policy**: All containers have `restart: unless-stopped`

### Testing Auto-Restart

1. Ensure all containers are running:
   ```bash
   docker-compose ps
   ```

2. Restart your computer

3. After boot, Docker Desktop starts automatically

4. Verify all containers are running:
   ```bash
   docker ps
   ```

All three containers should be running without manual intervention! ✅

### If Auto-Restart Fails

Check Docker Desktop settings:
- Settings → General → "Start Docker Desktop when you log in" ✅
- Settings → Resources → WSL Integration enabled ✅

---

## 🏗️ Project Structure

```
mysql-db/
├── docker-compose.yml          # Main orchestration file
├── .env                        # Environment variables (create this)
├── nginx.conf                  # nginx reverse proxy config
├── pma-config.user.inc.php     # phpMyAdmin custom config
├── update-configs.sh           # Helper script to update configs
└── README.md                   # This file
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- [MySQL](https://www.mysql.com/) - The world's most popular open source database
- [phpMyAdmin](https://www.phpmyadmin.net/) - Database management made easy
- [nginx](https://nginx.org/) - High-performance web server
- [Docker](https://www.docker.com/) - Containerization platform

---

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review [Docker logs](#viewing-logs)
3. Open an issue on GitHub

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

Made with ❤️ for the Docker community

</div>
