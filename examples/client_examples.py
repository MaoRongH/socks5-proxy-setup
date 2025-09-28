#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""SOCKS5代理客户端使用示例"""

import socket
import requests
import socks

# 代理配置
PROXY_HOST = "YOUR_SERVER_IP"
PROXY_PORT = 1080
PROXY_USER = "proxy"
PROXY_PASS = "your_password"


def example_requests_with_socks5():
    """使用requests通过SOCKS5代理发送HTTP请求"""
    print("=== requests + PySocks 示例 ===")

    # 配置SOCKS5代理
    socks.set_default_proxy(socks.SOCKS5, PROXY_HOST, PROXY_PORT,
                           username=PROXY_USER, password=PROXY_PASS)
    socket.socket = socks.socksocket

    try:
        # 发送请求
        response = requests.get("http://httpbin.org/ip", timeout=10)
        print(f"状态码: {response.status_code}")
        print(f"响应内容: {response.json()}")

        # 测试HTTPS
        response = requests.get("https://httpbin.org/ip", timeout=10)
        print(f"HTTPS响应: {response.json()}")

    except Exception as e:
        print(f"请求失败: {e}")
    finally:
        # 恢复默认socket
        socket.socket = socket._realsocket


def example_urllib_with_socks5():
    """使用urllib通过SOCKS5代理"""
    print("\n=== urllib + PySocks 示例 ===")

    import urllib.request

    # 创建SOCKS5代理处理器
    proxy_handler = urllib.request.ProxyHandler({
        'http': f'socks5://{PROXY_USER}:{PROXY_PASS}@{PROXY_HOST}:{PROXY_PORT}',
        'https': f'socks5://{PROXY_USER}:{PROXY_PASS}@{PROXY_HOST}:{PROXY_PORT}'
    })

    opener = urllib.request.build_opener(proxy_handler)

    try:
        response = opener.open("http://httpbin.org/ip", timeout=10)
        print(f"响应: {response.read().decode()}")
    except Exception as e:
        print(f"请求失败: {e}")


def example_raw_socket_socks5():
    """使用原生socket通过SOCKS5代理"""
    print("\n=== 原生socket + PySocks 示例 ===")

    try:
        # 创建SOCKS5连接
        sock = socks.socksocket()
        sock.set_proxy(socks.SOCKS5, PROXY_HOST, PROXY_PORT,
                      username=PROXY_USER, password=PROXY_PASS)

        # 连接到目标服务器
        sock.connect(("httpbin.org", 80))

        # 发送HTTP请求
        request = "GET /ip HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\n\r\n"
        sock.send(request.encode())

        # 接收响应
        response = sock.recv(4096).decode()
        print(f"HTTP响应:\n{response}")

        sock.close()

    except Exception as e:
        print(f"连接失败: {e}")


def example_aiohttp_with_socks5():
    """使用aiohttp通过SOCKS5代理（异步）"""
    print("\n=== aiohttp + aiohttp-socks 示例 ===")

    import asyncio
    try:
        from aiohttp_socks import ProxyConnector
        import aiohttp
    except ImportError:
        print("需要安装: pip install aiohttp aiohttp-socks")
        return

    async def fetch():
        proxy_url = f"socks5://{PROXY_USER}:{PROXY_PASS}@{PROXY_HOST}:{PROXY_PORT}"
        connector = ProxyConnector.from_url(proxy_url)

        async with aiohttp.ClientSession(connector=connector) as session:
            async with session.get("http://httpbin.org/ip") as response:
                result = await response.json()
                print(f"异步响应: {result}")

    try:
        asyncio.run(fetch())
    except Exception as e:
        print(f"异步请求失败: {e}")


if __name__ == "__main__":
    print("SOCKS5代理客户端使用示例")
    print("请先修改脚本中的代理配置信息")
    print("=" * 50)

    # 检查PySocks是否安装
    try:
        import socks
    except ImportError:
        print("请先安装PySocks: pip install PySocks")
        exit(1)

    # 运行示例
    example_requests_with_socks5()
    example_urllib_with_socks5()
    example_raw_socket_socks5()
    example_aiohttp_with_socks5()

    print("\n示例运行完成！")