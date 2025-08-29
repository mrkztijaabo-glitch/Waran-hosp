import os
from odoo import http
from odoo.http import request

class WaranAIController(http.Controller):
    @http.route('/waran/ai/suggest', type='json', auth='user', methods=['POST'])
    def suggest(self, **payload):
        key = os.getenv('OPENAI_API_KEY')
        mode = payload.get('mode')
        response = {}
        if key:
            response = {'suggested_departments': ['General'], 'suggested_labs': ['cbc'], 'triage_level': 'low'}
        else:
            response = {'mock': True, 'suggested_departments': ['General'], 'suggested_labs': [], 'triage_level': 'low'}
        request.env['waran.ai_audit'].sudo().create({
            'user_id': request.env.user.id,
            'source_model': mode,
            'input_summary': str(payload),
            'output_summary': str(response),
        })
        return response
