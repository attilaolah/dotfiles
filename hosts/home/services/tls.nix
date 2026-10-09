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
    name = "generate-host-tls";
    runtimeInputs = with pkgs; [
      coreutils
      host-tls
    ];
    text = ''
      host-tls ${lib.escapeShellArg tlsDirectory} ${lib.escapeShellArg "tls"}

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
