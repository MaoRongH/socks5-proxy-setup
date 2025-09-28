#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""SOCKS5代理客户端测试工具"""

import socket
import struct
import sys
import argparse
import requests
import time

def test_socks5_auth(host, port, username, password):
    """测试SOCKS5认证"""
    try:
        # 创建socket连接
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((host, port))

        # SOCKS5握手 - 认证方法协商
        # VER(1) + NMETHODS(1) + METHODS(1-255)
        auth_request = struct.pack('BBB', 0x05, 0x01, 0x02)  # 支持用户名密码认证
        sock.send(auth_request)

        # 读取服务器响应
        response = sock.recv(2)
        if len(response) != 2:
            return False, "认证协商响应长度错误"

        ver, method = struct.unpack('BB', response)
        if ver != 0x05:
            return False, f"不支持的SOCKS版本: {ver}"

        if method == 0x00:
            return True, "无需认证"
        elif method == 0x02:
            # 用户名密码认证
            # VER(1) + ULEN(1) + UNAME(1-255) + PLEN(1) + PASSWD(1-255)
            username_bytes = username.encode('utf-8')
            password_bytes = password.encode('utf-8')

            auth_data = struct.pack('BB', 0x01, len(username_bytes))
            auth_data += username_bytes
            auth_data += struct.pack('B', len(password_bytes))
            auth_data += password_bytes

            sock.send(auth_data)

            # 读取认证结果
            auth_response = sock.recv(2)
            if len(auth_response) != 2:
                return False, "认证响应长度错误"

            ver, status = struct.unpack('BB', auth_response)
            if status == 0x00:
                sock.close()
                return True, "认证成功"
            else:
                sock.close()
                return False, f"认证失败，状态码: {status}"
        else:
            return False, f"不支持的认证方法: {method}"

    except Exception as e:
        return False, f"连接错误: {e}"
    finally:
        if 'sock' in locals():
            sock.close()

def test_http_through_socks5(proxy_host, proxy_port, username, password, test_url="http://httpbin.org/ip"):
    """通过SOCKS5代理测试HTTP请求"""
    try:
        import socks

        # 配置SOCKS5代理
        socks.set_default_proxy(socks.SOCKS5, proxy_host, proxy_port, username=username, password=password)
        socket.socket = socks.socksocket

        # 发送HTTP请求
        start_time = time.time()
        response = requests.get(test_url, timeout=10)
        response_time = time.time() - start_time

        if response.status_code == 200:
            return True, f"HTTP请求成功，响应时间: {response_time:.2f}s", response.text
        else:
            return False, f"HTTP请求失败，状态码: {response.status_code}", None

    except ImportError:
        return False, "缺少PySocks库，请安装: pip install PySocks", None
    except Exception as e:
        return False, f"HTTP请求错误: {e}", None
    finally:
        # 恢复默认socket
        socket.socket = socket._realsocket

def main():
    parser = argparse.ArgumentParser(description="SOCKS5代理测试工具")
    parser.add_argument("host", help="代理服务器地址")
    parser.add_argument("port", type=int, help="代理服务器端口")
    parser.add_argument("-u", "--username", required=True, help="用户名")
    parser.add_argument("-p", "--password", required=True, help="密码")
    parser.add_argument("--test-url", default="http://httpbin.org/ip", help="测试URL")
    parser.add_argument("--auth-only", action="store_true", help="仅测试认证，不测试HTTP")

    args = parser.parse_args()

    print("=" * 60)
    print("SOCKS5代理测试工具")
    print("=" * 60)
    print(f"代理服务器: {args.host}:{args.port}")
    print(f"用户名: {args.username}")
    print(f"密码: {'*' * len(args.password)}")
    print()

    # 测试认证
    print("🔐 测试SOCKS5认证...")
    auth_success, auth_message = test_socks5_auth(args.host, args.port, args.username, args.password)

    if auth_success:
        print(f"✅ {auth_message}")
    else:
        print(f"❌ {auth_message}")
        return 1

    if args.auth_only:
        print("\n认证测试完成！")
        return 0

    # 测试HTTP请求
    print("\n🌐 测试HTTP请求...")
    http_success, http_message, response_data = test_http_through_socks5(
        args.host, args.port, args.username, args.password, args.test_url
    )

    if http_success:
        print(f"✅ {http_message}")
        if response_data:
            print("\n📄 响应内容:")
            try:
                import json
                data = json.loads(response_data)
                print(json.dumps(data, indent=2, ensure_ascii=False))
            except:
                print(response_data[:200] + "..." if len(response_data) > 200 else response_data)
    else:
        print(f"❌ {http_message}")
        return 1

    print("\n🎉 所有测试通过！代理服务器工作正常。")
    return 0

if __name__ == "__main__":
    sys.exit(main())