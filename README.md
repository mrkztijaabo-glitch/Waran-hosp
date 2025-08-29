# Waran-Hosp

Waran-Hosp is an open-source Hospital Information System built on Odoo 17.

## Quick Start

### Codespaces
1. Create a Codespace on the main branch.
2. Wait for the container to build; Odoo runs on port 10069.
3. In Odoo, activate developer mode, update the apps list and install modules in order:
   `waran_his_core`, `waran_his_lab`, `waran_his_pharmacy`, `waran_his_billing`, `waran_his_ai`.

### Local Docker
```bash
cp docker/.env.example docker/.env
cd docker
docker compose up -d
```
Visit [http://localhost:10069](http://localhost:10069) and install modules as above.

Set `OPENAI_API_KEY` in `docker/.env` to enable AI features.

## Modules
- Core patient management and encounters
- Laboratory orders and results
- Pharmacy prescriptions and dispensing
- Billing lite for self-pay
- Optional AI suggestions (decision-support only)

## AI Disclaimer
AI features provide suggestions only and must not replace clinical judgment.
