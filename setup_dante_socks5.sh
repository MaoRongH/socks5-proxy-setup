#!/bin/bash
# Dante SOCKS5代理服务器一键搭建脚本（推荐版本）
# 适用于Ubuntu/Debian系统，更简单稳定

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 检查root权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "需要root权限运行此脚本"
        echo "请使用: sudo $0"
        exit 1
    fi
}

# 检查系统
check_system() {
    if ! command -v apt &> /dev/null; then
        log_error "此脚本仅支持Ubuntu/Debian系统"
        exit 1
    fi
    log_info "系统检查通过"
}

# 安装Dante
install_dante() {
    log_step "安装Dante SOCKS服务器..."

    apt update
    apt install -y dante-server ufw curl

    log_info "Dante安装完成"
}

# 配置Dante
configure_dante() {
    log_step "配置Dante服务器..."

    # 获取网络接口和IP
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    SERVER_IP=$(curl -s ipinfo.io/ip || curl -s ifconfig.me)

    # 设置默认值
    SOCKS_PORT=${SOCKS_PORT:-1080}
    SOCKS_USER=${SOCKS_USER:-"proxy"}
    SOCKS_PASS=${SOCKS_PASS:-$(openssl rand -base64 12)}

    # 创建系统用户（如果不存在）
    if ! id "$SOCKS_USER" &>/dev/null; then
        useradd -r -s /bin/false "$SOCKS_USER"
        echo "$SOCKS_USER:$SOCKS_PASS" | chpasswd
        log_info "创建用户: $SOCKS_USER"
    fi

    # 备份原配置
    [ -f /etc/danted.conf ] && cp /etc/danted.conf /etc/danted.conf.bak

    # 创建配置文件
    cat > /etc/danted.conf << EOF
# Dante SOCKS5 服务器配置

# 服务器设置
logoutput: /var/log/danted.log
internal: $INTERFACE port = $SOCKS_PORT
external: $INTERFACE

# 认证方法
socksmethod: username
clientmethod: none

# 用户认证
user.privileged: root
user.unprivileged: nobody

# 客户端规则
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

# SOCKS规则
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
    socksmethod: username
}
EOF

    log_info "配置文件创建完成"
    log_info "端口: $SOCKS_PORT"
    log_info "用户名: $SOCKS_USER"
    log_info "密码: $SOCKS_PASS"
    log_info "服务器IP: $SERVER_IP"
}

# 配置防火墙
setup_firewall() {
    log_step "配置防火墙..."

    # 启用UFW防火墙
    ufw --force enable

    # 允许SSH（防止锁定）
    ufw allow ssh

    # 允许SOCKS5端口
    ufw allow $SOCKS_PORT/tcp

    # 重新加载防火墙
    ufw reload

    log_info "防火墙配置完成"
}

# 启动服务
start_service() {
    log_step "启动Dante服务..."

    # 重启并启用服务
    systemctl restart danted
    systemctl enable danted

    # 检查服务状态
    if systemctl is-active danted &>/dev/null; then
        log_info "Dante服务启动成功"
    else
        log_error "Dante服务启动失败"
        systemctl status danted --no-pager
        exit 1
    fi
}

# 测试连接
test_connection() {
    log_step "测试代理连接..."

    sleep 2

    if netstat -tlnp | grep ":$SOCKS_PORT " > /dev/null; then
        log_info "SOCKS5代理正在运行，端口: $SOCKS_PORT"
    else
        log_error "代理服务启动失败"
        exit 1
    fi
}

# 显示连接信息
show_connection_info() {
    clear
    echo "=========================================="
    echo "  🎉 SOCKS5代理服务器搭建成功！"
    echo "=========================================="
    echo
    echo "📡 连接信息:"
    echo "   服务器: $SERVER_IP"
    echo "   端口: $SOCKS_PORT"
    echo "   用户名: $SOCKS_USER"
    echo "   密码: $SOCKS_PASS"
    echo "   协议: SOCKS5"
    echo
    echo "🔗 连接字符串:"
    echo "   socks5://$SOCKS_USER:$SOCKS_PASS@$SERVER_IP:$SOCKS_PORT"
    echo
    echo "🛠️  管理命令:"
    echo "   启动: systemctl start danted"
    echo "   停止: systemctl stop danted"
    echo "   重启: systemctl restart danted"
    echo "   状态: systemctl status danted"
    echo "   日志: tail -f /var/log/danted.log"
    echo
    echo "📁 配置文件: /etc/danted.conf"
    echo "=========================================="
}

# 卸载服务
uninstall() {
    log_step "卸载SOCKS5代理服务器..."

    # 停止服务
    systemctl stop danted 2>/dev/null || true
    systemctl disable danted 2>/dev/null || true

    # 删除软件包
    apt remove -y dante-server

    # 删除配置和日志
    rm -f /etc/danted.conf /etc/danted.conf.bak
    rm -f /var/log/danted.log

    # 删除用户（可选）
    if [[ -n "$SOCKS_USER" ]] && id "$SOCKS_USER" &>/dev/null; then
        userdel "$SOCKS_USER" 2>/dev/null || true
    fi

    log_info "卸载完成"
}

# 查看状态
status() {
    if systemctl is-active danted &>/dev/null; then
        log_info "Dante服务正在运行"
        echo
        systemctl status danted --no-pager
        echo
        log_info "监听端口:"
        netstat -tlnp | grep danted
    else
        log_warn "Dante服务未运行"
    fi
}

# 显示帮助
show_help() {
    cat << EOF
Dante SOCKS5代理服务器一键搭建脚本

用法: $0 [命令]

命令:
  install     安装并配置SOCKS5代理服务器
  uninstall   卸载代理服务器
  status      查看服务状态
  restart     重启服务
  log         查看实时日志
  info        显示连接信息
  help        显示此帮助

环境变量:
  SOCKS_PORT  代理端口 (默认: 1080)
  SOCKS_USER  用户名 (默认: proxy)
  SOCKS_PASS  密码 (默认: 自动生成)

示例:
  $0 install                          # 默认安装
  SOCKS_PORT=8080 $0 install          # 指定端口
  SOCKS_USER=myuser SOCKS_PASS=mypass $0 install  # 指定用户名密码

EOF
}

# 主函数
main() {
    case "${1:-install}" in
        "install")
            check_root
            check_system
            install_dante
            configure_dante
            setup_firewall
            start_service
            test_connection
            show_connection_info
            ;;
        "uninstall")
            check_root
            uninstall
            ;;
        "status")
            status
            ;;
        "restart")
            check_root
            systemctl restart danted
            log_info "服务已重启"
            ;;
        "log")
            tail -f /var/log/danted.log
            ;;
        "info")
            if [[ -f /etc/danted.conf ]]; then
                SOCKS_PORT=$(grep "port = " /etc/danted.conf | awk '{print $NF}')
                SERVER_IP=$(curl -s ipinfo.io/ip || curl -s ifconfig.me)
                echo "服务器: $SERVER_IP:$SOCKS_PORT"
                echo "配置文件: /etc/danted.conf"
            else
                log_error "代理服务器未安装"
            fi
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"