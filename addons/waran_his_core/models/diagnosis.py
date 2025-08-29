from odoo import fields, models

class Diagnosis(models.Model):
    _name = 'waran.diagnosis'
    _description = 'Diagnosis'

    name = fields.Char(required=True)
    code = fields.Char('ICD10 Code', required=True)
