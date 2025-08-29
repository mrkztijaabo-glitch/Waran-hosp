from odoo import fields, models

class Prescription(models.Model):
    _name = 'waran.prescription'
    _description = 'Prescription'

    encounter_id = fields.Many2one('waran.encounter')
    line_ids = fields.One2many('waran.prescription.line', 'prescription_id')

class PrescriptionLine(models.Model):
    _name = 'waran.prescription.line'
    _description = 'Prescription Line'

    prescription_id = fields.Many2one('waran.prescription')
    drug_id = fields.Many2one('waran.formulary', required=True)
    dose = fields.Char()
    frequency = fields.Char()
    duration = fields.Char()
    instructions = fields.Char()
