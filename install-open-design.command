#!/bin/bash

# ==================================================
# Open Design 一键安装脚本（Mac Intel 平台）
# ==================================================
# 使用方法：双击此文件即可自动安装
# 适用平台：Mac Intel (x64) / Apple Silicon (兼容)
# 要求：已安装 Node.js 24.x
# 功能：版本检测、网络检测、代理配置、自动安装
# 版本：3.0（简化路径 + 脚本绑定 + 版本检测）
# ==================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
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

print_step() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}>>> $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# ==================================================
# 函数：获取最新稳定版本
# ==================================================
get_latest_version() {
    print_info "正在检测 Open Design 最新稳定版本..."
    
    # 使用 GitHub API 获取最新 release
    local api_url="https://api.github.com/repos/nexu-io/open-design/releases/latest"
    local version=""
    
    # 尝试从 GitHub API 获取
    if command -v curl &> /dev/null; then
        version=$(curl -s "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')
    fi
    
    # 如果获取失败，使用默认值
    if [[ -z "$version" ]]; then
        print_warning "无法获取最新版本，使用默认版本 0.4.1"
        version="0.4.1"
    else
        print_success "检测到最新稳定版本：v$version"
    fi
    
    echo "$version"
}

# ==================================================
# 函数：检测网络连接
# ==================================================
check_network() {
    print_info "正在检测网络连接..."
    
    # 检测 GitHub 是否可访问
    if curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
        print_success "网络连接正常，GitHub 可访问"
        return 0
    else
        print_warning "无法访问 GitHub"
        return 1
    fi
}

# ==================================================
# 函数：检测系统代理
# ==================================================
detect_proxy() {
    print_info "正在检测系统代理设置..."
    
    local proxy=""
    
    # 方法1：检查环境变量
    if [[ -n "$HTTP_PROXY" ]]; then
        proxy="$HTTP_PROXY"
        print_info "检测到环境变量 HTTP_PROXY: $proxy"
    elif [[ -n "$http_proxy" ]]; then
        proxy="$http_proxy"
        print_info "检测到环境变量 http_proxy: $proxy"
    fi
    
    # 方法2：检查 macOS 系统代理设置
    if [[ -z "$proxy" ]]; then
        local sys_proxy=$(scutil --proxy 2>/dev/null | grep "HTTPProxy" | head -1 | awk '{print $3}')
        local sys_port=$(scutil --proxy 2>/dev/null | grep "HTTPPort" | head -1 | awk '{print $3}')
        
        if [[ -n "$sys_proxy" && -n "$sys_port" ]]; then
            proxy="http://$sys_proxy:$sys_port"
            print_info "检测到系统代理: $proxy"
        fi
    fi
    
    # 方法3：检查常见国内代理端口
    if [[ -z "$proxy" ]]; then
        for port in 7890 1087 8080 8000; do
            if lsof -i:$port > /dev/null 2>&1; then
                proxy="http://127.0.0.1:$port"
                print_info "检测到本地代理 (端口 $port): $proxy"
                break
            fi
        done
    fi
    
    if [[ -n "$proxy" ]]; then
        echo "$proxy"
        return 0
    else
        print_warning "未检测到代理设置"
        return 1
    fi
}

# ==================================================
# 函数：配置 Git 使用代理
# ==================================================
configure_git_proxy() {
    local proxy="$1"
    
    if [[ -n "$proxy" ]]; then
        print_info "配置 Git 使用代理: $proxy"
        git config --global http.proxy "$proxy"
        git config --global https.proxy "$proxy"
        print_success "Git 代理已配置"
    fi
}

# ==================================================
# 函数：清除 Git 代理配置
# ==================================================
clear_git_proxy() {
    print_info "清除 Git 代理配置..."
    git config --global --unset http.proxy 2>/dev/null || true
    git config --global --unset https.proxy 2>/dev/null || true
}

# ==================================================
# 开始安装
# ==================================================

clear
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║     Open Design 一键安装脚本（Mac）          ║"
echo "║    版本：3.0（简化路径 + 版本检测）         ║"
echo "║    适用：Mac Intel (x64) / Apple Silicon    ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# ==================================================
# 步骤 1：检查系统
# ==================================================
print_step "步骤 1/10：检查系统"

# 检查是否为 macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "此脚本仅适用于 macOS 系统！"
    exit 1
fi

# 检查架构
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    print_success "系统检查通过：Mac Intel (x64)"
elif [[ "$ARCH" == "arm64" ]]; then
    print_success "系统检查通过：Apple Silicon (ARM64)"
else
    print_warning "未知架构：$ARCH"
    read -p "是否继续安装？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ==================================================
# 步骤 2：检测最新版本
# ==================================================
print_step "步骤 2/10：检测最新稳定版本"

LATEST_VERSION=$(get_latest_version)
print_success "将安装 Open Design v$LATEST_VERSION"

# ==================================================
# 步骤 3：检查网络连接
# ==================================================
print_step "步骤 3/10：检查网络连接"

USE_PROXY=false
PROXY_URL=""

if check_network; then
    print_success "网络连接正常"
else
    print_warning "无法访问 GitHub"
    echo ""
    echo "可能的原因："
    echo "  1. 网络未连接"
    echo "  2. 需要配置代理（国内用户常见）"
    echo ""
    
    # 尝试自动检测代理
    DETECTED_PROXY=$(detect_proxy)
    
    if [[ -n "$DETECTED_PROXY" ]]; then
        read -p "是否使用检测到的代理 $DETECTED_PROXY？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            USE_PROXY=true
            PROXY_URL="$DETECTED_PROXY"
            configure_git_proxy "$PROXY_URL"
        fi
    else
        read -p "是否手动配置代理？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "常见代理格式："
            echo "  http://127.0.0.1:7890"
            echo "  socks5://127.0.0.1:1080"
            read -p "请输入代理地址: " PROXY_URL
            USE_PROXY=true
            configure_git_proxy "$PROXY_URL"
        else
            print_error "无法继续安装，请检查网络连接"
            exit 1
        fi
    fi
fi

# ==================================================
# 步骤 4：检查 Node.js
# ==================================================
print_step "步骤 4/10：检查 Node.js"

if ! command -v node &> /dev/null; then
    print_error "未检测到 Node.js！"
    print_info "请先安装 Node.js 24.x："
    print_info "  1. 访问 https://nodejs.org/"
    print_info "  2. 下载并安装 Node.js 24.x LTS"
    print_info "  3. 重新运行此脚本"
    exit 1
fi

NODE_VERSION=$(node --version)
print_info "检测到 Node.js 版本：$NODE_VERSION"

# 检查版本是否为 24.x
if [[ "$NODE_VERSION" != v24* ]]; then
    print_warning "Node.js 版本不是 24.x"
    print_info "当前版本：$NODE_VERSION"
    print_info "Open Design 推荐使用 Node.js ~24"
    read -p "是否继续安装（可能不兼容）？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_success "Node.js 检查通过"

# ==================================================
# 步骤 5：安装/更新 pnpm
# ==================================================
print_step "步骤 5/10：安装/更新 pnpm"

# 启用 corepack
print_info "启用 corepack..."
corepack enable 2>/dev/null || {
    print_warning "corepack 启用失败，尝试使用 npm 安装 pnpm..."
    npm install -g pnpm@10.33.2
}

# 安装 pnpm 10.33.2
print_info "安装 pnpm@10.33.2..."
corepack prepare pnpm@10.33.2 --activate 2>/dev/null || {
    print_warning "corepack 安装失败，使用 npm 全局安装..."
    npm install -g pnpm@10.33.2
}

# 验证 pnpm 版本
PNPM_VERSION=$(pnpm --version 2>/dev/null || echo "failed")
if [[ "$PNPM_VERSION" == "failed" ]]; then
    print_error "pnpm 安装失败！"
    exit 1
fi

print_success "pnpm 安装成功：版本 $PNPM_VERSION"

# ==================================================
# 步骤 6：选择安装目录（优化版）
# ==================================================
print_step "步骤 6/10：选择安装目录"

DEFAULT_DIR="$HOME/Documents/open_design"
echo ""
echo "默认安装目录："
echo "  $DEFAULT_DIR"
echo ""
echo "操作说明："
echo "  - 直接按 Enter    使用默认目录"
echo "  - 输入路径        使用指定目录"
echo "  - 输入 Ctrl+C    取消安装"
echo ""

read -p "请输入安装目录: " INSTALL_DIR

# 如果用户直接按 Enter，使用默认目录
if [[ -z "$INSTALL_DIR" ]]; then
    INSTALL_DIR="$DEFAULT_DIR"
fi

# 展开 ~ 为用户目录
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

# 创建安装目录
mkdir -p "$INSTALL_DIR"
print_info "安装目录：$INSTALL_DIR"

# ==================================================
# 步骤 7：克隆仓库
# ==================================================
print_step "步骤 7/10：克隆 Open Design 仓库"

if [[ -d "$INSTALL_DIR/.git" ]]; then
    print_warning "检测到已存在的仓库"
    echo ""
    echo "选项："
    echo "  y - 删除并重新克隆（推荐）"
    echo "  n - 跳过克隆，使用现有仓库"
    echo "  Ctrl+C - 取消安装"
    echo ""
    read -p "是否删除并重新克隆？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        # 继续到克隆步骤
    else
        print_info "跳过克隆，使用现有仓库"
        cd "$INSTALL_DIR"
        # 设置标志跳过克隆
        SKIP_CLONE=true
    fi
fi

# 克隆或跳过
if [[ "$SKIP_CLONE" != true ]]; then
    print_info "正在克隆仓库（可能需要几分钟）..."
    print_info "仓库地址：<ADDRESS_REMOVED>"
    print_info "目标版本：v$LATEST_VERSION"
    
    if [[ "$USE_PROXY" == true ]]; then
        print_info "使用代理克隆：$PROXY_URL"
    fi
    
    git clone https://github.com/nexu-io/open-design.git "$INSTALL_DIR"
    
    if [[ $? -ne 0 ]]; then
        print_error "仓库克隆失败！"
        print_info "请检查网络连接，或手动克隆："
        print_info "  cd $INSTALL_DIR"
        print_info "  git clone https://github.com/nexu-io/open-design.git ."
        
        if [[ "$USE_PROXY" == true ]]; then
            print_info "代理可能已失效，请更新代理配置"
            print_info "或者清除代理：git config --global --unset http.proxy"
        fi
        
        exit 1
    fi
    
    # 切换到指定版本
    if [[ -n "$LATEST_VERSION" ]]; then
        cd "$INSTALL_DIR"
        print_info "切换到版本 v$LATEST_VERSION..."
        git checkout "v$LATEST_VERSION" 2>/dev/null || git checkout "$LATEST_VERSION" 2>/dev/null || {
            print_warning "无法切换到指定版本，使用默认分支"
        }
    fi
    
    print_success "仓库克隆成功"
else
    print_success "使用现有仓库"
fi

# 确保当前在安装目录
cd "$INSTALL_DIR"

# ==================================================
# 步骤 7：下载 Intel Mac 专用脚本
# ==================================================
print_step "步骤 7/10：下载 Intel Mac 专用脚本"

SCRIPT_REPO="mobyoung/open-design-setup-intel-mac"
SCRIPT_BASE="https://raw.githubusercontent.com/$SCRIPT_REPO/main"

print_info "下载启动脚本..."
if curl -fsSL "$SCRIPT_BASE/start-open-design.command" -o "$INSTALL_DIR/start-open-design.command"; then
    chmod +x "$INSTALL_DIR/start-open-design.command"
    print_success "启动脚本已下载"
else
    print_error "启动脚本下载失败"
    exit 1
fi

print_info "下载停止脚本..."
if curl -fsSL "$SCRIPT_BASE/stop-open-design.command" -o "$INSTALL_DIR/stop-open-design.command"; then
    chmod +x "$INSTALL_DIR/stop-open-design.command"
    print_success "停止脚本已下载"
else
    print_error "停止脚本下载失败"
    exit 1
fi

# ==================================================
# 步骤 8：安装依赖
# ==================================================
print_step "步骤 8/10：安装依赖（可能需要 5-10 分钟）"

cd "$INSTALL_DIR"
print_info "正在安装依赖..."

if [[ "$USE_PROXY" == true ]]; then
    print_info "使用代理下载依赖：$PROXY_URL"
    HTTPS_PROXY="$PROXY_URL" HTTP_PROXY="$PROXY_URL" pnpm install
else
    pnpm install
fi

if [[ $? -ne 0 ]]; then
    print_error "依赖安装失败！"
    print_info "请检查网络连接，或尝试："
    print_info "  1. 删除 node_modules 目录"
    print_info "  2. 重新运行 pnpm install"
    
    if [[ "$USE_PROXY" == false ]]; then
        print_info "提示：如果你的网络需要代理，请重新运行此脚本并配置代理"
    fi
    
    exit 1
fi

print_success "依赖安装成功"

# ==================================================
# 步骤 9：配置固定端口
# ==================================================
print_step "步骤 9/10：配置固定端口"

DAEMON_PORT=3000
WEB_PORT=3001

print_info "配置固定端口："
print_info "  - Daemon API: http://127.0.0.1:$DAEMON_PORT"
print_info "  - Web 界面: http://127.0.0.1:$WEB_PORT"

print_success "启动脚本已下载：$INSTALL_DIR/start-open-design.command"

# ==================================================
# 步骤 10：创建管理脚本和桌面启动器
# ==================================================
print_step "步骤 10/10：创建管理脚本和桌面启动器"

# 10.1 创建卸载脚本（放在安装目录内）
print_info "创建卸载脚本..."
cat > "$INSTALL_DIR/uninstall-open-design.command" << 'EOL'
#!/bin/bash

# 加载用户环境变量（确保 pnpm 在 PATH 中）
export PATH="$HOME/.local/bin:$PATH"
for _profile in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"; do
    if [[ -f "$_profile" ]]; then
        source "$_profile" 2>/dev/null
    fi
done

# 获取脚本所在目录（即安装目录）
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}>>> $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# 开始卸载
clear
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     Open Design 卸载脚本                      ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

