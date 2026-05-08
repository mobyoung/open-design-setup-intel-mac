# Open Design Setup (Intel Mac)

Open Design 项目的安装脚本和 Agent 自动化部署指南（适用于 Intel Mac）。

## 📦 包含内容

| 文件 | 说明 |
|------|------|
| `install-open-design.command` | Open Design v3.0 安装脚本（支持自动版本检测，Intel Mac） |
| `start-open-design.command` | 快速启动脚本 |
| `AGENT_INSTALLATION.md` | AI Agent 自动化安装指南 |
| `INSTALLATION_GUIDE.md` | 用户安装指南（v3.0） |
| `RELEASE_NOTES_v3.0.md` | v3.0 版本发布说明 |

> **注意**: 本仓库的脚本和文档专门针对 **Intel Mac** 优化。如果你使用 Apple Silicon (M1/M2/M3)，请参考 [Open Design 主仓库](https://github.com/nexu-io/open-design)。

## 🚀 快速开始

### 一键安装 Open Design

```bash
# 下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/mobyoung/open-design-setup-intel-mac/main/install-open-design.command -o install-open-design.command
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
- **Apple Silicon 版本**: 请访问 [Open Design 主仓库](https://github.com/nexu-io/open-design)
- **问题反馈**: https://github.com/nexu-io/open-design/issues

## ⚙️ 系统要求

- **处理器**: Intel Core i5 或更高
- **操作系统**: macOS 10.15 (Catalina) 或更高版本
- **内存**: 8GB RAM 或更多
- **存储**: 至少 5GB 可用空间
- **依赖**: Git, Node.js 18+, pnpm

## 📄 许可证

这些脚本和文档遵循 Open Design 主仓库的 Apache-2.0 许可证。

---

**维护者**: [@mobyoung](https://github.com/mobyoung)  
**更新时间**: 2026-05-07
