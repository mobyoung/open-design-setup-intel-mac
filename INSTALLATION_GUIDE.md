# Open Design 安装指南（Mac Intel 平台）

> **适用场景**：在 Mac Intel (x64) 平台上从源码安装 Open Design  
> **撰写日期**：2026-05-07  
> **Open Design 版本**：0.4.1  
> **作者**：boboyoung

---

## 📂 路径说明（更新）

本文档中的 `<open_design_dir>` 指的是 Open Design 的安装目录。

**默认安装目录**：`~/Documents/open_design`（已简化，去掉 Claw_AI 层级）
- 即：`/Users/<你的用户名>/Documents/open_design`

**脚本位置说明**：安装完成后，卸载和升级脚本会自动生成在 `<open_design_dir>` 内，分别为：
- `uninstall-open-design.command`（卸载脚本）
- `update-open-design.command`（升级脚本）

这些脚本会自动识别所在目录，无需额外配置，拷贝到其他 Mac 也能正常使用。

**根据你的实际情况替换路径**：
- 如果使用的是默认目录，将 `<open_design_dir>` 替换为 `~/Documents/open_design`
- 如果使用的是自定义目录，请替换为你的实际路径

---

## 🆕 安装脚本 3.0 新特性

1. **简化默认路径**：默认安装目录改为 `~/Documents/open_design`，结构更简洁
2. **脚本内置**：卸载、升级脚本自动生成在 Open Design 安装目录内，自动识别路径，与用户解耦
3. **自动检测版本**：安装时自动从 GitHub API 获取最新稳定版，获取失败则使用默认兼容版本（0.4.1）

---

## ⚠️ 重要说明

**Open Design 官方不支持 Mac Intel 平台！**

- ✅ 官方支持：Apple Silicon (M1/M2/M3 等 ARM64)，macOS 11+
- ❌ 官方不支持：Intel (x64) Mac
- ✅ **解决方案**：从源码编译运行（本指南）

---

## 📋 系统要求

| 组件 | 要求 | 检查命令 |
|------|------|----------|
| macOS | Intel Mac | `uname -m` → 应显示 `x86_64` |
| Node.js | `~24`（推荐 24.x） | `node --version` |
| pnpm | `10.33.2+` | `pnpm --version` |
| Git | 最新版 | `git --version` |
| 磁盘空间 | ≥ 2GB | - |

---

## 🚀 完整安装步骤

### 步骤 1：检查 Node.js 版本

```bash
node --version
```

**要求**：Node.js `~24`（24.x 版本）

如果版本不对，使用 nvm 或 fnm 安装：

```bash
# 使用 nvm
nvm install 24
nvm use 24

# 或使用 fnm
fnm install 24
fnm use 24
```

---

### 步骤 2：安装/更新 pnpm 到 10.33.2+

```bash
# 启用 corepack（Node.js 自带的包管理器）
corepack enable

# 安装并激活 pnpm 10.33.2
corepack prepare pnpm@10.33.2 --activate

# 验证版本
pnpm --version
# 应输出：10.33.2
```

---

### 步骤 3：克隆 Open Design 仓库

```bash
# 进入你想要的安装目录（示例使用默认路径）
cd ~/Documents

# 克隆仓库
git clone https://github.com/nexu-io/open-design.git open_design
cd open_design
```

**注意**：
- 仓库会克隆到 `~/Documents/open_design`（默认路径，可根据需要修改）
- 目录结构：
  ```
  open_design/
  ├── apps/          # 应用（web, daemon, desktop）
  ├── packages/      # 共享包（contracts, sidecar 等）
  ├── tools/         # 开发工具（dev, pack）
  ├── skills/        # 设计技能
  └── design-systems/  # 设计系统
  ```

---

### 步骤 4：安装依赖

```bash
# 在项目根目录执行
pnpm install
```

