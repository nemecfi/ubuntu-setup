# Ubuntu 26 LTS Setup

Modular bootstrap scripts for a fresh Ubuntu 26 LTS install — highly optimized for AMD hardware and developer productivity.

## Layout

```text
setup.sh                # Main orchestrator
scripts/
  ├── 01-debloat-and-perf.sh   # Bloat removal, swappiness, boot speed
  ├── 02-install-packages.sh   # Apt, snap, deb packages, fonts, Node.js
  ├── 03-configure-system.sh   # Dotfiles, Git, SSH, GNOME & Nautilus tweaks
  └── 04-customization.sh      # Floating dock, accent colors, UI cleanup
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

1.  **Blur my Shell** — *Highly Recommended*. Adds a beautiful glassy blur to the UI (top bar, app grid).
2.  **Vitals** — Provides the resource manager in the top bar (temperatures, CPU, RAM).
3.  **Just Perfection** — Allows further UI cleanup (hiding the 'Activities' text, tuning animations).
4.  **Copyous** or **Clipboard Indicator** — Your preferred clipboard manager.
5.  **Caffeine** — Prevents your screen from dimming or locking.
6.  **AppIndicator and KStatusNotifierItem Support** — Ensures Signal/Discord icons show up.

## Performance Tweaks Included
- **Swappiness:** Reduced to 10 for better RAM utilization.
- **Boot Speed:** Disabled `NetworkManager-wait-online` and reduced GRUB timeout to 1s.
- **AMD Support:** Includes `amd64-microcode`, `mesa-vulkan-drivers`, and `lm-sensors`.
- **Search:** Disabled web search results in the GNOME Activities overview (Firefox blocked, Edge allowed).

## Notes
- Scripts are **idempotent** — safe to re-run.
- Logged output can be found in `setup.log`.
