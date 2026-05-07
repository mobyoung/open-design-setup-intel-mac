# Open Design Setup

Open Design 项目的安装脚本和 Agent 自动化部署指南。

## 📦 包含内容

| 文件 | 说明 |
|------|------|
| `install-open-design.command` | Open Design v3.0 安装脚本（支持自动版本检测） |
| `start-open-design.sh` | 快速启动脚本 |
| `AGENT_INSTALLATION.md` | AI Agent 自动化安装指南 |
| `INSTALLATION_GUIDE.md` | 用户安装指南（v3.0） |
| `RELEASE_NOTES_v3.0.md` | v3.0 版本发布说明 |

## 🚀 快速开始

### 一键安装 Open Design

```bash
# 下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/mobyoung/open-design-setup/main/install-open-design.command -o install-open-design.command
chmod +x install-open-design.command
./install-open-design.command
```

### Agent 自动化安装

查看 [AGENT_INSTALLATION.md](AGENT_INSTALLATION.md) 了解如何在 CI/CD 或 AI Agent 中自动化安装。

## 🎯 主要特性

### v3.0 版本更新

- ✅ **自动版本检测** - 通过 GitHub API 自动获取最新稳定版
- ✅ **简化默认路径** - `~/Documents/open_design`（从 `~/Documents/Claw_AI/open_design` 简化）
- ✅ **脚本路径绑定** - 卸载/升级脚本自动生成在安装目录内，使用 `dirname "$0"` 识别路径
- ✅ **Agent 友好** - 新增 Agent 安装指南，支持静默安装模式

## 📖 文档

- **用户指南**: [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)
- **Agent 指南**: [AGENT_INSTALLATION.md](AGENT_INSTALLATION.md)
- **版本说明**: [RELEASE_NOTES_v3.0.md](RELEASE_NOTES_v3.0.md)

## 🔗 相关链接

- **Open Design 主仓库**: https://github.com/nexu-io/open-design
- **Open Design 官网**: https://open-design.ai/
- **问题反馈**: https://github.com/nexu-io/open-design/issues

## 📄 许可证

这些脚本和文档遵循 Open Design 主仓库的 Apache-2.0 许可证。

---

**维护者**: [@mobyoung](https://github.com/mobyoung)  
**更新时间**: 2026-05-07
