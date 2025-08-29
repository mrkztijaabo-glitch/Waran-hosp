from odoo import fields, models

class Dispense(models.Model):
    _name = 'waran.dispense'
    _description = 'Dispense'

    prescription_id = fields.Many2one('waran.prescription', required=True)
    dispensed_by = fields.Many2one('res.users')
    date = fields.Datetime(default=fields.Datetime.now)
    qty = fields.Integer()
