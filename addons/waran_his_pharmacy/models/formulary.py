from odoo import fields, models

class Formulary(models.Model):
    _name = 'waran.formulary'
    _description = 'Formulary'

    drug_name = fields.Char(required=True)
    strength = fields.Char()
    route = fields.Char()
    atc_code = fields.Char()
