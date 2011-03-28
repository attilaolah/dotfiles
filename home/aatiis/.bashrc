# Always source the system profile
source "/etc/profile"

# Make /[usr/]sbin commands accessible
export PATH="$PATH:/sbin:/usr/sbin"

# Keychain, to remember my passphrase
eval `keychain --eval --nogui -Q -q id_rsa`
