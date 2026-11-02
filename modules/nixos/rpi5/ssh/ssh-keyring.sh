# shellcheck shell=bash

real_ssh="${REAL_SSH:-/run/current-system/sw/bin/ssh}"
add_keyring="${SSH_ADD_KEYRING:-$(dirname -- "$(realpath -s -- "$0")")/ssh-add-keyring}"

# Use rpi5's own agent instead of an agent forwarded from the client.
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -S "$XDG_RUNTIME_DIR/gcr/ssh" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
fi

# Non-interactive callers cannot answer a passphrase prompt. Let the agent
# resolve the key from the keyring, if it can.
if [ ! -t 0 ]; then
  exec "$real_ssh" "$@"
fi

# Ask ssh which identity files this invocation would try, then make sure each
# one has its passphrase in the keyring.
if ! identities="$("$real_ssh" -G "$@" 2>/dev/null | awk '$1 == "identityfile" { $1 = ""; sub(/^ +/, ""); print }')"; then
  identities=""
fi

while IFS= read -r key; do
  [ -n "$key" ] || continue

  case "$key" in
    \~/*) key="$HOME/${key#\~/}" ;;
  esac

  [ -f "$key" ] || continue
  [ -f "$key.pub" ] || continue

  key_abs="$(realpath -s -- "$key")"
  unique="ssh-store:$key_abs"

  if ! secret-tool lookup xdg:schema org.freedesktop.Secret.Generic unique "$unique" >/dev/null 2>&1; then
    "$add_keyring" "$key"
  fi
done <<< "$identities"

exec "$real_ssh" "$@"
