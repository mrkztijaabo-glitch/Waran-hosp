from odoo import api, fields, models

class Patient(models.Model):
    _name = 'waran.patient'
    _description = 'Patient'

    name = fields.Char(required=True)
    sex = fields.Selection([('m', 'Male'), ('f', 'Female'), ('o', 'Other')])
    dob = fields.Date('Date of Birth')
    phone = fields.Char()
    address = fields.Char()
    internal_id = fields.Char(default=lambda self: self.env['ir.sequence'].next_by_code('waran.patient'))
    national_id = fields.Char()
    next_of_kin = fields.Char()
    allergies = fields.Text()
