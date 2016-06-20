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


# std lib
import logging
log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET
import collections
from operator import attrgetter
import itertools
import tempfile
import zipfile
from datetime import datetime

# 3rd party
from formencode import Schema, validators, ForEach
from formencode.variabledecode import variable_decode
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators as ciocvalidators, syslanguage
from cioc.core.bufferedzip import BufferedZipFile
from cioc.core.utf8csv import write_csv_to_zip
from cioc.core.webobfiletool import FileIterator

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/community/'

EditValues = collections.namedtuple('EditValues', 'CM_ID community descriptions alt_names alt_areas prov_state alt_area_name_map shown_cultures')


def xml_to_dict_list(text):
	if not text:
		return []

	root = ET.fromstring('<root>' + text.encode('utf8') + '</root>')

	return [el.attrib for el in root]


class CommunityBaseSchema(Schema):
	if_key_missing = None

	ParentCommunity = ciocvalidators.IDValidator()
	ParentCommunityName = ciocvalidators.UnicodeString()
	ProvinceState = ciocvalidators.IDValidator()


class CommunityDescriptionSchema(Schema):
	if_key_missing = None

	Name = ciocvalidators.UnicodeString(max=200)
	Display = ciocvalidators.UnicodeString(max=200)

	chained_validators = [ciocvalidators.RequireIfAny('Name', present=['Display'])]


class AltNameSchema(Schema):
	if_key_missing = None

	Delete = validators.Bool()
	Culture = ciocvalidators.ActiveCulture(record_cultures=True)
	AltName = ciocvalidators.UnicodeString(max=200)
	New = validators.Bool()


class CommunitySchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	pre_validators = [viewbase.cull_extra_cultures('descriptions')]
	community = CommunityBaseSchema()
	descriptions = ciocvalidators.CultureDictSchema(CommunityDescriptionSchema(),
												record_cultures=True,
												delete_empty=False,
												chained_validators=[ciocvalidators.FlagRequiredIfNoCulture(CommunityDescriptionSchema)])

	alt_names = ForEach(AltNameSchema())


class AltAreasSchema(CommunitySchema):

	alt_areas = ForEach(ciocvalidators.IDValidator(), not_emtpy=True)

	chained_validators = [ciocvalidators.ForceRequire('alt_areas')]


