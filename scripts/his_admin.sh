#!/usr/bin/env bash
set -euo pipefail

# --- Config from docker/.env with sensible defaults ---
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR/docker"

POSTGRES_DB="${POSTGRES_DB:-${POSTGRES_DB:-odoo}}"
POSTGRES_USER="${POSTGRES_USER:-${POSTGRES_USER:-odoo}}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-${POSTGRES_PASSWORD:-odoo}}"
ODOO_DB="${POSTGRES_DB}"

odoo_shell() {
  local py="$1"
  docker compose run --rm odoo bash -lc "
odoo shell -d "${ODOO_DB}" \
  --db_host=db --db_user="${POSTGRES_USER}" --db_password="${POSTGRES_PASSWORD}" <<'PY'
${py}
PY
"
}

install_modules() {
  local mods="$1"
  docker compose run --rm odoo \
    odoo -d "${ODOO_DB}" -i "${mods}" --stop-after-init \
    --db_host=db --db_user="${POSTGRES_USER}" --db_password="${POSTGRES_PASSWORD}"
}

set_password() {
  local login="$1"
  local password="$2"
  odoo_shell "
u = env['res.users'].search([('login', '=', '${login}')], limit=1) or env['res.users'].search([('email', '=', '${login}')], limit=1)
assert u, 'User not found: ${login}'
u.write({'password': '${password}'})
print('Password set for', u.login)
"
}

grant_his_access() {
  local login="$1"
  odoo_shell "
u = env['res.users'].search([('login', '=', '${login}')], limit=1) or env['res.users'].search([('email', '=', '${login}')], limit=1)
assert u, 'User not found: ${login}'
imd = env['ir.model.data']
xmlids = [
    'waran_his_core.group_waran_admin',
    'waran_his_core.group_waran_registration',
    'waran_his_core.group_waran_clinical_doctor',
    'waran_his_core.group_waran_clinical_nurse',
    'waran_his_lab.group_waran_lab',
    'waran_his_pharmacy.group_waran_pharmacy',
    'waran_his_billing.group_waran_billing',
]
groups = [g for g in (imd.xmlid_to_object(x) for x in xmlids) if g]
u.write({'groups_id': [(6, 0, [g.id for g in groups])]})
print('Granted HIS groups to', u.login, [getattr(g, 'xml_id', None) for g in groups])
"
}

usage() {
  cat <<USAGE
Usage:
  scripts/his_admin.sh install-all
      -> installs all HIS modules (core, lab, pharmacy, billing, ai) and restarts Odoo

  scripts/his_admin.sh set-password <login_or_email> <new_password>
      -> sets password for the given user

  scripts/his_admin.sh grant-access <login_or_email>
      -> grants all HIS department groups to that user

Examples:
  scripts/his_admin.sh install-all
  scripts/his_admin.sh set-password admin admin123
  scripts/his_admin.sh grant-access cfwaran@gmail.com
USAGE
}

case "${1:-}" in
  install-all)
    install_modules "waran_his_core,waran_his_lab,waran_his_pharmacy,waran_his_billing,waran_his_ai"
    docker compose restart odoo
    ;;
  set-password)
    [[ $# -eq 3 ]] || { usage; exit 1; }
    set_password "$2" "$3"
    ;;
  grant-access)
    [[ $# -eq 2 ]] || { usage; exit 1; }
    grant_his_access "$2"
    ;;
  *)
    usage
    exit 1
    ;;
esac

