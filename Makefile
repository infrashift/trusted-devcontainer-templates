TEMPLATES := ansible-cue dotnet-node go-cue java python

.DEFAULT_GOAL := help

## ── Testing ──────────────────────────────────────────────────

.PHONY: test-template
test-template: ## Test one template (TEMPLATE=python)
	@test -n "$(TEMPLATE)" || { echo "Usage: make test-template TEMPLATE=<name>"; exit 1; }
	bunx @devcontainers/cli up --workspace-folder "src/$(TEMPLATE)"
	bunx @devcontainers/cli exec --workspace-folder "src/$(TEMPLATE)" \
		bash /workspace/test/$(TEMPLATE)/test.sh

.PHONY: test
test: ## Test ALL templates sequentially
	@for t in $(TEMPLATES); do \
		echo "── Testing $$t ──"; \
		$(MAKE) test-template TEMPLATE=$$t; \
	done

## ── Containerfile Sync ───────────────────────────────────────

.PHONY: check-sync
check-sync: ## Verify all Containerfiles match shared/Containerfile
	@failed=0; \
	for t in $(TEMPLATES); do \
		if ! diff -q shared/Containerfile "src/$$t/.devcontainer/Containerfile" > /dev/null 2>&1; then \
			echo "DRIFT DETECTED: src/$$t/.devcontainer/Containerfile"; \
			diff shared/Containerfile "src/$$t/.devcontainer/Containerfile" || true; \
			failed=1; \
		else \
			echo "OK: $$t"; \
		fi; \
	done; \
	if [ "$$failed" -eq 1 ]; then \
		echo ""; \
		echo "Fix: make sync-containerfiles"; \
		exit 1; \
	fi

.PHONY: sync-containerfiles
sync-containerfiles: ## Copy shared/Containerfile to all templates
	@for t in $(TEMPLATES); do \
		cp shared/Containerfile "src/$$t/.devcontainer/Containerfile"; \
		echo "Synced: $$t"; \
	done

## ── Docs ─────────────────────────────────────────────────────

.PHONY: docs-dev
docs-dev: ## Start docs dev server
	cd docs && bun --bun run dev

.PHONY: docs-build
docs-build: ## Build docs site
	cd docs && bun --bun run build

.PHONY: docs-preview
docs-preview: ## Preview docs build
	cd docs && bun --bun run preview

## ── Housekeeping ─────────────────────────────────────────────

.PHONY: clean
clean: ## Remove docs/dist and caches
	rm -rf docs/dist docs/.astro docs/node_modules/.cache

## ── Help ─────────────────────────────────────────────────────

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
