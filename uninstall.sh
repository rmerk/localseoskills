#!/usr/bin/env bash
# Local SEO Skills uninstaller for macOS / Linux.
#
# Removes ~/.claude/skills/localseoskills. By default, any briefs/ directory
# (client data) is backed up to ~/.claude/lss-briefs-backup-<timestamp> before
# removal. Pass --no-backup to skip the backup step.
#
# Usage:
#   bash uninstall.sh              # prompts before deleting, backs up briefs
#   bash uninstall.sh --force      # no prompt
#   bash uninstall.sh --no-backup  # skip briefs backup

set -euo pipefail

INSTALL_DIR="${LSS_INSTALL_DIR:-${HOME:?HOME is not set}/.claude/skills/localseoskills}"
FORCE=0
BACKUP=1

for arg in "$@"; do
  case "$arg" in
    --force)     FORCE=1 ;;
    --no-backup) BACKUP=0 ;;
    *)
      printf 'Unknown option: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

say() {
  printf '\033[1;32m>\033[0m %s\n' "$1"
}

fail() {
  printf '\033[1;31mx\033[0m %s\n' "$1" >&2
  exit 1
}

main() {
  # Refuse to operate on catastrophically short paths, system roots, or
  # anything that resolves to the user's home directory. Protects against
  # accidents like LSS_INSTALL_DIR=/ or LSS_INSTALL_DIR=$HOME followed by
  # --force, plus traversal attacks like LSS_INSTALL_DIR=$HOME/../../usr.
  local resolved stripped
  # Resolve the parent via cd + pwd, then re-attach basename. When pwd is "/"
  # this produces "//basename"; tr -s '/' collapses repeated slashes so the
  # comparison against the blocklist is reliable.
  resolved="$(cd "$(dirname "$INSTALL_DIR")" 2>/dev/null && pwd)/$(basename "$INSTALL_DIR")" || resolved="$INSTALL_DIR"
  resolved="$(printf '%s' "$resolved" | tr -s '/')"
  resolved="${resolved%/}"
  [ -z "$resolved" ] && resolved="/"

  # Normalize trailing slashes on the raw input so "/", "//", "/usr/" all
  # compare equal to their blocklist entries.
  stripped="${INSTALL_DIR%/}"
  [ -z "$stripped" ] && stripped="/"

  # Check BOTH the raw input and the resolved path against the blocklist, so
  # attacks that normalize to a system root are caught.
  for candidate in "$stripped" "$resolved"; do
    case "$candidate" in
      /|""|/root|/home|/Users|/usr|/etc|/var|/tmp|/bin|/sbin|/opt|/boot|/dev|/proc|/sys|/lib|/mnt|/srv)
        fail "Refusing to operate on dangerous path: $INSTALL_DIR (resolves to $candidate)" ;;
    esac
  done

  if [ "${#stripped}" -lt 10 ]; then
    fail "Refusing to operate on suspiciously short path: $INSTALL_DIR"
  fi
  if [ "$resolved" = "$HOME" ] || [ "$INSTALL_DIR" = "$HOME" ] || [ "$stripped" = "${HOME%/}" ] || [ "$resolved" = "${HOME%/}" ]; then
    fail "Refusing to operate on your home directory: $INSTALL_DIR"
  fi

  if [ ! -e "$INSTALL_DIR" ]; then
    say "Nothing to uninstall at $INSTALL_DIR"
    exit 0
  fi

  if [ "$FORCE" -ne 1 ]; then
    printf 'This will delete %s.\nType "yes" to continue: ' "$INSTALL_DIR"
    read -r answer
    if [ "$answer" != "yes" ]; then
      fail "Aborted."
    fi
  fi

  if [ "$BACKUP" -eq 1 ] && [ -d "$INSTALL_DIR/briefs" ]; then
    local ts dst n
    ts="$(date +%Y%m%d-%H%M%S)"
    dst="${HOME}/.claude/lss-briefs-backup-${ts}"
    n=1
    while [ -e "$dst" ]; do
      dst="${HOME}/.claude/lss-briefs-backup-${ts}-${n}"
      n=$((n + 1))
    done
    say "Backing up briefs to $dst"
    mkdir -p "$(dirname "$dst")"
    cp -a "$INSTALL_DIR/briefs" "$dst"
  fi

  rm -rf "$INSTALL_DIR"
  say "Removed $INSTALL_DIR"
}

main "$@"