print_warning "此脚本将完全卸载 Open Design！"
echo ""
echo "将执行以下操作："
echo "  1. 停止正在运行的 Open Design 服务"
echo "  2. 删除安装目录（包括源码和依赖）"
echo "  3. 删除桌面启动器（Open Design.app）"
echo "  4. 清理临时文件和日志"
echo ""
read -p "是否继续？(y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "卸载已取消"
    exit 0
fi

# 步骤 1：停止服务
print_step "步骤 1/5：停止 Open Design 服务"

if [[ -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    print_info "正在停止服务..."
    cd "$SCRIPT_DIR" && pnpm tools-dev stop 2>/dev/null || true
    print_success "服务已停止"
else
    print_info "跳过服务停止（未找到项目文件）"
fi

# 步骤 2：删除安装目录
print_step "步骤 2/5：删除安装目录"

print_info "正在删除：$SCRIPT_DIR"
read -p "确认删除此目录？(y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$SCRIPT_DIR"
    print_success "安装目录已删除"
else
    print_info "保留安装目录"
fi

# 步骤 3：删除桌面启动器
print_step "步骤 3/5：删除桌面启动器"

DESTOP_APP="$HOME/Desktop/Open Design.app"
if [[ -d "$DESTOP_APP" ]]; then
    print_info "正在删除：$DESTOP_APP"
    rm -rf "$DESTOP_APP"
    print_success "桌面启动器已删除"
else
    print_info "桌面启动器不存在，跳过"
fi

# 步骤 4：清理临时文件
print_step "步骤 4/5：清理临时文件"

# 清理可能的 .od 目录
if [[ -d "$HOME/.od" ]]; then
    print_info "删除 $HOME/.od..."
    rm -rf "$HOME/.od"
fi

print_success "临时文件清理完成"

# 步骤 5：询问是否卸载 pnpm
print_step "步骤 5/5：可选操作"

echo ""
print_info "可选操作："
echo "  1. 卸载 pnpm（如果你不再需要）"
echo "  2. 保留 pnpm（推荐，其他项目可能用到）"
echo ""
read -p "是否卸载 pnpm？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "正在卸载 pnpm..."
    npm uninstall -g pnpm 2>/dev/null || true
    corepack disable pnpm 2>/dev/null || true
    print_success "pnpm 已卸载"
else
    print_info "保留 pnpm"
fi

# 卸载完成
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║          ✅ 卸载完成！                          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
print_success "Open Design 已完全卸载！"
echo ""
print_info "已删除："
echo "   ✓ 安装目录"
echo "   ✓ 桌面启动器"
echo "   ✓ 临时文件和日志"
echo ""
print_info "保留："
echo "   - Node.js（未删除）"
echo "   - pnpm（如果选择保留）"
echo ""
read -p "按 Enter 键退出..."
EOL

chmod +x "$INSTALL_DIR/uninstall-open-design.command"
print_success "卸载脚本已创建：$INSTALL_DIR/uninstall-open-design.command"

# 10.2 创建升级脚本（放在安装目录内）
print_info "创建升级脚本..."
cat > "$INSTALL_DIR/update-open-design.command" << 'EOL'
#!/bin/bash

# 加载用户环境变量（确保 pnpm 在 PATH 中）
export PATH="$HOME/.local/bin:$PATH"
for _profile in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"; do
    if [[ -f "$_profile" ]]; then
        source "$_profile" 2>/dev/null
    fi
done

# 获取脚本所在目录（即安装目录）
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}>>> $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# 开始升级
clear
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║     Open Design 升级脚本                      ║"
echo "║     功能：备份数据、拉取最新代码、更新依赖    ║"
echo "╚════════════════════════════════════════════╝"
echo ""

print_info "安装目录：$SCRIPT_DIR"

# 验证目录
if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    print_error "此目录不是 Open Design 安装目录！"
    exit 1
fi

# 步骤 1：检查服务状态
print_step "步骤 1/6：检查服务状态"

cd "$SCRIPT_DIR"

# 检查服务是否正在运行
if pnpm tools-dev status 2>/dev/null | grep -q "running"; then
    print_warning "检测到 Open Design 服务正在运行"
    print_info "升级前需要停止服务..."
    pnpm tools-dev stop
    sleep 2
    print_success "服务已停止"
    SERVICE_WAS_RUNNING=true
else
    print_info "服务未运行"
    SERVICE_WAS_RUNNING=false
fi

# 步骤 2：备份数据
print_step "步骤 2/6：备份数据"

BACKUP_DIR="$HOME/.open-design-backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

print_info "备份目录：$BACKUP_DIR"
print_info "正在备份..."

# 备份 .od 目录（数据库和项目文件）
if [[ -d "$SCRIPT_DIR/.od" ]]; then
    cp -r "$SCRIPT_DIR/.od" "$BACKUP_DIR/" 2>/dev/null || true
    print_success "已备份 .od 目录（数据库和项目）"
fi

# 备份 .tmp 目录（日志和临时文件）
if [[ -d "$SCRIPT_DIR/.tmp" ]]; then
    cp -r "$SCRIPT_DIR/.tmp" "$BACKUP_DIR/" 2>/dev/null || true
    print_success "已备份 .tmp 目录（日志）"
fi

# 备份自定义配置（如果有）
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    cp "$SCRIPT_DIR/.env" "$BACKUP_DIR/" 2>/dev/null || true
    print_success "已备份 .env 配置文件"
fi

print_success "备份完成：$BACKUP_DIR"

# 步骤 3：拉取最新代码
print_step "步骤 3/6：拉取最新代码"

print_info "正在检查远程更新..."
git fetch origin

LOCAL_VERSION=$(git rev-parse HEAD)
REMOTE_VERSION=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)

