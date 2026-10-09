{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  tlsDirectory = "/var/lib/tls";
  certificate = "${tlsDirectory}/crt.pem";
  privateKey = "${tlsDirectory}/key.pem";
  trustBundle = "${tlsDirectory}/ca-certificates.crt";
  trustSource = "${tlsDirectory}/trust-source";

  cacertPackage = pkgs.cacert.override {
    blacklist = config.security.pki.caCertificateBlacklist;
    extraCertificateFiles = config.security.pki.certificateFiles;
    extraCertificateStrings = config.security.pki.certificates;
  };

  tlsCertificate = pkgs.writeShellApplication {
    name = "generate-host-tls-certificate";
    runtimeInputs = with pkgs; [
      coreutils
      step-cli
    ];
    text = ''
      umask 077
      install -d -m 0755 -o root -g tls ${tlsDirectory}

      certificate_matches_key() {
        printf '%s' 'certificate key match' |
          step crypto jws sign --key ${privateKey} --alg ES256 |
          step crypto jws verify --key ${certificate} >/dev/null
      }

      if [[ ! -s ${privateKey} || ! -s ${certificate} ]] \
        || step certificate needs-renewal ${certificate} --expires-in 720h >/dev/null 2>&1 \
        || ! step certificate verify ${certificate} --host localhost --roots ${certificate} >/dev/null 2>&1 \
        || ! certificate_matches_key; then
        temporary_directory="$(mktemp -d ${tlsDirectory}/.generate.XXXXXX)"
        trap 'rm -rf "$temporary_directory"' EXIT

        step certificate create localhost \
          "$temporary_directory/crt.pem" \
          "$temporary_directory/key.pem" \
          --profile self-signed \
          --subtle \
          --no-password \
          --insecure \
          --kty EC \
          --curve P-256 \
          --not-after 19800h \
          --san '*.localhost' \
          --san localhost \
          --san 127.0.0.1 \
          --san ::1

        install -m 0640 -o root -g tls "$temporary_directory/key.pem" ${privateKey}
        install -m 0644 -o root -g tls "$temporary_directory/crt.pem" ${certificate}
        rm -rf "$temporary_directory"
        trap - EXIT
      fi

      chown root:tls ${privateKey} ${certificate}
      chmod 0640 ${privateKey}
      chmod 0644 ${certificate}

      temporary_bundle="$(mktemp ${tlsDirectory}/.ca-certificates.XXXXXX)"
      cat ${config.security.pki.caBundle} ${certificate} > "$temporary_bundle"
      install -m 0644 -o root -g root "$temporary_bundle" ${trustBundle}
      rm -f "$temporary_bundle"

      install -d -m 0755 -o root -g root ${trustSource}/anchors
      ln -sfn ${cacertPackage.p11kit}/etc/ssl/trust-source/ca-bundle.trust.p11-kit \
        ${trustSource}/ca-bundle.trust.p11-kit
      ln -sfn ${certificate} ${trustSource}/anchors/tls.pem
    '';
  };
in {
  # This group is intentionally empty.
  # Services that need a private key can opt in explicitly. The primary managed user must not be able to read it.
  users.groups.tls.members = [];

  assertions = [
    {
      assertion = !(lib.elem "tls" config.users.users.${user.username}.extraGroups);
      message = "${user.username} must not be a member of the tls group";
    }
    {
      assertion = !(lib.elem user.username config.users.groups.tls.members);
      message = "${user.username} must not be listed in the tls group";
    }
  ];

  # Generate the key on the host so it never enters the world-readable Nix store.
  # Keep the certificate stable across rebuilds, renewing it shortly before expiry.
  system.activationScripts.tlsCertificate = {
    deps = ["users"];
    text = lib.getExe tlsCertificate;
  };

  # Use the generated bundle as the machine-wide OpenSSL trust store.
  environment.etc = {
    "ssl/certs/ca-certificates.crt".source = lib.mkForce trustBundle;
    "ssl/certs/ca-bundle.crt".source = lib.mkForce trustBundle;
    "ssl/trust-source".source = lib.mkForce trustSource;
    "pki/tls/certs/ca-bundle.crt".source = lib.mkForce trustBundle;
    "tls/crt.pem".source = certificate;
    "tls/key.pem".source = privateKey;
  };
}
