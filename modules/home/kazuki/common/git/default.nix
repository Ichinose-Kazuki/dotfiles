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
        email = "ichinose-kazuki657@g.ecc.u-tokyo.ac.jp";
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
            email = "kazuking.ichinose@gmail.com";
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
