final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.8"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-phhAwKtDzFrG1m9Jcc51RPLYW3xz3EqeUM1zYes9M6c=";
  hash-cargo-deps = "sha256-lniEIp22CJjnBBBw/YOp4csQt5fCJjAPTUDEGIh9OlI=";
  version = builtins.elemAt github-tags 1;
in {
  bosun = prev.rustPlatform.buildRustPackage {
    pname = "bosun";
    inherit version;

    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    cargoHash = hash-cargo-deps;
    nativeCheckInputs = [prev.git];

    patches = [./bosun/encode-escape-as-csi-u.patch];

    meta = {
      description = "Tmux-native orchestrator for AI agent sessions";
      homepage = "https://github.com/yetidevworks/bosun";
      license = prev.lib.licenses.mit;
      mainProgram = "bosun";
    };
  };
}
