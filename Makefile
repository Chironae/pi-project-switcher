.PHONY: release-docs

release-docs:
	@echo "📝 Staging documentation for release..."
	git add CHANGELOG.md ENVIRONMENT.md README.md || true
	git commit -m "📝 Finalize documentation for release" || echo "⚠️  Nothing to commit."
	@echo "✅ Docs committed. You can now tag with: pi-switcher release"
