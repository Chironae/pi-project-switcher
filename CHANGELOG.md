# 📦 Changelog

## [Unreleased]
- Initial project scaffolding and architecture defined.
- Implemented `pi-switch.sh` for project context switching.
- Added per-project venv activation and clean deactivation.
- Created `pi-newproject.sh` for project scaffolding.
- Established JSON-based project registry.
- Added sandbox cheatsheet for usage reference.

## [v1.0.0] - 2025-05-17 – First Stable Release
- ✅ Added full support for `.env.defaults`, `.env`, and `.env.sh` loading
- ✅ Tracked all environment keys via `last_env_keys.txt`
- ✅ Implemented secure masking for secret values
- ✅ `--dry-run` support to test loading without exporting
- ✅ `pi-switcher clean` now unsets tracked variables and reloads shell
- ✅ CLI project scaffolding via `--type cli`
- ✅ `README`, `LICENSE`, and project docs finalized
- ✅ Project is ready for public use