if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
    print_success "已经是最新版本！"
    read -p "是否强制重新安装依赖？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "跳过代码更新"
    else
        print_info "正在重新安装依赖..."
        pnpm install
    fi
else
    print_info "正在拉取最新代码..."
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null
    
    if [[ $? -ne 0 ]]; then
        print_warning "Git pull 失败，尝试重置本地修改..."
        git reset --hard HEAD
        git pull origin main 2>/dev/null || git pull origin master 2>/dev/null
    fi
    
    print_success "代码已更新到最新版本"
fi

# 步骤 4：更新依赖
print_step "步骤 4/6：更新依赖"

print_info "正在安装/更新依赖（可能需要 5-10 分钟）..."
pnpm install

if [[ $? -ne 0 ]]; then
    print_error "依赖更新失败！"
    print_info "尝试清理后重新安装..."
    rm -rf node_modules
    pnpm install
fi

print_success "依赖已更新"

# 构建桌面应用
cd "$SCRIPT_DIR"
print_info "检查桌面应用构建状态..."
if [[ ! -f "$SCRIPT_DIR/apps/desktop/dist/main/index.js" ]]; then
    print_info "桌面应用未构建，正在构建..."
    pnpm --filter @open-design/desktop build
    BUILD_STATUS=$?
    if [[ $BUILD_STATUS -ne 0 ]]; then
        print_error "桌面应用构建失败！（exit code: $BUILD_STATUS）"
        print_info "请确保已安装所有依赖后重新运行安装脚本"
        exit 1
    fi
    print_success "桌面应用构建成功"
