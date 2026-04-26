# Ubuntu 26 LTS Setup

Modular bootstrap scripts for a fresh Ubuntu 26 LTS install — highly optimized for AMD hardware and developer productivity.

## Layout

```text
setup.sh                # Main orchestrator
scripts/
  ├── 01-debloat-and-perf.sh   # Bloat removal, swappiness, boot speed
  ├── 02-install-packages.sh   # Apt, snap, deb packages, fonts, Node.js
  └── 03-configure-system.sh   # Dotfiles, Git, SSH, GNOME & Nautilus tweaks
configs/                       # Personal dotfiles and app configs
citrixSetup.sh                 # Citrix Workspace + AMD video tuning
```

## How to Run

```bash
# Run the main orchestrator
bash setup.sh

# Optional: Citrix setup (requires .deb in configs/citrix/)
bash citrixSetup.sh
```

## Recommended Manual Steps

After the script finishes, open **Extension Manager** (already installed) and search/install the following extensions to complete the setup:

1.  **Vitals** — Provides the resource manager in the top bar (temperatures, CPU, RAM).
2.  **Copyous** or **Clipboard Indicator** — Your preferred clipboard manager.
3.  **Caffeine** — Prevents your screen from dimming or locking (ideal for long reads/builds).
4.  **AppIndicator and KStatusNotifierItem Support** — (Usually installed but ensure it's enabled for Signal/Discord icons).

## Performance Tweaks Included
- **Swappiness:** Reduced to 10 for better RAM utilization.
- **Boot Speed:** Disabled `NetworkManager-wait-online` and reduced GRUB timeout to 1s.
- **AMD Support:** Includes `amd64-microcode`, `mesa-vulkan-drivers`, and `lm-sensors`.
- **Search:** Disabled web search results in the GNOME Activities overview.

## Notes
- Scripts are **idempotent** — safe to re-run.
- Logged output can be found in `setup.log`.
