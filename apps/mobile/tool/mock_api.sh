#!/bin/sh
# Serves a mock of the Sakina API from the contract (PLAN M0.4, ADR-0011).
# Point the app at it with --dart-define=SAKINA_API_BASE=http://localhost:4010/api/v1
set -eu
cd "$(dirname "$0")/.."
exec npx --yes @stoplight/prism-cli@5 mock ../../docs/openapi.yaml -p "${PORT:-4010}" -h 0.0.0.0
