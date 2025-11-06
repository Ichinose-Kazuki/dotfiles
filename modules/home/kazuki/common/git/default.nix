{
  config,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;
    settings = {
      alias = {
        ci = "commit";
        cm = "commit -m";
        cam = "commit -am";
        co = "checkout";
        br = "branch";
        pl = "pull";
        ps = "push";
        st = "status";
        df = "diff";
        lg = "log";
      };
      user = {
        email = "mail@ichinose-kazuki.jp";
        name = "Ichinose-Kazuki";
      };
      init = {
        defaultBranch = "main";
      };
    };

    # Settings for ikazuk repositories
    includes = [
      {
        condition = "gitdir:~/ikazuk/";
        contents = {
          user = {
            email = "ikazuk@proton.me";
            name = "ikazuk";
          };
        };
      }
    ];
  };

  # Syntax-highlighting diff viewer
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
