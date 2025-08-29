#!/bin/bash
set -e

cd "$(dirname "$0")/../docker"

echo ">>> Starting containers..."
docker compose up -d

echo ">>> Initializing Odoo database schema..."
docker compose run --rm odoo \
    odoo -d ${POSTGRES_DB:-odoo} -i base --stop-after-init \
    --db_host=db --db_user=${POSTGRES_USER:-odoo} --db_password=${POSTGRES_PASSWORD:-odoo}

echo ">>> Installing Waran-Hosp modules..."
docker compose run --rm odoo \
    odoo -d ${POSTGRES_DB:-odoo} \
    -i waran_his_core,waran_his_lab,waran_his_pharmacy,waran_his_billing,waran_his_ai \
    --stop-after-init \
    --db_host=db --db_user=${POSTGRES_USER:-odoo} --db_password=${POSTGRES_PASSWORD:-odoo}

echo ">>> Restarting Odoo..."
docker compose restart odoo

echo ">>> Done. Open http://localhost:${ODOO_PORT:-10069} (login: admin/admin)."
