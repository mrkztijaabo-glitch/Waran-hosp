#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKER_DIR="$ROOT/docker"
ENV_FILE="$DOCKER_DIR/.env"

# Ensure docker compose is available
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is required" >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "Error: docker compose (v2) is required" >&2
  exit 1
fi

# Load environment variables
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
else
  echo "Warning: $ENV_FILE not found, using defaults" >&2
fi

POSTGRES_DB="${POSTGRES_DB:-waranhosp}"
POSTGRES_USER="${POSTGRES_USER:-odoo}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"

if [ -z "$POSTGRES_PASSWORD" ]; then
  echo "Error: POSTGRES_PASSWORD not set in $ENV_FILE" >&2
  exit 1
fi

dc() { (cd "$DOCKER_DIR" && docker compose "$@"); }

hint() {
  echo "Is the stack running? Try: cd docker && docker compose up -d" >&2
}

# Reset DB role/password
SQL="DO \$\$ BEGIN
          IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${POSTGRES_USER}') THEN
            CREATE ROLE ${POSTGRES_USER} LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS PASSWORD '${POSTGRES_PASSWORD}';
          ELSE
            ALTER USER ${POSTGRES_USER} WITH SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS PASSWORD '${POSTGRES_PASSWORD}';
          END IF;
        END \$\$;"

if ! dc exec -T db psql -U "$POSTGRES_USER" -d postgres -v ON_ERROR_STOP=1 -c "$SQL"; then
  hint
  exit 1
fi
echo "✅ reset/created role ${POSTGRES_USER}"

# Verify connectivity from odoo container
if ! dc exec -T odoo bash -lc "PGPASSWORD='${POSTGRES_PASSWORD}' psql -h db -p 5432 -U '${POSTGRES_USER}' -d '${POSTGRES_DB}' -c 'SELECT 1;' >/dev/null"; then
  echo "Error: DB connectivity test failed" >&2
  hint
  exit 1
fi
echo "✅ DB connectivity OK (odoo → db)"

# Ensure menus/actions
ENSURE_SCRIPT="$ROOT/scripts/ensure_menus.py"
if [ -f "$ENSURE_SCRIPT" ]; then
  if ! dc cp "$ENSURE_SCRIPT" odoo:/opt/ensure_menus.py; then
    hint
    exit 1
  fi
  if ! dc exec -T \
      -e POSTGRES_DB="${POSTGRES_DB}" \
      -e PGHOST=db -e PGPORT=5432 \
      -e PGUSER="${POSTGRES_USER}" \
      -e PGPASSWORD="${POSTGRES_PASSWORD}" \
      odoo python3 /opt/ensure_menus.py; then
    hint
    exit 1
  fi
  echo "✅ menus/actions ensured"
else
  echo "⚠️ $ENSURE_SCRIPT not found; skipping menu/action fixes" >&2
fi

echo "Next steps:"
echo " - Hard refresh the browser and check Settings → Technical → Actions → Window Actions (search 'waran')."
echo " - If menus are still hidden, go to Settings → Technical → User Interface → Menu Items and clear the Groups field or set to Internal User."
