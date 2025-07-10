# 🚀 Deployment Checklist - VN Stock Info App

## ✅ Pre-deployment Checklist

### 1. **RAILS_MASTER_KEY** (Bắt buộc!)
```bash
# Kiểm tra xem có master.key không
ls config/master.key

# Nếu không có, tạo mới:
rails credentials:edit
```

**Lưu ý:** Bạn cần copy giá trị từ `config/master.key` để set environment variable:
```bash
export RAILS_MASTER_KEY=your_master_key_here
```

### 2. **SSH Key Setup**
```bash
# Copy SSH key lên server
ssh-copy-id deploy@38.54.30.6

# Test connection
ssh deploy@38.54.30.6
```

### 3. **GitHub Container Registry**
```bash
# Login vào GitHub Container Registry
docker login ghcr.io -u huyvqhn -p Huy-github-access-token
```

### 4. **Kamal Installation**
```bash
# Cài đặt Kamal
gem install kamal
```

### 5. **Database Migration Status**
```bash
# Kiểm tra migrations
rails db:migrate:status
```

## 🚀 Deployment Steps

### Bước 1: Set Environment Variables
```bash
# Set RAILS_MASTER_KEY (quan trọng!)
export RAILS_MASTER_KEY=your_master_key_here
```

### Bước 2: Deploy lần đầu
```bash
# Deploy với setup database
./deploy-kamal.sh --setup
```

### Bước 3: Kiểm tra deployment
```bash
# Check status
kamal status

# Check logs
kamal app logs
```

## 🔧 Troubleshooting

### Nếu gặp lỗi "RAILS_MASTER_KEY not set":
```bash
# Tạo master key mới
rails credentials:edit

# Copy giá trị từ config/master.key
cat config/master.key

# Set environment variable
export RAILS_MASTER_KEY=your_key_here
```

### Nếu gặp lỗi SSH:
```bash
# Generate SSH key nếu chưa có
ssh-keygen -t rsa -b 4096

# Copy lên server
ssh-copy-id deploy@38.54.30.6
```

### Nếu gặp lỗi Docker Registry:
```bash
# Login lại
docker logout ghcr.io
docker login ghcr.io -u huyvqhn -p Huy-github-access-token
```

## 📋 Files cần thiết đã có:

- ✅ `deploy.yml` - Cấu hình Kamal
- ✅ `Dockerfile` - Container configuration
- ✅ `config/database.yml` - Database config
- ✅ `deploy-kamal.sh` - Deployment script
- ✅ `backup-db.sh` - Backup script

## 🎯 Ready to Deploy?

Nếu bạn đã hoàn thành checklist trên, ứng dụng đã sẵn sàng deploy!

```bash
# Bắt đầu deploy
./deploy-kamal.sh --setup
```

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. `kamal app logs` - Application logs
2. `kamal status` - Service status
3. `kamal health` - Health checks 