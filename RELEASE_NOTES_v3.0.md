# Open Design v3.0 - Release Notes

**发布日期**: 2026-05-07  
**版本代号**: Agent-Friendly Release

---

## 🎯 核心更新

### 1. Agent 自动化安装支持
- **新增** `AGENT_INSTALLATION.md` - 专为 AI Agent 设计的自动化安装指南
- **优化** `install-open-design.command` v3.0
  - 自动检测最新版本（GitHub API）
  - 简化默认路径：`~/Documents/open_design`
  - 管理脚本自动生成在安装目录内（使用 `dirname "$0"` 识别路径）
- **适用场景**: WorkBuddy、Claude、Cursor 等 AI Agent 自动化部署

### 2. 安装流程简化
- 默认安装路径从 `~/Documents/Claw_AI/open_design` 简化为 `~/Documents/open_design`
- 卸载和升级脚本与安装目录绑定，无需硬编码路径
- 支持静默安装模式（`export NONINTERACTIVE=1`）

### 3. 文档优化
- 更新 `INSTALLATION_GUIDE.md`（v3.0）
  - 新增脚本位置说明
  - 添加版本检测功能介绍
  - 简化安装步骤
- 主 `README.md` 添加 Agent 安装指南链接
- 支持 11 种语言版本

---

## 📦 安装方式

### 用户安装（图形界面）
```bash
# 下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/nexu-io/open-design/main/install-open-design.command -o install-open-design.command
chmod +x install-open-design.command
./install-open-design.command
```

### Agent 自动化安装
```bash
# 一键安装（适合 CI/CD）
curl -fsSL https://raw.githubusercontent.com/nexu-io/open-design/main/install-open-design.command | bash

# 查看 Agent 安装指南
cat AGENT_INSTALLATION.md
```

---

## 🔧 技术细节

### 安装脚本改进
| 功能 | v2.1 | v3.0 |
|------|-------|-------|
| 版本检测 | ❌ 固定版本 | ✅ GitHub API 自动检测 |
| 默认路径 | `~/Documents/Claw_AI/open_design` | `~/Documents/open_design` |
| 路径管理 | 硬编码 | `dirname "$0"` 动态识别 |
| 管理脚本位置 | 项目根目录 | 安装目录内自动生成 |
| 静默模式 | ❌ | ✅ `NONINTERACTIVE=1` |

### 文件结构
```
open_design/
├── install-open-design.command    # 安装脚本 (v3.0)
├── uninstall-open-design.command  # 卸载脚本 (自动生成)
├── update-open-design.command     # 升级脚本 (自动生成)
├── start-open-design.sh          # 启动脚本
├── AGENT_INSTALLATION.md         # Agent 安装指南 (新增)
├── INSTALLATION_GUIDE.md        # 用户安装指南 (更新)
└── README.md                    # 项目主页 (更新)
```

---

## 🐛 问题修复

- 修复安装脚本路径识别问题
- 修复管理脚本与安装目录解耦问题
- 优化错误处理和日志输出
- 改进版本检测逻辑

---

## 📚 文档更新

### 新增文档
- `AGENT_INSTALLATION.md` - AI Agent 自动化安装指南
  - 快速安装命令
  - 手动安装步骤
  - CI/CD 集成示例
  - WorkBuddy/Claude Agent 集成代码
  - 故障排查指南

### 更新文档
- `INSTALLATION_GUIDE.md` (v3.0)
  - 简化安装步骤
  - 新增脚本位置说明
  - 添加版本检测功能介绍
- `README.md`
  - 添加 Agent 安装指南链接
  - 更新安装脚本版本号

---

## 🚀 升级指南

### 从 v2.1 升级
```bash
cd /path/to/open_design
./update-open-design.command
```

### 全新安装
```bash
cd ~/Documents
git clone https://github.com/nexu-io/open-design.git open_design
cd open_design
./install-open-design.command
```

---

## 🔗 相关链接

- **项目主页**: https://open-design.ai/
- **GitHub 仓库**: https://github.com/nexu-io/open-design
- **安装指南**: https://github.com/nexu-io/open-design#installation
- **Agent 指南**: https://github.com/nexu-io/open-design/blob/main/AGENT_INSTALLATION.md
- **问题反馈**: https://github.com/nexu-io/open-design/issues

---

## 🙏 致谢

感谢所有为 Open Design 贡献代码、文档和反馈的开发者们！

---

## 📄 完整更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 获取完整更新历史。

---

**下载链接**:
- [install-open-design.command (v3.0)](https://github.com/nexu-io/open-design/raw/main/install-open-design.command)
- [AGENT_INSTALLATION.md](https://github.com/nexu-io/open-design/blob/main/AGENT_INSTALLATION.md)
- [INSTALLATION_GUIDE.md](https://github.com/nexu-io/open-design/blob/main/INSTALLATION_GUIDE.md)
