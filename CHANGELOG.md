# 📦 Changelog

## [Unreleased]
- _Coming soon_

## [v1.0.2] - 2025-05-20
- ✅ SSH key profile manager with `pi-switcher ssh-keys`
- ✅ Identity-aware `.ssh/config` generator with `pi-switcher ssh-config`
- ✅ Timestamped backup of `.ssh/config`
- ✅ CLI removal and cleanup of SSH key entries
- ✅ GitHub SSH enforcement and branch audit via `pi-switcher git-audit`
- ✅ Verified SSH keygen and config update workflows

## [v1.0.1] - 2025-05-18
- ✅ Added full support for `.env.defaults`, `.env`, and `.env.sh` loading
- ✅ Tracked all environment keys via `last_env_keys.txt`
- ✅ Implemented secure masking for secret values
- ✅ `--dry-run` support to test loading without exporting
- ✅ `pi-switcher clean` now unsets tracked variables and reloads shell
- ✅ CLI project scaffolding via `--type cli`
- ✅ `README`, `LICENSE`, and project docs finalized
- ✅ Project is ready for public use
- 🛠 Fixed symlink path resolution for `$SWITCHER_ROOT`
- 🐛 Resolved bug where release script pointed to `/usr/local/` instead of project path
- ✅ Verified `release` and `make release-docs` workflows run cleanly

## [v1.0.0] - 2025-05-17 – First Stable Release
- Initial project scaffolding and architecture defined.
- Implemented `pi-switch.sh` for project context switching.
- Added per-project venv activation and clean deactivation.
- Created `pi-newproject.sh` for project scaffolding.
- Established JSON-based project registry.
- Added sandbox cheatsheet for usage reference.
