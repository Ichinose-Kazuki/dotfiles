inputs@{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

# let
#   claude-code-base = ./claude-code-base.nix inputs;
# in
{
  config = lib.mkIf (osConfig.myModule.hostName == "x1carbon") {
    # # ユーザーレベルの systemd サービスとして docker load を実行
    # systemd.user.services.load-claude-code-base-image = {
    #   Unit = {
    #     Description = "Load Claude Code base image into Docker daemon";
    #     After = [ "docker.service" ];
    #   };
    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    #   Service = {
    #     Type = "oneshot";
    #     RemainAfterExit = true;
    #     # 登録処理のみを実行
    #     ExecStart = "${pkgs.docker}/bin/docker load -i ${claude-code-base}";
    #   };
    # };
    home.packages = with pkgs; [
      claude-code
    ];
  };
}
