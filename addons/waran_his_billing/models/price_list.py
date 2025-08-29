from odoo import fields, models

class PriceList(models.Model):
    _name = 'waran.price_list'
    _description = 'Price List'

    department = fields.Char()
    item_type = fields.Selection([('visit', 'Visit'), ('lab', 'Lab'), ('drug', 'Drug')], required=True)
    item_ref = fields.Reference([('waran.encounter', 'Visit'), ('waran.lab_order', 'Lab Order'), ('waran.formulary', 'Drug')], string='Item')
    price = fields.Float()
