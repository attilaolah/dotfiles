final: prev: {
  host-tls-certificate = prev.writeShellApplication {
    name = "host-tls-certificate";
    runtimeInputs = with prev; [
      coreutils
      step-cli
    ];
    text = ''
      if [ "$#" -ne 2 ]; then
        echo "usage: host-tls-certificate TLS_DIRECTORY GROUP" >&2
        exit 64
      fi

      tls_directory="$1"
      tls_group="$2"
      certificate="$tls_directory/crt.pem"
      private_key="$tls_directory/key.pem"

      umask 077
      install -d -m 0755 -o root -g "$tls_group" "$tls_directory"

      certificate_matches_key() {
        printf '%s' 'certificate key match' |
          step crypto jws sign --key "$private_key" --alg ES256 |
          step crypto jws verify --key "$certificate" >/dev/null
      }

      if [ ! -s "$private_key" ] || [ ! -s "$certificate" ] \
        || step certificate needs-renewal "$certificate" --expires-in 720h >/dev/null 2>&1 \
        || ! step certificate verify "$certificate" --host localhost --roots "$certificate" >/dev/null 2>&1 \
        || ! certificate_matches_key; then
        temporary_directory="$(mktemp -d "$tls_directory"/.generate.XXXXXX)"
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

        install -m 0640 -o root -g "$tls_group" "$temporary_directory/key.pem" "$private_key"
        install -m 0644 -o root -g "$tls_group" "$temporary_directory/crt.pem" "$certificate"
        rm -rf "$temporary_directory"
        trap - EXIT
      fi

      chown root:"$tls_group" "$private_key" "$certificate"
      chmod 0640 "$private_key"
      chmod 0644 "$certificate"
    '';
  };
}