@view_defaults(route_name='admin_community')
class Community(viewbase.AdminViewBase):

	@view_config(route_name='admin_community_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_Community_l')
			communities = cursor.fetchall()
			cursor.close()

		title = _('Manage Communities', request)
		return self._create_response_namespace(title, title, dict(communities=communities), no_index=True)

	@view_config(match_param="action=edit", request_method="POST", renderer=templateprefix + 'edit.mak')
	def save(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		is_alt_area = not not request.params.get('altarea')

		CM_ID = self._get_cmid()
		is_add = not CM_ID

		if not is_add and request.POST.get('Delete'):
			self._go_to_route('admin_community', action='delete', _query=[('CM_ID', CM_ID)])

		model_state = request.model_state
		model_state.form.variable_decode = True
		if is_alt_area:
			log.debug('alt area')
			model_state.schema = AltAreasSchema()
		else:
			log.debug('community')
			model_state.schema = CommunitySchema()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

		if model_state.validate():
			# valid. Save changes and redirect
			data = model_state.form.data
			cm_data = data.get('community', {})
			args = [CM_ID, user.Mod, is_alt_area, cm_data.get('ParentCommunity'),
						cm_data.get('ProvinceState')]

			root = ET.Element('DESCS')

			for culture, description in model_state.form.data['descriptions'].iteritems():
				if culture.replace('_', '-') not in shown_cultures:
					continue

				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in description.iteritems():
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root))

			root = ET.Element('NAMES')

			for name in model_state.form.data.get('alt_names') or []:
				if name.get('Delete') or not name.get('AltName') or \
					(not name.get('New') and
						name['Culture'].replace('_', '-') not in shown_cultures):
					continue

				desc = ET.SubElement(root, 'Name')
				ET.SubElement(desc, 'Culture').text = name['Culture']
				ET.SubElement(desc, 'AltName').text = name['AltName']

			args.append(ET.tostring(root))

			if is_alt_area:
				root = ET.Element('ALTAREAS')
				for area in data.get('alt_areas') or []:
					ET.SubElement(root, 'CM_ID').text = unicode(area)

				args.append(ET.tostring(root))

			else:
				args.append(None)

			root = ET.Element('ShownCultures')
			for culture in shown_cultures:
				ET.SubElement(root, 'Culture').text = culture

			args.append(ET.tostring(root))

			sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@CM_ID as int

				SET @CM_ID = ?

				EXECUTE @RC = dbo.sp_GBL_Community_u @CM_ID OUTPUT, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @CM_ID as CM_ID
				''' % ', '.join('?' * (len(args) - 1))
			with request.connmgr.get_connection('admin') as conn:
				result = conn.execute(sql, *args).fetchone()

			if not result.Return:
				CM_ID = result.CM_ID
				if is_alt_area:
					if is_add:
						msg = _('The Alternate Search Area was successfully added.', request)
					else:
						msg = _('The Alternate Search Area was successfully updated.', request)
				else:
					if is_add:
						msg = _('The Community was successfully added.', request)
					else:
						msg = _('The Community was successfully updated.', request)

				self._go_to_route('admin_community', action='edit', _query=[('InfoMsg', msg), ("CM_ID", CM_ID), ("ShowCultures", shown_cultures)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

			alt_areas = data.get('alt_areas') or []

		else:
			ErrMsg = _('There were validation errors.')

			data = model_state.form.data
			decoded = variable_decode(request.POST)
			alt_areas = decoded.get('alt_areas') or []

			data['alt_areas'] = alt_areas
			data['alt_names'] = decoded.get('alt_names') or []

		edit_values = self._get_edit_info(CM_ID, is_add, alt_areas)

		record_cultures = syslanguage.active_record_cultures()

		# XXX should we refetch the basic info?
		title = _('Manage Communities', request)
		return self._create_response_namespace(title, title,
				dict(community=edit_values.community, CM_ID=CM_ID,
					is_alt_area=is_alt_area, prov_state=edit_values.prov_state,
					alt_area_name_map=edit_values.alt_area_name_map,
					shown_cultures=shown_cultures, record_cultures=record_cultures,
					is_add=is_add, ErrMsg=ErrMsg), no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		CM_ID = self._get_cmid()
		is_add = not CM_ID

		edit_values = self._get_edit_info(CM_ID, is_add)
		if is_add:
			is_alt_area = not not request.params.get('altarea')
		else:
			is_alt_area = edit_values.community.AlternativeArea

		data = request.model_state.form.data
		data['community'] = edit_values.community
		data['descriptions'] = edit_values.descriptions
		data['alt_names'] = edit_values.alt_names
		data['alt_areas'] = [str(x.Search_CM_ID) for x in edit_values.alt_areas]

		title = _('Manage Communities', request)
		return self._create_response_namespace(
			title, title,
			dict(
				community=edit_values.community, CM_ID=CM_ID, is_add=is_add,
				is_alt_area=is_alt_area, prov_state=edit_values.prov_state,
				alt_area_name_map=edit_values.alt_area_name_map,
				shown_cultures=edit_values.shown_cultures,
				record_cultures=syslanguage.active_record_cultures()),
			no_index=True)

	def _get_edit_info(self, CM_ID, is_add, alt_area_get_names=None):
		request = self.request

		community = None
		community_descriptions = {}
		alt_names = []
		alt_areas = []
		prov_state = []
		alt_area_name_map = {}

		with request.connmgr.get_connection('admin') as conn:
			if not is_add:
				cursor = conn.execute('EXEC dbo.sp_GBL_Community_s ?', CM_ID)
				community = cursor.fetchone()
				if community:
					cursor.nextset()
					log.debug('descriptions')
					for lng in cursor.fetchall():
						community_descriptions[lng.Culture.replace('-', '_')] = lng

					cursor.nextset()
					alt_names = cursor.fetchall()

					cursor.nextset()
					alt_areas = cursor.fetchall()

				cursor.close()

				if not community:
					# not found
					self._error_page(_('Community Not Found', request))

			prov_state = map(tuple, conn.execute('SELECT ProvID, GBL_ProvinceStateCountry FROM dbo.vw_GBL_ProvinceStateCountry').fetchall())
			if alt_area_get_names:
				alt_area_name_map = {str(x[0]): x[1] for x in conn.execute('EXEC sp_GBL_Community_ls_Names ?', ','.join(str(x) for x in alt_area_get_names)).fetchall()}

		if community:
			community.AltSearchArea = xml_to_dict_list(community.AltSearchArea)

		if alt_area_get_names is None:
			alt_area_name_map = {str(x[0]): x[1] for x in alt_areas}

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

		return EditValues(CM_ID, community, community_descriptions, alt_names, alt_areas, prov_state, alt_area_name_map, shown_cultures)

	def _get_cmid(self, required=False):
		validator = ciocvalidators.IDValidator(not_empty=required)
		try:
			CM_ID = validator.to_python(self.request.params.get('CM_ID'))
		except validators.Invalid:
			self._error_page(_('Invalid Community ID', self.request))

		return CM_ID

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		CM_ID = self._get_cmid(True)

		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		title = _('Manage Communities', request)
		return self._create_response_namespace(title, title, dict(id_name='CM_ID', id_value=CM_ID, route='admin_community', action='delete'), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.SuperUserGlobal:
			self._security_failure()

		CM_ID = self._get_cmid(True)

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_GBL_Community_d ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, CM_ID)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('admin_community_index', _query=[('InfoMsg', _('The Community was successfully deleted.', request))])

		if result.Return == 3:
			self._error_page(_('Unable to delete Community: ', request) + result.ErrMsg)

		self._go_to_route('admin_community', action='edit', _query=[('ErrMsg', _('Unable to delete Community: ') + result.ErrMsg), ('CM_ID', CM_ID)])

	@view_config(match_param='action=parents', renderer='json')
	@view_config(match_param='action=alt_search_area', renderer='json')
	def autocomplete(self):
		request = self.request

		if not request.user.SuperUserGlobal:
			return []

		term_validator = ciocvalidators.UnicodeString(not_empty=True)
		try:
			terms = term_validator.to_python(request.params.get('term'))
		except validators.Invalid:
			return []

		cm_id_validator = ciocvalidators.IDValidator()
		try:
			cur_parent = cm_id_validator.to_python(request.params.get('parent'))
		except validators.Invalid:
			cur_parent = None

		cur_cm_id = None
		if request.matchdict.get('action') == 'alt_search_area':
			try:
				cur_cm_id = cm_id_validator.to_python(request.params.get('cmid'))
			except validators.Invalid:
				pass

		retval = []
		search_areas = request.matchdict.get('action') == 'alt_search_area'
		with request.connmgr.get_connection('admin') as conn:
			if search_areas:
				cursor = conn.execute('EXEC sp_GBL_Community_ls_SearchAreaSelector ?, ?, ?',
									cur_cm_id, cur_parent, terms)
			else:
				cursor = conn.execute('EXEC sp_GBL_Community_ls_ParentSelector ?, ?',
									cur_parent, terms)

			cols = ['chkid', 'value', 'label']

			retval = [dict(zip(cols, x)) for x in cursor.fetchall()]

			cursor.close()

		return retval

	@view_config(match_param='action=list', renderer=templateprefix + 'list.mak')
	def list(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		CM_ID = self._get_cmid()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_GBL_Community_l_Print ?', CM_ID)
			communities = cursor.fetchall()
			cursor.close()

		for community in communities:
			community.Names = self._culture_dict_from_xml(community.Names, 'Name')
			community.AltNames = u'; '.join(self._list_from_xml(community.AltNames, 'AltNames'))
			community.AltAreaSearch = u'; '.join(self._list_from_xml(community.AltAreaSearch, 'Name'))

		if request.params.get('csv'):
			active_cultures = syslanguage.active_cultures()
			culture_map = syslanguage.culture_map()
			headings = [_('ID')] + [_('Name (%s)') % culture_map[culture].LanguageName for culture in active_cultures]
			headings += [
				_('GUID'),
				_('Parent ID'),
				_('Parent'),
				_("Parent's Parent"),
				_('Province'),
				_('Is Alt-Area'),
				_('Is Parent'),
				_('Located In'),
				_('Areas Served'),
				_('Bus Routes'),
				_('Wards'),
				_('Views'),
			]
			fields = [
				'CM_GUID',
				'ParentCommunity',
				'ParentCommunityName',
				'ParentCommunity2',
				'ProvinceName',
				'AlternativeArea',
				'ParentUsage',
				'LocatedInUsage',
				'AreasServedUsage',
				'BusRouteUsage',
				'WardUsage',
				'ViewUsage',
			]
			if request.dboptions.UseVOL:
				headings += [
					_('Opportunities'),
					_('Community Groups'),
				]
				fields += [
					'VolOppUsage',
					'CommunityGroupUsage',
				]
			headings += [
				_('Alternate Names'),
				_('Alt Area Search'),
			]
			fields += [
				'AltNames',
				'AltAreaSearch',
			]
			form_cultures = [culture_map[culture].FormCulture for culture in active_cultures]

			base_field_getter = attrgetter(*fields)
			name_field_getter = lambda x: tuple(x.Names.get(y, {}).get('Name') for y in form_cultures)

			def row_getter(x):
				return tuple(u'' if y is None else unicode(y) for y in x[0:0] + name_field_getter(x) + base_field_getter(x))

			file = tempfile.TemporaryFile()
			with BufferedZipFile(file, 'w', zipfile.ZIP_DEFLATED) as zip:
				write_csv_to_zip(zip, itertools.chain([headings], itertools.imap(row_getter, communities)), 'communities.csv')

			length = file.tell()
			file.seek(0)
			res = request.response
			res.content_type = 'application/zip'
			res.charset = None
			res.app_iter = FileIterator(file)
			res.content_length = length
			res.headers['Content-Disposition'] = 'attachment;filename=communities-%s.zip' % (datetime.today().isoformat('-').replace(':', '-').split('.')[0])
			return res

		title = _('Manage Communities', request)
		return self._create_response_namespace(title, title, dict(communities=communities, CM_ID=CM_ID), no_index=True)
