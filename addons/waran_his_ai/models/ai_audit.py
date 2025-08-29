from odoo import fields, models

class AIAudit(models.Model):
    _name = 'waran.ai_audit'
    _description = 'AI Audit Log'

    timestamp = fields.Datetime(default=fields.Datetime.now)
    user_id = fields.Many2one('res.users')
    patient_id = fields.Many2one('waran.patient')
    source_model = fields.Char()
    input_summary = fields.Text()
    output_summary = fields.Text()
    raw_prompt = fields.Char()
    raw_response = fields.Char()