**预计时间**：2-5 分钟  
**安装内容**：
- 859+ npm 包
- Electron（自动下载）
- better-sqlite3（原生模块编译）
- esbuild（预编译）

**可能的警告**（可忽略）：
```
⚠️ Failed to create bin at .../od. ENOENT: no such file or directory
⚠️ Ignored build scripts: electron-winstaller, sharp
```

这些是 Windows 相关依赖，Mac 上可忽略。

---

### 步骤 5：启动 Open Design（测试）

```bash
# 启动服务（前台运行，可看到日志）
pnpm tools-dev run web
```

**成功标志**：
```
tools-dev start
- daemon: started ● running → http://127.0.0.1:随机端口
- web: started ● running → http://127.0.0.1:随机端口
```

**访问 Web 界面**：
- 打开浏览器
- 访问终端中显示的 Web URL（例如：http://127.0.0.1:59487）

**停止服务**：
- 在终端按 `Ctrl + C`

---

### 步骤 6：配置固定端口（推荐）

默认情况下，每次启动端口都会随机变化。建议配置**固定易记端口**：

```bash
# 停止当前服务（如果正在运行）
pnpm tools-dev stop

# 使用固定端口启动
pnpm tools-dev start web --daemon-port 3000 --web-port 3001
```

**推荐端口**：
| 服务 | 端口 | 地址 |
|------|------|------|
| Daemon API | `3000` | http://127.0.0.1:3000 |
| Web 界面 | `3001` | http://127.0.0.1:3001 |

**验证**：
```bash
# 检查服务状态
pnpm tools-dev status

# 应输出：
# - daemon: running ● http://127.0.0.1:3000
# - web: running ● http://127.0.0.1:3001
```

---

### 步骤 7：创建桌面启动器（macOS .app）

为了方便以后启动，创建一个**双击即可启动的 macOS 应用**。

#### 7.1 创建应用目录结构

```bash
mkdir -p ~/Desktop/"Open Design.app"/Contents/{MacOS,Resources}
```

#### 7.2 创建 `Info.plist`

创建文件 `~/Desktop/Open Design.app/Contents/Info.plist`：

```xml
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
```

#### 7.3 创建启动脚本

创建文件 `~/Desktop/Open Design.app/Contents/MacOS/launcher`：

```bash
#!/bin/bash

# 显示启动通知
osascript -e 'display notification "正在启动 Open Design..." with title "Open Design"'

# 设置工作目录（替换为你的实际安装目录）
WORK_DIR="<open_design_dir>"

# 停止旧进程
cd "$WORK_DIR" && pnpm tools-dev stop 2>/dev/null

# 启动 Open Design 服务（后台运行）
cd "$WORK_DIR" && nohup pnpm tools-dev start web --daemon-port 3000 --web-port 3001 > /dev/null 2>&1 &

# 等待服务启动
sleep 5

# 打开浏览器
open http://127.0.0.1:3001

# 显示完成通知
osascript -e 'display notification "Open Design 已启动！Web 界面已打开。" with title "Open Design"'
```

**重要**：修改 `WORK_DIR` 为你的实际安装目录！

添加执行权限：
```bash
chmod +x ~/Desktop/"Open Design.app/Contents/MacOS/launcher"
```

#### 7.4 复制 Open Design 图标

```bash
# 复制官方图标（从项目目录）
cp <open_design_dir>/tools/pack/resources/mac/icon.icns \
   ~/Desktop/"Open Design.app/Contents/Resources/icon.icns"
```

**如果上述路径不存在**，可以手动：
1. 在 Finder 中打开 `<open_design_dir>/tools/pack/resources/mac/`
2. 复制 `icon.icns`
3. 粘贴到 `~/Desktop/Open Design.app/Contents/Resources/`

#### 7.5 设置桌面图标（手动方式）

如果桌面图标未自动更新：

