{
    'name': 'Waran HIS Billing',
    'version': '1.0',
    'depends': ['waran_his_core'],
    'data': [
        'security/ir.model.access.csv',
        'security/billing_rules.xml',
        'views/menu.xml',
        'views/price_list_views.xml',
        'views/charge_views.xml',
    ],
}
