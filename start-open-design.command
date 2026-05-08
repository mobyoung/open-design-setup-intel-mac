#!/bin/bash

# Open Design 桌面启动器
# 功能：启动 Open Design 服务和桌面窗口，显示系统通知

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 固定端口配置（与安装脚本一致）
DAEMON_PORT=3000
WEB_PORT=3001

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 检查是否是安装目录
if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    print_error "未检测到 Open Design 安装目录！"
    osascript -e 'display notification "未找到 Open Design 安装目录！" with title "Open Design 启动失败"' 2>/dev/null
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║       Open Design 启动器                     ║"
echo "╚════════════════════════════════════════════╝"
echo ""

print_info "安装目录：$SCRIPT_DIR"
cd "$SCRIPT_DIR"

# 显示启动通知
osascript -e 'display notification "正在启动 Open Design..." with title "Open Design"' 2>/dev/null

# 检查 Node.js 和 pnpm
print_info "检查环境..."

if ! command -v node &> /dev/null; then
    print_error "Node.js 未安装！"
    osascript -e 'display notification "Node.js 未安装，请先安装！" with title "Open Design 启动失败"' 2>/dev/null
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    print_error "pnpm 未安装！"
    osascript -e 'display notification "pnpm 未安装，请先安装！" with title "Open Design 启动失败"' 2>/dev/null
    exit 1
fi

# 检查服务状态
print_info "检查服务状态..."
STATUS_OUTPUT=$(pnpm tools-dev status 2>&1)

# 检查是否真正在运行（排除 not-running）
if echo "$STATUS_OUTPUT" | grep -E "namespace default" | grep -v "not-running" | grep -q "running"; then
    print_warning "检测到服务已在运行！"
    print_info "正在打开浏览器..."
    open "http://127.0.0.1:$WEB_PORT"
    osascript -e 'display notification "已打开浏览器界面" with title "Open Design"' 2>/dev/null
    exit 0
fi

# 检查 desktop 构建
print_info "检查桌面应用构建状态..."

if [[ ! -d "$SCRIPT_DIR/apps/desktop/dist/main" ]]; then
    print_info "桌面应用未构建，正在构建..."
    pnpm --filter @open-design/desktop build

    if [[ $? -ne 0 ]]; then
        print_error "桌面应用构建失败！"
        osascript -e 'display notification "桌面应用构建失败！" with title "Open Design 启动失败"' 2>/dev/null
        exit 1
    fi
fi

# 启动服务（desktop 模式）
print_info "启动 Open Design 服务..."

# 创建日志目录
mkdir -p "$SCRIPT_DIR/.tmp"
cd "$SCRIPT_DIR"

# 启动服务并立即返回（后台运行），使用固定端口
pnpm tools-dev start desktop --daemon-port $DAEMON_PORT --web-port $WEB_PORT > "$SCRIPT_DIR/.tmp/desktop-launcher.log" 2>&1 &

print_success "启动命令已执行"
print_info "等待服务启动..."

# 等待服务就绪
MAX_WAIT=90
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))

    STATUS=$(cd "$SCRIPT_DIR" && pnpm tools-dev status 2>&1)

    # 检查是否真正在运行（排除 not-running）
    if echo "$STATUS" | grep -E "namespace default" | grep -v "not-running" | grep -q "running"; then
        WEB_URL="http://127.0.0.1:$WEB_PORT"

        echo ""
        print_success "✅ Open Design 启动成功！"
        echo ""
        print_info "📍 访问地址："
        echo "   - Web 界面：$WEB_URL"
        echo ""

        # 打开浏览器
        print_info "打开浏览器..."
        open "$WEB_URL"

        # 显示成功通知
        osascript -e 'display notification "Open Design 已启动！Web 界面已打开。" with title "Open Design"' 2>/dev/null

        exit 0
    fi

    # 每 10 秒显示一次等待状态
    if [ $((WAIT_COUNT % 10)) -eq 0 ]; then
        print_info "等待中... ($WAIT_COUNT/$MAX_WAIT 秒)"
    fi
done

# 超时处理
print_error "启动超时！"
print_info "查看日志：$SCRIPT_DIR/.tmp/desktop-launcher.log"
osascript -e 'display notification "启动超时，请查看日志！" with title "Open Design 启动失败"' 2>/dev/null

echo ""
print_info "常见问题排查："
echo "   1. 查看日志：tail -f $SCRIPT_DIR/.tmp/desktop-launcher.log"
echo "   2. 检查端口占用：lsof -i :3000 -i :3001"
echo "   3. 强制停止：pnpm tools-dev stop"
echo ""