1. 在 Finder 中打开 `open_design/tools/pack/resources/mac/`
2. 双击 `icon.icns`（在 Preview 中打开）
3. 按 `Cmd + A`（全选）
4. 按 `Cmd + C`（复制）
5. 右键点击桌面的 **"Open Design"** app
6. 选择 **"显示简介"**（`Cmd + I`）
7. 点击左上角的**小图标**（确保蓝色高亮）
8. 按 `Cmd + V`（粘贴）

✨ 桌面图标会立即更新为 Open Design 官方图标！

---

## 🖥️ 使用方法

### 启动 Open Design

**方法 1：双击桌面 app（推荐）**
- 双击 `~/Desktop/Open Design.app`
- 等待 5-10 秒
- 浏览器自动打开 http://127.0.0.1:3001

**方法 2：命令行启动**
```bash
cd <open_design_dir>
pnpm tools-dev start web --daemon-port 3000 --web-port 3001
```

---

### 停止 Open Design

**命令行方式**：
```bash
cd <open_design_dir>
pnpm tools-dev stop
```

**注意**：双击 app 只会**启动**服务，不会停止。停止需要命令行。

---

### 查看服务状态

```bash
cd <open_design_dir>
pnpm tools-dev status
```

**输出示例**：
```
tools-dev status (namespace default ■ partial)
- daemon: running ● http://127.0.0.1:3000  ● pid 12345
- web: running ● http://127.0.0.1:3001  ● pid 12346
- desktop: idle
```

---

### 查看日志

```bash
cd <open_design_dir>
pnpm tools-dev logs
```

**日志文件路径**：
- Daemon：` .tmp/tools-dev/default/logs/daemon/latest.log`
- Web：` .tmp/tools-dev/default/logs/web/latest.log`

---

## 🔧 常用命令速查

```bash
# 进入项目目录
cd <open_design_dir>

# 启动服务（固定端口）
pnpm tools-dev start web --daemon-port 3000 --web-port 3001

# 启动服务（随机端口）
pnpm tools-dev start web

# 停止服务
pnpm tools-dev stop

# 重启服务
pnpm tools-dev restart

# 查看状态
pnpm tools-dev status

# 查看日志
pnpm tools-dev logs

# 完整诊断
pnpm tools-dev check
```

---

## 🌐 访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| **Web 界面** | http://127.0.0.1:3001 | 可视化设计界面 ✅ |
| **Daemon API** | http://127.0.0.1:3000 | 后端 API 服务 |

### 验证 Daemon API 是否正常运行

```bash
curl http://127.0.0.1:3000/api/health
```

**正常响应**：
```json
{"ok":true,"version":"0.4.1"}
```

**注意**：直接访问 http://127.0.0.1:3000 会显示 `Cannot GET /`，这是**正常**的（API 根路径不需要网页）。

---

## ❓ 常见问题

### Q1：Daemon API 显示 "Cannot GET /"，是否正常？

**答**：完全正常！
- Daemon 是**后端 API 服务**，不是网页界面
- 根路径 `/` 没有设置网页响应
- 验证健康状态：`curl http://127.0.0.1:3000/api/health`
- Web 界面会通过前端代码自动与 Daemon API 通信

---

### Q2：如何修改固定端口？

**答**：修改启动命令中的 `--daemon-port` 和 `--web-port` 参数：

```bash
pnpm tools-dev start web --daemon-port 17456 --web-port 17573
```

同时更新桌面 app 的启动脚本（`~/Desktop/Open Design.app/Contents/MacOS/launcher`）：
- 修改 `--daemon-port` 和 `--web-port` 参数
- 修改 `open http://127.0.0.1:新端口`

---

### Q3：服务启动后自动停止？

**答**：可能原因：
1. **终端关闭**：使用 `pnpm tools-dev run web` 时，关闭终端会停止服务
   - **解决**：使用 `pnpm tools-dev start web`（后台模式）
   
2. **端口冲突**：端口被其他程序占用
   - **解决**：更换端口或停止占用端口的程序

