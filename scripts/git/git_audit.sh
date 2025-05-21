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
LOG_FILE="$HOME/projects/pi-project-switcher/logs/git_audit.log"
> "$LOG_FILE"

for dir in "$PROJECTS_DIR"/*; do
  [ -d "$dir/.git" ] || continue
  PROJECT=$(basename "$dir")
  cd "$dir" || continue

  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "UNKNOWN")
  REMOTE=$(git remote get-url origin 2>/dev/null || echo "none")

  STATUS="OK"
  BADGE="[✔]"

  if [ "$BRANCH" != "$DEFAULT_BRANCH" ]; then
    STATUS="wrong branch"
    BADGE="[⚠]"
  fi

  if [[ "$REMOTE" == "none" ]]; then
    STATUS="missing remote"
    BADGE="[⚠]"
  elif [[ "$AUTH_METHOD" == "ssh" && "$REMOTE" =~ ^https:// ]]; then
    STATUS="https remote"
    BADGE="[⚠]"
    if [ "$USE_FIX" = true ]; then
      ssh_url=$(echo "$REMOTE" | sed -E 's|https://github.com/|git@github.com:|; s|\.git$||')
      git remote set-url origin "$ssh_url"
      STATUS="fixed to SSH"
      BADGE="[🔧]"
    fi
  fi

  LINE=$(printf "%-22s | branch: %-10s | remote: %-40s | status: %s" \
    "$BADGE $PROJECT" "$BRANCH" "$REMOTE" "$STATUS")
  echo "$LINE" | tee -a "$LOG_FILE"

done

