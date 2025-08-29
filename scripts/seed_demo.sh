#!/bin/bash
set -e
curl -X POST http://localhost:10069/web/database/ensure_db -d 'master_pwd=admin&name=odoo'
curl -X POST http://localhost:10069/web/session/authenticate -H 'Content-Type: application/json' -d '{"params":{"db":"odoo","login":"admin","password":"admin"}}'
