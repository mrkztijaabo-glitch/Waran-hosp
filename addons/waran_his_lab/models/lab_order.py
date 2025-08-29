from odoo import fields, models

class LabOrder(models.Model):
    _name = 'waran.lab_order'
    _inherit = 'waran.order_common'
    _description = 'Lab Order'

    test_type = fields.Selection([
        ('cbc', 'CBC'),
        ('cmp', 'CMP'),
        ('ua', 'Urinalysis')
    ], required=True)
    priority = fields.Selection([('normal', 'Normal'), ('stat', 'STAT')], default='normal')
    specimen = fields.Char()
    status = fields.Selection([
        ('draft', 'Draft'),
        ('collected', 'Collected'),
        ('done', 'Done')
    ], default='draft')
