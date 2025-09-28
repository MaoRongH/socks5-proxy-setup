# SOCKS5 Proxy Setup Scripts

🚀 一键搭建SOCKS5代理服务器

## 快速开始

### Dante版本（推荐 - Ubuntu/Debian）

```bash
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/setup_dante_socks5.sh
chmod +x setup_dante_socks5.sh
sudo ./setup_dante_socks5.sh install
```

### 3proxy版本（通用 - 所有Linux）

```bash
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/setup_socks5_proxy.sh
chmod +x setup_socks5_proxy.sh
sudo ./setup_socks5_proxy.sh install
```

## 自定义配置

```bash
# 指定端口和用户
sudo SOCKS_PORT=8080 SOCKS_USER=myuser SOCKS_PASS=mypass ./setup_dante_socks5.sh install
```

## 端口配置详解

### 默认端口设置
- **SOCKS5端口**: 1080 (标准端口)
- **需要开放的服务器端口**: TCP 1080 + SSH 22

### 修改端口的三种方法

#### 1. 安装时指定（推荐）
```bash
# 使用自定义端口8080
sudo SOCKS_PORT=8080 ./setup_dante_socks5.sh install

# 完整自定义配置
sudo SOCKS_PORT=8080 SOCKS_USER=myuser SOCKS_PASS=mypass ./setup_dante_socks5.sh install
```

#### 2. 修改已安装服务的端口
```bash
# 1. 编辑配置文件
sudo nano /etc/danted.conf
# 修改: internal: eth0 port = 新端口号

# 2. 更新防火墙
sudo ufw allow 新端口号/tcp
sudo ufw delete allow 1080/tcp

# 3. 重启服务
sudo systemctl restart danted
```

#### 3. 脚本中的关键位置
- **第55行**: `SOCKS_PORT=${SOCKS_PORT:-1080}` - 默认端口
- **第75行**: 配置文件端口设置
- **第118行**: 防火墙端口开放

## 管理命令

```bash
./setup_dante_socks5.sh status    # 查看状态
./setup_dante_socks5.sh restart   # 重启服务
./setup_dante_socks5.sh log       # 查看日志
./setup_dante_socks5.sh uninstall # 卸载
```

## 测试代理

```bash
# 安装测试工具
pip3 install requests PySocks

# 下载测试脚本
wget https://raw.githubusercontent.com/MaoRongH/socks5-proxy-setup/main/test_socks5_client.py

# 测试连接
python3 test_socks5_client.py YOUR_SERVER_IP 1080 -u proxy -p your_password
```

## 客户端配置

### 浏览器代理设置

- **类型**: SOCKS5
- **地址**: YOUR_SERVER_IP
- **端口**: 1080
- **用户名**: proxy
- **密码**: 安装时显示的密码

### Python代码示例

```python
import requests
import socks
import socket

# 配置SOCKS5代理
socks.set_default_proxy(socks.SOCKS5, "YOUR_SERVER_IP", 1080,
                       username="proxy", password="your_password")
socket.socket = socks.socksocket

# 发送请求
response = requests.get("http://httpbin.org/ip")
print(response.json())
```

## 脚本对比

| 特性 | Dante | 3proxy |
|------|-------|---------|
| **系统支持** | Ubuntu/Debian | 所有Linux |
| **安装方式** | 官方包 | 源码编译 |
| **稳定性** | 极高 | 高 |
| **推荐度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**建议**: 优先使用Dante版本

## License

MIT License