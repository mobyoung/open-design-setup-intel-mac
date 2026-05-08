#!/bin/bash

# Open Design 停止脚本
# 功能：停止所有 Open Design 服务，并显示系统通知

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 检查是否是安装目录
if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    print_warning "未检测到 Open Design 安装目录，尝试在当前目录查找..."

    # 尝试在常见位置查找
    COMMON_DIRS=(
        "$HOME/Documents/Claw_AI/open_design"
        "$HOME/open_design"
        "/Users/boboyoung/Documents/Claw_AI/open_design"
    )

    for dir in "${COMMON_DIRS[@]}"; do
        if [[ -f "$dir/pnpm-workspace.yaml" ]]; then
            SCRIPT_DIR="$dir"
            break
        fi
    done

    if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
        echo -e "${RED}[ERROR]${NC} 无法找到 Open Design 安装目录！"
        exit 1
    fi
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║       Open Design 停止脚本                  ║"
echo "╚════════════════════════════════════════════╝"
echo ""

print_info "安装目录：$SCRIPT_DIR"

# 检查服务状态
print_info "检查服务状态..."
cd "$SCRIPT_DIR"

STATUS_OUTPUT=$(pnpm tools-dev status 2>&1)
echo "$STATUS_OUTPUT" | head -10

# 检查是否有服务在运行
if echo "$STATUS_OUTPUT" | grep -q "running"; then
    print_info "检测到服务正在运行，正在停止..."

    # 停止服务
    pnpm tools-dev stop

    # 等待服务停止
    sleep 2

    # 显示成功通知
    osascript -e 'display notification "Open Design 服务已停止！" with title "Open Design"' 2>/dev/null || true

    echo ""
    print_success "✅ 服务已停止！"
    echo ""
else
    # 显示通知（即使服务未运行也通知一下
    osascript -e 'display notification "Open Design 服务未在运行。" with title "Open Design"' 2>/dev/null || true

    print_warning "服务未在运行"
    echo ""
fi

print_info "管理命令："
echo "   - 查看状态：cd $SCRIPT_DIR && pnpm tools-dev status"
echo "   - 重新启动：open \"$SCRIPT_DIR/Open Design.app\" 2>/dev/null || cd \"$SCRIPT_DIR\" && pnpm tools-dev start"
echo ""
