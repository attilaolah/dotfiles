# Load the user profile.
# This will set up the $PATH to be managed by home-manager.
source "${HOME}/.profile"

# Start fish.
WHICH_FISH="$(which fish)"
if [[ "$-" =~ i && -x "${WHICH_FISH}" && ! "${SHELL}" -ef "${WHICH_FISH}" ]]; then
  # Safeguard to only activate fish for interactive shells and only if fish
  # shell is present and executable. Verify that this is a new session by
  # checking if ${SHELL} is set to the path to fish. If it is not, we set
  # ${SHELL} and start fish.

  # If this is not a new session, the user probably typed 'bash' into their
  # console and wants bash, so we skip this.
  exec env SHELL="${WHICH_FISH}" "${WHICH_FISH}" -i
fi
