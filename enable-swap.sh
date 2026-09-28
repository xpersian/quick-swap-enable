#!/usr/bin/env bash
set -euo pipefail

SWAP_FILE="/swapfile"
SWAP_SIZE="3G"
FSTAB_LINE="$SWAP_FILE none swap sw 0 0"

if [[ "$EUID" -ne 0 ]]; then
  echo "Error: run this script as root (or with sudo)."
  exit 1
fi

if ! command -v swapon >/dev/null 2>&1 || ! command -v swapoff >/dev/null 2>&1; then
  echo "Error: swapon/swapoff are required."
  exit 1
fi

if ! command -v mkswap >/dev/null 2>&1; then
  echo "Error: mkswap is required."
  exit 1
fi

echo "==> Checking existing swap configuration..."

# If /swapfile is already an active swap area, do not modify it.
if swapon --show=NAME --noheadings 2>/dev/null | grep -Fxq "$SWAP_FILE"; then
  echo "Swap file $SWAP_FILE is already active."
  swapon --show
  exit 0
fi

# Never overwrite an existing non-swap file.
if [[ -e "$SWAP_FILE" ]]; then
  echo "Error: $SWAP_FILE already exists but is not an active swap file."
  echo "Refusing to overwrite it."
  exit 1
fi

echo "==> Creating $SWAP_SIZE swap file at $SWAP_FILE..."

# fallocate is fast; dd is used as a fallback for filesystems where fallocate
# is unavailable or unsupported.
if command -v fallocate >/dev/null 2>&1; then
  if ! fallocate -l "$SWAP_SIZE" "$SWAP_FILE"; then
    echo "fallocate failed; falling back to dd..."
    dd if=/dev/zero of="$SWAP_FILE" bs=1M count=3072 status=progress
  fi
else
  dd if=/dev/zero of="$SWAP_FILE" bs=1M count=3072 status=progress
fi

chmod 600 "$SWAP_FILE"

echo "==> Formatting swap area..."
mkswap "$SWAP_FILE" >/dev/null

echo "==> Activating swap..."
swapon "$SWAP_FILE"

echo "==> Making swap persistent across reboots..."
if ! grep -Eq '^[[:space:]]*/swapfile[[:space:]]+.*[[:space:]]swap[[:space:]]' /etc/fstab; then
  echo "$FSTAB_LINE" >> /etc/fstab
fi

echo
echo "Swap enabled successfully."
echo
swapon --show
echo
free -h
