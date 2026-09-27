final: prev: let
  version = "0.47.3";
  src = final.fetchzip {
    url = "https://files.pythonhosted.org/packages/8e/56/048e7013047c2b80c4415c6f41c3099c676da34ac914e463204f18091645/opendal-0.47.3.tar.gz";
    hash = "sha256-AvaLr5CBzOM22bDgCvVfcgrr16H/oK1tCh13JDdZPqI=";
  };
in {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyFinal: pyPrev: {
        opendal = pyPrev.opendal.overridePythonAttrs (_old: {
          inherit version src;
          cargoDeps = final.rustPlatform.importCargoLock {
            lockFile = "${src}/bindings/python/Cargo.lock";
          };
          sourceRoot = "source";
          cargoRoot = "bindings/python";
          postPatch = "";
          preInstallCheck = ''export SSL_CERT_FILE=${final.cacert}/etc/ssl/certs/ca-bundle.crt'';
          preCheck = ''cd bindings/python'';
        });
      })
    ];

  opendal = final.python3Packages.opendal;
}
