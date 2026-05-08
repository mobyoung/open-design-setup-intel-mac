#!/bin/bash

# Open Design 启动脚本
# 使用固定端口：Daemon: 3000, Web: 3001

cd /Users/boboyoung/Documents/Claw_AI/open_design

echo "🚀 正在启动 Open Design..."
echo "   Daemon API: http://127.0.0.1:3000"
echo "   Web 界面: http://127.0.0.1:3001"
echo ""

# 启动服务（后台模式）
pnpm tools-dev start web --daemon-port 3000 --web-port 3001

echo ""
echo "✅ Open Design 已启动！"
echo "   在浏览器中打开: http://127.0.0.1:3001"
