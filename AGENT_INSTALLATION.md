# Open Design - Agent 安装指南

本文档为 AI Agent 提供自动化安装 Open Design 项目的指南。

## 快速安装（一键脚本）

```bash
# 默认安装到 ~/Documents/open_design
curl -fsSL https://raw.githubusercontent.com/your-repo/open-design/main/install-open-design.command | bash
```

## 手动安装步骤

### 1. 克隆仓库

```bash
cd ~/Documents
git clone https://github.com/your-repo/open-design.git open_design
cd open_design
```

### 2. 运行安装脚本

```bash
chmod +x install-open-design.command
./install-open-design.command
```

安装脚本会自动：
- 检测最新版本（通过 GitHub API）
- 安装依赖（pnpm install）
- 创建必要目录（.od/data, .od/backups, .od/logs）
- 生成管理脚本（uninstall-open-design.command, update-open-design.command）

### 3. 启动项目

```bash
./start-open-design.sh
```

## 自定义安装路径

```bash
# 克隆到自定义路径
git clone https://github.com/your-repo/open-design.git /your/custom/path
cd /your/custom/path
./install-open-design.command
```

安装后，管理脚本会自动在安装目录中生成，并使用 `dirname "$0"` 识别路径。

## 自动化安装（CI/CD）

```yaml
# .github/workflows/install.yml
name: Install Open Design
on: [push, pull_request]

jobs:
  install:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Open Design
        run: |
          chmod +x install-open-design.command
          ./install-open-design.command
```

## 依赖要求

- macOS 10.15+
- Git 2.0+
- Node.js 18+ (推荐 24.x)
- pnpm 8+

## 静默安装模式

```bash
# 跳过所有交互式提示
export NONINTERACTIVE=1
./install-open-design.command
```

## 卸载

```bash
cd /path/to/open_design
./uninstall-open-design.command
```

## 更新

```bash
cd /path/to/open_design
./update-open-design.command
```

## 故障排查

### 权限问题

```bash
chmod +x install-open-design.command
xattr -d com.apple.quarantine install-open-design.command
```

### 依赖缺失

```bash
# 安装 pnpm
npm install -g pnpm

# 安装项目依赖
pnpm install
```

### 端口占用

```bash
# 检查端口占用
lsof -i :3000
lsof -i :5173

# 杀死进程
kill -9 <PID>
```

## Agent 集成示例

### WorkBuddy Agent

```markdown
Task: 安装 Open Design 项目

Steps:
1. Check if ~/Documents/open_design exists
2. If not, clone repository
3. Run install-open-design.command
4. Verify installation (check .od directory)
5. Report status
```

### Claude Agent

```python
# 使用 Bash 工具执行安装
bash_command = """
  cd ~/Documents &&
  git clone https://github.com/your-repo/open-design.git open_design &&
  cd open_design &&
  chmod +x install-open-design.command &&
  ./install-open-design.command
"""
```

## 安装验证

```bash
# 检查目录结构
ls -la .od/

# 检查依赖
pnpm list

# 检查脚本
ls -la *.command *.sh

# 启动测试
./start-open-design.sh &
curl http://localhost:3000/health
```

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `OPEN_DESIGN_PATH` | 安装路径 | `~/Documents/open_design` |
| `NONINTERACTIVE` | 静默模式 | `0` |
| `OPEN_DESIGN_VERSION` | 指定版本 | `latest` |

## 版本管理

```bash
# 安装特定版本
git checkout v2.1.0
./install-open-design.command

# 更新到最新版
./update-open-design.command

# 回滚版本
git checkout <previous-version>
./install-open-design.command --force
```

## 常见问题

**Q: 安装脚本卡住怎么办？**
A: 检查网络连接，或使用国内镜像源。

**Q: 如何清理安装？**
A: 运行 `./uninstall-open-design.command`，会删除 .od 目录和生成的管理脚本。

**Q: 可以在 Linux 上运行吗？**
A: 目前仅支持 macOS，Linux 支持正在开发中。

## 相关文档

- [安装指南](INSTALLATION_GUIDE.md) - 用户友好的安装指南
- [快速开始](QUICKSTART.md) - 新手入门
- [README](README.md) - 项目概述
- [贡献指南](CONTRIBUTING.md) - 开发者文档

---

**版本**: 3.0  
**更新时间**: 2026-05-07  
**维护者**: Open Design Team
