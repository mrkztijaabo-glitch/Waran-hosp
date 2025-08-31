#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKER_DIR="$ROOT/docker"

# Load .env if present
if [ -f "$DOCKER_DIR/.env" ]; then
  set -a; source "$DOCKER_DIR/.env"; set +a
fi
DB="${POSTGRES_DB:-waranhosp}"
DB_USER="${POSTGRES_USER:-odoo}"
DB_PASS="${POSTGRES_PASSWORD:-odoo}"

dc() { (cd "$DOCKER_DIR" && docker compose "$@"); }

odoo_cmd() {
  dc exec odoo odoo -d "$DB" "$@" \
    --db_host=db --db_user="$DB_USER" --db_password="$DB_PASS"
}

odoo_shell() {
  local py="$1"
  dc run --rm odoo bash -lc "
odoo shell -d \"$DB\" \\
  --db_host=db --db_user=\"$DB_USER\" --db_password=\"$DB_PASS\" <<'PY'
${py}
PY
"
}

set_password() {
  local login="$1"; local password="$2"
  odoo_shell "u = env['res.users'].search([('login', '=', '${login}')], limit=1) or env['res.users'].search([('email', '=', '${login}')], limit=1)
assert u, 'User not found: ${login}'
u.write({'password': '${password}'})
print('Password set for', u.login)
"
}

grant_access() {
  local login="$1"
  odoo_shell "u = env['res.users'].search([('login', '=', '${login}')], limit=1) or env['res.users'].search([('email', '=', '${login}')], limit=1)
assert u, 'User not found: ${login}'
xmlids = [
    'waran_his_core.group_waran_admin',
    'waran_his_core.group_waran_registration',
    'waran_his_core.group_waran_clinical_doctor',
    'waran_his_core.group_waran_clinical_nurse',
    'waran_his_lab.group_waran_lab',
    'waran_his_pharmacy.group_waran_pharmacy',
    'waran_his_billing.group_waran_billing',
]
groups = []
for xid in xmlids:
    try:
        g = env.ref(xid)
        if g:
            groups.append(g.id)
    except ValueError:
        pass
assert groups, 'No HIS groups found by XMLID'
u.write({'groups_id': [(6, 0, groups)]})
print('Granted HIS groups to', u.login, groups)
"
}

usage() {
  cat <<'EOF'
Usage:
  scripts/his_admin.sh install-all
      -> installs all HIS modules (core, lab, pharmacy, billing, ai) and restarts Odoo

  scripts/his_admin.sh set-password <login_or_email> <new_password>
      -> sets password for the given user

  scripts/his_admin.sh grant-access <login_or_email>
      -> grants all HIS department groups to that user

  scripts/his_admin.sh upgrade-all
      -> upgrades all installed modules and restarts Odoo

  scripts/his_admin.sh upgrade <module1> [module2 ...]
      -> upgrades only the listed modules (no restart)

  scripts/his_admin.sh resolve-queued
      -> runs '-u all --stop-after-init' once to clear queued installs

  scripts/his_admin.sh ensure-menus
      -> ensures HIS models have actions and menus

  scripts/his_admin.sh db-fix-and-menus
      -> resets DB password (inside db container), verifies connectivity (from odoo), and ensures menus/actions

  scripts/his_admin.sh fix-db-and-menus
      -> alias of db-fix-and-menus

  scripts/his_admin.sh odoo "<raw args>"
      -> pass raw args to 'odoo' inside the container (advanced)

  scripts/his_admin.sh logs
      -> follow Odoo logs

  scripts/his_admin.sh health
      -> wait until Odoo HTTP endpoint responds
Examples:
  scripts/his_admin.sh install-all
  scripts/his_admin.sh set-password admin admin123
  scripts/his_admin.sh grant-access cfwaran@gmail.com
  scripts/his_admin.sh upgrade-all
  scripts/his_admin.sh upgrade waran_his_lab waran_his_pharmacy
  scripts/his_admin.sh resolve-queued
  scripts/his_admin.sh odoo "-u all --stop-after-init"
  scripts/his_admin.sh logs
  scripts/his_admin.sh db-fix-and-menus
EOF
}

cmd="${1:-}"; shift || true
case "${cmd}" in
  install-all)
    dc up -d
    odoo_cmd -i waran_his_core,waran_his_lab,waran_his_pharmacy,waran_his_billing,waran_his_ai --stop-after-init
    dc restart odoo
    ;;
  upgrade-all)
    odoo_cmd -u all --stop-after-init
    dc restart odoo
    ;;
  upgrade)
    [ "$#" -ge 1 ] || { echo "Usage: scripts/his_admin.sh upgrade <module1> [module2 ...]"; exit 1; }
    IFS=, modules="$*"
    modules="${modules// /,}"
    odoo_cmd -u "${modules}" --stop-after-init
    ;;
  resolve-queued)
    odoo_cmd -u all --stop-after-init
    ;;
  ensure-menus)
    cat "$ROOT/scripts/ensure_menus.py" | \
      dc run --rm -T \
        -e POSTGRES_DB="$DB" \
        -e POSTGRES_USER="$DB_USER" \
        -e POSTGRES_PASSWORD="$DB_PASS" \
        -e PGHOST=db -e PGPORT=5432 \
        odoo python -
    ;;
  db-fix-and-menus|fix-db-and-menus)
    "$ROOT/scripts/db_fix_and_menus.sh"
    ;;
  odoo)
    [ "$#" -ge 1 ] || { echo 'Usage: scripts/his_admin.sh odoo "<raw args>"'; exit 1; }
    odoo_cmd "$@"
    ;;
  logs)
    dc logs -f odoo
    ;;
  health)
    # wait up to ~120s
    for i in $(seq 1 60); do
      if curl -fsS "http://127.0.0.1:${ODOO_PORT:-8069}/web/login" >/dev/null; then
        echo "Odoo is responding"; exit 0
      fi
      sleep 2
    done
    echo "Odoo did not respond in time"; exit 1
    ;;
  set-password)
    [ "$#" -eq 2 ] || { echo 'Usage: scripts/his_admin.sh set-password <login_or_email> <new_password>'; exit 1; }
    set_password "$1" "$2"
    ;;
  grant-access)
    [ "$#" -eq 1 ] || { echo 'Usage: scripts/his_admin.sh grant-access <login_or_email>'; exit 1; }
    grant_access "$1"
    ;;
  ""|-h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $cmd"
    usage
    exit 1
    ;;
esac

