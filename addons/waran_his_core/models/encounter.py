from odoo import fields, models

class Encounter(models.Model):
    _name = 'waran.encounter'
    _description = 'Encounter'

    patient_id = fields.Many2one('waran.patient', required=True)
    provider_id = fields.Many2one('res.users')
    date = fields.Datetime(default=fields.Datetime.now)
    reason = fields.Char()
    appointment_id = fields.Many2one('waran.appointment')
    state = fields.Selection([
        ('open', 'Open'),
        ('done', 'Done')
    ], default='open')

    def action_ai_suggest(self):
        return {
            'type': 'ir.actions.client',
            'tag': 'display_notification',
            'params': {
                'title': 'AI is decision-support only',
                'message': 'Mock suggestion',
                'sticky': True,
            }
        }
