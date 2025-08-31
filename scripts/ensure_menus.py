#!/usr/bin/env python3
"""Ensure HIS models have actions and menus.

Reads database credentials from environment variables or a `.env` file and
connects to the Odoo registry. For each model whose technical name starts with
`waran.` it ensures there is an `ir.actions.act_window` (tree/form) and a
corresponding `ir.ui.menu` under the root menu
`waran_his_core.waran_menu_root`.
"""

import os
from pathlib import Path

import odoo
from odoo import api
from odoo.modules.registry import Registry
from odoo.tools import config


def load_env() -> None:
    """Load environment variables from `docker/.env` if present."""
    try:
        root = Path(__file__).resolve().parents[1]
    except Exception:  # when running from stdin
        root = Path.cwd()
    env_file = root / "docker" / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())


def ensure_menus() -> None:
    load_env()

    db = os.getenv("POSTGRES_DB", "waranhosp")
    user = os.getenv("POSTGRES_USER", "odoo")
    password = os.getenv("POSTGRES_PASSWORD", "odoo")
    host = os.getenv("PGHOST", "db")
    port = os.getenv("PGPORT", "5432")
    addons_path = os.getenv(
        "ODOO_ADDONS_PATH",
        "/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons",
    )

    config["db_host"] = host
    config["db_port"] = port
    config["db_user"] = user
    config["db_password"] = password
    config["addons_path"] = addons_path

    registry = Registry.new(db)
    with registry.cursor() as cr:
        env = api.Environment(cr, odoo.SUPERUSER_ID, {})
        try:
            root_menu = env.ref("waran_his_core.waran_menu_root")
        except ValueError as exc:
            raise SystemExit("Root menu waran_his_core.waran_menu_root not found") from exc

        seq = 10
        for model in sorted(m for m in registry.models if m.startswith("waran.")):
            desc = env[model]._description or model
            action = env["ir.actions.act_window"].search(
                [("res_model", "=", model), ("view_mode", "=", "tree,form")],
                limit=1,
            )
            if not action:
                action = env["ir.actions.act_window"].create(
                    {
                        "name": desc,
                        "res_model": model,
                        "view_mode": "tree,form",
                    }
                )
            menu = env["ir.ui.menu"].search(
                [
                    ("parent_id", "=", root_menu.id),
                    ("action", "=", f"ir.actions.act_window,{action.id}"),
                ],
                limit=1,
            )
            if not menu:
                env["ir.ui.menu"].create(
                    {
                        "name": desc,
                        "parent_id": root_menu.id,
                        "action": f"ir.actions.act_window,{action.id}",
                        "sequence": seq,
                    }
                )
                seq += 10
    print("✅ menus/actions ensured")


if __name__ == "__main__":
    ensure_menus()
