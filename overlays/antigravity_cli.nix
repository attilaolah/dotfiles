final: prev: let
  github-tags = ["google-antigravity/antigravity-cli" "1.4.12"];
  hash-src-aarch64-darwin = "sha256-TJibXM8OOcmaHObfgkEKu2KNTYPg0xg1J3At90TZxYk=";
  hash-src-aarch64-linux = "sha256-MN1h6+HwqIKQV+ot4p2tCMcQ3Zcs5MApSfUeYyE1qGs=";
  hash-src-x86_64-darwin = "sha256-Yk0BNp31hB9kVVdB3QnTq0ptF0aZpN7YlqUYDIHywt4=";
  hash-src-x86_64-linux = "sha256-M2jRkj/IafIeyPzoMlKoyWyJKDqsk5OViskfv3o5SeQ=";
  version = builtins.elemAt github-tags 1;
in {
  antigravity-cli = prev.antigravity-cli.overrideAttrs (old: let
    sources = prev.lib.mapAttrs (system: source:
      prev.fetchurl (source
        // {
          url = let
            platform = import ./lib/platform.nix system;
          in "https://github.com/google-antigravity/antigravity-cli/releases/download/${version}/agy_cli_${platform.platform}_${platform.arch}.tar.gz";
        })) {
      x86_64-linux.hash = hash-src-x86_64-linux;
      aarch64-linux.hash = hash-src-aarch64-linux;
      aarch64-darwin.hash = hash-src-aarch64-darwin;
      x86_64-darwin.hash = hash-src-x86_64-darwin;
    };
  in {
    inherit version;
    src =
      sources.${prev.stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${prev.stdenv.hostPlatform.system}");
    sourceRoot = ".";
    passthru = (old.passthru or {}) // {inherit sources;};
  });
}
