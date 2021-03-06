{ pkgs, lib, config, ... }:

with lib;

let
  myemacs = config.programs.emacs.package;
  editorScript =
    { name ? "emacseditor"
    , x11 ? false
    , extraArgs ? [ ]
    }: pkgs.writeScriptBin name ''
      #!${pkgs.runtimeShell}
      export TERM=xterm-direct
      # breaks clipetty in combination with tmux + mosh? https://github.com/spudlyo/clipetty/pull/22
      unset SSH_TTY
      exec -a emacs ${myemacs}/bin/emacsclient \
        --create-frame \
        --alternate-editor ${myemacs}/bin/emacs \
        ${optionalString (!x11) "-nw"} \
        ${toString extraArgs} "$@"
    '';

  daemonScript = pkgs.writeScript "emacs-daemon" ''
    #!${pkgs.zsh}/bin/zsh
    source ~/.zshrc
    export BW_SESSION=1 PATH=$PATH:${lib.makeBinPath [ pkgs.git pkgs.sqlite pkgs.unzip ]}
    exec ${myemacs}/bin/emacs --daemon
  '';

  editorScriptX11 = editorScript { name = "emacs"; x11 = true; };
in
{
  home.file.".emacs.d/init.el".text = lib.mkBefore ''
    (load "${pkgs.fetchFromGitHub {
      owner = "seanfarley";
      repo = "emacs-bitwarden";
      rev = "e03919ca68c32a8053ddea2ed05ecc5e454d8a43";
      sha256 = "sha256-ooLgOwpJX9dgkWEev9xmPyDVPRx4ycyZQm+bggKAfa0=";
    }}/bitwarden.el")
  '';

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ../../../home/.doom.d;
    emacsPackagesOverlay = self: super: with pkgs; {
      tsc = super.tsc.overrideAttrs (old:
        let
          libtsc_dyn = rustPlatform.buildRustPackage rec {
            pname = "emacs-tree-sitter";
            version = "0.13.1";
            src = fetchFromGitHub {
              owner = "ubolonton";
              repo = "emacs-tree-sitter";
              rev = version;
              sha256 = "sha256-m6hL7HK0fVAcaYaqS/fLaGH686e1jTjos51UdJgNguc=";
            };
            preBuild = ''
              export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
                $(< ${stdenv.cc}/nix-support/libc-cflags) \
                $(< ${stdenv.cc}/nix-support/cc-cflags) \
                $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
                ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
                ${lib.optionalString stdenv.cc.isGNU
                  "-isystem ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include/"} \
                ${lib.optionalString stdenv.cc.isGNU
                  "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config}"} \
                $NIX_CFLAGS_COMPILE"
            '';
            LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
            cargoHash = "sha256-UHuosX4MnZMvgRzr6Hc4RNafP0UCYknTxjPIJvYnXkU=";
          };
        in
        {
          inherit (libtsc_dyn) src;
          preBuild = ''
            ext=${stdenv.hostPlatform.extensions.sharedLibrary}
            dest=$out/share/emacs/site-lisp/elpa/tsc-${old.version}
            install -D ${libtsc_dyn}/lib/libtsc_dyn$ext $dest/tsc-dyn$ext
            echo -n "0.13.1" > $dest/DYN-VERSION
          '';
        });
    };

    extraPackages = [
      pkgs.mu
      # we cannot override the straight.el-build here because it will discard our grammars from $out/bin/*.so
      #(with pkgs; stdenv.mkDerivation rec {
      #  pname = "tree-sitter-langs";
      #  version = "0.9.2";
      #  src = fetchFromGitHub {
      #    owner = "ubolonton";
      #    repo = "tree-sitter-langs";
      #    rev = "fcd267f5d141b0de47f0da16306991ece93100a1";
      #    sha256 = "sha256-WwAy986QQ4zqbdWdMfm7QooGkLVa0uPFtAZm7RxFLUw=";
      #    fetchSubmodules = true;
      #  };
      #  nativeBuildInputs = [ tree-sitter nodejs emacs ];

      #  # mock git executable
      #  postPatch = ''
      #    cat > git <<'EOF'
      #    #!${runtimeShell}
      #    if [[ "$1" == submodule && "$2" == status ]]; then
      #      # simulate synchronized submodule
      #      echo " "
      #      exit 0
      #    fi
      #    ${git}/bin/git "$@"
      #    exit 0
      #    EOF
      #    export PATH=$(pwd):$PATH
      #    chmod +x git

      #    git init .
      #  '';

      #  buildPhase = ''
      #    runHook preBuild
      #    HOME=$TMPDIR emacs -L . --batch --eval "(progn (require 'tree-sitter-langs-build) (tree-sitter-langs-create-bundle))"
      #    runHook postBuild
      #  '';
      #  installPhase = ''
      #    runHook preInstall
      #    dest=$out/share/emacs/site-lisp/elpa/tree-sitters-langs
      #    install -D --target $dest *.el
      #    mkdir -p $dest/bin
      #    tar -C $dest/bin -xf tree-sitter-grammars-linux-${version}.tar.gz
      #    runHook postInstall
      #  '';
      #})
    ];
  };

  home.packages = with pkgs; [
    (lib.hiPrio editorScriptX11)
    ripgrep
    (lib.hiPrio (makeDesktopItem {
      name = "emacs";
      desktopName = "Emacs (Client)";
      exec = "${editorScriptX11}/bin/emacs %F";
      icon = "emacs";
      genericName = "Text Editor";
      comment = "Edit text";
      categories = "Development;TextEditor;Utility";
      mimeType = "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++";
    }))

    (lib.hiPrio (makeDesktopItem {
      name = "emacs-mailto";
      desktopName = "Emacs (MailTo)";
      # %u contains single quotes
      exec = ''${editorScriptX11}/bin/emacs --eval "(browse-url (replace-regexp-in-string \"'\" \"\" \"%u\"))"'';
      icon = "emacs";
      genericName = "Text Editor";
      comment = "Send email with Emacs";
      categories = "Utility";
      mimeType = "x-scheme-handler/mailto";
    }))

    (editorScript {
      name = "mu4e";
      x11 = true;
      extraArgs = [ "--eval" "'(mu4e)'" ];
    })
    (editorScript { })
    gopls
    golangci-lint
    (pkgs.runCommand "gotools-${gotools.version}" { } ''
      mkdir -p $out/bin
      # skip tools colliding with binutils
      for p in ${gotools}/bin/*; do
        name=$(basename $p)
        if [[ -x "${binutils-unwrapped}/bin/$name" ]]; then
          continue
        fi
        ln -s $p $out/bin/
      done
    '')
    gotests
    reftools
    gomodifytags
    gopkgs
    impl
    godef
    gogetdoc
  ];

  systemd.user.services.emacs-daemon = {
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "forking";
      TimeoutStartSec = "10min";
      # bitwarden.el checks if that value is set,
      # we set it in our own bw wrapper internally
      Restart = "always";
      ExecStart = toString daemonScript;
    };
  };
}
