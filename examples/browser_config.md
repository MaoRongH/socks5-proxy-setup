# 浏览器代理配置指南

## Chrome/Edge 配置

### 方法一：命令行启动（推荐）

```bash
# Chrome
google-chrome --proxy-server="socks5://YOUR_SERVER_IP:1080" --proxy-auth="proxy:your_password"

# Edge
microsoft-edge --proxy-server="socks5://YOUR_SERVER_IP:1080" --proxy-auth="proxy:your_password"
```

### 方法二：系统代理设置

1. 打开 Chrome/Edge
2. 设置 → 高级 → 打开代理设置
3. 手动代理配置
4. SOCKS代理: `YOUR_SERVER_IP:1080`
5. 勾选"对所有协议使用此代理服务器"

## Firefox 配置

1. 打开 Firefox
2. 设置 → 网络设置 → 设置
3. 手动代理配置:
   - SOCKS主机: `YOUR_SERVER_IP`
   - 端口: `1080`
   - 选择 "SOCKS v5"
   - 勾选 "远程DNS"

## Safari 配置

1. 系统偏好设置 → 网络
2. 选择网络连接 → 高级 → 代理
3. 勾选 "SOCKS代理"
4. 服务器: `YOUR_SERVER_IP:1080`

## 浏览器扩展

### SwitchyOmega (Chrome/Firefox)

```json
{
  "name": "SOCKS5代理",
  "protocol": "socks5",
  "server": "YOUR_SERVER_IP",
  "port": 1080,
  "username": "proxy",
  "password": "your_password"
}
```

### Proxy SwitchySharp (Chrome)

- 协议: SOCKS5
- 服务器: YOUR_SERVER_IP
- 端口: 1080
- 用户名: proxy
- 密码: your_password

## 验证代理设置

访问以下网站验证代理是否生效：

- https://whatismyipaddress.com/
- https://ipinfo.io/
- https://httpbin.org/ip

如果显示的IP地址是你的代理服务器IP，说明代理配置成功。