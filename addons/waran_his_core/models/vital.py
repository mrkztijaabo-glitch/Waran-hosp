from odoo import fields, models

class Vital(models.Model):
    _name = 'waran.vital'
    _description = 'Vitals'

    encounter_id = fields.Many2one('waran.encounter', required=True)
    temp = fields.Float()
    pulse = fields.Integer()
    resp = fields.Integer()
    bp_systolic = fields.Integer()
    bp_diastolic = fields.Integer()
    spo2 = fields.Integer()
    bmi = fields.Float()
