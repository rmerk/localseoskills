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
  # Refuse outright if INSTALL_DIR contains any `..` segment. Path traversal
  # makes the final target ambiguous and bypasses the in-home fast-allow
  # when realpath can't canonicalize (non-existent targets). There is no
  # legitimate reason for an install dir path to include `..`.
  case "/$INSTALL_DIR/" in
    */../*) fail "Refusing to operate on path with .. traversal: $INSTALL_DIR" ;;
  esac
  # Refuse outright if INSTALL_DIR itself is a symlink. A symlink whose target
  # is a system path would pass the resolved-path check (we'd see the target),
  # but `rm -rf` on the symlink follows it and deletes the target's contents.
  if [ -L "$INSTALL_DIR" ]; then
    fail "Refusing to operate on a symlink: $INSTALL_DIR"
  fi
  # Prefer realpath/readlink -f when available so symlinks in the path are
  # resolved to their real targets before blocklist comparison. Falls back to
  # cd + pwd, which resolves symlinks on macOS/Linux but not `/./` segments;
  # tr -s '/' collapses repeated slashes so the comparison is reliable.
  if command -v realpath >/dev/null 2>&1; then
    resolved="$(realpath "$INSTALL_DIR" 2>/dev/null)" || resolved="$INSTALL_DIR"
  elif readlink -f "$INSTALL_DIR" >/dev/null 2>&1; then
    resolved="$(readlink -f "$INSTALL_DIR")"
  else
    resolved="$(cd "$(dirname "$INSTALL_DIR")" 2>/dev/null && pwd)/$(basename "$INSTALL_DIR")" || resolved="$INSTALL_DIR"
  fi
  resolved="$(printf '%s' "$resolved" | tr -s '/')"
  resolved="${resolved%/}"
  [ -z "$resolved" ] && resolved="/"

  # Normalize trailing slashes on the raw input so "/", "//", "/usr/" all
  # compare equal to their blocklist entries.
  stripped="${INSTALL_DIR%/}"
  [ -z "$stripped" ] && stripped="/"

  # Match case-insensitively so macOS (HFS+/APFS default is case-insensitive)
  # can't bypass with `$HOME/../../LIBRARY`. No-op on Linux where the FS is
  # case-sensitive anyway. shopt is bash-specific and already required by
  # `set -euo pipefail` on line 13.
  shopt -s nocasematch

  # Fast-allow: if the resolved path is strictly inside the current user's
  # home subtree, it's a legitimate location and we only need the home-dir
  # equality check below. Without this shortcut the prefix blocklist would
  # refuse the default `/Users/<user>/.claude/...` because /Users is in the
  # list. Compared against the resolved form (not raw), so a traversal like
  # `$HOME/../../Users` (resolves to `/Users`) does NOT hit the fast-allow.
  local inside_home=0
  if [ -n "${HOME:-}" ] && [[ "$resolved" == "${HOME%/}"/* ]]; then
    inside_home=1
  fi

  # Blocklist covers:
  #   - POSIX: /, /root, /home, /usr, /etc, /var, /tmp, /bin, /sbin, /opt,
  #     /boot, /dev, /proc, /sys, /lib, /mnt, /srv, /run, /media,
  #     /lost+found, /snap, /selinux, /sysroot
  #   - macOS: /Users, /Library, /System, /Applications, /private, /cores,
  #     /Volumes, /Network, /.vol
  # Check BOTH equality and prefix-with-slash (so /System/Library and any
  # path nested under a blocklisted root is also refused). Reviews caught
  # an earlier bypass via `$HOME/../../Library` (missing from the original
  # list) and a second bypass via `/System/Library` (nested inside a
  # blocklisted root but not itself on the list); prefix matching plus the
  # expanded list closes both classes.
  local blocklist=(
    / /root /home /Users
    /usr /etc /var /tmp /bin /sbin /opt /boot /dev /proc /sys /lib /mnt /srv
    /run /media /lost+found /snap /selinux /sysroot
    /Library /System /Applications /private /cores /Volumes /Network /.vol
  )
  if [ "$inside_home" -eq 0 ]; then
    for candidate in "$stripped" "$resolved"; do
      [ -z "$candidate" ] && fail "Refusing to operate on empty path"
      for blocked in "${blocklist[@]}"; do
        if [ "$candidate" = "$blocked" ] || [[ "$candidate" == "$blocked"/* ]]; then
          fail "Refusing to operate on dangerous path: $INSTALL_DIR (resolves to $candidate, inside blocklisted $blocked)"
        fi
      done
    done
  fi
  shopt -u nocasematch

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
    # Refuse to copy if briefs is a symlink: `cp -a` would follow the top-level
    # link and silently back up whatever it points at, potentially landing a
    # copy of an unrelated directory outside the install tree.
    if [ -L "$INSTALL_DIR/briefs" ]; then
      fail "Refusing to back up briefs: $INSTALL_DIR/briefs is a symlink"
    fi
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
