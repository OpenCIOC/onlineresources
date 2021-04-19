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


from __future__ import absolute_import
import logging
import six
from six.moves import map
log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET
from six.moves.urllib.parse import parse_qsl
from six.moves.urllib.parse import urlencode

from formencode import Schema, validators, foreach, variabledecode, Any, schema
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/'


search_pages = frozenset([
	'bresults.asp',
	'cresults.asp',
	'results.asp',
	'sresults.asp',
	'tresults.asp',
])


def should_skip_item(quicksearch):
	if not quicksearch.get('QuickSearchID'):
		return True

	if quicksearch.get('delete'):
		return True

	if quicksearch.get('QuickSearchID') == 'NEW':
		log.debug('quicksearch: %s', quicksearch)
		if all(not v for k, v in six.iteritems(quicksearch) if k not in ['PageName', 'Descriptions', 'QuickSearchID', 'DisplayOrder']):
			descriptions = quicksearch.get('Descriptions') or {}
			if not descriptions or all(not v for d in descriptions.values() for v in d.values()):
				return True

	return False


@schema.SimpleFormValidator
def cull_skippable_items(value_dict, state, self):
	items = value_dict.get('quicksearch') or []

	new_items = []
	for item in items:
		descriptions = item.get('Descriptions') or {}
		for key, value in descriptions.items():
			if not value.get('Name'):
				del descriptions[key]

		if should_skip_item(item):
			continue
		new_items.append(item)

	value_dict['quicksearch'] = new_items


class QuickSearchDescriptionSchema(Schema):
	if_key_missing = None

	Name = ciocvalidators.UnicodeString(max=100, not_empty=True)


class QuickSearchBaseSchema(Schema):
	if_key_missing = None

	QuickSearchID = Any(ciocvalidators.IDValidator(), validators.OneOf(['NEW']))
	DisplayOrder = validators.Int(min=0, max=255, not_empty=True)
	PageName = validators.OneOf(search_pages)
	PromoteToTab = validators.Bool()
	QueryParameters = ciocvalidators.String(max=1000, not_empty=True)
	delete = validators.Bool()

	Descriptions = ciocvalidators.CultureDictSchema(
		QuickSearchDescriptionSchema(), allow_extra_fields=True, fiter_extra_fields=False,
		chained_validators=[ciocvalidators.FlagRequiredIfNoCulture(QuickSearchDescriptionSchema)]
	)


class PostSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	pre_validators = [
		cull_skippable_items
	]
	quicksearch = foreach.ForEach(QuickSearchBaseSchema())


@view_defaults(route_name='admin_view', match_param="action=quicksearch", renderer=templateprefix + 'quicksearch.mak', request_param="DM=" + str(const.DM_CIC))
class QuickSearch(viewbase.AdminViewBase):

	@view_config()
	def index(self):
		request = self.request

		ViewType, domain = self._basic_info()

		edit_info = self._get_edit_info(domain, ViewType)

		if not edit_info['viewinfo']:  # not a valid view
			self._error_page(_('View Not Found', request))

		quicksearches = edit_info['quicksearches']
		for quicksearch in quicksearches:
			quicksearch.Descriptions = self._culture_dict_from_xml(quicksearch.Descriptions, 'DESC')

		request.model_state.form.data['quicksearch'] = quicksearches

		title = _('Quick Searches (%s)', request) % edit_info['viewinfo'].ViewName

		return self._create_response_namespace(
			title,
			title,
			edit_info,
			no_index=True,
			print_table=False
		)

	@view_config(request_method="POST")
	def save(self):
		request = self.request
		user = request.user

		ViewType, domain = self._basic_info()

		model_state = request.model_state
		model_state.schema = PostSchema()

		model_state.form.variable_decode = True

		if model_state.validate():
			# valid. Save changes and redirect

			root = ET.Element('QuickSearches')
			for i, quicksearch in enumerate(model_state.form.data['quicksearch']):
				if should_skip_item(quicksearch):
					continue

				quicksearch_el = ET.SubElement(root, 'QuickSearch')
				ET.SubElement(quicksearch_el, 'CNT').text = six.text_type(i)

				qp = quicksearch['QueryParameters']
				if '?' in qp:
					page, qp = qp.split('?', 1)

					page = page.rsplit('/', 1)[-1]
					if page in search_pages:
						quicksearch['PageName'] = page

				skip = ['UseCICVw', 'Ln', 'UseVOLVw', 'Number']

				try:
					qp = urlencode([(k, v) for k, v in parse_qsl(qp, True) if (k not in skip and (k != 'page' or v == 'all'))])
				except ValueError:
					pass

				quicksearch['QueryParameters'] = qp

				for key, value in six.iteritems(quicksearch):
					if key == 'QuickSearchID' and value == 'NEW':
						value = -1

					if key != 'Descriptions':
						if value is not None:
							ET.SubElement(quicksearch_el, key).text = six.text_type(value)
						continue

					descs = ET.SubElement(quicksearch_el, 'DESCS')
					for culture, data in six.iteritems((value or {})):
						culture = culture.replace('_', '-')

						desc = ET.SubElement(descs, 'DESC')
						ET.SubElement(desc, 'Culture').text = culture
						for key, value in six.iteritems(data):
							if value:
								ET.SubElement(desc, key).text = value

			args = [ViewType, user.Mod, request.dboptions.MemberID, user.Agency, ET.tostring(root, encoding='unicode')]

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int

				EXECUTE @RC = dbo.sp_%s_View_QuickSearch_u ?, ?, ?, ?, ?, @ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % domain.str

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:

				self._go_to_route('admin_view', action="quicksearch",
						_query=[('InfoMsg', _('The Quick Searches were successfully updated.', request)),
							('DM', domain.id), ('ViewType', ViewType)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		edit_info = self._get_edit_info(domain, ViewType)
		edit_info['ErrMsg'] = ErrMsg

		quicksearches = variabledecode.variable_decode(request.POST)['quicksearch']
		model_state.form.data['quicksearch'] = quicksearches

		title = _('Change Quick Searches', request)
		return self._create_response_namespace(title, title, edit_info,
			no_index=True, print_table=False)

	def _get_edit_info(self, domain, ViewType):
		request = self.request
		user = request.user

		quicksearches = []
		pages = []
		viewinfo = None
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_%s_View_QuickSearch_lf ?, ?, ?' % domain.str, request.dboptions.MemberID, user.Agency, ViewType)

			viewinfo = cursor.fetchone()
			if viewinfo:

				cursor.nextset()

				pages = list(map(tuple, cursor.fetchall()))

				cursor.nextset()

				quicksearches = cursor.fetchall()

			cursor.close()

		return {'quicksearches': quicksearches, 'pages': pages, 'viewinfo': viewinfo, 'domain': domain, 'ViewType': ViewType}

	def _basic_info(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain = viewbase.get_domain(request.params)
		if not domain:
			return self._go_to_page('~/admin/setup.asp')

		if (domain.id == const.DM_CIC and not user.cic.SuperUser) or \
			(domain.id == const.DM_VOL and not user.vol.SuperUser):

			self._security_failure()

		validator = ciocvalidators.IDValidator(not_empty=True)
		try:
			ViewType = validator.to_python(request.params.get('ViewType'))
		except validators.Invalid as e:
			self._error_page(_('Invalid View Type: ', request) + e.message)

		return ViewType, domain
