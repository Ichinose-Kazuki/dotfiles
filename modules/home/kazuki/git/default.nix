{ config
, pkgs
, ...
}:

{
  programs.git = {
    enable = true;
    userEmail = "ichinose-kazuki657@g.ecc.u-tokyo.ac.jp";
    userName = "Ichinose-Kazuki";
    delta.enable = true;

    # Settings for ikazuk repositories
    includes = [{
      condition = "gitdir:~/ikazuk/";
      contents = {
        user = {
          email = "kazuking.ichinose@gmail.com";
          name = "ikazuk";
        };
      };
    }];
  };
}
