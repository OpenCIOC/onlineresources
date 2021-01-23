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

import xml.etree.cElementTree as ET
import collections

# 3rd party
from formencode import Schema, ForEach, Any, variabledecode
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators, constants as const
from cioc.core.listformat import format_pub_list

from cioc.core.i18n import gettext as _
from cioc.web.cic.viewbase import CicViewBase
import six
from six.moves import map

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.cic:templates/publication/'


class PublicationBaseSchema(Schema):
	if_key_missing = None

	PubCode = validators.Regex('^[-A-Z0-9]{,20}$', not_empty=True, strip=True)
	NonPublic = validators.StringBool()
	FieldHeadings = validators.Bool()
	FieldHeadingsNP = validators.Bool()
	FieldDesc = validators.Bool()
	FieldHeadingGroups = validators.Bool()
	FieldHeadingGroupsNP = validators.Bool()

	CanEditHeadingsShared = validators.Bool()

base_fields = list(PublicationBaseSchema.fields.keys())


class PublicationDescriptionSchema(Schema):
	if_key_missing = None

	Name = validators.UnicodeString(max=100)
	Notes = validators.UnicodeString()


class HeadingGroupDescriptionSchema(Schema):
	if_key_missing = None

	Name = validators.UnicodeString(max=200)


class HeadingGroupBaseSchema(Schema):
	if_key_missing = None

	GroupID = Any(validators.IDValidator(), validators.OneOf(['NEW']))
	DisplayOrder = validators.Int(min=0, max=256, not_empty=True)
	Descriptions = validators.CultureDictSchema(HeadingGroupDescriptionSchema(), allow_extra_fields=True, fiter_extra_fields=False)
	IconNameFull = validators.String(max=65)

	delete = validators.Bool()


class PublicationSchema(validators.RootSchema):

	if_key_missing = None

	publication = PublicationBaseSchema()
	descriptions = validators.CultureDictSchema(PublicationDescriptionSchema(), pre_validators=[validators.DeleteKeyIfEmpty()])

	group = ForEach(HeadingGroupBaseSchema())


EditValues = collections.namedtuple('EditValues', 'publication publication_descriptions groups views generalheadings publications is_add PB_ID is_shared_edit')


class HideSchema(validators.RootSchema):
	if_key_missing = None

	PubHide = ForEach(validators.IDValidator())


