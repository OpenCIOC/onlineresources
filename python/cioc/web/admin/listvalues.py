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
import six
log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET

# 3rd party
from formencode import Schema, foreach, variabledecode, Any
from pyramid.view import view_config, view_defaults
from pyramid.decorator import reify

# this app
from cioc.core import constants as const, validators, syslanguage, rootfactories
from cioc.core.viewbase import init_page_info, error_page

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/listvalues/'


class ListValuesContext(rootfactories.BasicRootFactory):
	def __init__(self, request):
		request.context = self
		self.request = request

		init_page_info(request, const.DM_GLOBAL, const.DM_GLOBAL)

		self.list_type = self._get_list_type()
		self._set_security_values()

	def _get_list_type(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		list_type = request.params.get('list')
		if not list_type:
			error_page(request, _('No checklist selected', request), const.DM_GLOBAL, const.DM_GLOBAL)

		log.debug('list_types: %s', list_types)
		list_type = list_types.get(list_type)
		if not list_type:
			error_page(request, _('Not a valid checklist.', request), const.DM_GLOBAL, const.DM_GLOBAL)

		list_type = list_type(request)

		return list_type

	def _set_security_values(self):
		user = self.request.user

		self.SuperUserGlobal = user.SuperUserGlobal

	@reify
	def OtherMembersActive(self):
		return self.request.dboptions.OtherMembersActive


class ListBaseSchema(Schema):
	if_key_missing = None

	allow_extra_fields = True

	delete = validators.Bool()


class PostSchema(validators.RootSchema):
	if_key_missing = None


@view_defaults(route_name='admin_listvalues')
class ListValues(viewbase.AdminViewBase):

	def _check_security(self, list_type, only_global_super=False):
		user = self.request.user

		if (only_global_super and not user.SuperUserGlobal) or not user.SuperUser:
			self._security_failure()

		return user.SuperUserGlobal

	def _get_edit_info(self, list_type):
		request = self.request

		listitems = []
		with request.connmgr.get_connection('admin') as conn:
			# sp_GBL_BoxType_l or sp_GBL_StreetType_lf or ...
			sql = 'EXEC sp_%s_%s' % (list_type.Table, list_type.ListProcExtension)
			listitems = conn.execute(sql).fetchall()

			list_type.ListName = _(list_type.ListName, request)

		list_type.set_usage(listitems)

		return listitems

	def _get_request_info(self, list_type, title_template):
		request = self.request

		listitems = self._get_edit_info(list_type)

		record_cultures = syslanguage.active_record_cultures()

		title = list_type.ListName if request.viewdata.PrintMode else title_template.format(list_type.ListName)
		return self._create_response_namespace(title, title,
				dict(
					listitems=listitems, SuperUserGlobal=request.context.SuperUserGlobal,
					record_cultures=record_cultures,
					list_type=list_type
				), no_index=True)

	@view_config(renderer=templateprefix + 'index.mak', custom_predicates=[lambda c, r: not c.SuperUserGlobal])
	@view_config(renderer=templateprefix + 'index.mak', request_param='PrintMd=on')
	def index(self):
		list_type = self.request.context.list_type
		self._check_security(list_type)

		return self._get_request_info(list_type, '{0}')

	@view_config(renderer=templateprefix + 'edit.mak')
	def edit(self):
		list_type = self.request.context.list_type
		self._check_security(list_type, True)

		retval = self._get_request_info(list_type, _(list_type.PageTitleTemplate, self.request))

		request = self.request
		request.model_state.form.data['listitem'] = retval['listitems']
		return retval

	@view_config(renderer=templateprefix + 'edit.mak', request_method='POST')
	def save(self):
		request = self.request
		user = request.user

		list_type = self.request.context.list_type
		self._check_security(list_type, True)

		extra_validators = {}
		if list_type.ID:
			extra_validators = {list_type.ID or 'OldValue': Any(list_type.id_validator, validators.OneOf(['NEW']))}

		extra_validators[list_type.NameField] = validators.UnicodeString(max=list_type.NameFieldMaxLength)

		for field in list_type.ExtraFields or []:
			extra_validators[field['field']] = field['validator']

		base_schema = ListBaseSchema(**extra_validators)
		schema_params = {'listitem': foreach.ForEach(base_schema)}
		schema = PostSchema(**schema_params)

		model_state = request.model_state
		model_state.schema = schema

		model_state.form.variable_decode = True

		if model_state.validate():
			# valid. Save changes and redirect

			root = ET.Element('CHECKLIST')
			for listitem in model_state.form.data['listitem']:
				if list_type.ID and not listitem.get(list_type.ID):
					continue

				if not listitem.get(list_type.NameField):
					continue

				if list_type.CanDelete and listitem.get('delete'):
					continue

				list_el = ET.SubElement(root, 'CHK')

				for key, value in six.iteritems(listitem):
					if key == list_type.ID and value == 'NEW':
						value = -1

					elif isinstance(value, bool):
						value = int(value)

					if value is not None:
						ET.SubElement(list_el, key).text = six.text_type(value)

			if list_type.HasModified:
				args = [user.Mod, ET.tostring(root, encoding='unicode')]
			else:
				args = [ET.tostring(root, encoding='unicode')]

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
					DECLARE @RC int, @ErrMsg nvarchar(500)
					EXEC @RC = sp_%s_u %s, @ErrMsg OUTPUT
					SELECT @RC AS [Return], @ErrMsg AS ErrMsg''' % (list_type.Table, ','.join('?' * len(args)))
				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:

				self._go_to_route(request.matched_route.name,
						_query=(('InfoMsg', _('The record(s) were successfully updated.', request)),
							('list', list_type.FieldCode)))

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		listitems = self._get_edit_info(list_type)

		record_cultures = syslanguage.active_record_cultures()
		listitems = variabledecode.variable_decode(request.POST)['listitem']
		model_state.form.data['listitem'] = listitems

		title_template = _(list_type.PageTitleTemplate, self.request)
		title = list_type.ListName if request.viewdata.PrintMode else title_template.format(list_type.ListName)
		return self._create_response_namespace(title, title,
				dict(
					listitems=listitems, record_cultures=record_cultures,
					SuperUserGlobal=request.context.SuperUserGlobal,
					list_type=list_type, ErrMsg=ErrMsg
				), no_index=True)


old_ = _
_ = lambda x: x
_normal_notice_1 = _('<p class="Alert">It is strongly recommended that you do not remove or edit the values that came with the database. Keeping these shared values promotes consistency and facilitates data sharing.</p>')


class ListValuesModel(object):
	FieldName = None
	ListName = None

	ExtraFields = None
	HasModified = True

	DuplicateFields = None

	PageName = _('Edit List / Drop-Down Values')
	PageTitleTemplate = _('Edit Values For: {0}')

	SearchLinkTitle1 = _('CIC:')
	SearchLinkTitle2 = _('Volunteer:')
	SearchLink1 = None
	SearchLink2 = None
	ShowAdd = True
	ShowDelete = True
	ShowNotice1 = _normal_notice_1
	ShowNotice2 = None
	ShowOnForm = False
	CanDelete = True
	CanAdd = True
	CanDeleteCondition = None

	id_validator = validators.IDValidator()

	ListProcExtension = 'lf'

	NameField = 'Name'
	NameFieldMaxLength = 20
	NameFieldSize = 22

	def can_delete_item(self, itemid):
		return True

	@property
	def AdminAreaCode(self):
		return 'CHECK_' + self.FieldCode.upper()

	OtherSqlValidators = None

	HasMunicipality = False

	def __init__(self, request):
		self.request = request

	def set_usage(self, listvalues):
		self.Usage = None


class ListStreetType(ListValuesModel):
	Table = "GBL_StreetType"
	FieldCode = "st"
	AdminAreaCode = 'STREETTYPE'

	NameField = 'StreetType'

	ID = 'SType_ID'

	ListName = _('Street Type')
	ListNamePlural = _('street types')

	ExtraFields = [
		{'type': 'language', 'title': _('Language'), 'field': 'Culture', 'kwargs': {}, 'validator': validators.ActiveCulture(record_cultures=True)},
		{'type': 'checkbox', 'title': _('Display After Street'), 'field': 'AfterName', 'kwargs': {}, 'validator': validators.Bool(), 'element_title': _('Street Type displays after the Street Name: ')}
	]


class ListBoxType(ListValuesModel):
	Table = "GBL_BoxType"
	FieldCode = "bt"
	ID = "BT_ID"

	AdminAreaCode = 'BOXTYPE'

	NameField = 'BoxType'

	ListName = _('Postal Box Type')
	ListNamePlural = _('postal box types')

	ListProcExtension = 'l'


class ListContactHonorific(ListValuesModel):
	Table = "GBL_Contact_Honorific"
	FieldCode = "ch"
	ID = None
	id_validator = validators.UnicodeString(max=20)

	AdminAreaCode = 'HONORIFIC'

	NameField = 'Honorific'

	ListName = _('Contact Honorific')
	ListNamePlural = _('honorifics')

	HasModified = False

	SearchLink1 = ('~/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM GBL_Contact WHERE GblNUM IS NOT NULL AND bt.NUM=GblNUM AND NAME_HONORIFIC=\'IDIDID\')'))
	SearchLink2 = ('~/volunteer/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM GBL_Contact WHERE VolVNUM IS NOT NULL AND vo.VNUM=VolVNUM AND NAME_HONORIFIC=\'IDIDID\')'))


class ListContactPhoneType(ListValuesModel):
	Table = "GBL_Contact_PhoneType"
	FieldCode = "cpt"
	ID = None
	id_validator = validators.UnicodeString(max=20)

	AdminAreaCode = 'PHONETYPE'

	NameField = 'PhoneType'

	ListName = _('Contact Phone Type')
	ListNamePlural = _('phone types')

	ExtraFields = [
		{'type': 'language', 'title': _('Language'), 'field': 'Culture', 'kwargs': {}, 'validator': validators.ActiveCulture(record_cultures=True)},
	]

	HasModified = False

list_types = dict((x.FieldCode, x) for k, x in six.iteritems(globals()) if k.startswith('List') and issubclass(x, ListValuesModel) and x is not ListValuesModel)

_ = old_
del old_
