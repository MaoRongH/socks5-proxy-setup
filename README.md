# SOCKS5 Proxy Server Setup Scripts

🚀 一键搭建SOCKS5代理服务器的Shell脚本集合

[English](#english) | [中文](#中文)

## 中文

### 📋 功能特点

- ✅ **一键安装**: 自动检测系统，安装所需组件
- ✅ **多系统支持**: Ubuntu/Debian/CentOS
- ✅ **用户认证**: 安全的用户名密码认证
- ✅ **防火墙配置**: 自动配置防火墙规则
- ✅ **服务管理**: 集成systemd服务管理
- ✅ **安全日志**: 完整的连接日志记录
- ✅ **易于管理**: 提供管理命令和状态查看
- ✅ **客户端测试**: 包含Python测试工具

### 🛠️ 支持的代理服务器

1. **Dante SOCKS5** (推荐) - 适用于Ubuntu/Debian
2. **3proxy** - 适用于所有Linux发行版

### 🚀 快速开始

#### 方法一：Dante版本（推荐）

```bash
# 下载脚本
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/setup_dante_socks5.sh
chmod +x setup_dante_socks5.sh

# 一键安装
sudo ./setup_dante_socks5.sh install
```

#### 方法二：3proxy版本（通用）

```bash
# 下载脚本
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/setup_socks5_proxy.sh
chmod +x setup_socks5_proxy.sh

# 一键安装
sudo ./setup_socks5_proxy.sh install
```

#### 自定义配置

```bash
# 指定端口和用户
sudo SOCKS_PORT=8080 SOCKS_USER=myuser SOCKS_PASS=mypass ./setup_dante_socks5.sh install
```

### 📊 测试代理

```bash
# 安装测试依赖
pip3 install requests PySocks

# 下载测试脚本
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/test_socks5_client.py

# 测试代理连接
python3 test_socks5_client.py YOUR_SERVER_IP 1080 -u proxy -p your_password
```

### 🔧 管理命令

```bash
# 查看服务状态
./setup_dante_socks5.sh status

# 重启服务
./setup_dante_socks5.sh restart

# 查看实时日志
./setup_dante_socks5.sh log

# 显示连接信息
./setup_dante_socks5.sh info

# 卸载服务
./setup_dante_socks5.sh uninstall
```

### 📁 文件说明

- `setup_dante_socks5.sh` - Dante SOCKS5服务器搭建脚本（推荐）
- `setup_socks5_proxy.sh` - 3proxy服务器搭建脚本（通用）
- `test_socks5_client.py` - 客户端测试工具
- `SOCKS5_PROXY_SETUP.md` - 详细使用文档

### 🛡️ 安全建议

1. 使用强密码
2. 限制访问IP
3. 定期查看日志
4. 及时更新系统

---

## English

### 📋 Features

- ✅ **One-click Installation**: Auto-detect system and install components
- ✅ **Multi-System Support**: Ubuntu/Debian/CentOS
- ✅ **User Authentication**: Secure username/password authentication
- ✅ **Firewall Configuration**: Auto-configure firewall rules
- ✅ **Service Management**: Integrated systemd service management
- ✅ **Security Logging**: Complete connection logging
- ✅ **Easy Management**: Management commands and status monitoring
- ✅ **Client Testing**: Includes Python testing tools

### 🛠️ Supported Proxy Servers

1. **Dante SOCKS5** (Recommended) - For Ubuntu/Debian
2. **3proxy** - For all Linux distributions

### 🚀 Quick Start

#### Method 1: Dante Version (Recommended)

```bash
# Download script
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/setup_dante_socks5.sh
chmod +x setup_dante_socks5.sh

# One-click install
sudo ./setup_dante_socks5.sh install
```

#### Method 2: 3proxy Version (Universal)

```bash
# Download script
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/setup_socks5_proxy.sh
chmod +x setup_socks5_proxy.sh

# One-click install
sudo ./setup_socks5_proxy.sh install
```

#### Custom Configuration

```bash
# Specify port and user
sudo SOCKS_PORT=8080 SOCKS_USER=myuser SOCKS_PASS=mypass ./setup_dante_socks5.sh install
```

### 📊 Test Proxy

```bash
# Install test dependencies
pip3 install requests PySocks

# Download test script
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/test_socks5_client.py

# Test proxy connection
python3 test_socks5_client.py YOUR_SERVER_IP 1080 -u proxy -p your_password
```

### 🔧 Management Commands

```bash
# Check service status
./setup_dante_socks5.sh status

# Restart service
./setup_dante_socks5.sh restart

# View real-time logs
./setup_dante_socks5.sh log

# Show connection info
./setup_dante_socks5.sh info

# Uninstall service
./setup_dante_socks5.sh uninstall
```

### 📁 File Description

- `setup_dante_socks5.sh` - Dante SOCKS5 server setup script (recommended)
- `setup_socks5_proxy.sh` - 3proxy server setup script (universal)
- `test_socks5_client.py` - Client testing tool
- `SOCKS5_PROXY_SETUP.md` - Detailed documentation

### 🛡️ Security Recommendations

1. Use strong passwords
2. Restrict access IPs
3. Monitor logs regularly
4. Keep system updated

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=MaoRongH/socks5-proxy-setup&type=Date)](https://star-history.com/#MaoRongH/socks5-proxy-setup&Date)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚠️ Disclaimer

This tool is for educational and legitimate purposes only. Users are responsible for compliance with local laws and regulations.