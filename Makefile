.PHONY: help install dev dev-backend dev-flutter build build-backend build-flutter
.PHONY: test test-backend lint clean docker docker-down

# Default target
help: ## Show this help message
	@echo "🎓 EduScan - Available Commands:"
	@echo "================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# =====================
# Setup & Installation
# =====================

install: install-web install-backend install-flutter ## Install all dependencies

install-web: ## Install web frontend dependencies
	pnpm install

install-backend: ## Install backend dependencies
	cd backend && pip install -r requirements.txt

install-flutter: ## Install Flutter dependencies
	cd flutter_app && flutter pub get

# =====================
# Development
# =====================

dev: dev-backend ## Start all development servers
	@echo "Backend started. Run 'make dev-web' or 'make dev-flutter' in another terminal."

dev-web: ## Start web frontend dev server
	pnpm dev

dev-backend: ## Start backend dev server
	cd backend && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000

dev-flutter: ## Start Flutter app
	cd flutter_app && flutter run

# =====================
# Build
# =====================

build: build-web ## Build all platforms

build-web: ## Build web frontend
	pnpm build

build-flutter-apk: ## Build Flutter APK
	cd flutter_app && flutter build apk --release

build-flutter-web: ## Build Flutter web
	cd flutter_app && flutter build web

# =====================
# Testing
# =====================

test: test-backend ## Run all tests

test-backend: ## Run backend tests
	cd backend && python -m pytest test_*.py -v

test-flutter: ## Run Flutter tests
	cd flutter_app && flutter test

# =====================
# Linting
# =====================

lint: ## Lint web frontend
	pnpm lint

lint-flutter: ## Lint Flutter app
	cd flutter_app && flutter analyze

# =====================
# Docker
# =====================

docker: ## Start with Docker Compose
	docker-compose up --build -d

docker-down: ## Stop Docker Compose
	docker-compose down

docker-logs: ## View Docker logs
	docker-compose logs -f

# =====================
# Utilities
# =====================

clean: ## Clean build artifacts
	rm -rf .next
	rm -rf flutter_app/build
	rm -rf flutter_app/.dart_tool
	rm -rf backend/__pycache__
	rm -rf backend/**/__pycache__
	cd backend && find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

clean-flutter: ## Clean Flutter build artifacts
	cd flutter_app && flutter clean

# =====================
# Database
# =====================

db-migrate: ## Run database migrations
	cd backend && python scripts/run_migration.py

db-seed: ## Seed test data
	cd backend && python seed_test_data.py

# =====================
# Release
# =====================

version: ## Show current version
	@grep -oP '"version":\s*"\K[^"]+' package.json
	@echo -n "Flutter: "
	@grep -oP 'version:\s*\K[^\s]+' flutter_app/pubspec.yaml