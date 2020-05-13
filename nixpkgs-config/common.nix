{ pkgs, config, lib, ... }:

{
  options.python.packages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = ''
      Names of python packages to install
    '';
  };

  imports = [
    #./vim.nix
    ./emacs
  ];

  config = {
    python.packages = [
      "pyls-mypy"
      "pyls-isort"
      "pyls-black"
    ];

    home.packages = with pkgs; [
      #(pkgs.callPackage /home/joerg/git/nix-review {})
      nur.repos.mic92.nixpkgs-review-unstable
      nur.repos.mic92.mosh-ssh-agent
      nix-prefetch

      gdb
      hexyl
      strace
      binutils
      clang-tools
      grc

      # python language server + plugins
      (pkgs.python3.withPackages (ps: lib.attrVals config.python.packages ps))
      #rls

      tmux
      htop
      psmisc
      gitAndTools.hub
      gitAndTools.tig
      tokei
      direnv
      nix-direnv
      fzf
      exa
      fd
      bat
      vivid
      silver-searcher
      zsh
      glibcLocales
      less
      bashInteractive
      gnupg
      ncurses
    ];

    home.stateVersion = "18.09";
    programs.home-manager.enable = true;
  };
}
