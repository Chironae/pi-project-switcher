.PHONY: bump release release-docs

VERSION := $(shell grep -E '^## \[v[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')

bump:
	@echo "🔼 Bumping changelog version..."
	@scripts/release/bump_changelog.sh

release-docs:
	@echo "📝 Staging documentation for release..."
	@git add CHANGELOG.md ENVIRONMENT.md README.md || true
	@git commit -m "📝 Finalize documentation for release" || echo "⚠️  Nothing to commit."
	@echo "✅ Docs committed. You can now tag with: pi-switcher release"

release: bump
	@echo "📝 Staging documentation for release..."
	@if git tag | grep -q "^$(VERSION)$$"; then \
		echo "❌ Tag $(VERSION) already exists. Aborting."; \
		exit 1; \
	fi
	@git add CHANGELOG.md ENVIRONMENT.md README.md || true
	@git commit -m "📝 Finalize documentation for release" || echo "⚠️  Nothing to commit."
	@git tag -a $(VERSION) -m "🚀 Release: $(VERSION)"
	@git push origin master --tags
