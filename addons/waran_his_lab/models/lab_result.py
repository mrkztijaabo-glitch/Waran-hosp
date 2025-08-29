from odoo import api, fields, models

class LabResult(models.Model):
    _name = 'waran.lab_result'
    _description = 'Lab Result'
    _inherit = ['mail.thread']

    lab_order_id = fields.Many2one('waran.lab_order', required=True)
    result_value = fields.Char()
    unit = fields.Char()
    normal_range = fields.Char(readonly=True)
    flag = fields.Selection([
        ('low', 'Low'),
        ('normal', 'Normal'),
        ('high', 'High'),
        ('critical', 'Critical')
    ], compute='_compute_flag', store=True)
    state = fields.Selection([('draft', 'Draft'), ('validated', 'Validated')], default='draft', tracking=True)

    @api.depends('result_value', 'lab_order_id.test_type')
    def _compute_flag(self):
        for rec in self:
            rec.flag = 'normal'
            rec.normal_range = ''
            ref = self.env['waran.lab_reference'].search([('test_type', '=', rec.lab_order_id.test_type)], limit=1)
            if ref:
                rec.normal_range = f"{ref.low}-{ref.high}"
                try:
                    val = float(rec.result_value)
                    if val < ref.low:
                        rec.flag = 'low'
                    elif val > ref.high:
                        rec.flag = 'high'
                    else:
                        rec.flag = 'normal'
                except Exception:
                    rec.flag = 'normal'

    def action_validate(self):
        self.write({'state': 'validated'})
