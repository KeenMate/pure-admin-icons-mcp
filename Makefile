.PHONY: build dev publish publish-dry clean

build: ## Build TypeScript
	npm run build

dev: ## Watch mode
	npm run dev

publish-dry: ## Dry run publish
	npm publish --access public --dry-run

publish: ## Publish to npm
	npm publish --access public

clean: ## Clean build artifacts
	rm -rf dist node_modules
