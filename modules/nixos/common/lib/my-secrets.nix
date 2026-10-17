{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;

  envFiles = config.mySecrets.envFiles;
  names = map (file: file.name) envFiles;

  templates = map (
    file:
    pkgs.writeText "my-secret-${file.name}" (
      "${file.commentDelimBegin} "
      + file.comment
      + " ${file.commentDelimEnd}"
      + "\n"
      + lib.concatMapStringsSep "\n" (var: "${var}=''") file.vars
      + "\n"
    )
  ) envFiles;

  entries = lib.zipListsWith (file: template: { inherit file template; }) envFiles templates;

  createFiles = lib.concatMapStringsSep "\n" (
    entry:
    let
      path = "/etc/my-secrets/${entry.file.name}";
    in
    ''
      if [ ! -e "${path}" ] && [ ! -L "${path}" ]; then
        ${pkgs.coreutils}/bin/install \
          -o root -g root -m 0600 \
          "${entry.template}" "${path}"
      fi
    ''
  ) entries;

in
{
  options.mySecrets.envFiles = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "env ファイル名";
          };

          vars = mkOption {
            type = types.listOf types.str;
            description = "環境変数名の一覧";
          };

          comment = mkOption {
            type = types.str;
            description = "ファイル先頭のコメント";
          };

          commentDelimBegin = mkOption {
            type = types.str;
            description = "コメント開始文字列";
            default = "#";
          };
          commentDelimEnd = mkOption {
            type = types.str;
            description = "コメント終了文字列";
            default = "";
          };
        };
      }
    );
    default = [ ];
  };

  config = {
    assertions = [
      {
        assertion = builtins.length names == builtins.length (lib.unique names);
        message = "mySecrets: env ファイル名が重複しています";
      }
      {
        assertion = lib.all (
          file: builtins.match "[A-Za-z0-9_-][A-Za-z0-9._-]*" file.name != null
        ) envFiles;
        message = "mySecrets: 不正な env ファイル名です";
      }
      {
        assertion = lib.all (
          file: lib.all (var: builtins.match "[A-Za-z_][A-Za-z0-9_]*" var != null) file.vars
        ) envFiles;
        message = "mySecrets: 不正な環境変数名です";
      }
    ];

    system.activationScripts = lib.mkIf (envFiles != [ ]) {
      mySecrets.text = ''
        ${pkgs.coreutils}/bin/install \
          -d -o root -g root -m 0700 /etc/my-secrets

        ${createFiles}
      '';
    };
  };
}
