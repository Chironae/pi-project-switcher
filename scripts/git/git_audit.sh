#!/bin/bash

PROJECTS_DIR="$HOME/projects"
CONFIG_FILE="$HOME/.pi-switcher/git-config.json"
USE_FIX=false

if [ "$1" == "--fix" ]; then
  USE_FIX=true
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Git config not found at $CONFIG_FILE"
  exit 1
fi

DEFAULT_BRANCH=$(jq -r '.default_branch // "master"' "$CONFIG_FILE")
AUTH_METHOD=$(jq -r '.auth_method // "ssh"' "$CONFIG_FILE")

echo "🔍 Scanning projects in $PROJECTS_DIR"
echo

for dir in "$PROJECTS_DIR"/*; do
  [ -d "$dir/.git" ] || continue
  echo "📁 Project: $(basename "$dir")"

  cd "$dir" || continue

  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  REMOTE=$(git remote get-url origin 2>/dev/null || echo "(no remote)")

  echo "   • Branch: $BRANCH"
  echo "   • Remote: $REMOTE"

  # Flag wrong branch
  if [ "$BRANCH" != "$DEFAULT_BRANCH" ]; then
    echo "   ⚠️ Branch mismatch: expected $DEFAULT_BRANCH"
  fi

  # Flag non-SSH usage
  if [ "$AUTH_METHOD" == "ssh" ] && [[ "$REMOTE" =~ ^https:// ]]; then
    echo "   ⚠️ Remote uses HTTPS, expected SSH"

    if [ "$USE_FIX" = true ]; then
      ssh_url=$(echo "$REMOTE" | sed -E 's|https://github.com/|git@github.com:|; s|\.git$||').git
      git remote set-url origin "$ssh_url"
      echo "   🔧 Remote updated to SSH: $ssh_url"
    fi
  fi

  echo
done
