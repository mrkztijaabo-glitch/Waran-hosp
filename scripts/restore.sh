#!/bin/bash
set -e
source docker/.env 2>/dev/null || true
cat backup.sql | docker compose -f docker/compose.yml exec -T db psql -U ${POSTGRES_USER:-odoo} ${POSTGRES_DB:-odoo}
