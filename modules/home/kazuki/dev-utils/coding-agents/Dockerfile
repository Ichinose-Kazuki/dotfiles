# syntax=docker/dockerfile:1

# ベースイメージ
FROM debian:bookworm-slim

# 対話的プロンプトをスキップし、タイムゾーンを日本に設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# 基本ツールをインストール
RUN apt-get update && apt-get install -y \
    curl \
    git \
    procps \
    unzip \
    tree \
    ripgrep \
    build-essential \
    python3 \
    chromium \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Node.js のインストール
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# docker-compose.yml から渡される引数を受け取る
ARG USER_UID
ARG USER_GID

# Ubuntu 24.04 デフォルトの ubuntu ユーザーとIDが衝突するのを防ぐため削除
RUN userdel -r ubuntu 2>/dev/null || true

# ホストと同じ UID/GID を持つ devuser を作成（安全のため非特権ユーザー）
RUN groupadd --gid ${USER_GID} devuser \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -ms /bin/bash devuser

# --- ここから devuser 権限での操作 ---
USER devuser
WORKDIR /home/devuser

# Bun のインストールと環境変数の設定 (gstackに必須)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/home/devuser/.bun/bin:${PATH}"

# 公式インストーラで Claude Code をインストール
RUN curl -fsSL https://claude.ai/install.sh | bash

# gstack のインストール
RUN mkdir -p ~/.claude/skills \
    && git clone https://github.com/garrytan/gstack.git ~/.claude/skills/gstack \
    && cd ~/.claude/skills/gstack \
    && ./setup

# コンテナ内のグローバルな CLAUDE.md と settings.json を作成
RUN echo "## gstack" > ~/.claude/CLAUDE.md && \
    echo "For all web browsing, ALWAYS use the \`/browse\` skill from gstack." >> ~/.claude/CLAUDE.md && \
    echo "NEVER use \`mcp__claude-in-chrome__*\` tools." >> ~/.claude/CLAUDE.md && \
    echo "" >> ~/.claude/CLAUDE.md && \
    echo "**Available gstack skills:**" >> ~/.claude/CLAUDE.md && \
    echo "/office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review, /design-consultation, /review, /ship, /land-and-deploy, /canary, /benchmark, /browse, /qa, /qa-only, /design-review, /setup-browser-cookies, /setup-deploy, /retro, /investigate, /document-release, /codex, /cso, /autoplan, /careful, /freeze, /guard, /unfreeze, /gstack-upgrade" >> ~/.claude/CLAUDE.md && \
    echo '{ "$schema": "https://json.schemastore.org/claude-code-settings.json", "permissions": { "defaultMode": "bypassPermissions" }, "attribution": { "commit": "", "pr": "" }, "enabledPlugins": { "superpowers@claude-plugins-official": true, "code-review@claude-plugins-official": true, "code-simplifier@claude-plugins-official": true, "commit-commands@claude-plugins-official": true, "ralph-loop@claude-plugins-official": true, "claude-md-management@claude-plugins-official": true, "feature-dev@claude-plugins-official": true, "serena@claude-plugins-official": true, "agent-sdk-dev@claude-plugins-official": true, "plugin-dev@claude-plugins-official": true, "skill-creator@claude-plugins-official": true, "clangd-lsp@claude-plugins-official": true }, "effortLevel": "medium" }' > ~/.claude/settings.json

# uv のインストール
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# claude-monitor のインストール
RUN uv tool install claude-monitor

# claude-code-router のインストール
RUN npm install -g @musistudio/claude-code-router
RUN <<EOF > ~/.claude-code-router/config.json
{
    "LOG": true,
    "Providers": [
        {
            "name": "anthropic",
            "api_base_url": "https://api.anthropic.com/v1/messages",
            "api_key": "${ANTHROPIC_API_KEY}",
            "models": [
                "claude-opus-4-6",
            ],
        },
        {
            "name": "zai",
            "api_base_url": "https://api.z.ai/api/anthropic",
            "api_key": "${ZAI_API_KEY}",
            "models": [
                "glm-5.1",
            ],
        },
    ],
}
EOF

# コンテナ起動時のデフォルト作業ディレクトリを設定
WORKDIR /workdir

# Claude Code へのパスを通す
ENV PATH="/home/devuser/.local/bin:${PATH}"

# その他のツールのインストール
USER root
# RUN apt-get update && apt-get install -y \
#     zsh

# ユーザーを devuser に戻す
USER devuser
