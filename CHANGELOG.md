# Changelog

本文档记录 `open-design-setup-intel-mac` 项目的所有 notable changes。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [Unreleased]

### 🐛 修复
- **README 链接错误** - 修正下载链接 `open-design-setup` → `open-design-setup-intel-mac`
- **文件名更新** - README 表格中 `start-open-design.sh` → `start-open-design.command`

### 📦 文件变更
- `README.md` - 更新下载链接和文件列表

### 计划功能
- 添加中文 README
- 添加 LICENSE 文件
- 支持更多 Intel Mac 型号检测

---

## [3.0.2] - 2026-05-07

### 🐛 修复
- **文档错误** - 移除 `RELEASE_NOTES_v3.0.md` 中对不存在的 `CHANGELOG.md` 的错误引用
- **链接修正** - 改为链接到 Open Design 主仓库的 CHANGELOG
- **结构优化** - 添加"相关链接"章节，移除冗余的"致谢"章节

### 📦 文件变更
- `RELEASE_NOTES_v3.0.md` - 修复文档引用错误

---

## [3.0.1] - 2026-05-07

### 📝 文档更新
- **明确平台定位** - 所有文档明确标注"Intel Mac"平台
  - `README.md` - 标题添加 "(Intel Mac)"，添加系统要求说明
  - `AGENT_INSTALLATION.md` - 添加 Intel Mac 注意事项
  - `RELEASE_NOTES_v3.0.md` - 添加"适用平台"标识
- **添加系统要求** - README 新增系统要求章节（Intel Core i5、macOS 10.15+）
- **区分平台** - 明确本仓库仅支持 Intel Mac，Apple Silicon 用户需访问主仓库

### 🔧 仓库管理
- **重命名仓库** - `open-design-setup` → `open-design-setup-intel-mac`
- **更新描述** - 添加 "(Intel Mac)" 标识
- **更新远程 URL** - 同步本地 git 配置

### 📦 文件变更
- `README.md` - 添加平台标识和系统要求
- `AGENT_INSTALLATION.md` - 添加 Intel Mac 说明
- `RELEASE_NOTES_v3.0.md` - 添加平台信息

---

## [3.0.0] - 2026-05-07

### 🎉 首次发布

本版本是 `open-design-setup-intel-mac` 的初始版本，包含 Open Design v3.0 的安装脚本和文档。

### ✨ 新增功能

#### 1. 安装脚本 (v3.0)
- **自动版本检测** - 通过 GitHub API 自动获取最新稳定版
- **简化默认路径** - 从 `~/Documents/Claw_AI/open_design` 简化为 `~/Documents/open_design`
- **脚本路径绑定** - 卸载/升级脚本自动生成在安装目录内
  - 使用 `dirname "$0"` 动态识别路径
  - 与用户解耦，拷贝到其他 Mac 也能正常使用
- **静默安装模式** - 支持 `export NONINTERACTIVE=1` 跳过交互提示
- **依赖自动安装** - 自动检测并安装 pnpm 等依赖

#### 2. Agent 自动化支持
- **新增文档** - `AGENT_INSTALLATION.md` 专为 AI Agent 设计
  - 快速安装命令（一行代码）
  - 手动安装步骤
  - CI/CD 集成示例（GitHub Actions）
  - WorkBuddy/Claude Agent 集成代码示例
  - 故障排查指南
- **自动化友好** - 适合 WorkBuddy、Claude、Cursor 等 AI Agent 自动化部署

#### 3. 文档完善
- **用户安装指南** - `INSTALLATION_GUIDE.md` (v3.0)
  - 新增脚本位置说明
  - 添加版本检测功能介绍
  - 简化安装步骤
  - 明确 Intel Mac 平台支持
- **版本发布说明** - `RELEASE_NOTES_v3.0.md`
  - 核心更新说明
  - 安装方式对比
  - 技术细节（对比 v2.1）
  - 问题修复列表
  - 升级指南
- **项目 README** - 清晰的项目说明和快速开始指南

#### 4. 启动脚本
- **新增** `start-open-design.sh` - 快速启动 Open Design

### 🔧 技术细节

#### 安装脚本改进
| 功能 | v2.1 | v3.0 |
|------|-------|-------|
| 版本检测 | ❌ 固定版本 | ✅ GitHub API 自动检测 |
| 默认路径 | `~/Documents/Claw_AI/open_design` | `~/Documents/open_design` |
| 路径管理 | 硬编码 | `dirname "$0"` 动态识别 |
| 管理脚本位置 | 项目根目录 | 安装目录内自动生成 |
| 静默模式 | ❌ | ✅ `NONINTERACTIVE=1` |
| Agent 友好 | ❌ | ✅ 专用文档和示例 |

#### 文件结构
```
open-design-setup-intel-mac/
├── install-open-design.command    # 安装脚本 (v3.0)
├── start-open-design.command      # 启动脚本
├── stop-open-design.command       # 停止脚本
├── CHANGELOG.md                  # 版本变更记录
├── AGENT_INSTALLATION.md         # Agent 自动化安装指南
├── INSTALLATION_GUIDE.md        # 用户安装指南 (v3.0)
├── RELEASE_NOTES_v3.0.md       # 版本发布说明
└── README.md                    # 项目说明文档
```

### 🐛 问题修复
- 修复安装脚本路径识别问题
- 修复管理脚本与安装目录解耦问题
- 优化错误处理和日志输出
- 改进版本检测逻辑

### 📋 系统要求
- **处理器**: Intel Core i5 或更高 (x64)
- **操作系统**: macOS 10.15 (Catalina) 或更高版本
- **内存**: 8GB RAM 或更多
- **存储**: 至少 5GB 可用空间
- **依赖**: Git, Node.js 18+, pnpm

### 🔗 相关链接
- **本仓库**: https://github.com/mobyoung/open-design-setup-intel-mac
- **Open Design 主仓库**: https://github.com/nexu-io/open-design
- **Open Design 官网**: https://open-design.ai/

### 🙏 致谢
感谢 Open Design 项目团队和所有贡献者！

---

## 版本说明

### 版本格式
- **主版本号**: 重大变更，可能不兼容
- **次版本号**: 新增功能，向下兼容
- **修订号**: Bug 修复，向下兼容

### 平台标识
- **Intel Mac** - 本仓库支持的平台 (x64)
- **Apple Silicon** - 请访问 [Open Design 主仓库](https://github.com/nexu-io/open-design)

---

## 历史背景

### Open Design 项目
- **官方支持**: Apple Silicon (M1/M2/M3) Mac，macOS 11+
- **Intel Mac 支持**: 官方不支持，需从源码编译运行
- **本仓库目的**: 为 Intel Mac 用户提供优化的安装脚本和文档

### v3.0 脚本来源
- 基于 Open Design 主仓库的 `install-open-design.command`
- 针对 Intel Mac 平台优化
- 添加版本检测和路径简化功能

---

**仓库地址**: https://github.com/mobyoung/open-design-setup-intel-mac  
**最后更新**: 2026-05-07
