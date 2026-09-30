final: prev: let
  inherit (builtins) elemAt;

  # The CLI is distributed only as release binaries.
  # Renovate reads this tuple and updates the version from the release channel.
  coderabbit-cli = ["coderabbit-cli" "0.8.2"];
  version = elemAt coderabbit-cli 1;

  # Keep these as top-level `hash-*` variables (not inlined in `sources`):
  # `.github/workflows/renovate_overlay_hashes.yaml` parses and rewrites them.
  hash-src-aarch64-darwin = "sha256-YJHQMWS0cZC027IN6XMS95veA/w1tLfCcF+PTTuoBn4=";
  hash-src-x86_64-linux = "sha256-pjREhRU8WInJG65x2RcsDS19OSSkVmEXMDDihXC7e7I=";

  sources = prev.lib.mapAttrs (system: source:
    prev.fetchurl (source
      // {
        url = let
          platform = import ./lib/platform.nix system;
        in "https://cli.coderabbit.ai/releases/${version}/coderabbit-${platform.os}-${platform.arch}.zip";
      })) {
    aarch64-darwin.hash = hash-src-aarch64-darwin;
    x86_64-linux.hash = hash-src-x86_64-linux;
  };
in {
  coderabbit = prev.stdenvNoCC.mkDerivation {
    pname = "coderabbit";
    inherit version;

    src =
      sources.${prev.stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${prev.stdenv.hostPlatform.system}");
    dontUnpack = true;
    nativeBuildInputs = with prev; [
      autoPatchelfHook
      unzip
    ];
    buildInputs = [prev.glibc];

    installPhase = ''
      runHook preInstall

      install -d $out/bin
      unzip -q $src -d $out/bin
      ln -s coderabbit $out/bin/cr

      runHook postInstall
    '';

    passthru = {inherit sources;};

    meta = {
      description = "CodeRabbit AI code-review CLI";
      homepage = "https://www.coderabbit.ai/cli";
      license = prev.lib.licenses.unfreeRedistributable;
      mainProgram = "coderabbit";
      platforms = builtins.attrNames sources;
    };
  };
}
