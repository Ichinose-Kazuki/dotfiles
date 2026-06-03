{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

# UID と GUI が固定なのがなんだかな。
let
  # 1. コンテナ内に配置する設定ファイルを定義する
  claudeSettings = pkgs.writeTextDir "home/devuser/.claude/settings.json" ''
    {
      "$schema": "https://json.schemastore.org/claude-code-settings.json",
      "permissions": { "defaultMode": "bypassPermissions" },
      "attribution": { "commit": "", "pr": "" },
      "enabledPlugins": {
        "superpowers@claude-plugins-official": true,
        "code-review@claude-plugins-official": true,
        "code-simplifier@claude-plugins-official": true,
        "commit-commands@claude-plugins-official": true,
        "ralph-loop@claude-plugins-official": true,
        "claude-md-management@claude-plugins-official": true,
        "feature-dev@claude-plugins-official": true,
        "serena@claude-plugins-official": true,
        "agent-sdk-dev@claude-plugins-official": true,
        "plugin-dev@claude-plugins-official": true,
        "skill-creator@claude-plugins-official": true,
        "clangd-lsp@claude-plugins-official": true
      },
      "effortLevel": "medium"
    }
  '';

  claudeMd = pkgs.writeTextDir "home/devuser/.claude/CLAUDE.md" ''
    ## gstack
    For all web browsing, ALWAYS use the `/browse` skill from gstack.
    NEVER use `mcp__claude-in-chrome__*` tools.

    **Available gstack skills:**
    /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review, /design-consultation, /review, /ship, /land-and-deploy, /canary, /benchmark, /browse, /qa, /qa-only, /design-review, /setup-browser-cookies, /setup-deploy, /retro, /investigate, /document-release, /codex, /cso, /autoplan, /careful, /freeze, /guard, /unfreeze, /gstack-upgrade
  '';

  # 2. 必要なパッケージをまとめる
  envPackages = with pkgs; [
    # 基本ツール
    bashInteractive
    coreutils
    wget
    curl
    git
    gnumake
    gcc
    unzip
    gnupg
    sudo
    tzdata
    cmake
    ninja
    python3

    # 言語ランタイムとツール
    nodejs_20
    bun

    # Claude Code 関係
    claude-code
    claude-monitor
    claude-code-router

    # 設定ファイルの組み込み
    claudeSettings
    claudeMd
  ];

in
pkgs.dockerTools.buildLayeredImage {
  name = "claude-code-base";
  tag = "latest";

  contents = envPackages;

  # 3. ルート権限での初期化処理 (ディレクトリとユーザー作成)
  fakeRootCommands = ''
    # 作業ディレクトリの作成
    mkdir -p /workdir
    chmod 777 /workdir

    # ユーザーとグループの静的作成 (UID:1000, GID:1000 をデフォルトとする)
    mkdir -p /etc
    echo "root:x:0:0:System administrator:/root:/bin/bash" > /etc/passwd
    echo "devuser:x:1000:1000:Developer:/home/devuser:${pkgs.zsh}/bin/zsh" >> /etc/passwd
    echo "root:x:0:" > /etc/group
    echo "devuser:x:1000:" >> /etc/group
    echo "root:x::" > /etc/shadow

    # ホームディレクトリと必要なパスの作成、権限変更
    mkdir -p /home/devuser/.claude/skills
    chown -R 1000:1000 /home/devuser
  '';

  # 4. コンテナ実行時のメタデータ
  config = {
    User = "devuser";
    WorkingDir = "/workdir";
    Env = [
      "TZ=Asia/Tokyo"
      "PATH=/home/devuser/.bun/bin:/home/devuser/.local/bin:${pkgs.bun}/bin:${pkgs.nodejs_20}/bin:${pkgs.python3}/bin:${pkgs.git}/bin:${pkgs.curl}/bin:${pkgs.zsh}/bin:/bin:/usr/bin"
    ];
    Cmd = [ "${pkgs.zsh}/bin/zsh" ];
  };
}
