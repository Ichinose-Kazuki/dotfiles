# shellcheck shell=bash

# ssh-add invokes this script as its askpass helper. Read the passphrase from
# the controlling terminal, reply on stdout, and keep a copy for the caller.
if [ "${SSH_ASKPASS_KEYRING_MODE:-}" = "askpass" ]; then
  prompt="${1:-Enter passphrase}"

  if [ ! -r /dev/tty ]; then
    printf 'ssh-add-keyring: no controlling terminal\n' >&2
    exit 1
  fi

  printf '%s ' "$prompt" >&2
  IFS= read -r -s secret < /dev/tty || exit 1
  printf '\n' >&2
  printf '%s\n' "$secret"

  # Only passphrase prompts are remembered; confirmations and yes/no prompts
  # must not overwrite the saved passphrase.
  case "$prompt" in
    *passphrase*|*Passphrase*)
      if [ -n "${SSH_PASS_TMP:-}" ]; then
        umask 077
        printf '%s' "$secret" > "$SSH_PASS_TMP"
      fi
      ;;
  esac
  exit 0
fi

if [ "$#" -lt 1 ]; then
  echo "usage: ssh-add-keyring <private-key> [ssh-add options...]" >&2
  exit 2
fi

key="$1"
shift

if [ ! -f "$key" ]; then
  echo "ssh-add-keyring: no such key: $key" >&2
  exit 1
fi
if [ ! -f "$key.pub" ]; then
  echo "ssh-add-keyring: missing public key: $key.pub" >&2
  exit 1
fi

# Prefer rpi5's own agent over one forwarded from the client.
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -S "$XDG_RUNTIME_DIR/gcr/ssh" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
fi

# gcr-ssh-agent looks the passphrase up by this exact attribute.
key_abs="$(realpath -s -- "$key")"
unique="ssh-store:$key_abs"

# Keep the passphrase on tmpfs while ssh-add verifies it, so a wrong
# passphrase is never stored in the keyring.
tmp="$(mktemp -p "${XDG_RUNTIME_DIR:-/tmp}" ssh-pass.XXXXXX)"
trap 'rm -f "$tmp"' EXIT
chmod 600 "$tmp"

self="$(realpath -s -- "$0")"
SSH_PASS_TMP="$tmp" \
SSH_ASKPASS="$self" \
SSH_ASKPASS_KEYRING_MODE=askpass \
SSH_ASKPASS_REQUIRE=force \
ssh-add "$@" "$key"

if [ -s "$tmp" ]; then
  if ! secret-tool store \
      --label="Unlock password for $(basename -- "$key")" \
      xdg:schema org.freedesktop.Secret.Generic \
      unique "$unique" < "$tmp"; then
    echo "ssh-add-keyring: the key was added, but storing the passphrase in the keyring failed" >&2
  fi
fi
