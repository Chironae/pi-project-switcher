#!/bin/bash
set -e

VERSION=$(grep -m1 '^## \[v' CHANGELOG.md | sed 's/^## \[\(v.*\)\].*/\1/')
DATE=$(grep -m1 '^## \[v' CHANGELOG.md | sed 's/^## \[v.*\] - \(.*\)/\1/')

if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "❌ Tag $VERSION already exists."
  exit 1
fi

if ! grep -q "$VERSION" CHANGELOG.md; then
  echo "❌ CHANGELOG.md does not contain tag: $VERSION"
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working tree not clean. Commit changes first."
  exit 1
fi

echo "🏷️ Tagging $VERSION ($DATE)..."
git tag "$VERSION"
git push origin master --tags
echo "✅ Release finalized and pushed."