else
    print_info "桌面应用已构建，跳过"
fi

# 步骤 5：更新桌面启动器
print_step "步骤 5/6：更新桌面启动器"

DESTOP_APP="$HOME/Desktop/Open Design.app"

if [[ -d "$DESTOP_APP" ]]; then
    print_info "正在更新桌面启动器..."
    
    # 删除旧的启动器
    rm -rf "$DESTOP_APP"
    
    # 重新创建应用目录结构
    mkdir -p "$DESTOP_APP/Contents/"{MacOS,Resources}
    
    # 创建 Info.plist
    cat > "$DESTOP_APP/Contents/Info.plist" << 'INFO'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.opendesign.launcher</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Open Design</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.10</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
INFO
    
    # 创建启动脚本
    cat > "$DESTOP_APP/Contents/MacOS/launcher" << 'LAUNCHER'
#!/bin/bash

# Open Design 桌面启动器
# 功能：启动 Open Design 服务，显示系统通知

# 颜色定义
RED='[0;31m'
GREEN='[0;32m'
YELLOW='[1;33m'
BLUE='[0;34m'
NC='[0m'

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

# 加载用户环境变量（确保 pnpm 在 PATH 中）
export PATH="$HOME/.local/bin:$PATH"
for _profile in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"; do
    if [[ -f "$_profile" ]]; then
        source "$_profile" 2>/dev/null
    fi
