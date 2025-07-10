# Hướng dẫn triển khai PostgreSQL trên LightNode với Kamal

## Tổng quan
Ứng dụng Rails này sử dụng **Kamal** để triển khai PostgreSQL database trên cùng LightNode instance. Kamal là deployment tool chính thức của Rails và cung cấp nhiều tính năng production-ready.

## Tại sao sử dụng Kamal thay vì Docker Compose?

### ✅ **Ưu điểm của Kamal:**
- **Rails-native** - được thiết kế đặc biệt cho Rails
- **Zero-downtime deployment** - rolling updates
- **Built-in health checks** - tự động restart nếu service fail
- **Environment management** - quản lý env vars dễ dàng
- **Database migrations** - tự động chạy migrations
- **Asset precompilation** - tự động precompile assets
- **SSL/TLS support** - tích hợp Let's Encrypt
- **Monitoring** - built-in monitoring và logging

### 🐳 **Kamal vs Docker Compose:**
| Tính năng | Kamal | Docker Compose |
|-----------|-------|----------------|
| Rails integration | ✅ Native | ❌ Manual |
| Zero-downtime | ✅ Built-in | ❌ Manual setup |
| Health checks | ✅ Automatic | ⚠️ Manual config |
| SSL/TLS | ✅ Built-in | ❌ Manual setup |
| Database migrations | ✅ Automatic | ❌ Manual |
| Production ready | ✅ Yes | ⚠️ Requires setup |

## Cấu hình hiện tại

### `deploy.yml` đã được cấu hình:
```yaml
database:
  type: postgresql
  deploy: container  # PostgreSQL sẽ chạy trong container

redis:
  enabled: true      # Redis cũng chạy trong container

env:
  DATABASE_URL: postgresql://trader:trader@localhost:5432/vnstocks_production
  REDIS_URL: redis://localhost:6379/0
  RAILS_SERVE_STATIC_FILES: true
```

## Các bước triển khai với Kamal

### Bước 1: Chuẩn bị LightNode
```bash
# Cài đặt Docker (nếu chưa có)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Logout và login lại để apply docker group
exit
# SSH lại vào server
```

### Bước 2: Cấu hình SSH key
```bash
# Trên máy local, copy SSH key lên server
ssh-copy-id deploy@38.54.30.6

# Test SSH connection
ssh deploy@38.54.30.6
```

### Bước 3: Cấu hình Container Registry
```bash
# Đăng nhập vào GitHub Container Registry
docker login ghcr.io -u huyvqhn -p Huy-github-access-token
```

### Bước 4: Deploy với Kamal
```bash
# Deploy lần đầu (sẽ tạo database và chạy migrations)
kamal deploy

# Hoặc deploy với setup database
kamal deploy --setup
```

## Quản lý hàng ngày với Kamal

### Deploy updates
```bash
# Deploy code mới
kamal deploy

# Deploy với restart
kamal deploy --restart

# Deploy với rollback nếu có lỗi
kamal deploy --rollback
```

### Database operations
```bash
# Chạy migrations
kamal app exec rails db:migrate

# Reset database (cẩn thận!)
kamal app exec rails db:reset

# Backup database
kamal app exec rails db:backup
```

### Monitoring và logs
```bash
# Xem logs
kamal app logs

# Xem logs real-time
kamal app logs --follow

# Xem status của services
kamal status

# Xem resource usage
kamal app exec top
```

### Environment variables
```bash
# Xem env vars hiện tại
kamal env

# Set env var mới
kamal env set DATABASE_POOL=10

# Unset env var
kamal env unset OLD_VAR
```

## Backup và Recovery

### Backup database
```bash
# Tạo backup
kamal app exec pg_dump -U trader vnstocks_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Hoặc sử dụng script backup đã tạo
kamal app exec ./backup-db.sh
```

### Restore database
```bash
# Restore từ backup
kamal app exec psql -U trader vnstocks_production < backup_file.sql
```

## Troubleshooting

### Kiểm tra services
```bash
# Kiểm tra tất cả containers
kamal app exec docker ps

# Kiểm tra database connection
kamal app exec rails db:version

# Kiểm tra Redis connection
kamal app exec rails runner "puts Redis.new.ping"
```

### Restart services
```bash
# Restart application
kamal restart

# Restart database
kamal app exec docker restart vn-stock-info-app-db-1

# Restart Redis
kamal app exec docker restart vn-stock-info-app-redis-1
```

### Debug issues
```bash
# Vào container để debug
kamal app exec bash

# Xem logs chi tiết
kamal app logs --tail=100

# Kiểm tra disk space
kamal app exec df -h
```

## Security Best Practices

### 1. **Update passwords**
```bash
# Thay đổi database password
kamal env set DATABASE_URL=postgresql://trader:new_password@localhost:5432/vnstocks_production
kamal deploy
```

### 2. **SSL/TLS**
```bash
# Enable SSL (nếu có domain)
# Chỉnh sửa deploy.yml
domain:
  name: your-domain.com
  ssl: true
```

### 3. **Firewall**
```bash
# Chỉ mở ports cần thiết
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

## Performance Optimization

### 1. **Database tuning**
```bash
# Tăng connection pool
kamal env set DATABASE_POOL=20

# Tăng Redis connections
kamal env set REDIS_POOL=10
```

### 2. **Resource limits**
```bash
# Set memory limits trong deploy.yml
servers:
  web:
    hosts: 38.54.30.6
    labels:
      traefik.http.routers.vn-stock-info-app.rule: Host(`your-domain.com`)
    env:
      RAILS_MAX_THREADS: 5
      WEB_CONCURRENCY: 2
```

## Monitoring và Alerts

### 1. **Health checks**
```bash
# Kamal tự động health check
kamal health

# Manual health check
curl http://38.54.30.6/health
```

### 2. **Log monitoring**
```bash
# Setup log rotation
kamal app exec logrotate -f /etc/logrotate.conf

# Monitor error logs
kamal app logs | grep ERROR
```

## Migration từ Docker Compose sang Kamal

Nếu bạn đã có data trong Docker Compose:

```bash
# 1. Backup data từ Docker Compose
docker-compose exec db pg_dump -U trader vnstocks_production > migration_backup.sql

# 2. Deploy với Kamal
kamal deploy --setup

# 3. Restore data
kamal app exec psql -U trader vnstocks_production < migration_backup.sql
```

## Kết luận

**Kamal là lựa chọn tốt hơn** cho production deployment vì:
- ✅ **Rails-native** - tích hợp tốt với Rails
- ✅ **Production-ready** - có sẵn các tính năng cần thiết
- ✅ **Zero-downtime** - không gián đoạn service
- ✅ **Easy management** - commands đơn giản và intuitive
- ✅ **Built-in monitoring** - health checks và logging

Sử dụng Kamal sẽ giúp bạn quản lý PostgreSQL database và ứng dụng Rails một cách chuyên nghiệp và hiệu quả hơn! 