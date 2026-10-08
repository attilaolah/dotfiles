#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -lt 2 ]]; then
  echo "Usage: $0 <overlay_file> <key[[@occurrence]]=flake_output> [<key[[@occurrence]]=flake_output> ...]" >&2
  exit 1
fi

readonly OVERLAY_FILE="$1"
shift
readonly MAPPINGS=("$@")
readonly FAKE_HASH='sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='

if [[ ! -f "${OVERLAY_FILE}" || ! -r "${OVERLAY_FILE}" ]]; then
  echo "Overlay file '${OVERLAY_FILE}' does not exist or is not readable." >&2
  exit 1
fi

LOG_DIR="$(mktemp -d)"
if [[ "$?" -ne 0 || -z "${LOG_DIR}" ]]; then
  echo "Failed to create temporary log directory with mktemp -d." >&2
  exit 1
fi
readonly LOG_DIR

cleanup() {
  rm -rf "${LOG_DIR}"
}
trap cleanup EXIT

set_hash_value() {
  local key="$1"
  local occurrence="$2"
  local value="$3"
  local tmp_file
  tmp_file="$(mktemp)"

  if ! awk -v key="${key}" -v occurrence="${occurrence}" -v value="${value}" '
    BEGIN {
      count = 0;
      found = 0;
    }
    {
      line = $0;
      if (line ~ /^[[:space:]]*[A-Za-z0-9._-]+[[:space:]]*=[[:space:]]*"sha256-/) {
        hash_value = line;
        sub(/^[^=]*=[[:space:]]*"/, "", hash_value);
        hash = substr(hash_value, 1, 51);

        if (length(hash) == 51 &&
            hash ~ /^sha256-[A-Za-z0-9+\/]+=$/ &&
            substr(hash_value, 52, 1) == "\"") {
          line_key = line;
          sub(/^[[:space:]]*/, "", line_key);
          sub(/[[:space:]]*=.*/, "", line_key);

          if (line_key == key) {
            count++;
            if (count == occurrence) {
              if (sub(/sha256-[A-Za-z0-9+\/]+=/, value, line) == 1) {
                $0 = line;
                found = 1;
              }
            }
          }
        }
      }
      print;
    }
    END {
      if (!found) {
        exit 42;
      }
    }
  ' "${OVERLAY_FILE}" > "${tmp_file}"; then
    rm -f "${tmp_file}"
    echo "Failed to set '${key}' occurrence ${occurrence} in ${OVERLAY_FILE}." >&2
    exit 1
  fi

  mv "${tmp_file}" "${OVERLAY_FILE}"
}

extract_got_hash() {
  local log_file="$1"
  grep -Eo 'got:[[:space:]]*sha256-[A-Za-z0-9+/=]+' "${log_file}" \
    | sed -E 's/.*(sha256-[A-Za-z0-9+/=]+).*/\1/' \
    | tail -n1
}

build_output() {
  local flake_output="$1"
  local log_file="$2"
  nix build \
    --no-link \
    --print-build-logs \
    ".#${flake_output}" \
    > "${log_file}" 2>&1
}

for mapping in "${MAPPINGS[@]}"; do
  if [[ "${mapping}" != *=* ]]; then
    echo "Invalid mapping '${mapping}', expected <key[[@occurrence]]=flake_output>." >&2
    exit 1
  fi

  key_spec="${mapping%%=*}"
  flake_output="${mapping#*=}"

  if [[ "${key_spec}" == *@* ]]; then
    key="${key_spec%@*}"
    occurrence="${key_spec#*@}"
  else
    key="${key_spec}"
    occurrence="1"
  fi

  if ! [[ "${occurrence}" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid occurrence '${occurrence}' for key '${key}'." >&2
    exit 1
  fi

  log_file="${LOG_DIR}/${key_spec}.log"

  set_hash_value "${key}" "${occurrence}" "${FAKE_HASH}"
  if build_output "${flake_output}" "${log_file}"; then
    echo "Expected hash mismatch for '${key_spec}', but build of '${flake_output}' succeeded." >&2
    exit 1
  fi

  expected_hash="$(extract_got_hash "${log_file}")"
  if [[ -z "${expected_hash}" ]]; then
    echo "Failed to extract expected hash for '${key_spec}' from '${flake_output}' output." >&2
    exit 1
  fi

  set_hash_value "${key}" "${occurrence}" "${expected_hash}"
done

for mapping in "${MAPPINGS[@]}"; do
  flake_output="${mapping#*=}"
  build_output "${flake_output}" "${LOG_DIR}/verify-${flake_output}.log"
done