done

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 优先从配置文件读取安装目录
CONFIG_FILE="$HOME/.open_design_install_dir"
if [[ -f "$CONFIG_FILE" ]]; then
    INSTALL_DIR_FROM_CONFIG="$(cat "$CONFIG_FILE" | tr -d '\n')"
    if [[ -n "$INSTALL_DIR_FROM_CONFIG" && -f "$INSTALL_DIR_FROM_CONFIG/pnpm-workspace.yaml" ]]; then
        SCRIPT_DIR="$INSTALL_DIR_FROM_CONFIG"
    fi
fi

# 如果配置文件无效，尝试使用 .app bundle 检测
if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    APPBundle_PATH="$( echo "$SCRIPT_DIR" | grep -o '.*\.app' | head -1 )"
    if [[ -n "$APPBundle_PATH" && "$SCRIPT_DIR" == "$APPBundle_PATH/Contents/MacOS" ]]; then
        SCRIPT_DIR="$( dirname "$APPBundle_PATH" )"
    fi
fi

# 显示启动通知
osascript -e 'display notification "正在启动 Open Design..." with title "Open Design"' 2>/dev/null

# 检查是否是安装目录
if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    print_error "未检测到 Open Design 安装目录！"
    osascript -e 'display notification "未找到 Open Design 安装目录！" with title "Open Design 启动失败"' 2>/dev/null
    exit 1
fi

print_info "安装目录：$SCRIPT_DIR"
cd "$SCRIPT_DIR"

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

