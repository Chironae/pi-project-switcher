#!/bin/bash

# === Pi Checkin Tool v2 ===
# Supports: --quick, roadmap sync, project config, remote-safe push

echo "🔄 Pi Checkin Tool - End of Day Workflow"
echo "----------------------------------------"

CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")

echo "📁 Current project: $PROJECT_NAME"
echo ""

# === Load config ===
CONFIG_FILE="./config/pi-checkin-config.json"
if [ -f "$CONFIG_FILE" ]; then
  NOTES_FILE=$(jq -r '.notes_file // "NOTES.md"' "$CONFIG_FILE")
  CHANGELOG_FILE=$(jq -r '.changelog_file // "CHANGELOG.md"' "$CONFIG_FILE")
  ROADMAP_FILE=$(jq -r '.roadmap_file // "ROADMAP.md"' "$CONFIG_FILE")
  DEFAULT_BRANCH=$(jq -r '.default_branch // "master"' "$CONFIG_FILE")
  ENABLE_PUSH=$(jq -r '.enable_push // true' "$CONFIG_FILE")
else
  NOTES_FILE="NOTES.md"
  CHANGELOG_FILE="CHANGELOG.md"
  ROADMAP_FILE="ROADMAP.md"
  DEFAULT_BRANCH="master"
  ENABLE_PUSH=true
fi

# === Parse completed roadmap tasks ===
parse_done_tasks() {
  if [ -f "$ROADMAP_FILE" ]; then
    grep '\- \[x\]' "$ROADMAP_FILE"
  else
    echo ""
  fi
}

# === QUICK MODE ===
if [[ $1 == "--quick" ]]; then
  COMMIT_MESSAGE="🔄 Quick checkin $(date '+%Y-%m-%d %H:%M')"
  TASK_SUMMARY="Quick checkin: files updated without detailed summary"

  echo "### $(date '+%Y-%m-%d')" >> "$NOTES_FILE"
  echo "- $TASK_SUMMARY" >> "$NOTES_FILE"
  echo "" >> "$NOTES_FILE"

  echo "## $(date '+%Y-%m-%d')" >> "$CHANGELOG_FILE"
  echo "- $COMMIT_MESSAGE" >> "$CHANGELOG_FILE"
  echo "" >> "$CHANGELOG_FILE"

  git add "$NOTES_FILE" "$CHANGELOG_FILE"
  git commit -m "$COMMIT_MESSAGE"

  if $ENABLE_PUSH && git remote | grep -q origin; then
    git push origin "$DEFAULT_BRANCH"
  else
    echo "⚠️  No git remote configured or push disabled. Skipping push step."
  fi

  echo ""
  echo "✅ Quick checkin complete for $PROJECT_NAME."
  echo "----------------------------------------"
  exit 0
fi

# === INTERACTIVE MODE ===
read -rp "📝 What tasks did you complete today? " TASK_SUMMARY
read -rp "💬 Enter commit summary: " COMMIT_MESSAGE

# Optional: include roadmap
ROADMAP_DONE=$(parse_done_tasks)
if [[ -n "$ROADMAP_DONE" ]]; then
  read -rp "✅ Found completed ROADMAP tasks. Include in log? (y/n) " INCLUDE_ROADMAP
  if [[ "$INCLUDE_ROADMAP" == "y" || "$INCLUDE_ROADMAP" == "Y" ]]; then
    TASK_SUMMARY+="\nCompleted from ROADMAP:\n$ROADMAP_DONE"
  fi
fi

echo -e "### $(date '+%Y-%m-%d')" >> "$NOTES_FILE"
echo -e "- $TASK_SUMMARY" >> "$NOTES_FILE"
echo "" >> "$NOTES_FILE"

echo -e "## $(date '+%Y-%m-%d')" >> "$CHANGELOG_FILE"
echo -e "- $COMMIT_MESSAGE" >> "$CHANGELOG_FILE"
echo "" >> "$CHANGELOG_FILE"

git add "$NOTES_FILE" "$CHANGELOG_FILE"
git commit -m "$COMMIT_MESSAGE"

if $ENABLE_PUSH && git remote | grep -q origin; then
  git push origin "$DEFAULT_BRANCH"
else
  echo "⚠️  No git remote configured or push disabled. Skipping push step."
fi

echo ""
echo "✅ Checkin complete for $PROJECT_NAME."
echo "----------------------------------------"
