# Open Design Setup (Intel Mac)

> 专为 **Intel Mac** 用户打造的 Open Design 安装工具，一键安装，自动创建启动/停止/卸载脚本，桌面启动器一点就开。

**官方只支持 Apple Silicon？Intel Mac 用户也能用上 Open Design。**

---

## ✨ 核心能力

| 功能 | 说明 |
|------|------|
| **一条指令安装** | `curl` + `执行` 两步完成，无需手动配置 |
| **自动创建脚本** | 安装后自动生成启动、停止、卸载脚本，随时可用 |
| **桌面启动器** | 双击即开，服务就绪后自动跳转浏览器 |
| **一键启动/停止/卸载** | 双击脚本即可操作，零门槛 |

---

## 📦 安装后生成的文件

| 文件 | 说明 |
|------|------|
| `start-open-design.command` | 启动脚本（双击即可启动服务并打开界面） |
| `stop-open-design.command` | 停止脚本（双击停止所有服务） |
| `uninstall-open-design.command` | 卸载脚本（双击移除整个安装） |
| `Open Design` 桌面应用 | 桌面启动器，一点就开 |

---

## 🚀 快速开始

### 一条指令安装

```bash
curl -fsSL https://raw.githubusercontent.com/mobyoung/open-design-setup-intel-mac/main/install-open-design.command -o install-open-design.command
chmod +x install-open-design.command
./install-open-design.command
```

安装完成后：

- 双击 `start-open-design.command` 启动服务
- 双击 `stop-open-design.command` 停止服务
- 双击 `uninstall-open-design.command` 卸载

---

## 🎯 主要特性

- ✅ **Intel Mac 原生支持** - 解决官方只提供 Apple Silicon 版本的痛点
- ✅ **自动版本检测** - 通过 GitHub API 自动获取最新稳定版
- ✅ **脚本路径自适应** - 启动/停止/卸载脚本使用 `dirname "$0"` 识别路径，任意位置都能运行
- ✅ **桌面应用入口** - 提供桌面启动器，点击即开

---

## 📖 文档

| 文档 | 用途 |
|------|------|
| [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) | 用户安装指南 |
| [AGENT_INSTALLATION.md](AGENT_INSTALLATION.md) | AI Agent 自动化安装指南 |
| [RELEASE_NOTES_v3.0.md](RELEASE_NOTES_v3.0.md) | v3.0 版本发布说明 |

---

## 🔗 相关链接

| 资源 | 链接 |
|------|------|
| Open Design 主仓库 | https://github.com/nexu-io/open-design |
| Open Design 官网 | https://open-design.ai/ |
| Intel Mac 安装脚本 | https://github.com/mobyoung/open-design-setup-intel-mac |
| 问题反馈 | https://github.com/nexu-io/open-design/issues |

---

## ⚙️ 系统要求

| 要求 | 规格 |
|------|------|
| **处理器** | Intel Core i5 或更高 |
| **操作系统** | macOS 10.15 (Catalina) 或更高 |
| **内存** | 8GB RAM 或更多 |
| **存储** | 至少 5GB 可用空间 |
| **依赖** | Git, Node.js 18+, pnpm |

---

## 📄 许可证

这些脚本和文档遵循 Open Design 主仓库的 **Apache-2.0** 许可证。

---

**维护者**: [@mobyoung](https://github.com/mobyoung)
**更新时间**: 2026-05-14
