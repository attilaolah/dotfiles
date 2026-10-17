final: prev: let
  github-tags = ["yetidevworks/bosun" "2.2.2"]; # extractVersion=^v(?<version>.*)$
  hash-src = "sha256-6zM4Nafo99oUTpYrKla1jG3G7wNIW9IAdpDmQlj9wHk=";
  hash-cargo-deps = "sha256-8p1HVd4Xdwpkw4oK3szZHB2HTpWzkDKmjCVg5QUUe0U=";
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

    meta = {
      description = "Tmux-native orchestrator for AI agent sessions";
      homepage = "https://github.com/yetidevworks/bosun";
      license = prev.lib.licenses.mit;
      mainProgram = "bosun";
    };
  };
}
