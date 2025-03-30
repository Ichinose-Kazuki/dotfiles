{ pkgs, ... }: {
  programs.wlogout = {
    enable = true;
    style =
      let
        getPath = name: "${pkgs.wlogout}/share/wlogout/icons/${name}.png";
        rawCss = builtins.readFile ./wlogout.css;
        builtinTargets = [ "shutdown" "reboot" "suspend" "hibernate" "lock" "logout" ];
        targetNames = builtinTargets ++ [ "win" ];
        targets = builtins.map (name: "@${name}@") targetNames;
        icons = builtins.map (name: getPath name) builtinTargets ++ [ "${./win.png}" ];
        # Replace the @target@ strings in the CSS with the corresponding icon paths
        css = builtins.replaceStrings targets icons rawCss;
      in
      css;
    layout = [
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "win";
        action = "${./bootwin.sh}";
        text = "Boot Windows";
        keybind = "w";
      }
    ];
  };
}