# 检查 desktop 构建（检查 dist/main/index.js 而非仅目录）
print_info "检查桌面应用构建状态..."
if [[ ! -f "$SCRIPT_DIR/apps/desktop/dist/main/index.js" ]]; then
    print_error "桌面应用未构建，请重新运行安装脚本完成构建！"
    osascript -e 'display notification "桌面应用未构建，请重新运行安装脚本！" with title "Open Design 启动失败"' 2>/dev/null
    exit 1
fi

# 启动服务（desktop 模式）
print_info "启动 Open Design 服务..."

# 创建日志目录
mkdir -p "$SCRIPT_DIR/.tmp"
cd "$SCRIPT_DIR"

# 启动服务并立即返回（后台运行）
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动命令: pnpm tools-dev start desktop --daemon-port $DAEMON_PORT --web-port $WEB_PORT" > "$SCRIPT_DIR/.tmp/desktop-launcher.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 工作目录: $(pwd)" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] PATH: $PATH" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
pnpm tools-dev start desktop --daemon-port $DAEMON_PORT --web-port $WEB_PORT >> "$SCRIPT_DIR/.tmp/desktop-launcher.log" 2>&1 &
LAUNCH_PID=$!
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动PID: $LAUNCH_PID" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"

print_success "启动命令已执行"
print_info "等待服务启动..."

