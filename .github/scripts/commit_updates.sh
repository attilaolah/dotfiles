#!/usr/bin/env bash
set -euo pipefail

if git diff --quiet -- overlays flake.lock; then
  echo 'No overlay hash or flake lock updates needed.'
  exit 0
fi

message='chore(renovate): refresh overlay hashes and flake lock'

expected_head_oid="$(git rev-parse HEAD)"

additions_json="$(
  git diff --name-only -z -- overlays flake.lock |
    while IFS= read -r -d '' path; do
      contents="$(base64 < "${path}" | tr -d '\n')"
      jq -n --arg path "${path}" --arg contents "${contents}" \
        '{path: $path, contents: $contents}'
    done |
    jq -s .
)"

# shellcheck disable=SC2016
mutation='
  mutation($input: CreateCommitOnBranchInput!) {
    createCommitOnBranch(input: $input) {
      commit {
        oid
      }
    }
  }
'

commit_oid="$(
  jq -n \
    --arg query "${mutation}" \
    --arg repo "${REPO}" \
    --arg branch "${BRANCH}" \
    --arg expected_head_oid "${expected_head_oid}" \
    --arg message "${message}" \
    --argjson additions "${additions_json}" \
    '{
      query: $query,
      variables: {
        input: {
          branch: {
            repositoryNameWithOwner: $repo,
            branchName: $branch
          },
          expectedHeadOid: $expected_head_oid,
          message: {
            headline: $message
          },
          fileChanges: {
            additions: $additions
          }
        }
      }
    }' |
    gh api graphql --input - --jq '.data.createCommitOnBranch.commit.oid'
)"

verification="$(
  gh api "repos/${REPO}/commits/${commit_oid}" \
    --jq '.commit.verification.reason'
)"

if [[ "${verification}" != 'valid' ]]; then
  echo "Commit ${commit_oid} was not GitHub-verified (reason: ${verification})." >&2
  exit 1
fi
