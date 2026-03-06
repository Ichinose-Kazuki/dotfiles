{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.etc."startup-wtf-dashboard.yml".text = ''
    wtf:
      colors:
        background: "default"
        border:
          focusable: "darkslateblue"
          focused: "orange"
          normal: "gray"
      grid:
        columns: [60, -1]
        rows: [20, -1, 7]
      refreshInterval: 1

      mods:
        docker:
          enabled: true
          position:
            top: 0
            left: 0
            height: 1
            width: 1
          title: "🐳 Docker Containers"

        systemd-failed:
          type: cmdrunner
          cmd: "systemctl"
          args: ["--failed", "--no-pager"]
          enabled: true
          position:
            top: 1
            left: 0
            height: 1
            width: 1
          refreshInterval: 30
          title: "❌ Failed systemd Units"

        journal-errors:
          type: cmdrunner
          cmd: "journalctl"
          args: ["-p", "3", "-xb", "-n", "15", "--no-pager"]
          enabled: true
          position:
            top: 0
            left: 1
            height: 1
            width: 1
          refreshInterval: 60
          title: "🚨 Critical Journal Logs"

        disk-usage:
          type: cmdrunner
          cmd: "sh"
          args: ["-c", "df -h / /home && echo '\n--- BTRFS System ---' && sudo btrfs filesystem df /"]
          enabled: true
          position:
            top: 1
            left: 1
            height: 1
            width: 1
          refreshInterval: 60
          title: "💾 BTRFS & Disk Usage"

        cockpit-link:
          type: cmdrunner
          cmd: "echo"
          # 表示したいテキストを \n (改行) を使ってデザインします
          args: ["\n  🌐 Cockpit Web Console:\n\n  http://localhost:9090\n\n"]
          enabled: true
          position:
            # 配置場所（後述のグリッド設定に合わせて調整してください）
            top: 2
            left: 0
            height: 1
            width: 2  # 横幅を2列分（画面いっぱい）使う
          refreshInterval: 86400  # 固定テキストなので更新頻度は1日1回で十分
          title: "🚀 System Management"
  '';
}
