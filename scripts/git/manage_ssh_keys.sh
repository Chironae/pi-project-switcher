#!/bin/bash

CONFIG_FILE="$HOME/.pi-switcher/git-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Git config not found: $CONFIG_FILE"
  exit 1
fi

if [[ "$1" == "remove" ]]; then
  key_id="$2"
  if [ -z "$key_id" ]; then
    echo "Usage: pi-switcher ssh-keys remove <key_id>"
    exit 1
  fi

  key_path=$(jq -r --arg id "$key_id" '.ssh_keys[$id].path // empty' "$CONFIG_FILE")

  if [ -z "$key_path" ]; then
    echo "❌ No key named '$key_id' found in config."
    exit 1
  fi

  # Remove from config
  jq "del(.ssh_keys[\"$key_id\"])" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
  echo "🗑️ Removed '$key_id' from git-config.json"

  # Prompt for file deletion
  echo
  read -rp "📦 Archive key files instead of deleting? [y/N]: " archive_confirm
  if [[ "$archive_confirm" =~ ^[Yy]$ ]]; then
    archive_dir="$HOME/.pi-switcher/ssh-archive/$key_id"
    mkdir -p "$archive_dir"
    mv "$key_path" "$key_path.pub" "$archive_dir/" 2>/dev/null
    echo "✅ Key files archived to: $archive_dir"
  else
    read -rp "⚠️  Permanently delete key files at $key_path? [y/N]: " delete_confirm
    if [[ "$delete_confirm" =~ ^[Yy]$ ]]; then
      rm -f "$key_path" "$key_path.pub"
      echo "✅ Deleted:"
      echo "   • $key_path"
      echo "   • $key_path.pub"
    else
      echo "ℹ️  Key files left on disk."
    fi
  fi

  exit 0
fi

echo "🔐 SSH Key Manager"
echo

jq -r '.ssh_keys | to_entries[] | "\(.key): \(.value.label) → \(.value.path)"' "$CONFIG_FILE"

echo
echo "To generate a new SSH key, enter a key name:"
read -rp "➕ New key ID (e.g. personal, work, alt): " key_id

[[ -z "$key_id" ]] && echo "⚠️ Cancelled." && exit 1

key_path="$HOME/.ssh/id_ed25519_$key_id"

echo "🔨 Generating key at: $key_path"
ssh-keygen -t ed25519 -C "$(jq -r .github_email "$CONFIG_FILE")" -f "$key_path"

# Add to config
tmpfile="$CONFIG_FILE.tmp"

jq --arg id "$key_id" \
    --arg path "$key_path" \
    --arg label "SSH Key for $key_id" \
    --argjson new_key "$(jq -n --arg p "$key_path" --arg l "SSH Key for $key_id" '{path: $p, label: $l}')" \
    '.ssh_keys[$id] = $new_key' \
    "$CONFIG_FILE" > "$tmpfile" && mv "$tmpfile" "$CONFIG_FILE"

echo
echo "✅ Key '$key_id' added to config."
echo "📎 Public key is here: ${key_path}.pub"
