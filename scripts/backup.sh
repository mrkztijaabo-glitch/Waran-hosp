#!/bin/bash
set -e
source docker/.env 2>/dev/null || true
docker compose -f docker/compose.yml exec -T db pg_dump -U ${POSTGRES_USER:-odoo} ${POSTGRES_DB:-odoo} > backup.sql
