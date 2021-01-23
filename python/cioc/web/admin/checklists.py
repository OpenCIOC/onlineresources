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

from formencode import schema, Schema, validators, foreach, variabledecode, Any
from pyramid.view import view_config
from pyramid.decorator import reify

from cioc.core import validators as ciocvalidators, constants as const, syslanguage, rootfactories
from cioc.core.viewbase import init_page_info, error_page, security_failure

from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/checklists/'

from .checklist_model import checklists, ChkExtraChecklist, ChkExtraDropDown


def should_skip_item(chk_type, chkitem):
	if not chkitem.get(chk_type.ID):
		return True

	if all(not v for k, v in six.iteritems(chkitem) if k != 'Descriptions' and not (k == chk_type.ID and v == 'NEW')):

		if all(not v for d in chkitem.get('Descriptions', {}).values() for k, v in d.items()):
			return True

	if chk_type.CanDelete and chkitem.get('delete'):
		return True

	return False


@schema.SimpleFormValidator
def cull_skippable_items(value_dict, state, self):
	items = value_dict.get('chkitem') or []

	new_items = []
	for item in items:
		if should_skip_item(state.chk_type, item):
			continue
		new_items.append(item)

	value_dict['chkitem'] = new_items


class ChecklistContext(rootfactories.BasicRootFactory):

	def __init__(self, request):
		request.context = self
		self.request = request

		init_page_info(request, const.DM_GLOBAL, const.DM_GLOBAL)

		self.chk_type = self._get_chk_type()
		self._set_security_values()

	def _get_chk_type(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			security_failure(request)

		chklst = request.params.get('chk')
		if not chklst:
			error_page(request, _('No checklist selected', request), const.DM_GLOBAL, const.DM_GLOBAL)

		chk_type = checklists.get(chklst)
		if not chk_type:
			if chklst.startswith('exc'):
				chk_type = ChkExtraChecklist
			elif chklst.startswith('exd'):
				chk_type = ChkExtraDropDown
			elif chklst.startswith('vxc'):
				chk_type = ChkExtraChecklist
			elif chklst.startswith('vxd'):
				chk_type = ChkExtraDropDown
			else:
				error_page(request, _('Not a valid checklist.', request), const.DM_GLOBAL, const.DM_GLOBAL)

		chk_type = chk_type(request)

		return chk_type

	def _set_security_values(self):
		user = self.request.user
		chk_type = self.chk_type

		user_dom = None
		if chk_type.Domain.id == const.DM_CIC:
			user_dom = user.cic
		elif chk_type.Domain.id == const.DM_VOL:
			user_dom = user.vol

		self.user_dom = user_dom
		self.SuperUserGlobal = (user_dom and user_dom.SuperUserGlobal) or (not user_dom and user.SuperUserGlobal)

	@reify
	def OtherMembersActive(self):
		return self.request.dboptions.OtherMembersActive


class ChecklistDescriptionSchema(Schema):
	if_key_missing = None

	Name = ciocvalidators.UnicodeString(max=200)


class ChecklistBaseSchema(Schema):
	if_key_missing = None
	allow_extra_fields = True

	delete = validators.Bool()


def make_checklist_base_schema(extra_description_validators=None, **extra_validators):
	if extra_description_validators is None:
		extra_description_validators = {}

	extra_validators['Descriptions'] = ciocvalidators.CultureDictSchema(ChecklistDescriptionSchema(**extra_description_validators), record_cultures=True, allow_extra_fields=True, fiter_extra_fields=False)

	return ChecklistBaseSchema(**extra_validators)


class PostSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	pre_validators = [viewbase.cull_extra_cultures('Descriptions', 'chkitem'), cull_skippable_items]
	# chkitem = foreach.ForEach(ChecklistBaseSchema())

	shared = validators.Bool()


class HideSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	ChkHide = foreach.ForEach(ciocvalidators.IDValidator())


class Checklists(viewbase.AdminViewBase):

	def _check_security(self, chk_type, only_global_super):
		user = self.request.user

		if (only_global_super and not user.SuperUserGlobal) or not user.SuperUser:
			self._security_failure()

		user_dom = self.request.context.user_dom
		if user_dom and ((only_global_super and not user_dom.SuperUserGlobal) or not user_dom.SuperUser):
			self._security_failure()

		return (user_dom and user_dom.SuperUserGlobal) or (not user_dom and user.SuperUserGlobal)

	def _get_edit_info(self, chk_type, only_mine, only_shared, no_other):
		request = self.request

		chkitems = []
		chkusage = {}
		with request.connmgr.get_connection('admin') as conn:
			sql = chk_type.SelectSQL(only_mine, only_shared, no_other) + (chk_type.UsageSQL or '') + (chk_type.NameSQL or '') + chk_type.OtherMemberItemsCountSQL
			cursor = conn.execute(sql)
			chkitems = cursor.fetchall()

			if chk_type.UsageSQL:
				cursor.nextset()

				chkusage = dict((six.text_type(x[0]), x) for x in cursor.fetchall())

			if chk_type.NameSQL:
				cursor.nextset()
				row = cursor.fetchone()
				if row:
					chk_type.CheckListName = row[0]
				else:
					error_page(request, _('Not a valid checklist.', request), const.DM_GLOBAL, const.DM_GLOBAL)

			else:
				chk_type.CheckListName = _(chk_type.CheckListName, request)

			if chk_type.OtherMemberItemsCountSQL:
				cursor.nextset()
				chk_type.OtherMemberItemsCount = cursor.fetchone()[0]
			else:
				chk_type.OtherMemberItemsCount = 0

			cursor.close()

		for chkitem in chkitems:
			chkitem.Descriptions = self._culture_dict_from_xml(chkitem.Descriptions, 'DESC')

		for field in chk_type.ExtraFields or []:
			fformat = field.get('format')

			if not fformat:
				continue

			elif not callable(fformat):
				format_fn = lambda x, y: format(x, fformat)
			else:
				format_fn = fformat

			for chkitem in chkitems:
				try:
					val = getattr(chkitem, field['field'])
					setattr(chkitem, field['field'], format_fn(val, request))
				except AttributeError:
					pass

		return chkitems, chkusage

	def _get_request_info(self, chk_type, SuperUserGlobal, only_mine, only_other, title_template):
		log.debug('SuperUserGlobal, only_mine, only_other: %s,%s,%s', SuperUserGlobal, only_mine, only_other)
		request = self.request

		chkitems, chkusage = self._get_edit_info(chk_type, only_mine, only_other, not SuperUserGlobal)

		record_cultures = syslanguage.active_record_cultures()
		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)

		title = chk_type.CheckListName if request.viewdata.PrintMode else title_template.format(chk_type.CheckListName)
		return self._create_response_namespace(
			title, title,
			dict(
			chkitems=chkitems, SuperUserGlobal=SuperUserGlobal,
			record_cultures=record_cultures,
			shown_cultures=shown_cultures, chkusage=chkusage, chk_type=chk_type),
			no_index=True)

	@view_config(route_name='admin_checklists', request_method='POST', renderer=templateprefix + 'index.mak')
	def hide(self):
		chk_type = self.request.context.chk_type
		SuperUserGlobal = self._check_security(chk_type, False)

		if chk_type.Shared == 'full':
			return  # this is not a valid state

		request = self.request
		model_state = request.model_state
		model_state.schema = HideSchema()

		if model_state.validate():
			extra_delete_condition = chk_type.ExtraHideDeleteCondition or ''
			sql = '''
					DECLARE @MemberID int
					SET @MemberID = ?

					MERGE INTO %(Table)s_InactiveByMember chk
					USING (SELECT DISTINCT ItemID AS %(ID)s FROM
							dbo.fn_GBL_ParseIntIDList(?, ',') nt
							INNER JOIN %(Table)s c
								ON c.%(ID)s=nt.ItemID AND c.MemberID IS NULL) nt
					ON nt.%(ID)s=chk.%(ID)s AND chk.MemberID=@MemberID
					WHEN NOT MATCHED BY TARGET THEN
						INSERT (%(ID)s, MemberID) VALUES (nt.%(ID)s, @MemberID)
					WHEN NOT MATCHED BY SOURCE AND chk.MemberID=@MemberID%(ExtraDeleteCondition)s THEN
						DELETE
						;
					''' % {'Table': chk_type.Table, 'ID': chk_type.ID, 'ExtraDeleteCondition': extra_delete_condition}

			with request.connmgr.get_connection('admin') as conn:
				conn.execute(sql, request.dboptions.MemberID, ','.join(map(str, model_state.value('ChkHide') or [])))

			return self._go_to_route('admin_checklists', _query=[('chk', chk_type.FieldCode), ('InfoMsg', _('Visibility Settings Saved', request))])

		retval = self._get_request_info(chk_type, SuperUserGlobal, True, False, _(chk_type.ManagePageTitleTemplate, self.request))

		request = self.request
		if request.matched_route.name == 'admin_checklists':
			request.model_state.form.data['ChkHide'] = [getattr(x, chk_type.ID) for x in retval['chkitems']]

		return retval

	@view_config(route_name='admin_checklists', renderer=templateprefix + 'index.mak')
	@view_config(route_name='admin_checklists', renderer=templateprefix + 'index.mak', request_param='PrintMd=on', custom_predicates=[lambda c, r: not c.OtherMembersActive or (c.SuperUserGlobal and c.chk_type.Shared == 'full')])
	def index(self):
		chk_type = self.request.context.chk_type
		SuperUserGlobal = self._check_security(chk_type, chk_type.Shared == 'full')

		retval = self._get_request_info(chk_type, SuperUserGlobal, False, False, _(chk_type.ManagePageTitleTemplate, self.request))

		request = self.request
		if chk_type.Shared == 'partial':
			request.model_state.form.data['ChkHide'] = [six.text_type(getattr(x, chk_type.ID)) for x in retval['chkitems'] if x.Hidden]
		return retval

	@view_config(route_name='admin_checklists_shared', renderer=templateprefix + 'edit.mak')
	@view_config(route_name='admin_checklists_local', renderer=templateprefix + 'edit.mak')
	@view_config(route_name='admin_checklists', renderer=templateprefix + 'edit.mak', custom_predicates=[lambda c, r: not c.OtherMembersActive or c.chk_type.Shared == 'full'])
	def edit(self):
		chk_type = self.request.context.chk_type
		SuperUserGlobal = self._check_security(chk_type, chk_type.Shared == 'full')

		all_values = not self.request.dboptions.OtherMembersActive
		shared_values = not not (all_values or not self.request.matched_route.name.endswith('_local'))

		if shared_values and not SuperUserGlobal:
			self._security_failure()

		if chk_type.Shared == 'full' and not shared_values:
			self._error_page(_('This checklist does not support local values', self.request))

		type_name = ''
		if chk_type.Shared == 'partial' and not all_values:
			if shared_values:
				type_name = _('Shared', self.request)
			else:
				type_name = _('Local', self.request)

		retval = self._get_request_info(chk_type, SuperUserGlobal, not all_values and not shared_values, not all_values and shared_values, _(chk_type.PageTitleTemplate, self.request) % {'type': type_name})

		request = self.request
		request.model_state.form.data['chkitem'] = retval['chkitems']
		return retval

	@view_config(route_name='admin_checklists_shared', renderer=templateprefix + 'edit.mak', request_method='POST')
	@view_config(route_name='admin_checklists_local', renderer=templateprefix + 'edit.mak', request_method='POST')
	@view_config(route_name='admin_checklists', renderer=templateprefix + 'edit.mak', request_method='POST', custom_predicates=[lambda c, r: not c.OtherMembersActive or (c.SuperUserGlobal and c.chk_type.Shared == 'full')])
	def save(self):
		request = self.request
		user = request.user

		chk_type = self.request.context.chk_type
		all_values = not self.request.dboptions.OtherMembersActive
		shared_values = not not (all_values or not self.request.matched_route.name.endswith('_local'))
		SuperUserGlobal = self._check_security(chk_type, chk_type.Shared == 'full' or shared_values)

		if shared_values and not SuperUserGlobal:
			self._security_failure()

		if chk_type.ShowAdd:
			extra_validators = {chk_type.ID: Any(ciocvalidators.IDValidator(), validators.OneOf(['NEW']))}
		else:
			extra_validators = {chk_type.ID: ciocvalidators.IDValidator(not_empty=chk_type.CanDelete)}
		if chk_type.CodeTitle:
			if not chk_type.CodeValidator:
				extra_validators[chk_type.CodeField] = ciocvalidators.String(max=chk_type.CodeMaxLength)
			else:
				extra_validators[chk_type.CodeField] = chk_type.CodeValidator

		if chk_type.DisplayOrder:
			extra_validators['DisplayOrder'] = validators.Int(min=0, max=256, if_empty=0)
		if chk_type.ShowOnForm:
			extra_validators['ShowOnForm'] = validators.Bool()

		for field in chk_type.ExtraFields or []:
			extra_validators[field['field']] = field['validator']

		extra_name_validators = {}
		for field in chk_type.ExtraNameFields or []:
			extra_name_validators[field['field']] = field['validator']

		base_schema = make_checklist_base_schema(extra_name_validators, **extra_validators)
		schema_params = {'chkitem': foreach.ForEach(base_schema)}
		schema = PostSchema(**schema_params)

		model_state = request.model_state
		model_state.form.state.chk_type = chk_type
		model_state.schema = schema

		model_state.form.variable_decode = True

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if model_state.validate():
			# valid. Save changes and redirect

			root = ET.Element('CHECKLIST')
			for i, chkitem in enumerate(model_state.form.data['chkitem']):
				if should_skip_item(chk_type, chkitem):
					continue

				chk_el = ET.SubElement(root, 'CHK')
				ET.SubElement(chk_el, "CNT").text = six.text_type(i)

				for key, value in six.iteritems(chkitem):
					if key == chk_type.ID and value == 'NEW':
						value = -1

					elif isinstance(value, bool):
						value = int(value)

					if key != 'Descriptions':
						if value is not None:
							ET.SubElement(chk_el, key).text = six.text_type(value)
						continue

					descs = ET.SubElement(chk_el, 'DESCS')
					for culture, data in six.iteritems(value):
						culture = culture.replace('_', '-')
						if culture not in shown_cultures:
							continue

						desc = ET.SubElement(descs, 'DESC')
						ET.SubElement(desc, 'Culture').text = culture
						for key, value in six.iteritems(data):
							if value:
								ET.SubElement(desc, key).text = value

			args = [request.dboptions.MemberID, user.Mod, ET.tostring(root)]

			with request.connmgr.get_connection('admin') as conn:
				sql = chk_type.UpdateSQL(shared_values)
				log.debug('sql: %s', sql)
				log.debug('args: %s', args)
				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:

				self._go_to_route(request.matched_route.name,
						_query=(('InfoMsg', _('The record(s) were successfully updated.', request)),
							('ShowCultures', shown_cultures),
							('chk', chk_type.FieldCode)))

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		chkitems, chkusage = self._get_edit_info(chk_type, not all_values and not shared_values, not all_values and shared_values, not SuperUserGlobal)

		record_cultures = syslanguage.active_record_cultures()

		chkitems = variabledecode.variable_decode(request.POST)['chkitem']
		model_state.form.data['chkitem'] = chkitems

		type_name = ''
		if chk_type.Shared == 'partial' and not all_values:
			if shared_values:
				type_name = _('Shared', self.request)
			else:
				type_name = _('Local', self.request)

		title_template = _(chk_type.PageTitleTemplate, self.request) % {'type': type_name}
		title = chk_type.CheckListName if request.viewdata.PrintMode else title_template.format(chk_type.CheckListName)
		return self._create_response_namespace(
			title, title,
			dict(
				chkitems=chkitems, record_cultures=record_cultures,
				shown_cultures=shown_cultures, SuperUserGlobal=SuperUserGlobal,
				chkusage=chkusage, chk_type=chk_type, ErrMsg=ErrMsg),
			no_index=True)

	@view_config(route_name='admin_checklists_sharedstate', renderer=templateprefix + 'sharedstate.mak')
	def sharedstate(self):
		chk_type = self.request.context.chk_type
		self._check_security(chk_type, True)

		request = self.request

		model_state = request.model_state

		model_state.validators = {
			'state': validators.OneOf(['local', 'shared'], not_empty=True),
			'ID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		ID = model_state.form.data['ID']

		title = _('Manage Publications', request)
		return self._create_response_namespace(title, title, dict(ID=ID, state=model_state.value('state'), chk_type=chk_type), no_index=True)

	@view_config(route_name='admin_checklists_sharedstate', request_method='POST')
	def sharedstate_confirm(self):
		chk_type = self.request.context.chk_type
		self._check_security(chk_type, True)

		request = self.request

		model_state = request.model_state

		model_state.validators = {
			'state': validators.OneOf(['local', 'shared'], not_empty=True),
			'ID': ciocvalidators.IDValidator(not_empty=True)
		}

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		ID = model_state.form.data['ID']
		# shared = model_state.value('state')=='shared'

		sql = '''
			DECLARE @OldMemberID int, @MemberID int, @ChkID int

			SET @MemberID=?
			SET @ChkID=?

			SELECT @OldMemberID=MemberID FROM %(Table)s WHERE %(ID)s=@ChkID

			UPDATE %(Table)s SET MODIFIED_BY=?, MODIFIED_DATE=GETDATE(), MemberID=NULL WHERE %(ID)s=@ChkID

			INSERT INTO %(Table)s_InactiveByMember (%(ID)s, MemberID)
			SELECT @ChkID, MemberID FROM STP_Member m WHERE MemberID NOT IN (ISNULL(@OldMemberID, 0), @MemberID)
				AND NOT EXISTS(SELECT * FROM %(Table)s_InactiveByMember  WHERE %(ID)s=@ChkID AND MemberID=m.MemberID)
		''' % {'Table': chk_type.Table, 'ID': chk_type.ID}

		with request.connmgr.get_connection('admin') as conn:
			conn.execute(sql, [request.dboptions.MemberID, ID, request.user.Mod])

		msg = _('The value was successfully shared.', request)
		self._go_to_route('admin_checklists', _query=[('InfoMsg', msg), ('chk', chk_type.FieldCode)])
