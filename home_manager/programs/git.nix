{
  config,
  lib,
  pkgs,
  user,
  ...
}: {
  programs.git = {
    enable = true;

    signing = with config.programs.gpg; {
      signByDefault = enable;
      key = settings.default-key;
      format = "openpgp";
    };
    settings = {
      user = {
        name = user.fullname;
      };
      alias = let
        difft = lib.getExe pkgs.difftastic;
        col = colour: content: "%C(${colour})${content}%C(reset)";
        fmtl = lib.concatStringsSep " " [
          (col "yellow" "%h")
          (col "bold cyan" "%ad")
          (col "blue" "%aL")
          "%s${col "auto" "%d"}"
        ];
        fmtll = lib.concatStringsSep " " [
          (col "yellow" "%h")
          (col "bold cyan" "%aD")
          "${col "bold green" "(%ar)"}${col "auto" "%d"}%n"
          "      " # pad to abbrev-commit minimum length
          (col "white" "%s")
          (col "dim white" "- %an [%aL]")
        ];
      in {
        bc = "branch-clean";
        branch-clean = ''
          !f() {
            flag=-d
            for option in "$@"; do
              if [ "$option" = '-f' ]; then
                flag=-D
              fi
            done
            current=$(git symbolic-ref --quiet --short HEAD || :)
            git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads |
              while IFS=' ' read -r branch tracking; do
                if [ "$tracking" = '[gone]' ] && [ "$branch" != "$current" ]; then
                  git branch "$flag" -- "$branch"
                fi
              done
          }
          f
        '';
        ci = "commit";
        co = "checkout";
        d = "-c diff.external=${difft} diff";
        ds = "-c diff.external=${difft} diff --staged";
        l = lib.concatStringsSep " " [
          "log"
          "--pretty=format:\"${fmtl}\""
          "--date=short"
          "--decorate"
          "--graph"
        ];
        ld = "-c diff.external=${difft} log -p --ext-diff";
        ll = lib.concatStringsSep " " [
          "log"
          "--format=format:\"${fmtll}\""
          "--abbrev-commit"
          "--decorate"
          "--graph"
        ];
      };

      pull.rebase = true;
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      log.mailmap = true;
      advice = {
        forceDeleteBranch = false;
        skippedCherryPicks = false;
      };
      credential.helper = "cache --timeout=${toString (60 * 60 * 8)}";
    };

    includes = [
      {path = config.sops.templates.git.path;}
    ];
  };
}
