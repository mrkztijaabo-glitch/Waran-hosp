#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[32m"
RESET="\033[0m"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKER_DIR="$ROOT/docker"
ENV_FILE="$DOCKER_DIR/.env"

# Ensure docker compose is available
if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required" >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose is required" >&2
  exit 1
fi

# Load environment variables
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "Warning: $ENV_FILE not found, using defaults" >&2
fi

DB="${POSTGRES_DB:-waranhosp}"
USER="${POSTGRES_USER:-odoo}"
PASS="${POSTGRES_PASSWORD:-odoo}"

dc() {
  (cd "$DOCKER_DIR" && docker compose "$@")
}

# 1. Reset password
printf 'Resetting Postgres password for %s...\n' "$USER"
dc exec db psql -U postgres -c "ALTER USER $USER WITH PASSWORD '$PASS';" >/dev/null
printf "%b✅ reset password for %s%b\n" "$GREEN" "$USER" "$RESET"

# 2. Verify connectivity from odoo container
printf 'Testing database connectivity from odoo container...\n'
if ! dc exec odoo bash -lc "PGPASSWORD='$PASS' psql -h db -U '$USER' -d '$DB' -c 'SELECT 1;' >/dev/null"; then
  echo "Error: database connection test failed" >&2
  exit 1
fi
printf "%b✅ DB connectivity OK%b\n" "$GREEN" "$RESET"

# 3. Ensure menus/actions
ENSURE_SCRIPT="$ROOT/scripts/ensure_menus.py"
if [ ! -f "$ENSURE_SCRIPT" ]; then
  echo "Error: $ENSURE_SCRIPT not found" >&2
  exit 1
fi

printf 'Copying ensure_menus.py into odoo container...\n'
dc cp "$ENSURE_SCRIPT" odoo:/opt/ensure_menus.py

printf 'Running ensure_menus.py...\n'
dc exec \
  -e POSTGRES_DB="$DB" \
  -e PGHOST=db \
  -e PGPORT=5432 \
  -e PGUSER="$USER" \
  -e PGPASSWORD="$PASS" \
  odoo python3 /opt/ensure_menus.py >/dev/null
printf "%b✅ menus/actions ensured%b\n" "$GREEN" "$RESET"
