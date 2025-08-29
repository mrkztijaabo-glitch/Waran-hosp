from odoo import fields, models

class LabReference(models.Model):
    _name = 'waran.lab_reference'
    _description = 'Lab Reference Range'

    test_type = fields.Selection([
        ('cbc', 'CBC'),
        ('cmp', 'CMP'),
        ('ua', 'Urinalysis')
    ], required=True)
    low = fields.Float()
    high = fields.Float()
