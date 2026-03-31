#!/bin/bash
#卸载与环境清理脚本 (一键回退版)
#用于彻底杀死过去手动启动的常驻服务，并清空沙盒配置。

echo "=== 开始执行 Voice Clone 还原与清理工作 ==="

# 1. 杀死正在占用端点或在后台脱壳狂跑的 FastAPI 进程
echo "[-] 正在探测并杀死占用 8000 端口及后台滞留的 app.py 进程..."
# 获取监听 8000 的进程PID（如果存在）
PIDS=$(lsof -t -i:8000 || echo "")
if [ -n "$PIDS" ]; then
    kill -9 $PIDS
    echo "    - 成功强制关闭端口 8000 的守护进程 (PID: $PIDS)。"
else
    echo "    - 端点清空：当前 8000 端口未被占用。"
fi

# 再用正则容错匹配杀掉遗漏的后台执行实例
pkill -f "python app.py" && echo "    - 成功清理遗留脱壳进程。" || true

# 2. 移除为了项目构建的极其庞大的推演沙盒 Python 虚拟环境
echo "[-] 正在删除用于隔离 F5-TTS 和 Torch 的本地 venv 虚拟硬盘环境..."
if [ -d "venv" ]; then
    rm -rf venv
    echo "    - 成功删除本目录 venv 系统 (释放了上 GB 空间)。"
else
    echo "    - venv 已不存在。"
fi

# 3. 截断向 OpenClaw 大脑主目录自动生成的 Agent 挂载短接头
echo "[-] 正在卸除系统级的 Agent Skill 注册态..."
SKILL_LINK="$HOME/.openclaw/skills/openclaw-voice-clone"
if [ -L "$SKILL_LINK" ] || [ -d "$SKILL_LINK" ]; then
    rm -rf "$SKILL_LINK"
    echo "    - 成功拔除技能注册锚点: $SKILL_LINK"
fi

# 4. （可选保留项）大模型权重文件
# 因为模型重达几个 GB，每次下载需要耗费十分钟且极吃带宽，故默认不删除。
# 想要彻底格式化的用户可以手动去掉下方行的注释。
# rm -rf "$HOME/.openclaw/models/voice-clone/"

echo ""
echo "=== 回退完毕！你的系统已经对刚才跑过的这部分服务彻底失忆了。 ==="
echo "如果你想再次体验开机和新 Agent 是如何毫无干预地把它拉起来的，请直接运行："
echo "   bash scripts/run_tts.sh --text '你好' --ref_audio '某个录音.ogg'"
