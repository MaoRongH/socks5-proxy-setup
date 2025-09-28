# SOCKS5代理服务器搭建指南

## 🚀 一键搭建脚本

提供两个版本的搭建脚本：

### 1. Dante版本（推荐）
基于Dante服务器，适用于Ubuntu/Debian系统，更稳定易用。

```bash
# 下载并运行脚本
wget https://github.com/your-repo/setup_dante_socks5.sh
chmod +x setup_dante_socks5.sh

# 默认安装
sudo ./setup_dante_socks5.sh install

# 自定义端口和用户
sudo SOCKS_PORT=8080 SOCKS_USER=myuser SOCKS_PASS=mypass ./setup_dante_socks5.sh install
```

### 2. 3proxy版本（通用）
基于3proxy，支持CentOS/Ubuntu/Debian系统。

```bash
# 下载并运行脚本
wget https://github.com/your-repo/setup_socks5_proxy.sh
chmod +x setup_socks5_proxy.sh

# 默认安装
sudo ./setup_socks5_proxy.sh install
```

## 📋 功能特点

- ✅ **一键安装**: 自动检测系统，安装所需组件
- ✅ **用户认证**: 支持用户名密码认证
- ✅ **防火墙配置**: 自动配置防火墙规则
- ✅ **服务管理**: 集成systemd服务管理
- ✅ **安全日志**: 完整的连接日志记录
- ✅ **易于管理**: 提供管理命令和状态查看

## 🛠️ 使用方法

### 安装代理服务器

```bash
# 使用默认配置安装
sudo ./setup_dante_socks5.sh install

# 自定义配置安装
sudo SOCKS_PORT=1081 SOCKS_USER=proxy SOCKS_PASS=123456 ./setup_dante_socks5.sh install
```

### 管理命令

```bash
# 查看服务状态
sudo ./setup_dante_socks5.sh status

# 重启服务
sudo ./setup_dante_socks5.sh restart

# 查看实时日志
sudo ./setup_dante_socks5.sh log

# 显示连接信息
sudo ./setup_dante_socks5.sh info

# 卸载服务
sudo ./setup_dante_socks5.sh uninstall
```

### 系统服务管理

```bash
# 启动服务
sudo systemctl start danted

# 停止服务
sudo systemctl stop danted

# 重启服务
sudo systemctl restart danted

# 查看状态
sudo systemctl status danted

# 开机自启
sudo systemctl enable danted

# 禁用自启
sudo systemctl disable danted
```

## 🔧 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `SOCKS_PORT` | 1080 | SOCKS5监听端口 |
| `SOCKS_USER` | proxy | 认证用户名 |
| `SOCKS_PASS` | 自动生成 | 认证密码 |

### 配置文件

**Dante配置文件**: `/etc/danted.conf`
```bash
# 查看配置
sudo cat /etc/danted.conf

# 编辑配置
sudo nano /etc/danted.conf

# 重启服务使配置生效
sudo systemctl restart danted
```

## 📊 测试代理

### 使用测试脚本

```bash
# 安装测试依赖
pip3 install requests PySocks

# 测试代理连接
python3 test_socks5_client.py YOUR_SERVER_IP 1080 -u proxy -p your_password

# 仅测试认证
python3 test_socks5_client.py YOUR_SERVER_IP 1080 -u proxy -p your_password --auth-only
```

### 使用curl测试

```bash
# 通过代理访问网站
curl --socks5-hostname proxy:password@YOUR_SERVER_IP:1080 http://httpbin.org/ip

# 测试代理速度
curl -w "Time: %{time_total}s\n" --socks5-hostname proxy:password@YOUR_SERVER_IP:1080 http://httpbin.org/ip
```

## 🔐 客户端配置

### 浏览器配置

**Chrome/Edge:**
1. 设置 → 高级 → 打开代理设置
2. 手动代理配置
3. SOCKS代理: `YOUR_SERVER_IP:1080`
4. 用户名: `proxy`
5. 密码: `your_password`

**Firefox:**
1. 设置 → 网络设置
2. 手动代理配置
3. SOCKS主机: `YOUR_SERVER_IP` 端口: `1080`
4. SOCKS v5 + 远程DNS

### 编程语言配置

**Python (requests + PySocks):**
```python
import requests
import socks
import socket

# 配置SOCKS5代理
socks.set_default_proxy(socks.SOCKS5, "YOUR_SERVER_IP", 1080, username="proxy", password="your_password")
socket.socket = socks.socksocket

# 发送请求
response = requests.get("http://httpbin.org/ip")
print(response.json())
```

**Node.js (socks-proxy-agent):**
```javascript
const SocksProxyAgent = require('socks-proxy-agent');
const fetch = require('node-fetch');

const agent = new SocksProxyAgent('socks5://proxy:your_password@YOUR_SERVER_IP:1080');

fetch('http://httpbin.org/ip', { agent })
  .then(res => res.json())
  .then(data => console.log(data));
```

## 📈 性能优化

### 系统优化

```bash
# 增加文件描述符限制
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf

# 优化网络参数
echo "net.core.rmem_max = 67108864" >> /etc/sysctl.conf
echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 67108864" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 67108864" >> /etc/sysctl.conf

# 应用配置
sysctl -p
```

### Dante配置优化

```bash
# 编辑配置文件
sudo nano /etc/danted.conf

# 添加性能优化选项
timeout.negotiate: 30
timeout.io: 86400
```

## 🛡️ 安全建议

### 防火墙配置

```bash
# 仅允许特定IP访问（推荐）
sudo ufw delete allow 1080/tcp
sudo ufw allow from YOUR_CLIENT_IP to any port 1080

# 限制连接数
sudo ufw limit 1080/tcp
```

### 定期维护

```bash
# 查看连接日志
sudo tail -f /var/log/danted.log

# 清理日志（防止占用过多空间）
sudo logrotate /etc/logrotate.d/danted

# 监控服务状态
sudo systemctl status danted
```

### 用户管理

```bash
# 修改用户密码
sudo passwd proxy

# 删除用户
sudo userdel proxy

# 创建新用户
sudo useradd -r -s /bin/false newuser
sudo passwd newuser
```

## 🚨 故障排除

### 常见问题

**1. 服务启动失败**
```bash
# 查看详细错误
sudo systemctl status danted -l

# 检查配置文件语法
sudo danted -f /etc/danted.conf -V

# 查看端口占用
sudo netstat -tlnp | grep 1080
```

**2. 认证失败**
```bash
# 检查用户是否存在
id proxy

# 重置用户密码
sudo passwd proxy

# 检查配置文件用户设置
grep -i user /etc/danted.conf
```

**3. 连接被拒绝**
```bash
# 检查防火墙
sudo ufw status

# 检查服务监听
sudo netstat -tlnp | grep danted

# 测试本地连接
telnet localhost 1080
```

### 日志分析

```bash
# 查看最近的连接日志
sudo tail -100 /var/log/danted.log

# 搜索特定IP的连接
sudo grep "CLIENT_IP" /var/log/danted.log

# 统计连接数
sudo grep "connect" /var/log/danted.log | wc -l
```

## 📞 支持与反馈

如果遇到问题或需要帮助：

1. 查看详细日志: `sudo tail -f /var/log/danted.log`
2. 检查服务状态: `sudo systemctl status danted`
3. 验证配置文件: `sudo danted -f /etc/danted.conf -V`
4. 测试网络连通性: `telnet YOUR_SERVER_IP 1080`

---

## 📜 许可证

本脚本基于MIT许可证开源，仅供学习和合法用途使用。