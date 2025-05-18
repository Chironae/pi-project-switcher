# 🌍 Environment Handling – pi-switcher

## 🧰 Supported Files

- `.env.defaults` – Loads fallback values **only if not already set**
- `.env` – Loads primary values; masks secrets like tokens or passwords
- `.env.sh` – Executes logic and dynamic exports; all exported keys are tracked

## 🔐 Secret Masking

Any variable name that contains one of the following will be masked in logs:

- `SECRET`
- `TOKEN`
- `KEY`
- `PASS`

Example:
```
🔐 API_KEY=********
```

## 🧪 Dry Run Mode

Run with `--dry-run` to preview what would be loaded **without exporting** anything:

```bash
pi-switcher switch my-project --dry-run
```

Useful for safe testing.

## 🧹 Cleaning the Environment

To unset all environment variables loaded during the last project switch:

```bash
pi-switcher clean
```

This will:
- Unset all tracked keys from `.env`, `.env.defaults`, and `.env.sh`
- Delete the `last_env_keys.txt` tracker
- Restart the shell session so variables are truly cleared
