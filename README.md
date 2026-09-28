# Quick Swap Enable

A small Bash script that creates and enables a **3 GiB Linux swap file** in one run.

## Usage

### One command

Run directly from GitHub:

\`\`\`bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/xpersian/quick-swap-enable/main/enable-swap.sh)"
\`\`\`

### Download and run


```bash
curl -fsSL https://raw.githubusercontent.com/xpersian/quick-swap-enable/main/enable-swap.sh -o enable-swap.sh
sudo bash enable-swap.sh
```

Or clone the repository:

```bash
git clone https://github.com/xpersian/quick-swap-enable.git
cd quick-swap-enable
sudo bash enable-swap.sh
```

## What it does

1. Creates `/swapfile` with a size of 3 GiB.
2. Sets secure permissions (`600`).
3. Formats it with `mkswap`.
4. Activates it with `swapon`.
5. Adds a persistent `/etc/fstab` entry so it survives reboots.
6. Displays the resulting swap configuration and memory usage.

The script is safe to run again when `/swapfile` is already active: it leaves the existing swap untouched. It also refuses to overwrite an existing non-swap file at `/swapfile`.

## Requirements

- Linux
- root privileges (run with `sudo`)
- `swapon`, `swapoff`, and `mkswap` from util-linux

The script prefers `fallocate` and falls back to `dd` when needed.

## Source

The creation procedure is based on the Pars Pack Linux swap-file guide:

https://parspack.com/blog/os/linux/create-linux-swap-file
