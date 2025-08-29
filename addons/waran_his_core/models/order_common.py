from odoo import fields, models

class OrderCommon(models.AbstractModel):
    _name = 'waran.order_common'
    _description = 'Order Common Mixin'

    order_date = fields.Datetime(default=fields.Datetime.now)
    ordered_by = fields.Many2one('res.users')
    patient_id = fields.Many2one('waran.patient', required=True)
    state = fields.Selection([('draft', 'Draft'), ('done', 'Done')], default='draft')
