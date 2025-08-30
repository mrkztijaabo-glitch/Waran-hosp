from odoo import fields, models


class PharmacyOrder(models.Model):
    _name = "waran.pharmacy.order"
    _description = "Pharmacy Order"

    name = fields.Char(required=True)
