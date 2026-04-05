#!/usr/bin/env bash

# -----------------------------------------
# 設定
# -----------------------------------------
# 内蔵モニター名（hyprctl monitorsで確認）
INTERNAL_MON="eDP-1"

# 依存コマンドのチェック
if ! command -v jq &> /dev/null || ! command -v socat &> /dev/null; then
    echo "Error: 'jq' and 'socat' are required."
    exit 1
fi

# -----------------------------------------
# 関数定義
# -----------------------------------------

# 外部モニターをカウントする関数
count_externals() {
    # jqで内蔵モニターを除外して名前を抽出し、行数をカウント
    hyprctl monitors -j | jq -r '.[] | select(.name != "'$INTERNAL_MON'") | .name' | wc -l
}

# 内蔵モニターをオフ
disable_internal() {
    echo "Detecting 2+ external monitors. Disabling internal ($INTERNAL_MON)..."
    hyprctl keyword monitor "$INTERNAL_MON,disable"
}

# 内蔵モニターをオン
enable_internal() {
    echo "Detecting <2 external monitors. Enabling internal ($INTERNAL_MON)..."
    # 解像度は環境に合わせて調整してください（例: preferred, highrr, auto, 1 など）
    hyprctl keyword monitor "$INTERNAL_MON,preferred,auto,1"
}

# 状態をチェックして適用するメインロジック
update_monitor_state() {
    # 変更が反映されるまで一瞬待つ（重要）
    sleep 0.5

    local external_count=$(count_externals)
    echo "External monitors count: $external_count"

    if [[ $external_count -ge 2 ]]; then
        disable_internal
    else
        enable_internal
    fi
}

# -----------------------------------------
# メイン処理
# -----------------------------------------

# 初期実行（スクリプト起動時にも現在の状態をチェック）
update_monitor_state

# IPCソケットパスの特定
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

echo "Listening for events on $SOCKET..."

# イベント監視ループ
socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    # "monitoradded>>" で始まる行かどうかを判定
    if [[ "$line" == "monitoradded>>"* ]] || [[ "$line" == "monitorremoved>>"* ]]; then

        # イベント内容を表示（デバッグ用）
        echo "Event received: $line"

        # 状態チェック関数を呼ぶ
        update_monitor_state
    fi
done
