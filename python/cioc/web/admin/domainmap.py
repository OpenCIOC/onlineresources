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
from __future__ import absolute_import
import logging
from collections import namedtuple
import xml.etree.cElementTree as ET


# 3rd party
from formencode import Schema, ForEach, variabledecode
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase
import six
from six.moves import map

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.admin:templates/'

EditInfo = namedtuple('EditInfo', 'domains domain_names cic_views vol_views')


class DomainSchema(Schema):
	if_key_missing = None

	DMAP_ID = validators.IDValidator(not_empty=True)
	DefaultCulture = validators.ActiveCulture(not_empty=True)
	CICViewType = validators.IDValidator()
	VOLViewType = validators.IDValidator()
	SecondaryName = validators.Bool()
	GoogleMapsAPIKeyCIC = validators.String(max=100)
	GoogleMapsClientIDCIC = validators.UnicodeString(max=100)
	GoogleMapsChannelCIC = validators.UnicodeString(max=100)
	GoogleMapsAPIKeyVOL = validators.String(max=100)
	GoogleMapsClientIDVOL = validators.UnicodeString(max=100)
	GoogleMapsChannelVOL = validators.UnicodeString(max=100)
	FullSSLCompatible = validators.Bool()


class DomainMapSchema(validators.RootSchema):
	if_key_missing = None

	domain = ForEach(DomainSchema())


@view_defaults(route_name='admin_domainmap', renderer=templateprefix + 'domainmap.mak')
class DomainMapView(viewbase.AdminViewBase):

	@view_config(request_method='POST')
	def post(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = DomainMapSchema()
		model_state.form.variable_decode = True

		if model_state.validate():
			domains = ET.Element('Domains')

			for domain in model_state.value('domain') or []:
				if not any(domain.values()):
					continue

				el = ET.SubElement(domains, 'Domain')
				for key, val in six.iteritems(domain):
					if isinstance(val, bool):
						ET.SubElement(el, key).text = six.text_type(int(val))

					if val:
						ET.SubElement(el, key).text = six.text_type(val)

			args = [request.dboptions.MemberID, user.Mod, user.cic.SuperUser, user.vol.SuperUser, ET.tostring(domains, encoding='unicode')]

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
					DECLARE @ErrMsg as nvarchar(500),
					@RC as int

					EXECUTE @RC = dbo.sp_GBL_View_DomainMap_u ?,?,?,?, ?, @ErrMsg=@ErrMsg OUTPUT

					SELECT @RC as [Return], @ErrMsg AS ErrMsg
				'''

				cursor = conn.execute(sql, args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				self.request.dboptions._invalidate()
				msg = _('The Domain Name Mapping successfully updated.', request)

				self._go_to_route('admin_domainmap', _query=[('InfoMsg', msg)])

		else:
			ErrMsg = _('There were validation errors.')

		edit_info = self._get_edit_info()._asdict()
		edit_info['ErrMsg'] = ErrMsg

		model_state.form.data = variabledecode.variable_decode(request.POST)

		title = _('Manage Domain Name Mapping', request)
		return self._create_response_namespace(title, title, edit_info, no_index=True)

	@view_config()
	def get(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		edit_info = self._get_edit_info()

		request.model_state.form.data['domain'] = edit_info.domains

		title = _('Manage Domain Name Mapping', request)
		return self._create_response_namespace(title, title, edit_info._asdict(), no_index=True)

	def _get_edit_info(self, all=True):
		request = self.request

		domains = []
		cic_views = []
		vol_views = []
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_View_DomainMap_l ?', request.user.Agency)

			domains = cursor.fetchall()

			cursor.nextset()

			cic_views = cursor.fetchall()

			cursor.nextset()

			vol_views = list(map(tuple, cursor.fetchall()))

		domain_names = {str(x.DMAP_ID): x.DomainName for x in domains}

		return EditInfo(domains, domain_names, cic_views, vol_views)
