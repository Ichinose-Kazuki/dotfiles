{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-configtool
        ];
        waylandFrontend = true;
        settings.globalOptions = {
          Hotkey = {
            # トリガーキーを押すたびに切り替える
            EnumerateWithTriggerKeys = true;
            # 一時的に第1入力メソッドに切り替える
            AltTriggerKeys = "";
            # 次の入力メソッドに切り替える
            EnumerateForwardKeys = "";
            # 前の入力メソッドに切り替える
            EnumerateBackwardKeys = "";
            # 切り替え時は第1入力メソッドをスキップする
            EnumerateSkipFirst = false;
            # 入力メソッドを有効にする
            ActivateKeys = "";
            # 入力メソッドをオフにする
            DeactivateKeys = "";
            # Time limit in milliseconds for triggering modifier key shortcuts
            ModifierOnlyKeyTimeout = 250;
          };

          "Hotkey/TriggerKeys" = {
            "0" = "Control+space";
            "1" = "Zenkaku_Hankaku";
          };

          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };

          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };

          "Hotkey/PrevPage" = {
            "0" = "Up";
          };

          "Hotkey/NextPage" = {
            "0" = "Down";
          };

          "Hotkey/PrevCandidate" = {
            "0" = "Shift+Tab";
          };

          "Hotkey/NextCandidate" = {
            "0" = "Tab";
          };

          "Hotkey/TogglePreedit" = {
            "0" = "Control+Alt+P";
          };

          "Behavior" = {
            # デフォルトで有効にする
            ActiveByDefault = false;
            # フォーカス時に状態をリセット
            resetStateWhenFocusIn = "No";
            # 入力状態を共有する
            ShareInputState = "No";
            # アプリケーションにプリエディットを表示する
            PreeditEnabledByDefault = true;
            # 入力メソッドを切り替える際に入力メソッドの情報を表示する
            ShowInputMethodInformation = true;
            # フォーカスを変更する際に入力メソッドの情報を表示する
            showInputMethodInformationWhenFocusIn = false;
            # 入力メソッドの情報をコンパクトに表示する
            CompactInputMethodInformation = true;
            # 第1入力メソッドの情報を表示する
            ShowFirstInputMethodInformation = true;
            # デフォルトのページサイズ
            DefaultPageSize = 5;
            # XKB オプションより優先する
            OverrideXkbOption = false;
            # カスタム XKB オプション
            CustomXkbOption = "";
            # Force Enabled Addons
            EnabledAddons = "";
            # Force Disabled Addons
            DisabledAddons = "";
            # Preload input method to be used by default
            PreloadInputMethod = true;
            # パスワード欄に入力メソッドを許可する
            AllowInputMethodForPassword = true; # This is needed for password input on login screen.
            # パスワード入力時にプリエディットテキストを表示する
            ShowPreeditForPassword = false;
            # ユーザーデータを保存する間隔（分）
            AutoSavePeriod = 30;
          };
        };
      };
    };
  };
}
