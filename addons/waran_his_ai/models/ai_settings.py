from odoo import fields, models

class AISettings(models.TransientModel):
    _inherit = 'res.config.settings'

    ai_enabled = fields.Boolean(string='Enable AI Suggestions', config_parameter='waran_ai.enabled')
