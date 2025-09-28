#!/bin/bash
# SOCKS5代理服务器一键搭建脚本
# 支持Ubuntu/Debian/CentOS系统

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        echo "请使用: sudo $0"
        exit 1
    fi
}

# 检测系统类型
detect_os() {
    if [[ -f /etc/redhat-release ]]; then
        OS="centos"
        PM="yum"
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
        PM="apt"
    else
        log_error "不支持的操作系统"
        exit 1
    fi
    log_info "检测到系统: $OS"
}

# 更新系统包
update_system() {
    log_step "更新系统包管理器..."
    if [[ $OS == "centos" ]]; then
        yum update -y
        yum install -y epel-release
    else
        apt update && apt upgrade -y
    fi
}

# 安装必要的软件包
install_packages() {
    log_step "安装必要软件包..."
    if [[ $OS == "centos" ]]; then
        yum install -y wget curl gcc make autoconf automake libtool openssl-devel
    else
        apt install -y wget curl build-essential autoconf automake libtool libssl-dev
    fi
}

# 安装3proxy
install_3proxy() {
    log_step "下载并编译3proxy..."

    cd /tmp
    wget -O 3proxy.tar.gz https://github.com/z3APA3A/3proxy/archive/0.9.4.tar.gz
    tar xzf 3proxy.tar.gz
    cd 3proxy-*

    # 编译
    make -f Makefile.Linux

    # 安装
    mkdir -p /etc/3proxy /usr/local/bin
    cp bin/3proxy /usr/local/bin/
    chmod +x /usr/local/bin/3proxy

    log_info "3proxy安装完成"
}

# 生成随机密码
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 13
}

# 创建配置文件
create_config() {
    log_step "创建3proxy配置文件..."

    # 获取服务器IP
    SERVER_IP=$(curl -s ipinfo.io/ip || curl -s ifconfig.me || hostname -I | awk '{print $1}')

    # 设置默认值
    SOCKS_PORT=${SOCKS_PORT:-1080}
    SOCKS_USER=${SOCKS_USER:-"proxy_user"}
    SOCKS_PASS=${SOCKS_PASS:-$(generate_password)}

    cat > /etc/3proxy/3proxy.cfg << EOF
# 3proxy配置文件
daemon
pidfile /var/run/3proxy.pid
nserver 8.8.8.8
nserver 8.8.4.4
nscache 65536

# 日志配置
log /var/log/3proxy.log D
logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"
rotate 7

# 认证配置
auth strong

# 用户配置
users $SOCKS_USER:CL:$SOCKS_PASS

# 访问控制
allow $SOCKS_USER

# SOCKS5代理
socks -p$SOCKS_PORT
EOF

    log_info "配置文件创建完成: /etc/3proxy/3proxy.cfg"
    log_info "SOCKS5端口: $SOCKS_PORT"
    log_info "用户名: $SOCKS_USER"
    log_info "密码: $SOCKS_PASS"
    log_info "服务器IP: $SERVER_IP"
}

# 创建systemd服务
create_service() {
    log_step "创建systemd服务..."

    cat > /etc/systemd/system/3proxy.service << EOF
[Unit]
Description=3proxy Proxy Server
After=network.target

[Service]
Type=forking
PIDFile=/var/run/3proxy.pid
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
ExecReload=/bin/kill -USR1 \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable 3proxy
    log_info "systemd服务创建完成"
}

# 配置防火墙
configure_firewall() {
    log_step "配置防火墙..."

    if command -v firewall-cmd &> /dev/null; then
        # CentOS/RHEL防火墙
        firewall-cmd --permanent --add-port=$SOCKS_PORT/tcp
        firewall-cmd --reload
        log_info "firewalld规则已添加"
    elif command -v ufw &> /dev/null; then
        # Ubuntu防火墙
        ufw allow $SOCKS_PORT/tcp
        log_info "ufw规则已添加"
    elif command -v iptables &> /dev/null; then
        # 通用iptables
        iptables -I INPUT -p tcp --dport $SOCKS_PORT -j ACCEPT

        # 保存规则
        if [[ $OS == "centos" ]]; then
            service iptables save
        else
            iptables-save > /etc/iptables/rules.v4
        fi
        log_info "iptables规则已添加"
    fi
}

