#!/usr/bin/env bash
set -euo pipefail

git fetch --no-tags --depth=1 origin \
  "+refs/heads/${BASE_REF}:refs/remotes/origin/${BASE_REF}"

changed_overlays=()
mapfile -d '' -t changed_overlays < <(
  git diff --name-only -z "origin/${BASE_REF}...HEAD" -- 'overlays/*.nix'
)

if [[ "${#changed_overlays[@]}" -eq 0 ]]; then
  echo 'No overlay changes detected.'
fi

collect_hash_keys() {
  local overlay="$1"
  # Dependency hashes are derived from the fetched source tree.
  grep -E "^[[:space:]]*hash-[A-Za-z0-9._-]+[[:space:]]*=[[:space:]]*\"sha256-[A-Za-z0-9+/]{43}=\"" "${overlay}" |
    sed -E "s/^[[:space:]]*(hash-[A-Za-z0-9._-]+)[[:space:]]*=.*/\\1/" |
    awk '
      !seen[$0]++ {
        keys[++n] = $0;
      }
      END {
        for (pass = 1; pass >= 0; pass--) {
          for (i = 1; i <= n; i++) {
            source_first = keys[i] ~ /^hash-src($|-)/;
            if (source_first == pass) {
              print keys[i];
            }
          }
        }
      }
    ' || true
}

mapping_for_hash_key() {
  local package_name="$1"
  local key="$2"
  local suffix

  suffix="${key#hash-}"

  echo "${key}=${package_name}-${suffix}"
}

updated_any='false'
for overlay in "${changed_overlays[@]}"; do

  package_name="$(basename "${overlay}" .nix | tr '_' '-')"
  mappings=()

  while IFS= read -r key; do
    [[ -z "${key}" ]] && continue
    mappings+=("$(mapping_for_hash_key "${package_name}" "${key}")")
  done < <(collect_hash_keys "${overlay}")

  if [[ "${#mappings[@]}" -eq 0 ]]; then
    echo "No hash keys detected in ${overlay}; skipping."
    continue
  fi

  ./.github/scripts/update_overlay_hashes.sh "${overlay}" "${mappings[@]}"
  updated_any='true'
done

if [[ "${updated_any}" != 'true' ]]; then
  echo 'No mapped overlay hash updates required.'
fi

nix flake lock
