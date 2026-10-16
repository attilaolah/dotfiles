final: prev: let
  github-tags = ["blackwell-systems/gcf-proxy" "0.11.5"];
  hash-src = "sha256-BLBl4GtQVBcM7JOy0MKMn2ukFHWBORgpCAgrxD/Igxo=";
  hash-vendor = "sha256-qfhhmjcsNuSeDCXyHBgz4bWc0aJvlgkPATm1+T7nHJg=";
  version = builtins.elemAt github-tags 1;
in {
  gcf-proxy = prev.buildGoModule {
    pname = "gcf-proxy";
    inherit version;

    src = import ./lib/fetch_from_github_tuple.nix prev {
      inherit github-tags hash-src;
      rev = "v${version}";
    };

    vendorHash = hash-vendor;
    meta.mainProgram = "gcf-proxy";
  };
}
