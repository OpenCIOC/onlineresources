# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================


# stdlib
import logging

# 3rd party
from pyramid.view import view_config, view_defaults
from markupsafe import escape_silent as h, Markup

# this app
from cioc.core.i18n import gettext as _
from cioc.core.viewbase import ViewBase

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.gbl:templates/'

def make_icon_html(icon_type, icon_name, no_blanks=False, extra_class=''):

	if icon_name and not icon_type:
		icon_type, icon_name = icon_name.split('-',1)

	if icon_type == 'fa':
		icon_html = Markup('<i class="fa fa-%s %s"></i>' % (icon_name, extra_class))
	elif icon_type == 'glyphicon':
		icon_html = Markup('<span class="glyphicon glyphicon-%s %s"></span>' % (icon_name, extra_class))
	elif icon_type == 'icon':
		icon_html = Markup('<span class="fa icon-%s %s"></span>' % (icon_name, extra_class))
	elif no_blanks:
		icon_html = '?'
	else:
		icon_html = ''

	return icon_html

@view_defaults(route_name='gbl_iconlist', renderer=templateprefix + 'iconlist.mak')
class IconlistView(ViewBase):
	def __init__(self, request, require_login=True):
		super(IconlistView, self).__init__(request, require_login)

	@view_config()
	def get(self):
		request = self.request
		user = request.user

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			EXEC sp_STP_Icon_ls NULL, NULL
			'''
			cursor = conn.execute(sql)

			icons = cursor.fetchall()

			cursor.close()

		title = _('Browse Icons', request)
		return self._create_response_namespace(title, title, {'icons': icons, 'make_icon_html': make_icon_html}, no_index=True)
