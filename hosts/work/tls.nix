{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  tlsDirectory = "/var/db/tls";
  certificate = "${tlsDirectory}/crt.pem";
  keychainFingerprint = "${tlsDirectory}/system-keychain-cert.sha256";
  systemKeychain = "/Library/Keychains/System.keychain";

  tlsCertificate = pkgs.writeShellApplication {
    name = "generate-host-tls";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      host-tls
      step-cli
    ];
    text = ''
      # The group is managed by nix-darwin,
      # but tolerate a missing local user or directory-service group during recovery activations.
      if /usr/sbin/dseditgroup -o checkmember -m ${lib.escapeShellArg user.username} tls 2>/dev/null |
        grep -q '^yes'; then
        /usr/sbin/dseditgroup -o edit -d ${lib.escapeShellArg user.username} -t user tls 2>/dev/null || true
      fi

      host-tls ${lib.escapeShellArg tlsDirectory} ${lib.escapeShellArg "tls"}

      certificate_fingerprint="$(step certificate fingerprint ${certificate} --format hex)"

      # Delete only the previous fingerprint that this activation recorded and the exact current leaf.
      # Never select certificates by common name: a System keychain can contain unrelated certificates.
      if [ -r ${keychainFingerprint} ]; then
        previous_fingerprint="$(cat ${keychainFingerprint})"
        if [ "$previous_fingerprint" != "$certificate_fingerprint" ]; then
          security delete-certificate -Z "$previous_fingerprint" ${systemKeychain} 2>/dev/null || true
        fi
      fi
      security delete-certificate -Z "$certificate_fingerprint" ${systemKeychain} 2>/dev/null || true

      # Reinstalling the exact leaf ensures a matching but untrusted keychain entry cannot prevent the
      # System trust setting from being applied.
      security add-trusted-cert -d -r trustRoot -k ${systemKeychain} ${certificate}
      temporary_fingerprint="$(mktemp ${tlsDirectory}/.system-keychain-cert.XXXXXX)"
      printf '%s\n' "$certificate_fingerprint" > "$temporary_fingerprint"
      install -m 0600 -o root -g wheel "$temporary_fingerprint" ${keychainFingerprint}
      rm -f "$temporary_fingerprint"
    '';
  };
in {
  # Keep the TLS key readable only by root and services explicitly added.
  # The empty member list also prevents the managed desktop user reading it.
  users.groups.tls = {
    description = "Readers of host TLS private keys";
    members = [];
  };

  assertions = [
    {
      assertion = !(lib.elem user.username config.users.groups.tls.members);
      message = "${user.username} must not be listed in the tls group";
    }
  ];

  # The key and leaf certificate are generated locally rather than copied from the Nix store.
  # This produces a separate, self-signed leaf for the host.
  system.activationScripts.tlsCertificate = {
    deps = ["users"];
    text = lib.getExe tlsCertificate;
  };
}
