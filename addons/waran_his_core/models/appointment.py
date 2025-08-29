from odoo import fields, models

class Appointment(models.Model):
    _name = 'waran.appointment'
    _description = 'Appointment'

    patient_id = fields.Many2one('waran.patient', required=True)
    provider_id = fields.Many2one('res.users', string='Provider')
    department = fields.Char()
    start = fields.Datetime(required=True)
    end = fields.Datetime()
    status = fields.Selection([
        ('scheduled', 'Scheduled'),
        ('done', 'Done'),
        ('cancel', 'Cancelled')
    ], default='scheduled')
