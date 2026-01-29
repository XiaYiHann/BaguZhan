#!/bin/bash

# 八股斩完整启动脚本
# 启动后端服务 + iPhone 模拟器 + Flutter 应用

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 后端进程 PID
BACKEND_PID=""

# 清理函数：脚本退出时关闭后端
cleanup() {
    if [ -n "$BACKEND_PID" ]; then
        echo -e "\n${YELLOW}正在关闭后端服务...${NC}"
        kill $BACKEND_PID 2>/dev/null || true
        wait $BACKEND_PID 2>/dev/null || true
        echo -e "${GREEN}后端服务已关闭${NC}"
    fi
}

# 捕获退出信号
trap cleanup EXIT INT TERM

echo -e "${GREEN}=== 八股斩完整启动脚本 ===${NC}"
echo ""

# BFF 端口（避免与常用 3000/3001 冲突）
BFF_PORT="${BFF_PORT:-37123}"

# ============ 第一步：启动后端服务 ============
echo -e "${BLUE}[1/3] 启动后端服务...${NC}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"

# 检查后端目录是否存在
if [ ! -d "$SERVER_DIR" ]; then
    echo -e "${RED}错误: 后端目录不存在: $SERVER_DIR${NC}"
    exit 1
fi

# 检查 node_modules 是否存在
if [ ! -d "$SERVER_DIR/node_modules" ]; then
    echo -e "${YELLOW}未检测到 node_modules，正在安装后端依赖...${NC}"
    cd "$SERVER_DIR"
    npm install
    cd "$SCRIPT_DIR"
fi

# 启动后端服务（后台运行）
cd "$SERVER_DIR"
PORT="$BFF_PORT" npm run dev > "$SCRIPT_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
cd "$SCRIPT_DIR"

echo -e "${GREEN}后端服务已启动 (PID: $BACKEND_PID)${NC}"
echo -e "  日志文件: ${YELLOW}$SCRIPT_DIR/backend.log${NC}"

# 等待后端启动
echo -e "${YELLOW}等待后端服务就绪...${NC}"
sleep 3

# 检查后端是否正常运行
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}错误: 后端服务启动失败${NC}"
    echo "请查看日志: $SCRIPT_DIR/backend.log"
    exit 1
fi

# 健康检查（必须 200 + JSON）
for i in {1..10}; do
    HEALTH_RESP="$(curl -fsS http://localhost:${BFF_PORT}/health 2>/dev/null || true)"
    if [[ "$HEALTH_RESP" == *'"status"'*'"ok"'* ]]; then
        echo -e "${GREEN}后端服务就绪！${NC}\n"
        break
    fi
    if [ $i -eq 10 ]; then
        echo -e "${YELLOW}警告: 无法连接到后端，但继续启动...${NC}\n"
    fi
    sleep 1
done

# ============ 第二步：启动 iPhone 模拟器 ============
echo -e "${BLUE}[2/3] 启动 iPhone 模拟器...${NC}"

# 切换到 Flutter 项目目录
cd "$SCRIPT_DIR/baguzhan"

# 默认使用 iPhone 16 模拟器（排除 Pro、Plus、e 型号）
DEVICE_LINE=$(xcrun simctl list devices available | grep "iPhone 16" | grep -vE "(iPhone 16 Pro|iPhone 16 Plus|iPhone 16e)" | head -1)
DEVICE_ID=$(echo "$DEVICE_LINE" | grep -oE '[A-F0-9-]{36}')
DEVICE_NAME=$(echo "$DEVICE_LINE" | sed 's/ *(//' | sed 's/).*//')

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}错误: 未找到可用的 iPhone 模拟器${NC}"
    echo "请先安装 Xcode 并创建一个 iPhone 模拟器"
    exit 1
fi

echo -e "${YELLOW}检测到模拟器: $DEVICE_NAME${NC}"

# 检查模拟器是否已经运行
if xcrun simctl list devices | grep "$DEVICE_ID" | grep -q "Booted"; then
    echo -e "${GREEN}模拟器已在运行中${NC}\n"
else
    echo -e "${YELLOW}正在启动模拟器...${NC}"
    xcrun simctl boot "$DEVICE_ID"

    # 等待模拟器启动
    echo -e "${YELLOW}等待模拟器完全启动...${NC}"
    sleep 5

    # 打开模拟器窗口
    open -a Simulator
    echo -e "${GREEN}模拟器启动完成${NC}\n"
fi

# ============ 第三步：运行 Flutter 应用 ============
echo -e "${BLUE}[3/3] 启动 Flutter 应用...${NC}"
echo -e "${GREEN}后端运行中: ${YELLOW}http://localhost:${BFF_PORT}${NC}"
echo -e "${GREEN}后端日志: ${YELLOW}$SCRIPT_DIR/backend.log${NC}"
echo ""
echo -e "${YELLOW}提示: 按 Ctrl+C 退出应用并关闭后端服务${NC}"
echo ""

flutter run -d "$DEVICE_ID"
