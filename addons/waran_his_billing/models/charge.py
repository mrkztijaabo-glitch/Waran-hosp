from odoo import api, fields, models

class Charge(models.Model):
    _name = 'waran.charge'
    _description = 'Charge'

    patient_id = fields.Many2one('waran.patient', required=True)
    encounter_id = fields.Many2one('waran.encounter')
    item_type = fields.Selection([('visit', 'Visit'), ('lab', 'Lab'), ('drug', 'Drug')])
    item_ref = fields.Reference([('waran.encounter', 'Visit'), ('waran.lab_order', 'Lab Order'), ('waran.formulary', 'Drug')], string='Item')
    qty = fields.Float(default=1.0)
    unit_price = fields.Float()
    total = fields.Float(compute='_compute_total', store=True)
    state = fields.Selection([('draft', 'Draft'), ('posted', 'Posted')], default='draft')

    @api.depends('qty', 'unit_price')
    def _compute_total(self):
        for rec in self:
            rec.total = rec.qty * rec.unit_price

    def action_mark_paid(self):
        self.write({'state': 'posted'})