3. **系统休眠**：Mac 休眠后可能导致服务停止
   - **解决**：重新双击桌面 app 启动

---

### Q4：如何在其他 Mac 设备上安装？

**答**：按照本指南的步骤完整执行一遍：
1. 检查 Node.js 和 pnpm 版本
2. 克隆仓库
3. 安装依赖
4. 配置固定端口
5. 创建桌面启动器

**预计时间**：10-15 分钟（取决于网络速度）

---

### Q5：能否升级到新版本？

**答**：可以！步骤如下：

```bash
cd <open_design_dir>

# 停止服务
pnpm tools-dev stop

# 拉取最新代码
git pull origin main

# 重新安装依赖（可能有新增依赖）
pnpm install

# 重新启动
pnpm tools-dev start web --daemon-port 3000 --web-port 3001
```

---

### Q6：如何完全卸载 Open Design？

**答**：

```bash
# 1. 停止服务
cd <open_design_dir>
pnpm tools-dev stop

# 2. 删除项目目录
rm -rf <open_design_dir>

# 3. 删除桌面启动器
rm -rf ~/Desktop/"Open Design.app"

# 4. （可选）卸载 pnpm
corepack disable pnpm
```

---

## 📝 技术细节

### 项目结构

```
open_design/
├── apps/
│   ├── web/          # Next.js 16 + React 18 Web 界面
│   ├── daemon/       # 本地守护进程（API 服务）
│   └── desktop/      # Electron 桌面壳（可选）
├── packages/
│   ├── contracts/    # TypeScript 契约层
│   ├── sidecar-proto/  # Sidecar 协议
│   └── sidecar/      # 通用 Sidecar 运行时
├── tools/
│   ├── dev/          # 开发生命周期控制（tools-dev）
│   └── pack/         # 打包工具
├── skills/            # 31 个设计技能
├── design-systems/    # 72 个设计系统
└── craft/             # 通用设计规则
```

---

### 服务架构

```
┌─────────────────────────────────────────┐
│          Web 界面 (端口 3001)          │
│      Next.js 16 + React 18             │
│      URL: http://127.0.0.1:3001      │
└──────────────┬──────────────────────────┘
               │ HTTP API 调用
               ↓
┌─────────────────────────────────────────┐
│        Daemon API (端口 3000)          │
│    本地守护进程                          │
│    URL: http://127.0.0.1:3000         │
│                                        │
│   • Agent 管理                          │
│   • 技能加载（31 个）                   │
│   • 设计系统（72 个）                   │
│   • SQLite 数据库                       │
└─────────────────────────────────────────┘
```

---

### 数据存储

| 目录 | 说明 |
|------|------|
| `.od/` | 运行时数据（SQLite 数据库、项目文件、渲染输出） |
| `.tmp/` | 临时文件（日志、IPC 套接字） |
| `node_modules/` | npm 依赖 |

**注意**：`.od/` 和 `.tmp/` 在 `.gitignore` 中，不会被提交到 Git。

---

## 📚 参考资源

| 资源 | 链接 |
|------|------|
| Open Design 官网 | https://open-design.ai/ |
| GitHub 仓库 | https://github.com/nexu-io/open-design |
| 发布页面 | https://github.com/nexu-io/open-design/releases |
| 快速开始 | https://github.com/nexu-io/open-design#quickstart |
| 贡献指南 | https://github.com/nexu-io/open-design/blob/main/CONTRIBUTING.md |

---

## 🎉 安装完成！

现在你可以：
1. **双击桌面上的 "Open Design" app** 启动服务
2. **在浏览器中访问** http://127.0.0.1:3001 开始设计
3. **查看状态**：`pnpm tools-dev status`
4. **查看日志**：`pnpm tools-dev logs`

---

## 📝 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-05-07 | 1.0 | 初始版本，完整安装流程 |
