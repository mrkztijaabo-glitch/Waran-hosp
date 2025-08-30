from odoo import fields, models


class Billing(models.Model):
    _name = "waran.billing"
    _description = "Billing"

    name = fields.Char(required=True)
