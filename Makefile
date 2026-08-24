TEMPLATES := ansible-cue dotnet-node go-cue java python

# Every Containerfile that must stay byte-identical to shared/Containerfile.
# Includes this repo's own .devcontainer/Containerfile, which previously
# escaped the drift check and had already diverged.
MANAGED_CONTAINERFILES := .devcontainer/Containerfile \
	$(foreach t,$(TEMPLATES),src/$(t)/.devcontainer/Containerfile)

# `devcontainer up --workspace-folder src/<t>` mounts ONLY src/<t>, so the
# repo-level test/ directory is not reachable from inside a template container.
# Bind it in explicitly rather than changing the published templates.
TEST_MOUNT := /tmp/tdt-test

.DEFAULT_GOAL := help

## ── Testing ──────────────────────────────────────────────────

.PHONY: test-template
test-template: ## Test one template (TEMPLATE=python)
	@test -n "$(TEMPLATE)" || { echo "Usage: make test-template TEMPLATE=<name>"; exit 1; }
	bunx @devcontainers/cli up --workspace-folder "src/$(TEMPLATE)" \
		--mount "type=bind,source=$(CURDIR)/test,target=$(TEST_MOUNT)"
	bunx @devcontainers/cli exec --workspace-folder "src/$(TEMPLATE)" \
		bash $(TEST_MOUNT)/$(TEMPLATE)/test.sh

.PHONY: tools
tools: ## Install the pinned CI tools locally (BIN=~/.local/bin make tools)
	BIN=$${BIN:-$$HOME/.local/bin} ./scripts/install-tools.sh opa gitleaks syft grype

.PHONY: check-policy
check-policy: ## Check, format-check and unit-test the PDP, with a coverage floor
	@command -v opa > /dev/null || { \
		echo "opa not found. Run: make tools"; \
		exit 1; \
	}
	./scripts/check-no-orphan-rego.sh
	opa check --strict .github/pdp/
	@out=$$(opa fmt --list .github/pdp/); \
		if [ -n "$$out" ]; then echo "rego needs formatting: $$out"; exit 1; fi
	opa test .github/pdp/
	@cov=$$(opa test .github/pdp/ --coverage --format json | jq -r '.coverage'); \
		printf 'coverage: %.1f%%\n' "$$cov"; \
		awk -v c="$$cov" 'BEGIN{ if (c+0 < 85) { print "coverage below the 85% floor"; exit 1 } }'

.PHONY: pin-features
pin-features: ## Re-resolve and pin every template's feature references by digest
	./scripts/pin-features.sh

.PHONY: check-pins
check-pins: ## Verify every template feature reference is digest-pinned
	./scripts/pin-features.sh --check

.PHONY: check-workflows
check-workflows: ## Lint workflows for pinning and required-context drift
	./scripts/lint-workflows.sh

.PHONY: repo-gate
repo-gate: ## Run the repository-scoped PDP against the working tree
	@command -v gitleaks > /dev/null || { \
		echo "gitleaks not found. Run: make tools"; \
		exit 1; \
	}
	./scripts/repo-gate.sh repo-decision.json

# Everything CI's repo-gate job runs, minus the container builds. Fast enough to
# run before every push.
.PHONY: check
check: check-sync check-pins check-workflows check-policy repo-gate ## Run every static check
	@echo "── all static checks passed ──"

.PHONY: test
test: check ## Run every static check, then test ALL templates sequentially
	@for t in $(TEMPLATES); do \
		echo "── Testing $$t ──"; \
		$(MAKE) test-template TEMPLATE=$$t; \
	done

## ── Containerfile Sync ───────────────────────────────────────

.PHONY: check-sync
check-sync: ## Verify all Containerfiles match shared/Containerfile
	@failed=0; \
	for f in $(MANAGED_CONTAINERFILES); do \
		if ! diff -q shared/Containerfile "$$f" > /dev/null 2>&1; then \
			echo "DRIFT DETECTED: $$f"; \
			diff shared/Containerfile "$$f" || true; \
			failed=1; \
		else \
			echo "OK: $$f"; \
		fi; \
	done; \
	if [ "$$failed" -eq 1 ]; then \
		echo ""; \
		echo "Fix: make sync-containerfiles"; \
		exit 1; \
	fi

.PHONY: sync-containerfiles
sync-containerfiles: ## Copy shared/Containerfile to all managed Containerfiles
	@for f in $(MANAGED_CONTAINERFILES); do \
		cp shared/Containerfile "$$f"; \
		echo "Synced: $$f"; \
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

.PHONY: clean-containers
clean-containers: ## Remove devcontainer containers and caches
	@echo "Removing devcontainer containers..."
	@docker ps -a --filter "label=devcontainer.local_folder" --format "{{.ID}}" | xargs -r docker rm -f
	@echo "Pruning Docker build cache..."
	@docker builder prune -f
	@echo "Clearing devcontainers CLI OCI cache..."
	@rm -rf /tmp/devcontainercli-$$(whoami)/container-features/
	@echo "Done."

.PHONY: clean
clean: ## Remove docs/dist and caches
	rm -rf docs/dist docs/.astro docs/node_modules/.cache

## ── Help ─────────────────────────────────────────────────────

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
