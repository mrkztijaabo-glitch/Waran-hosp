from odoo import fields, models

class ClinicalNote(models.Model):
    _name = 'waran.clinical_note'
    _description = 'Clinical Note'

    encounter_id = fields.Many2one('waran.encounter', required=True)
    subjective = fields.Text()
    objective = fields.Text()
    assessment = fields.Text()
    plan = fields.Text()
    diagnosis_id = fields.Many2one('waran.diagnosis')