# 等待服务就绪
MAX_WAIT=90
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))

    STATUS=$(cd "$SCRIPT_DIR" && pnpm tools-dev status 2>&1)

    # 每 10 秒记录一次状态到日志
    if [ $((WAIT_COUNT % 10)) -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 状态检查 #$WAIT_COUNT: $STATUS" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
    fi

    # 检查是否真正在运行（排除 not-running）
    if echo "$STATUS" | grep -E "namespace default" | grep -v "not-running" | grep -q "running"; then
        WEB_URL="http://127.0.0.1:$WEB_PORT"

        echo ""
        print_success "✅ Open Design 启动成功！"
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
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动超时，WAIT_COUNT=$WAIT_COUNT" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检查后台进程..." >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
ps aux | grep -i "open.design\|tools-dev\|desktop" | grep -v grep >> "$SCRIPT_DIR/.tmp/desktop-launcher.log" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检查端口 $DAEMON_PORT 和 $WEB_PORT..." >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
lsof -ti :$DAEMON_PORT 2>/dev/null && echo "daemon端口忙碌" || echo "daemon端口空闲" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
lsof -ti :$WEB_PORT 2>/dev/null && echo "web端口忙碌" || echo "web端口空闲" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
osascript -e 'display notification "启动超时，请查看日志！" with title "Open Design 启动失败"' 2>/dev/null
LAUNCHER

    
    chmod +x "$DESTOP_APP/Contents/MacOS/launcher"
    
    # 复制图标
    if [[ -f "$SCRIPT_DIR/tools/pack/resources/mac/icon.icns" ]]; then
        cp "$SCRIPT_DIR/tools/pack/resources/mac/icon.icns" "$DESTOP_APP/Contents/Resources/icon.icns"
        print_success "图标已更新"
    fi
    
    print_success "桌面启动器已更新"
else
    print_warning "未找到桌面启动器，跳过更新"
    print_info "可以重新运行 install-open-design.command 来创建启动器"
fi

# 步骤 6：重启服务
print_step "步骤 6/6：重启服务"

if [[ "$SERVICE_WAS_RUNNING" == true ]]; then
    print_info "正在重新启动服务..."
    pnpm tools-dev start web --daemon-port 3000 --web-port 3001 > /dev/null 2>&1 &
    
    print_info "等待服务启动（5 秒）..."
    sleep 5
    
    # 检查服务状态
    if pnpm tools-dev status 2>/dev/null | grep -q "running"; then
        print_success "服务已重新启动"
        print_info "Web 界面：http://127.0.0.1:3001"
    else
        print_warning "服务可能未正常启动"
        print_info "请手动启动：cd $SCRIPT_DIR && pnpm tools-dev start web --daemon-port 3000 --web-port 3001"
    fi
else
    print_info "服务未自动启动（升级前未运行）"
    print_info "如需启动，请双击桌面上的 Open Design app"
fi

# 升级完成
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║          ✅ 升级完成！                          ║"
echo "╚════════════════════════════════════════════╝"
echo ""
print_success "Open Design 已成功升级！"
echo ""
print_info "📦 升级信息："
echo "   - 安装目录：$SCRIPT_DIR"
echo "   - 备份目录：$BACKUP_DIR"
echo "   - Daemon API：http://127.0.0.1:3000"
echo "   - Web 界面：http://127.0.0.1:3001"
echo ""
print_info "🚀 启动方式："
echo "   1. 双击桌面上的 Open Design app"
echo "   2. 等待 5-10 秒"
echo "   3. 浏览器会自动打开 http://127.0.0.1:3001"
echo ""
print_info "🛠️  管理命令："
echo "   - 查看状态：cd $SCRIPT_DIR && pnpm tools-dev status"
echo "   - 停止服务：cd $SCRIPT_DIR && pnpm tools-dev stop"
echo "   - 查看日志：cd $SCRIPT_DIR && pnpm tools-dev logs"
echo ""
print_warning "注意：如果启动失败，备份数据在：$BACKUP_DIR"
echo ""
read -p "按 Enter 键退出..."
EOL

chmod +x "$INSTALL_DIR/update-open-design.command"
print_success "升级脚本已创建：$INSTALL_DIR/update-open-design.command"

# 10.3 构建桌面应用
print_info "构建桌面应用..."
cd "$INSTALL_DIR"
if [[ ! -f "$INSTALL_DIR/apps/desktop/dist/main/index.js" ]]; then
    pnpm --filter @open-design/desktop build
    BUILD_STATUS=$?
    if [[ $BUILD_STATUS -ne 0 ]]; then
        print_error "桌面应用构建失败！（exit code: $BUILD_STATUS）"
        print_info "请确保已安装所有依赖后重新运行安装脚本"
        exit 1
    fi
    print_success "桌面应用构建成功"
else
    print_info "桌面应用已构建，跳过"
fi

# 10.4 创建桌面启动器
print_info "创建桌面启动器..."
DESTOP_APP="$HOME/Desktop/Open Design.app"

# 如果已存在，先删除
if [[ -d "$DESTOP_APP" ]]; then
    print_warning "检测到已存在的启动器，正在删除..."
    rm -rf "$DESTOP_APP"
fi

# 创建应用目录结构
mkdir -p "$DESTOP_APP/Contents/"{MacOS,Resources}

# 创建 Info.plist
cat > "$DESTOP_APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.opendesign.launcher</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Open Design</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.10</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# 创建启动脚本
cat > "$DESTOP_APP/Contents/MacOS/launcher" << 'EOL'
#!/bin/bash

# Open Design 桌面启动器
# 功能：启动 Open Design 服务，显示系统通知

# 颜色定义
RED='[0;31m'
GREEN='[0;32m'
YELLOW='[1;33m'
BLUE='[0;34m'
NC='[0m'

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

# 加载用户环境变量（确保 pnpm 在 PATH 中）
export PATH="$HOME/.local/bin:$PATH"
for _profile in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"; do
    if [[ -f "$_profile" ]]; then
        source "$_profile" 2>/dev/null
    fi
done

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 优先从配置文件读取安装目录
CONFIG_FILE="$HOME/.open_design_install_dir"
if [[ -f "$CONFIG_FILE" ]]; then
    INSTALL_DIR_FROM_CONFIG="$(cat "$CONFIG_FILE" | tr -d '\n')"
    if [[ -n "$INSTALL_DIR_FROM_CONFIG" && -f "$INSTALL_DIR_FROM_CONFIG/pnpm-workspace.yaml" ]]; then
        SCRIPT_DIR="$INSTALL_DIR_FROM_CONFIG"
    fi
fi

# 如果配置文件无效，尝试使用 .app bundle 检测
if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    APPBundle_PATH="$( echo "$SCRIPT_DIR" | grep -o '.*\.app' | head -1 )"
    if [[ -n "$APPBundle_PATH" && "$SCRIPT_DIR" == "$APPBundle_PATH/Contents/MacOS" ]]; then
        SCRIPT_DIR="$( dirname "$APPBundle_PATH" )"
    fi
fi

# 显示启动通知
osascript -e 'display notification "正在启动 Open Design..." with title "Open Design"' 2>/dev/null

# 检查是否是安装目录
if [[ ! -f "$SCRIPT_DIR/pnpm-workspace.yaml" ]]; then
    print_error "未检测到 Open Design 安装目录！"
    osascript -e 'display notification "未找到 Open Design 安装目录！" with title "Open Design 启动失败"' 2>/dev/null
    exit 1
fi

print_info "安装目录：$SCRIPT_DIR"
cd "$SCRIPT_DIR"

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

# 检查 desktop 构建（检查 dist/main/index.js 而非仅目录）
print_info "检查桌面应用构建状态..."
if [[ ! -f "$SCRIPT_DIR/apps/desktop/dist/main/index.js" ]]; then
    print_error "桌面应用未构建，请重新运行安装脚本完成构建！"
    osascript -e 'display notification "桌面应用未构建，请重新运行安装脚本！" with title "Open Design 启动失败"' 2>/dev/null
    exit 1
fi

# 启动服务（desktop 模式）
print_info "启动 Open Design 服务..."

# 创建日志目录
mkdir -p "$SCRIPT_DIR/.tmp"
cd "$SCRIPT_DIR"

# 启动服务并立即返回（后台运行）
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动命令: pnpm tools-dev start desktop --daemon-port $DAEMON_PORT --web-port $WEB_PORT" > "$SCRIPT_DIR/.tmp/desktop-launcher.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 工作目录: $(pwd)" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] PATH: $PATH" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
pnpm tools-dev start desktop --daemon-port $DAEMON_PORT --web-port $WEB_PORT >> "$SCRIPT_DIR/.tmp/desktop-launcher.log" 2>&1 &
LAUNCH_PID=$!
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动PID: $LAUNCH_PID" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"

print_success "启动命令已执行"
print_info "等待服务启动..."

# 等待服务就绪
MAX_WAIT=90
WAIT_COUNT=0
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))

    STATUS=$(cd "$SCRIPT_DIR" && pnpm tools-dev status 2>&1)

    # 每 10 秒记录一次状态到日志
    if [ $((WAIT_COUNT % 10)) -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 状态检查 #$WAIT_COUNT: $STATUS" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
    fi

    # 检查是否真正在运行（排除 not-running）
    if echo "$STATUS" | grep -E "namespace default" | grep -v "not-running" | grep -q "running"; then
        WEB_URL="http://127.0.0.1:$WEB_PORT"

        echo ""
        print_success "✅ Open Design 启动成功！"
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
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动超时，WAIT_COUNT=$WAIT_COUNT" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检查后台进程..." >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
ps aux | grep -i "open.design\|tools-dev\|desktop" | grep -v grep >> "$SCRIPT_DIR/.tmp/desktop-launcher.log" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 检查端口 $DAEMON_PORT 和 $WEB_PORT..." >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
lsof -ti :$DAEMON_PORT 2>/dev/null && echo "daemon端口忙碌" || echo "daemon端口空闲" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
lsof -ti :$WEB_PORT 2>/dev/null && echo "web端口忙碌" || echo "web端口空闲" >> "$SCRIPT_DIR/.tmp/desktop-launcher.log"
osascript -e 'display notification "启动超时，请查看日志！" with title "Open Design 启动失败"' 2>/dev/null
EOL

chmod +x "$DESTOP_APP/Contents/MacOS/launcher"

# 保存安装目录配置（供launcher读取）
CONFIG_FILE="$HOME/.open_design_install_dir"
echo "$INSTALL_DIR" > "$CONFIG_FILE"
print_info "安装目录配置已保存"

# 复制图标
if [[ -f "$INSTALL_DIR/tools/pack/resources/mac/icon.icns" ]]; then
    cp "$INSTALL_DIR/tools/pack/resources/mac/icon.icns" "$DESTOP_APP/Contents/Resources/icon.icns"
    print_success "图标已复制"
    
    # 尝试设置桌面图标（可能需要手动设置）
    print_info "如果桌面图标未更新，请手动设置："
    print_info "  1. 打开 $INSTALL_DIR/tools/pack/resources/mac/icon.icns"
    print_info "  2. Cmd+A 全选，Cmd+C 复制"
    print_info "  3. 右键点击桌面 Open Design.app → 显示简介"
    print_info "  4. 点击左上角小图标，Cmd+V 粘贴"
else
    print_warning "未找到图标文件，跳过图标设置"
fi

print_success "桌面启动器已创建：$DESTOP_APP"

# ==================================================
# 清理：清除 Git 代理配置（如果使用了代理）
# ==================================================
if [[ "$USE_PROXY" == true ]]; then
    print_info "清理：清除 Git 代理配置..."
    clear_git_proxy
    print_info "Git 代理已清除（避免影响后续使用）"
fi

# ==================================================
# 安装完成
# ==================================================
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║          ✅ 安装完成！                          ║"
echo "╚════════════════════════════════════════════╝"
echo ""
print_success "Open Design v$LATEST_VERSION 已成功安装！"
echo ""
print_info "📦 安装信息："
echo "   - 安装目录：$INSTALL_DIR"
echo "   - Daemon API：http://127.0.0.1:$DAEMON_PORT"
echo "   - Web 界面：http://127.0.0.1:$WEB_PORT"
echo ""
print_info "🚀 启动方式："
echo "   1. 双击桌面上的 Open Design app"
echo "   2. 等待 5-10 秒"
echo "   3. 浏览器会自动打开 http://127.0.0.1:$WEB_PORT"
echo ""
print_info "🛠️  管理命令："
echo "   - 查看状态：cd $INSTALL_DIR && pnpm tools-dev status"
echo "   - 停止服务：cd $INSTALL_DIR && pnpm tools-dev stop"
echo "   - 查看日志：cd $INSTALL_DIR && pnpm tools-dev logs"
echo ""
print_info "🗑️  卸载和升级："
echo "   - 卸载脚本：$INSTALL_DIR/uninstall-open-design.command"
echo "   - 升级脚本：$INSTALL_DIR/update-open-design.command"
echo ""
print_info "📖 完整文档："
echo "   $INSTALL_DIR/INSTALLATION_GUIDE.md"
echo ""
print_warning "注意：首次启动可能需要下载额外依赖，请耐心等待..."
echo ""
read -p "按 Enter 键退出..."