# 启动服务
start_service() {
    log_step "启动3proxy服务..."
    systemctl start 3proxy
    systemctl status 3proxy --no-pager
    log_info "服务启动完成"
}

# 测试连接
test_proxy() {
    log_step "测试代理连接..."

    # 等待服务启动
    sleep 2

    if netstat -tlnp | grep ":$SOCKS_PORT " > /dev/null; then
        log_info "代理服务器正在运行，端口: $SOCKS_PORT"
    else
        log_error "代理服务器启动失败"
        return 1
    fi
}

# 显示连接信息
show_info() {
    echo
    echo "================================"
    echo "  SOCKS5代理服务器搭建完成！"
    echo "================================"
    echo "服务器IP: $SERVER_IP"
    echo "端口: $SOCKS_PORT"
    echo "用户名: $SOCKS_USER"
    echo "密码: $SOCKS_PASS"
    echo "代理协议: SOCKS5"
    echo
    echo "连接格式:"
    echo "socks5://$SOCKS_USER:$SOCKS_PASS@$SERVER_IP:$SOCKS_PORT"
    echo
    echo "管理命令:"
    echo "启动服务: systemctl start 3proxy"
    echo "停止服务: systemctl stop 3proxy"
    echo "重启服务: systemctl restart 3proxy"
    echo "查看状态: systemctl status 3proxy"
    echo "查看日志: tail -f /var/log/3proxy.log"
    echo
    echo "配置文件: /etc/3proxy/3proxy.cfg"
    echo "================================"
}

# 卸载函数
uninstall_proxy() {
    log_step "卸载SOCKS5代理服务器..."

    # 停止并禁用服务
    systemctl stop 3proxy 2>/dev/null || true
    systemctl disable 3proxy 2>/dev/null || true

    # 删除文件
    rm -f /usr/local/bin/3proxy
    rm -rf /etc/3proxy
    rm -f /etc/systemd/system/3proxy.service
    rm -f /var/log/3proxy.log

    # 重新加载systemd
    systemctl daemon-reload

    log_info "卸载完成"
}

# 显示帮助
show_help() {
    echo "SOCKS5代理服务器一键搭建脚本"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  install              安装SOCKS5代理服务器"
    echo "  uninstall            卸载SOCKS5代理服务器"
    echo "  status               查看服务状态"
    echo "  restart              重启服务"
    echo "  log                  查看日志"
    echo "  info                 显示连接信息"
    echo "  -h, --help           显示此帮助信息"
    echo
    echo "环境变量:"
    echo "  SOCKS_PORT           SOCKS5端口 (默认: 1080)"
    echo "  SOCKS_USER           用户名 (默认: proxy_user)"
    echo "  SOCKS_PASS           密码 (默认: 自动生成)"
    echo
    echo "示例:"
    echo "  $0 install                    # 使用默认配置安装"
    echo "  SOCKS_PORT=1081 $0 install   # 使用自定义端口安装"
    echo "  SOCKS_USER=myuser SOCKS_PASS=mypass $0 install"
}

# 查看服务状态
check_status() {
    if systemctl is-active 3proxy &>/dev/null; then
        log_info "3proxy服务正在运行"
        systemctl status 3proxy --no-pager
    else
        log_warn "3proxy服务未运行"
    fi
}

# 主函数
main() {
    case "${1:-install}" in
        "install")
            check_root
            detect_os
            update_system
            install_packages
            install_3proxy
            create_config
            create_service
            configure_firewall
            start_service
            test_proxy
            show_info
            ;;
        "uninstall")
            check_root
            uninstall_proxy
            ;;
        "status")
            check_status
            ;;
        "restart")
            check_root
            systemctl restart 3proxy
            log_info "服务已重启"
            ;;
        "log")
            tail -f /var/log/3proxy.log
            ;;
        "info")
            if [[ -f /etc/3proxy/3proxy.cfg ]]; then
                # 从配置文件读取信息
                SOCKS_PORT=$(grep "socks -p" /etc/3proxy/3proxy.cfg | sed 's/socks -p//')
                SOCKS_USER=$(grep "users " /etc/3proxy/3proxy.cfg | cut -d: -f1 | cut -d' ' -f2)
                SERVER_IP=$(curl -s ipinfo.io/ip || curl -s ifconfig.me)
                show_info
            else
                log_error "代理服务器未安装"
            fi
            ;;
        "-h"|"--help"|"help")
            show_help
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"