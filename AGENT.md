# AGENT.md — 项目上下文

## 项目概述

**仓库**: https://github.com/mobyoung/open-design-setup-intel-mac  
**用途**: 为 Intel Mac 用户提供 Open Design 的安装/启动/管理脚本  
**用户**: boboyoung (GitHub: mobyoung)，广州易识科技前端开发者  
**平台**: macOS Intel Mac (x64)，安装目录默认为 `~/Documents/open_design`

## 文件结构

```
open-design-setup-intel-mac/
├── install-open-design.command       # 安装脚本（核心文件，一直在迭代）
├── start-open-design.command         # 启动脚本（终端中运行时环境完整）
├── stop-open-design.command          # 停止脚本
├── CHANGELOG.md                      # 版本变更记录
├── AGENT.md                          # 本文件 — Agent 上下文
├── AGENT_INSTALLATION.md             # AI Agent 安装指南
├── INSTALLATION_GUIDE.md             # 用户安装指南
├── RELEASE_NOTES_v3.0.md             # 版本发布说明
└── README.md                         # 项目说明
```

## 桌面启动器架构（关键设计）

### 架构模式：桥接模式

```
双击 Open Design.app
        ↓
  Contents/MacOS/launcher  (约20行，简洁桥接器)
        ↓
  open ~/Documents/open_design/start-open-design.command
        ↓
  Terminal 中运行 start-open-design.command（环境完整）
        ↓
  pnpm tools-dev start desktop ... → 启动服务 → 打开浏览器
```

### 为什么这样设计？

**历史教训**：通过 `.app` 双击启动时，macOS 只提供基础 PATH（`/usr/bin:/bin:/usr/sbin:/sbin`），缺少 `/usr/local/bin`，导致 `node` 和 `pnpm` 都找不到。加 PATH 和加载 profile 都不可靠（非交互式 shell 可能跳过 `.zshrc`）。

**解决方案**：launcher 只做桥接——找到安装目录 → `open` 命令调用 `start-open-design.command`，在 Terminal 中运行，环境自然完整。

### launcher 路径定位逻辑

1. 优先读取 `~/.open_design_install_dir` 配置文件
2. 如果配置文件无效，尝试 `.app bundle` 路径检测（`BASH_SOURCE[0]` + `grep .app`）
3. 找到后 `open` 目标目录下的 `start-open-design.command`

## 配置文件

- **`~/.open_design_install_dir`** — 安装目录路径，安装时写入，launcher 启动时读取

## 常见问题诊断

| 症状 | 日志线索 | 根因 |
|------|---------|------|
| 桌面图标被禁用 | 无 | launcher heredoc 缺少结束标记 |
| 未找到安装目录 | — | launcher 找不到安装路径（.app 在 Desktop，安装目录在 Documents） |
| pnpm: command not found | `pnpm: command not found` | PATH 缺少 `/usr/local/bin` |
| env: node: No such file or directory | `env: node: No such file or directory` | PATH 缺少 `/usr/local/bin` |
| 启动超时 | 空日志或错误日志 | 命令无法执行或服务启动失败 |
| 桌面应用构建失败 | `BUILD_STATUS` 非零 | launcher 中 build 环境不完整 |

## 关键修复历史

- **v3.0.5** (2026-05-15) — 桌面启动器全面修复
  - heredoc 缺少 `EOL` 结束标记 → 插入
  - heredoc 变量被展开 → 改用 `<< 'EOL'` 单引号
  - 找不到安装目录 → 新增 `~/.open_design_install_dir` 配置文件
  - PATH 不完整 → launcher 改为桥接模式，调用 `start-open-design.command`
  - 桌面应用构建环境问题 → 构建移入安装脚本

## 修改注意事项

1. **launcher heredoc 必须用单引号**：`<< 'EOL'` / `<< 'LAUNCHER'`，否则 `$()` 和 `${}` 会在写入时展开
2. **EOL 必须单独一行**：heredoc 结束标记前不能有空格或 Tab
3. **安装目录与桌面启动器路径不同**：`~/Documents/open_design` vs `~/Desktop/Open Design.app`
4. **所有 pnpm 命令**：安装脚本可以在终端中使用 `pnpm`（环境完整），但 launcher 中建议用 `/usr/local/bin/pnpm`
5. **修改后务必测试完整流程**：删除旧 `.app` → 下载安装脚本 → 安装 → 双击启动器

## 提交规范

```bash
git add <file>
git commit -m "type: 描述"
git push myorigin main
```

远程仓库名: `myorigin`
