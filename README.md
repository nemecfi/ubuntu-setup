# installConfig

Bootstrap scripts for a fresh Ubuntu 26 LTS install — my personal setup.

## Layout

```
setup.sh          # base packages, apps, fonts, git, ssh, ai cli
citrixSetup.sh    # Citrix Workspace + AMD video tuning
gnomeSetup.sh     # GNOME desktop tweaks
setup.py          # Python port of setup.sh (alternative)
configs/          # all the dotfiles dropped into ~/
```

## Run order

```bash
bash setup.sh        # do this first
bash citrixSetup.sh  # only if you use Citrix
bash gnomeSetup.sh   # only on GNOME (Ubuntu default)
```

## Notes

- `citrixSetup.sh` looks for an `icaclient_*.deb` in `configs/citrix/`. Download it from [citrix.com](https://www.citrix.com/downloads/workspace-app/linux/) (EULA gate) and drop it there before running.
- Scripts are idempotent — safe to re-run.
- Targets Ubuntu / Debian (uses `apt`, `snap`).
