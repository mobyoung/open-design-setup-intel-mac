# AGENT.md — 项目完整上下文

> 本文档供后续接手的 AI Agent 快速了解项目全貌。请先通读，再操作。

---

## 1. 项目定位

**仓库**: https://github.com/mobyoung/open-design-setup-intel-mac  
**用途**: 为 Intel Mac 用户提供 [Open Design](https://github.com/nexu-io/open-design) 的一键安装脚本和桌面启动器  
**用户**: boboyoung (mobyoung)，广州易识科技前端开发者  
**平台**: macOS Intel (x64)，本地开发环境

### 项目关系

| 层级 | 说明 |
|------|------|
| **Open Design（上游）** | https://github.com/nexu-io/open-design — 主项目，daemon + web sidecar 架构 |
| **本仓库（安装器）** | https://github.com/mobyoung/open-design-setup-intel-mac — Intel Mac 安装/启动脚本 |
| **安装后产物** | `~/Documents/open_design/`（默认路径）— 安装脚本将 Open Design 部署到此目录 |

本仓库不包含 Open Design 源码，只负责在 Intel Mac 上一键完成安装、依赖部署、创建桌面启动器。

---

## 2. 文件结构

```
open-design-setup-intel-mac/
├── install-open-design.command    # 🎯 核心：安装脚本（一直在迭代）
│                                  # 包含 install / upgrade / desktop launcher 三套逻辑
├── start-open-design.command      # 启动脚本（终端中运行，环境完整）
├── stop-open-design.command       # 停止脚本
├── CHANGELOG.md                   # 版本变更记录（Keep a Changelog 格式）
├── AGENT.md                       # ➡️ 本文件
├── AGENT_INSTALLATION.md          # AI Agent 自动化安装指南
├── INSTALLATION_GUIDE.md          # 用户安装指南
├── RELEASE_NOTES_v3.0.md          # v3.0 发布说明
└── README.md                      # 项目说明
```

---

## 3. Open Design 架构背景

了解这个背景有助于理解安装脚本的设计。

### 核心架构

```
┌─────────────────────────────────────────────────┐
│                   tools-dev CLI                  │
│  (pnpm tools-dev start/stop/status/logs)        │
├────────────────────┬────────────────────────────┤
│     daemon         │        web sidecar          │
│  (后台服务进程)     │    (Next.js 前端)            │
│  端口: 3000        │    端口: 3001               │
│  绑定: OD_BIND_HOST│    绑定: OD_HOST            │
│  launchd 管理      │    daemon 管理               │
└────────────────────┴────────────────────────────┘
```

- **daemon**: 后台常驻服务，通过 `launchd` 管理
- **web sidecar**: Next.js 前端，由 daemon 管理
- **desktop**: Electron 桌面应用，需要 `pnpm --filter @open-design/desktop build` 构建
- **tools-dev**: 统一的 CLI 入口，封装了 start / stop / status / logs 等操作

### 网络配置

| 环境变量 | 作用 | 典型值 |
|---------|------|--------|
| `OD_BIND_HOST` | daemon 绑定地址 | `127.0.0.1` |
| `OD_HOST` | web sidecar 绑定地址 | `127.0.0.1` |
| HMR WebSocket | Next.js webpack 热更新 | 仅 localhost（LAN 不可用） |

### 启动模式

| 模式 | 命令 | 启动内容 |
|------|------|---------|
| desktop | `tools-dev start desktop` | daemon + web + Electron 窗口 |
| web | `tools-dev start web` | daemon + web 浏览器 |
| daemon | `tools-dev start daemon` | 仅后台服务 |

---

## 4. 安装脚本详解

### 安装步骤 (10步)

| 步骤 | 标题 | 做什么 |
|------|------|--------|
| 1 | 选择安装目录 | 默认 `~/Documents/open_design` |
| 2 | 检查系统依赖 | Git、Node.js 等 |
| 3 | 检查已安装 | 检测是否已有 Open Design |
| 4 | 安装 Node.js | 如未安装则自动安装 |
| 5 | 安装/更新 pnpm | 固定版本 10.33.2 |
| 6 | 选择安装类型 | 全新安装 or 升级 |
| 7 | 下载脚本文件 | 从 GitHub 下载 start/stop/update 等脚本 |
| 8 | 安装依赖 | `pnpm install` |
| 9 | 创建管理脚本 | uninstall / update 脚本 |
| 10 | 构+创桌面启动器 | **构建桌面应用** → **创建 Open Design.app** |
| — | 清理 | Git 代理清理 |
| — | 完成 | 显示安装信息 |

### 升级步骤 (5/6步)

升级时跳过的步骤：不检测目录、不安装 Node.js/pnpm，只做依赖更新和桌面启动器重建。

### 代理支持

- 通过 `USE_PROXY` 环境变量控制
- 自动设置 Git 代理（http.proxy / https.proxy）
- 安装完成后自动清除代理，避免影响后续使用

### 静默模式

```bash
export NONINTERACTIVE=1
```
跳过交互提示，适合自动化部署。

---

## 5. 桌面启动器架构（核心设计）

### 架构演进

桌面启动器经历了 **3次迭代** 才达到稳定状态：

#### v1: 自包含模式（失败）
launcher 脚本直接内联 `pnpm tools-dev start desktop ...` + 状态检查循环。
- ❌ heredoc 缺少 `EOL` 结束标记 → `cat` 写入 7KB 垃圾
- ❌ heredoc 不带引号 → `$(BASH_SOURCE[0])` 被提前展开为硬编码路径
- ❌ `.app` 启动时 PATH 不完整 → `pnpm` 找不到 → `node` 找不到
- ❌ launcher 中 `pnpm build` 环境不完整 → 构建失败

#### v2: 加 PATH / profile 加载（失败）
在 launcher 中加 `source ~/.zshrc`、加 `/usr/local/bin` 到 PATH。
- ❌ 非交互式 shell 跳过 `.zshrc`
- ❌ 仍依赖 PATH 环境

#### v3: 桥接模式 ✅（当前方案）
launcher 只做桥接：**找到安装目录 → `open start-open-design.command`**

### 最终架构

```
双击 Open Design.app  (桌面)
        ↓
  Contents/MacOS/launcher  (~20行，简洁桥接器)
        ↓
  1. 读取 ~/.open_design_install_dir 配置文件
  2. open 目标目录下的 start-open-design.command
        ↓
  Terminal 窗口弹出 → 运行 start-open-design.command
        ↓
  终端环境完整（PATH含 /usr/local/bin）
        ↓
  pnpm tools-dev start desktop ... → 启动服务 → 打开浏览器
```

### 路径定位逻辑（launcher内）

```
1. 读取 ~/.open_design_install_dir → 验证 pnpm-workspace.yaml 存在
   → 找到则 open start-open-design.command
2. 若配置文件无效，尝试 BASH_SOURCE[0] → grep '.app' 
   → bundle同级目录找 start-open-design.command
3. 都找不到 → osascript 弹窗报错
```

---

## 6. 配置文件

| 文件路径 | 何时创建 | 用途 |
|---------|---------|------|
| `~/.open_design_install_dir` | 安装时 | 保存安装目录路径，供 launcher 读取 |
| `~/.tmp/desktop-launcher.log` | launcher运行时 | 启动日志（调试用） |

---

## 7. 编码规范与用户偏好

### 交流风格
- **中文沟通**：完全中文交流
- **结构化表格**：偏好表格输出多维度信息
- **树状层级**：节点父子关系清晰的可视化
- **编号列表**：以列表形式提出多个并行修改需求
- **原子化操作**：一次一个修改，迭代优化

### 编码约束 ⚠️
- **禁止硬编码**：通用可复用样式必须抽成独立样式表
- **系统性重构**：优先从架构层面解决问题，而非打补丁
- **并列修改**：当用户以编号列表提出多个需求时，全部完成
- **代码即起效**：修改后必须测试完整流程

### UI/UX 要求（精细级别）
- 间距、字号、交互反馈必须精确

### 工作流触发
| 用户说 | 触发操作 |
|--------|---------|
| "结束今天的工作" | 更新 CHANGELOG → 写记忆 → git push |
| "推送到 github" | `git push myorigin main` |

---

## 8. 调试指南

### 启动日志

查看桌面启动器日志：
```bash
cat ~/Documents/open_design/.tmp/desktop-launcher.log
```

### 服务状态
```bash
cd ~/Documents/open_design
/usr/local/bin/pnpm tools-dev status
```

### 常见问题诊断表

| 症状 | 日志线索 | 根因 | 修复方案 |
|------|---------|------|---------|
| 桌面图标灰色被禁用 | launcher 文件过大 (~7KB) | heredoc 缺少 `EOL` 结束标记 | 在 osascript 行后插入 `EOL` |
| "未找到安装目录" | — | launcher 找不到安装路径 | 检查 `~/.open_design_install_dir` 是否存在 |
| `pnpm: command not found` | 日志中 PATH 缺 `/usr/local/bin` | `.app` 启动 PATH 不完整 | launcher 中 `/usr/local/bin/pnpm` 绝对路径 或 桥接模式 |
| `env: node: No such file or directory` | 同上 | `pnpm` 运行时需要 `node` | 同上 |
| 启动超时 | 日志为空 | 启动命令根本没执行 | 检查 PATH / 命令是否存在 |
| 启动超时 | 日志显示 status 返回错误 | 服务启动失败 | 手动运行 `/usr/local/bin/pnpm tools-dev status` 排查 |
| `SCRIPT_DIR="/Users/boboyoung/..."` | launcher 中路径被硬编码 | heredoc 无单引号 → 变量被提前展开 | `<< 'EOL'` 而非 `<< EOL` |
| launcher 运行但无终端弹出 | — | `start-open-design.command` 不存在 | 安装时从 GitHub 下载缺失脚本 |
| "桌面应用构建失败" | exit code 非零 | 安装时构建失败 或 launcher 中重试构建 | 安装脚本中明确构建步骤 + launcher 只检查 |

### 逐层排查路径

```
桌面启动器不工作
├── 图标灰色被禁用？
│   └── → 重新安装（gen_launcher heredoc 有问题）
├── 双击后无任何反应？
│   └── → 检查 ~/.open_design_install_dir 配置
├── 弹出终端但很快退出？
│   └── → 直接双击 start-open-design.command 测试
│       ├── 正常工作 → launcher 路径检测有问题
│       └── 也有问题 → start-open-design.command 本身的 bug
└── 终端一直等待直到超时？
    └── → 查看 ~/Documents/open_design/.tmp/desktop-launcher.log
```

---

## 9. 关键修复历史摘要

### v3.0.5 (2026-05-15) — 桌面启动器全面修复 🏆

| 问题 | 根因 | 修复 |
|------|------|------|
| launcher 写入 7KB 垃圾 | heredoc 无结束标记 | 插入 `EOL` |
| SCRIPT_DIR 路径硬编码 | heredoc 不带单引号 → 变量展开 | `<< 'EOL'` |
| 找不到安装目录 | `dirname` 只能到 Desktop | `~/.open_design_install_dir` 配置系统 |
| pnpm 找不到 | PATH 缺 `/usr/local/bin` | 所有 `pnpm` → `/usr/local/bin/pnpm` |
| node 找不到 | 同上 | 同上 |
| launcher build 失败 | 环境不完整 | 构建移到安装脚本 |
| 全部问题 | 根本原因是 PATH 环境 | 最终方案：**桥接模式** → 委托给终端命令 |

### 其他历史修复
- **v3.0.4**: 路径硬编码修复（`${BASH_SOURCE[0]}` 动态检测）、构建检查逻辑修复
- **v3.0.3**: 仓库清理、start/stop 脚本下载缺失修复、desktop 模式替代 web 模式
- **v3.0.0**: 初始发布，版本检测、路径简化

---

## 10. 编辑注意事项 ⚠️

### Heredoc 铁律
```bash
# ✅ 正确：用单引号防止变量展开
cat > file << 'EOL'
  $HOME  # 会作为字面文本写入，不会展开
  $(pwd) # 同上
EOL

# ❌ 错误：不带引号
cat > file << EOL
  $HOME  # 会被展开！写入文件的是实际路径
  $(pwd) # 同上
EOL
```

**EOL 必须单独一行，前后无空格/Tab。**

### 两处 heredoc 需同步修改
每个 launcher 逻辑在安装脚本中出现两处：
- **install step**: `cat > "$DESTOP_APP/..." << 'EOL'`（行 1165）
- **upgrade step**: `cat > "$DESTOP_APP/..." << 'LAUNCHER'`（行 870）

修改一处后必须同步修改另一处。使用 `replace_all=true` 可同时修改。

### git 工作流
```bash
git add <file>
git commit -m "type: 描述"
git push myorigin main
```

**远程仓库名**: `myorigin`（不是 `origin`）

### 测试流程（必须）
```
1. rm -rf ~/Desktop/Open\ Design.app
2. 下载最新 install-open-design.command
3. 运行安装
4. 双击桌面 Open Design.app 测试
5. 如果失败：cat ~/Documents/open_design/.tmp/desktop-launcher.log
```

---

## 11. tools-dev CLI 参考

| 命令 | 用途 |
|------|------|
| `pnpm tools-dev status` | 查看 daemon/web 服务状态 |
| `pnpm tools-dev start desktop` | 启动 daemon + web + Electron |
| `pnpm tools-dev start web` | 启动 daemon + web（浏览器打开） |
| `pnpm tools-dev start daemon` | 仅启动 daemon |
| `pnpm tools-dev stop` | 停止所有服务 |
| `pnpm tools-dev logs` | 查看运行日志 |
| `pnpm tools-dev run desktop` | 同上（别名） |
| `pnpm tools-dev run web` | 同上（别名） |

---

## 12. 注意事项

1. **Desktop ≠ Desktop 目录**：“desktop 模式”指 Electron 桌面应用模式，不同于 macOS 的桌面（Desktop）文件夹
2. **APP 命名带空格**：`Open Design.app` 含空格，shell 中需引号或转义
3. **桌面图标禁用**：macOS 对 `.app` 格式要求严格，`Info.plist` 或 `MacOS/launcher` 任一有问题就会显示禁用图标
4. **launcher 不处理服务逻辑**：桥接模式下 launcher 职责单一——找到路径，调用命令，退出
5. **交互式 vs 非交互式**：`.zshrc` 中可能对非交互式 shell 有条件判断（`[[ -o interactive ]]`），导致 `source` 不生效

---

*最后更新: 2026-05-15 · 桌面启动器修复完成，采用桥接模式稳定运行*
