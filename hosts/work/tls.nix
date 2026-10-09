{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  tlsDirectory = "/var/db/tls";
  certificate = "${tlsDirectory}/cert.pem";
  privateKey = "${tlsDirectory}/key.pem";
  keychainFingerprint = "${tlsDirectory}/system-keychain-cert.sha256";
  hostname = config.networking.hostName;
  systemKeychain = "/Library/Keychains/System.keychain";

  tlsCertificate = pkgs.writeShellApplication {
    name = "generate-host-tls-certificate";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      step-cli
    ];
    text = ''
      umask 077
      install -d -m 0755 -o root -g tls ${tlsDirectory}

      # The group is managed by nix-darwin, but tolerate a missing local user or directory-service group during
      # recovery activations.
      if /usr/sbin/dseditgroup -o checkmember -m ${lib.escapeShellArg user.username} tls 2>/dev/null |
        grep -q '^yes'; then
        /usr/sbin/dseditgroup -o edit -d ${lib.escapeShellArg user.username} -t user tls 2>/dev/null || true
      fi

      certificate_matches_key() {
        printf '%s' 'certificate key match' |
          step crypto jws sign --key ${privateKey} --alg ES256 |
          step crypto jws verify --key ${certificate} >/dev/null
      }

      if [ ! -s ${privateKey} ] || [ ! -s ${certificate} ] \
        || ! step certificate verify ${certificate} --host ${hostname} --roots ${certificate} >/dev/null 2>&1 \
        || step certificate needs-renewal ${certificate} --expires-in 720h >/dev/null 2>&1 \
        || ! certificate_matches_key; then
        temporary_directory="$(mktemp -d ${tlsDirectory}/.generate.XXXXXX)"
        trap 'rm -rf "$temporary_directory"' EXIT

        step certificate create ${hostname} "$temporary_directory/cert.pem" "$temporary_directory/key.pem" \
          --profile self-signed \
          --subtle \
          --no-password \
          --insecure \
          --kty EC \
          --curve P-256 \
          --not-after 19800h \
          --san ${hostname} \
          --san ${hostname}.local \
          --san localhost \
          --san 127.0.0.1 \
          --san ::1

        install -m 0640 -o root -g tls "$temporary_directory/key.pem" ${privateKey}
        install -m 0644 -o root -g tls "$temporary_directory/cert.pem" ${certificate}
        rm -rf "$temporary_directory"
        trap - EXIT
      fi

      chown root:tls ${privateKey} ${certificate}
      chmod 0640 ${privateKey}
      chmod 0644 ${certificate}

      certificate_fingerprint="$(step certificate fingerprint ${certificate} --format hex)"

      # Delete only the previous fingerprint that this activation recorded and the exact current leaf. Never select
      # certificates by common name: a System keychain can contain unrelated certificates for this hostname.
      if [ -r ${keychainFingerprint} ]; then
        previous_fingerprint="$(cat ${keychainFingerprint})"
        if [ "$previous_fingerprint" != "$certificate_fingerprint" ]; then
          /usr/bin/security delete-certificate -Z "$previous_fingerprint" ${systemKeychain} 2>/dev/null || true
        fi
      fi
      /usr/bin/security delete-certificate -Z "$certificate_fingerprint" ${systemKeychain} 2>/dev/null || true

      # Reinstalling the exact leaf ensures a matching but untrusted keychain entry cannot prevent the System trust
      # setting from being applied.
      /usr/bin/security add-trusted-cert -d -r trustRoot -k ${systemKeychain} ${certificate}
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
  # This produces a separate, self-signed leaf for this host.
  system.activationScripts.tlsCertificate = {
    deps = ["users"];
    text = lib.getExe tlsCertificate;
  };
}
