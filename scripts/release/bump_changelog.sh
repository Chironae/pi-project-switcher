#!/bin/bash

CHANGELOG="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

if [ ! -f "$CHANGELOG" ]; then
  echo "❌ No CHANGELOG.md found."
  exit 1
fi

# Get current version
current_version=$(grep -E '^## \[v[0-9]+\.[0-9]+\.[0-9]+\]' "$CHANGELOG" | head -n 1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
if [ -z "$current_version" ]; then
  echo "❌ Couldn't find a current version in changelog."
  exit 1
fi

IFS='.' read -r major minor patch <<< "${current_version#v}"

# Bump PATCH version (for now)
next_version="v$major.$minor.$((patch + 1))"

# Replace [Unreleased] with new version + date
sed -i "s/^## \[Unreleased\]/## [$next_version] - $DATE/" "$CHANGELOG"

# Add new Unreleased section at top
sed -i "2i\\
\\
## [Unreleased]\\
- _Coming soon_\\
" "$CHANGELOG"

echo "✅ Bumped version to $next_version"
