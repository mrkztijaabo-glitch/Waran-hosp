from odoo import fields, models


class LabRequest(models.Model):
    _name = "waran.lab.request"
    _description = "Lab Request"

    name = fields.Char(required=True)
