# Sakina monorepo tasks. Run `make help` for the list.
# Each target runs from the repo root and works inside the relevant app directory.

BACKEND_DIR := apps/backend
BACKEND_SLN := $(BACKEND_DIR)/Sakina.sln
API_PROJECT := $(BACKEND_DIR)/src/Sakina.Api/Sakina.Api.csproj
MOBILE_DIR  := apps/mobile

.DEFAULT_GOAL := help
.PHONY: help backend-restore backend-build backend-test backend-unit-test backend-lint backend-format backend-run \
        mobile-get mobile-test mobile-analyze mobile-format api-lint test lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

## ---------- Backend (ASP.NET Core 8) ----------

backend-restore: ## Restore NuGet packages
	dotnet restore $(BACKEND_SLN)

backend-build: backend-restore ## Build the solution (warnings are errors)
	dotnet build $(BACKEND_SLN) --no-restore -c Release

backend-test: ## Run all backend tests with coverage (integration tests need Docker)
	dotnet test $(BACKEND_SLN) -c Release --collect:"XPlat Code Coverage" --results-directory $(BACKEND_DIR)/TestResults

backend-unit-test: ## Run backend unit tests only (no Docker needed)
	dotnet test $(BACKEND_DIR)/tests/Sakina.UnitTests -c Release

backend-lint: ## Verify formatting and analyzers (no changes allowed)
	dotnet format $(BACKEND_SLN) --verify-no-changes --severity warn

backend-format: ## Apply dotnet format fixes
	dotnet format $(BACKEND_SLN)

backend-run: ## Run the API locally (needs ConnectionStrings__Default)
	ASPNETCORE_ENVIRONMENT=Development dotnet run --project $(API_PROJECT)

## ---------- Mobile (Flutter) ----------

mobile-get: ## flutter pub get
	cd $(MOBILE_DIR) && flutter pub get

mobile-test: ## Run Flutter tests with coverage
	cd $(MOBILE_DIR) && flutter test --coverage

mobile-analyze: ## Check formatting and run the analyzer
	cd $(MOBILE_DIR) && dart format --output=none --set-exit-if-changed . && flutter analyze

mobile-format: ## Apply dart format
	cd $(MOBILE_DIR) && dart format .

## ---------- Contract ----------

api-lint: ## Lint the OpenAPI contract
	npx --yes @redocly/cli@1.25.11 lint docs/openapi.yaml

## ---------- Aggregates ----------

test: backend-test mobile-test ## Run every test suite
lint: backend-lint mobile-analyze api-lint ## Run every linter