@view_defaults(route_name='cic_publication')
class Publication(CicViewBase):

	@view_config(route_name='cic_publication_index', renderer=templateprefix + 'list.mak', request_param='PrintMd=on')
	@view_config(route_name='cic_publication_index', renderer=templateprefix + 'list.mak', request_param='pop=on')
	@view_config(route_name='cic_publication_index', renderer=templateprefix + 'list.mak', custom_predicates=[lambda c, r: r.user.cic.LimitedView])
	def list(self):
		request = self.request
		user = request.user
		pop = not not request.params.get('pop')

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL or user.cic.LimitedView:
			self._security_failure()

		pubs = []
		with request.connmgr.get_connection('admin') as conn:
			pubs = conn.execute('EXEC dbo.sp_CIC_Publication_l_Admin_Print ?', request.dboptions.MemberID).fetchall()
			for pub in pubs:
				pub.Descriptions = self._culture_dict_from_xml(pub.Descriptions, 'DESC')

		title = _('Publications List', request)
		return self._create_response_namespace(title, title, dict(pubs=pubs, pop_mode=pop), no_index=True, print_table=not pop)

	@view_config(route_name='cic_publication_index', renderer=templateprefix + 'index.mak', request_method='POST')
	def hide(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = HideSchema()

		if model_state.validate():
			with request.connmgr.get_connection('admin') as conn:
				result = conn.execute('''
						DECLARE @RC int, @ErrMsg as nvarchar(500)

						EXEC @RC = dbo.sp_CIC_Publication_u_MemberInactive ?, ?, @ErrMsg OUTPUT

						SELECT @RC AS [Return], @ErrMsg AS ErrMsg
						''', request.dboptions.MemberID, ','.join(map(str, model_state.value('PubHide') or []))).fetchone()

			if not result.Return:
				return self._go_to_route('cic_publication_index',
							_query=[('InfoMsg', _('Publication visibility settings saved.', request))])

			ErrMsg = _('Unable to update Publication visibility settings: ') + result.ErrMsg
		else:
			ErrMsg = _('There were validation errors.')

		pubs, shared_pubs, other_pubs = self._get_index_edit_info()

		title = _('Manage Publications', request)
		return self._create_response_namespace(title, title, dict(pubs=pubs, shared_pubs=shared_pubs, other_pubs=other_pubs, ErrMsg=ErrMsg), no_index=True, print_table=True)

	@view_config(route_name='cic_publication_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL or user.cic.LimitedView:
			self._security_failure()

		pubs, shared_pubs, other_pubs = self._get_index_edit_info()

		request.model_state.form.data['PubHide'] = {six.text_type(p.PB_ID) for p in shared_pubs if p.Hide}

		title = _('Manage Publications', request)
		return self._create_response_namespace(title, title, dict(pubs=pubs, shared_pubs=shared_pubs, other_pubs=other_pubs), no_index=True, print_table=True)

	def _get_index_edit_info(self):
		request = self.request
		pubs = []
		shared_pubs = []
		other_pubs = None
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_CIC_Publication_l_Admin ?', request.dboptions.MemberID if request.dboptions.OtherMembersActive else None)
			pubs = cursor.fetchall()

			if request.dboptions.OtherMembersActive:
				cursor.nextset()

				shared_pubs = cursor.fetchall()

				cursor.nextset()

				other_pubs = cursor.fetchone()

		for shared in shared_pubs:
			shared.InUseByMembers = self._dict_list_from_xml(shared.InUseByMembers, 'MEMBER')

		return pubs, shared_pubs, other_pubs

	@view_config(renderer=templateprefix + 'other.mak', match_param='action=other')
	def other(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
			self._security_failure()

		pubs = []
		with request.connmgr.get_connection('admin') as conn:
			pubs = conn.execute('EXEC dbo.sp_CIC_Publication_l_Admin_Other ?', request.dboptions.MemberID).fetchall()

		title = _('Publications for Other Members', request)
		return self._create_response_namespace(title, title, dict(pubs=pubs), no_index=True, print_table=True)

	@view_config(route_name='cic_publication', match_param='action=edit', request_method="POST", renderer=templateprefix + 'edit.mak')
	def save(self):
		request = self.request

		if request.POST.get('Delete'):
			self._go_to_route('cic_publication', action='delete', _query=[('PB_ID', request.POST.get('PB_ID'))])

		user = request.user

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL or user.cic.LimitedView:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = PublicationSchema()
		model_state.form.variable_decode = True

		validator = validators.IDValidator()
		try:
			PB_ID = validator.to_python(request.POST.get('PB_ID'))
		except validators.Invalid:
			self._error_page(_('Invalid Publication ID', request))

		is_add = not PB_ID

		if model_state.validate():
			# valid. Save changes and redirect

			form_data = model_state.form.data
			publication = form_data.get('publication')
			args = [PB_ID, user.Mod,
					request.dboptions.MemberID, not request.dboptions.OtherMembersActive or user.cic.SuperUserGlobal]
			args.extend(publication.get(x) for x in base_fields)
			kwargstr = ', '.join(x.join(('@', '=?')) for x in base_fields)

			root = ET.Element('DESCS')

			for culture, data in six.iteritems((form_data['descriptions'] or {})):
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in six.iteritems(data):
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root))

			root = ET.Element('GROUPS')
			for i, group in enumerate(form_data['group'] or []):
				if not group.get('GroupID'):
					continue

				if group.get('delete'):
					continue

				descriptions = group.get('Descriptions') or {}
				log.debug('descriptions: %s', descriptions)
				if not any(x.get('Name') for x in descriptions.values()):
					log.debug('Not any values')
					continue

				group_el = ET.SubElement(root, 'GROUP')
				ET.SubElement(group_el, 'CNT').text = six.text_type(i)

				for key, value in six.iteritems(group):
					if key == 'GroupID' and value == 'NEW':
						value = -1

					if key != 'Descriptions':
						if value is not None:
							ET.SubElement(group_el, key).text = six.text_type(value)

						continue

					descs = ET.SubElement(group_el, 'DESCS')
					for culture, data in six.iteritems(value):
						culture = culture.replace('_', '-')

						desc = ET.SubElement(descs, 'DESC')
						ET.SubElement(desc, 'Culture').text = culture
						for key, value in six.iteritems(data):
							if value:
								ET.SubElement(desc, key).text = value

			args.append(ET.tostring(root))

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@PB_ID as int

				SET @PB_ID = ?

				EXECUTE @RC = dbo.sp_CIC_Publication_u @PB_ID OUTPUT, ?,?,?, %s, @Descriptions=?, @Groups=?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @PB_ID as PB_ID
				''' % kwargstr

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				PB_ID = result.PB_ID
				if is_add:
					msg = _('The Publication was successfully added.', request)
				else:
					msg = _('The Publication was successfully updated.', request)
				self._go_to_route('cic_publication', action='edit', _query=[('InfoMsg', msg), ("PB_ID", PB_ID)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		edit_values = self._get_edit_info(is_add, PB_ID)
		if is_add:
			title = _('Add Publication', request)
		else:
			title = _('Edit Publication: %s', request) % edit_values.publication.PubCode

		groups = variabledecode.variable_decode(request.POST).get('group') or {}
		model_state.form.data['group'] = groups
		edit_values = edit_values._asdict()
		edit_values['ErrMsg'] = ErrMsg

		return self._create_response_namespace(title, title,
				edit_values,
				no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		log.debug('before first check')
		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {
			'PB_ID': validators.IDValidator()
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid PB_ID

			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.form.data.get('PB_ID')
		is_add = not PB_ID

		log.debug('before second security check')
		if user.cic.LimitedView and user.cic.PB_ID != PB_ID:
			self._security_failure()

		edit_values = self._get_edit_info(is_add, PB_ID)

		data = model_state.form.data
		data['publication'] = edit_values.publication
		data['descriptions'] = edit_values.publication_descriptions
		data['group'] = edit_values.groups

		if is_add:
			title = _('Add Publication', request)
		else:
			title = _('Edit Publication: %s', request) % edit_values.publication.PubCode

		return self._create_response_namespace(
			title, title,
			edit_values._asdict(),
			no_index=True)

	def _get_edit_info(self, is_add, PB_ID):
		request = self.request

		publication = None
		publication_descriptions = {}

		views = []
		generalheadings = []
		publications = []
		groups = []

		cicvw = request.viewdata.cic
		pub_name_only = cicvw.UsePubNamesOnly

		is_shared_edit = False

		if not is_add:
			with request.connmgr.get_connection('admin') as conn:
				sql = 'EXEC dbo.sp_CIC_Publication_s ?, ? ; EXEC dbo.sp_CIC_Publication_l_Admin_Headings ?'
				cursor = conn.execute(sql, request.dboptions.MemberID, PB_ID, request.dboptions.MemberID)
				publication = cursor.fetchone()
				if publication:
					if publication.MemberID is None and request.dboptions.OtherMembersActive and not request.user.cic.SuperUserGlobal:
						if publication.CanEditHeadingsShared:
							is_shared_edit = True
						else:
							log.debug('go to route')
							self._go_to_route('cic_generalheading_index', _query=[('PB_ID', PB_ID)])

					cursor.nextset()
					for lng in cursor.fetchall():
						publication_descriptions[lng.Culture.replace('-', '_')] = lng

					cursor.nextset()

					views = cursor.fetchall()

					cursor.nextset()

					groups = cursor.fetchall()

					cursor.nextset()

					generalheadings = [tuple(x) for x in cursor.fetchall()]

					cursor.nextset()

					publications = cursor.fetchall()

					publications = format_pub_list((x for x in publications if x.PB_ID != PB_ID), True, pub_name_only)

				cursor.close()

			if not publication:
				# not found
				self._error_page(_('Publication Not Found', request))

		for group in groups:
			group.Descriptions = self._culture_dict_from_xml(group.Descriptions, 'DESC')

		return EditValues(publication, publication_descriptions, groups, views, generalheadings, publications, is_add, PB_ID, is_shared_edit)

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
			self._security_failure()

		model_state = request.model_state
		model_state.method = None
		model_state.validators = {
			'PB_ID': validators.IDValidator(not_empty=True)
		}

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.form.data['PB_ID']

		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		title = _('Manage Publications', request)
		return self._create_response_namespace(title, title, dict(id_name='PB_ID', id_value=PB_ID, route='cic_publication', action='delete'), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'PB_ID': validators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.form.data['PB_ID']

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_CIC_Publication_d ?,?,?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, PB_ID, request.dboptions.MemberID, not request.dboptions.OtherMembersActive or user.cic.SuperUserGlobal)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('cic_publication_index', _query=[('InfoMsg', _('The Publication was successfully deleted.', request))])

		if result.Return == 3:
			# XXX check that this is the only #3
			self._error_page(_('Unable to delete Publication:', request) + result.ErrMsg)

		self._go_to_route('cic_publication', action='edit', _query=[('ErrMsg', _('Unable to delete Publication: ') + result.ErrMsg), ('PB_ID', PB_ID)])

	@view_config(match_param='action=clearrecords', renderer='cioc.web.cic:templates/publication/clearrecords.mak')
	def clearrecords(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.method = None
		model_state.validators = {
			'PB_ID': validators.IDValidator(not_empty=True)
		}

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.form.data['PB_ID']
		edit_values = self._get_edit_info(False, PB_ID)

		request.override_renderer = 'cioc.web.cic:templates/publication/clearrecords.mak'

		title = _('Manage Publication from Records', request)
		return self._create_response_namespace(title, title, dict(id_name='PB_ID', id_value=PB_ID, route='cic_publication', action='clearrecords', publication=edit_values.publication), no_index=True)

	@view_config(match_param='action=clearrecords', request_method="POST")
	def clearrecords_confirm(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'PB_ID': validators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.form.data['PB_ID']

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_CIC_Publication_ClearRecords_d ?,?,?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, PB_ID, request.dboptions.MemberID, not request.dboptions.OtherMembersActive or user.cic.SuperUserGlobal)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('cic_publication', action='edit', _query=[('PB_ID', PB_ID), ('InfoMsg', _('The records were successfuly cleared.', request))])

		if result.Return == 3:
			# XXX check that this is the only #3
			self._error_page(_('Unable to clear records:', request) + result.ErrMsg)

		self._go_to_route('cic_publication', action='edit', _query=[('ErrMsg', _('Unable to clear records: ') + result.ErrMsg), ('PB_ID', PB_ID)])

	@view_config(match_param='action=sharedstate', renderer=templateprefix + 'sharedstate.mak')
	def sharedstate(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'state': validators.OneOf(['local', 'shared'], not_empty=True),
			'PB_ID': validators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.form.data['PB_ID']

		title = _('Manage Publications', request)
		return self._create_response_namespace(title, title, dict(PB_ID=PB_ID, state=model_state.value('state')), no_index=True)

	@view_config(match_param='action=sharedstate', request_method="POST")
	def sharedstate_confirm(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUserGlobal:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'state': validators.OneOf(['local', 'shared'], not_empty=True),
			'PB_ID': validators.IDValidator(not_empty=True)
		}

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.form.data['PB_ID']
		shared = model_state.value('state') == 'shared'

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_CIC_Publication_u_SharedState ?,?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, PB_ID, shared)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			if shared:
				msg = _('The Publication was successfully shared.', request)
			else:
				msg = _('The Publication was successfully made local.', request)

			self._go_to_route('cic_publication_index', _query=[('InfoMsg', msg)])

		if shared:
				msg = _('Unable to make the Publication shared: ', request)
		else:
				msg = _('Unable to make the Publication local: ', request)

		self._go_to_route('cic_publication_index', _query=[('ErrMsg', msg + result.ErrMsg)])
