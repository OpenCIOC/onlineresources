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
from six.moves import map

import xml.etree.cElementTree as ET
from datetime import timedelta, date, datetime

from itertools import groupby

# 3rd Party
from formencode import Schema, validators, ForEach, All
from pyramid.view import view_config, view_defaults

# this app
from cioc.core import validators as ciocvalidators, constants as const, rootfactories
from cioc.core.viewbase import security_failure, init_page_info, error_page
from cioc.core.email import send_email, format_message

from cioc.core.i18n import gettext, format_date
from cioc.web.admin.viewbase import AdminViewBase, get_domain

log = logging.getLogger(__name__)
templateprefix = 'cioc.web.admin:templates/sharingprofile/'

def _(x):
	return x


_send_subject = _('A Record Sharing Profile is ready for review.')
_send_template = _(
	"""\
Hello,

A member in your CIOC database (%(MemberName)s) has created the Record Sharing
Profile '%(ProfileName)s' for you to review. Please go to the Sharing Profile
setup area of your CIOC site to accept it.
""")

_accept_subject = _('A Record Sharing Profile has been accepted.')
_accept_template = _(
	"""\
Hello,

Your Record Sharing Profile '%(ProfileName)s' has been accepted by a member
in your CIOC database (%(MemberName)s).
""")

_revoke_subject = _('A Sharing Profile has been revoked and will end on %(ExpireDate)s.')
_revoke_template = _(
	"""\
Hello,

Your Record Sharing Profile called '%(ProfileName)s' has been revoked by a
member participating in the agreement called '%(MemberName)s'. The agreement
will end on %(ExpireDate)s.
""")

_revoke_records_subject = _('Removal of shared records in your database as of %(ExpireDate)s')
_revoke_records_template = _(
	"""\
Hello,

Some records in your Sharing Profile called '%(ProfileName)s' have been
removed by a member called '%(MemberName)s' that is a participant in
the agreement. The records will no longer be available in the Sharing
Agreement as of %(ExpireDate)s.

The records affected are:

%%s

For more information on which records are available in this sharing profile,
review the Sharing Profile and click the link called "View records associated
with this profile" or go to: %(ProfileURL)s
""")


_ = gettext


class SharingProfileContext(rootfactories.BasicRootFactory):
	def __init__(self, request):
		request.context = self
		self.request = request

		# required to use go_to_page
		init_page_info(request, const.DM_GLOBAL, const.DM_GLOBAL)

		user = request.user

		if not user.SuperUser or not request.dboptions.OtherMembersActive:
			security_failure(request)

		domain = self.domain = get_domain(request.params)
		if not domain:
			error_page(request, _('No domain selected', request), const.DM_GLOBAL, const.DM_GLOBAL, _('Manage Sharing Profiles', request))

		if not request.dboptions.OtherMembersActive and \
			((domain.id == const.DM_CIC and not user.cic.SuperUser) or
			(domain.id == const.DM_VOL and not user.vol.SuperUser)):
			security_failure(request)

		ProfileID = request.params.get('ProfileID')

		validator = ciocvalidators.IDValidator()
		try:
			ProfileID = validator.to_python(ProfileID)
		except validators.Invalid:
			error_page(request, _('Invalid ID', request), const.DM_GLOBAL, const.DM_GLOBAL, _('Manage Sharing Profiles', request))

		self.ProfileID = ProfileID

		profile = None
		if ProfileID:
			with request.connmgr.get_connection('admin') as conn:
				profile = conn.execute('EXEC dbo.sp_%s_SharingProfile_s_Basic ?, ?' % domain.str,
							request.dboptions.MemberID, ProfileID).fetchone()

		if ProfileID and not profile:
			error_page(request, _('Profile Not Found', request), const.DM_GLOBAL, const.DM_GLOBAL, _('Manage Sharing Profiles', request))

		self.profile = profile

	@property
	def editable(self):
		profile = self.profile
		if not profile:
			return False

		if self.request.dboptions.MemberID != profile.MemberID:
			return False

		return not (profile.Active or profile.ReadyToAccept or profile.RevokedDate)

	@property
	def addable(self):
		profile = self.profile
		if not profile:
			return False

		if self.request.dboptions.MemberID != profile.MemberID:
			return False

		return (profile.Active or profile.ReadyToAccept) and (not profile.RevokedDate or profile.RevokedDate >= datetime.now())

	@property
	def partnerreview(self):
		profile = self.profile
		return profile and (profile.ReadyToAccept or profile.Active or profile.RevokedDate) and self.request.dboptions.MemberID != profile.MemberID

	@property
	def partneracceptable(self):
		profile = self.profile
		return profile and profile.ReadyToAccept and not(profile.Active or profile.RevokedDate) and self.request.dboptions.MemberID != profile.MemberID

	@property
	def revoked(self):
		profile = self.profile
		return profile and profile.RevokedDate and profile.RevokedDate < datetime.now()

	@property
	def partnerrecordrevoke(self):
		profile = self.profile
		return profile and profile.Active and self.request.dboptions.MemberID != profile.MemberID


class EmailListValidator(All):
	validators = [ciocvalidators.String(max=1000, not_empty=True), ciocvalidators.EmailListRegexValidator(not_empty=True)]


class ProfileBaseSchema(Schema):
	if_key_missing = None

	ShareMemberID = ciocvalidators.IDValidator()
	CanUseAnyView = validators.DictConverter({'Y': True, 'N': False})
	CanUpdateRecords = validators.Bool()
	CanUsePrint = validators.Bool()
	CanUseExport = validators.Bool()
	CanUpdatePubs = validators.Bool()
	CanViewFeedback = validators.Bool()
	CanViewPrivate = validators.Bool()
	RevocationPeriod = validators.Int(min=0, max=999, not_empty=True)
	NotifyEmailAddresses = EmailListValidator()

	Views = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))
	Fields = ForEach(ciocvalidators.IDValidator())
	EditLangs = ForEach(ciocvalidators.ActiveCulture(record_cultures=True))

profile_core_fields = [x for x in ProfileBaseSchema.fields if x not in ['Views', 'Fields', 'EditLangs']]


class ProfileDescriptionSchema(Schema):
	if_key_missing = None

	Name = ciocvalidators.UnicodeString(max=100)


class ProfileSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	profile = ProfileBaseSchema()
	descriptions = ciocvalidators.CultureDictSchema(ProfileDescriptionSchema())


class BaseSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None


class ShareEmailValidation(BaseSchema):
	ShareNotifyEmailAddresses = EmailListValidator()


@view_defaults(route_name='admin_sharingprofile')
class SharingProfile(AdminViewBase):

	@view_config(route_name='admin_sharingprofile_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUser or not request.dboptions.OtherMembersActive:
			self._security_failure()

		domain = get_domain(request.params)
		if not domain:
			self._error_page(_('No domain selected', request), _('Manage Sharing Profiles', request))

		if not request.dboptions.OtherMembersActive and \
			((domain.id == const.DM_CIC and not user.cic.SuperUser) or
			(domain.id == const.DM_VOL and not user.vol.SuperUser)):
			self._security_failure()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute(
				'EXEC sp_GBL_SharingProfile_l ?, ?',
				request.dboptions.MemberID, domain.id)

			my_profiles = cursor.fetchall()

			cursor.nextset()

			partner_profiles = cursor.fetchall()

			cursor.close()

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(domain=domain,
			my_profiles=my_profiles, partner_profiles=partner_profiles), no_index=True)

	@view_config(match_param="action=edit", request_method="POST", renderer=templateprefix + 'edit.mak', custom_predicates=[lambda c, r: c.editable])
	@view_config(match_param='action=edit', request_method="POST", renderer=templateprefix + 'additems.mak', custom_predicates=[lambda c, r: c.addable])
	@view_config(match_param="action=add", request_method="POST", renderer=templateprefix + 'edit.mak')
	def save(self):
		request = self.request
		domain = request.context.domain

		# Accept/Send To Partner/Other state changes.
		if request.POST.get('Delete'):
			self._go_to_route('admin_sharingprofile', action='delete', _query=[('ProfileID', request.POST.get('ProfileID')), ('DM', request.params.get('DM'))])

		if request.POST.get('Send'):
			self._go_to_route('admin_sharingprofile', action='send', _query=[('ProfileID', request.POST.get('ProfileID')), ('DM', request.params.get('DM'))])

		action = request.matchdict.get('action')
		is_add = action == 'add'

		extra_validators = {}
		model_state = request.model_state
		if not is_add:
			extra_validators['ProfileID'] = ciocvalidators.IDValidator(not_empty=True)

		model_state.schema = ProfileSchema(**extra_validators)
		model_state.form.variable_decode = True

		if model_state.validate():
			# valid. Save changes and redirect
			if not is_add:
				ProfileID = model_state.form.data['ProfileID']
			else:
				ProfileID = None

			args = [ProfileID, request.user.Mod, request.dboptions.MemberID]

			profile = model_state.value('profile', {})

			args.extend(profile.get(x) for x in profile_core_fields)
			kwnames = profile_core_fields[:]

			root = ET.Element('DESCS')

			for culture, data in six.iteritems(model_state.form.data['descriptions']):
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in six.iteritems(data):
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root, encoding='unicode'))
			kwnames.append('Descriptions')

			root = ET.Element('VIEWS')
			for view_type in model_state.value('profile.Views') or []:
				ET.SubElement(root, 'VIEW').text = six.text_type(view_type)

			args.append(ET.tostring(root, encoding='unicode'))
			kwnames.append('Views')

			root = ET.Element('FIELDS')
			for field in model_state.value('profile.Fields') or []:
				ET.SubElement(root, "FIELD").text = six.text_type(field)

			args.append(ET.tostring(root, encoding='unicode'))
			kwnames.append('Fields')

			args.append(','.join(model_state.value('profile.EditLangs') or []) or None)
			kwnames.append('EditLangs')

			kwnames = ','.join(x.join(('@', '=?')) for x in kwnames)

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				Declare @ErrMsg as nvarchar(500),
				@RC as int,
				@ProfileID as int

				SET @ProfileID = ?

				EXECUTE @RC = dbo.sp_%s_SharingProfile_u @ProfileID OUTPUT, ?, ?, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg, @ProfileID as ProfileID
				''' % (domain.str, kwnames)

				log.debug('sql: %s', sql)
				log.debug('args: %s', args)

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				ProfileID = result.ProfileID

				if is_add:
					msg = _('The Profile was successfully added.', request)
				else:
					msg = _('The Profile was successfully updated.', request)

				self._go_to_route('admin_sharingprofile', action='edit', _query=[('InfoMsg', msg), ("ProfileID", ProfileID), ('DM', domain.id)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			if model_state.is_error('ProfileID'):
				self._error_page(_('Invalid Profile ID', request)), ('DM', domain.id)

			ErrMsg = _('There were validation errors.', request)

		profile = request.context.profile
		profile_descriptions = {}
		members = []
		fields = []
		views = []
		view_descs = []
		field_descs = []

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_%s_SharingProfile_s_FormLists ?, ?' % domain.str, request.MemberID, model_state.value('ProfileID'))

			members = list(map(tuple, cursor.fetchall()))

			cursor.nextset()

			view_descs = cursor.fetchall()

			cursor.nextset()

			field_descs = cursor.fetchall()

			cursor.close()

			if not is_add:
				cursor = conn.execute('EXEC dbo.sp_%s_SharingProfile_s_Edit ?, ?' % domain.str, request.dboptions.MemberID, model_state.value('ProfileID'))

				# Skip descriptions
				cursor.fetchall()
				cursor.nextset()

				fields = [str(x.FieldID) for x in cursor.fetchall()]

				cursor.nextset()

				views = [str(x.ViewType) for x in cursor.fetchall()]

				cursor.close()

		model_state.form.data['profile.Views'] = request.POST.getall('profile.Views')
		model_state.form.data['profile.Fields'] = request.POST.getall('profile.Fields')
		model_state.form.data['profile.CanUseAnyView'] = request.POST['profile.CanUseAnyView']

		always_shared_fields = []
		for k, g in groupby(field_descs, lambda x: x.CanShare):
			if k:
				field_descs = list(g)
			else:
				always_shared_fields = list(g)

		# XXX should we refetch the basic info?
		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(
			title, title,
			dict(
				action=action, profile=profile, profile_descriptions=profile_descriptions,
				ProfileID=model_state.value('ProfileID'), domain=domain,
				members=members, field_descs=field_descs,
				fields=fields, views=views,
				always_shared_fields=always_shared_fields,
				view_descs=view_descs, ErrMsg=ErrMsg),
			no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak', custom_predicates=[lambda c, r: c.editable])
	@view_config(match_param='action=edit', renderer=templateprefix + 'additems.mak', custom_predicates=[lambda c, r: c.addable])
	@view_config(match_param='action=edit', renderer=templateprefix + 'revoked.mak', custom_predicates=[lambda c, r: c.revoked])
	@view_config(match_param='action=add', renderer=templateprefix + 'edit.mak')
	def edit(self):
		request = self.request
		context = request.context
		domain = context.domain

		action = request.matchdict.get('action')
		is_add = action == 'add'

		model_state = request.model_state
		model_state.validators = {
			'ProfileID': ciocvalidators.IDValidator(not_empty=not is_add)
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid ProfileID
			self._error_page(_('Invalid ID', request), _('Manage Sharing Profiles', request))

		ProfileID = model_state.value('ProfileID')

		profile = None
		profile_descriptions = {}
		views = []
		fields = []
		edit_languages = []
		members = []
		view_descs = []
		field_descs = []

		with request.connmgr.get_connection('admin') as conn:
			profile = context.profile
			if ProfileID and profile:
				cursor = conn.execute('EXEC dbo.sp_%s_SharingProfile_s_Edit ?, ?' % domain.str, request.dboptions.MemberID, ProfileID)
				for lng in cursor.fetchall():
					profile_descriptions[lng.Culture.replace('-', '_')] = lng

				cursor.nextset()

				fields = cursor.fetchall()

				cursor.nextset()

				views = cursor.fetchall()

				cursor.nextset()

				edit_languages = cursor.fetchall()

				cursor.close()

			if not is_add and not profile:
				# not found
				self._error_page(_('Profile Not Found', request), _('Manage Sharing Profiles', request))

			cursor = conn.execute('EXEC dbo.sp_%s_SharingProfile_s_FormLists ?, ?' % domain.str, request.MemberID, ProfileID)

			members = list(map(tuple, cursor.fetchall()))

			cursor.nextset()

			view_descs = cursor.fetchall()

			cursor.nextset()

			field_descs = cursor.fetchall()

			if is_add:
				cursor.nextset()

				emailaddresses = cursor.fetchone()
				if emailaddresses:
					model_state.form.data['profile.NotifyEmailAddresses'] = emailaddresses.NotifyEmailAddresses

			cursor.close()

		model_state.form.data['profile'] = profile
		model_state.form.data['descriptions'] = profile_descriptions
		views = model_state.form.data['profile.Views'] = [str(v.ViewType) for v in views]
		model_state.form.data['profile.EditLangs'] = [x.Culture for x in edit_languages]
		fields = model_state.form.data['profile.Fields'] = [str(f.FieldID) for f in fields]
		model_state.form.data['profile.CanUseAnyView'] = 'Y' if not profile or profile.CanUseAnyView else 'N'

		if is_add:
			for desc in six.itervalues(profile_descriptions):
				desc.Name = None

		always_shared_fields = []
		for k, g in groupby(field_descs, lambda x: x.CanShare):
			if k:
				field_descs = list(g)
			else:
				always_shared_fields = list(g)

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(
			title, title,
			dict(
				action=action, profile=profile, domain=domain,
				profile_descriptions=profile_descriptions, members=members,
				views=views, fields=fields, edit_languages=edit_languages, always_shared_fields=always_shared_fields,
				ProfileID=ProfileID, field_descs=field_descs, view_descs=view_descs),
			no_index=True)

	def _get_partner_review_data(self):
		request = self.request
		context = request.context

		domain = context.domain
		ProfileID = context.ProfileID

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_%s_SharingProfile_s_Review ?, ?' % domain.str, request.MemberID, ProfileID)
			profile = cursor.fetchone()

			cursor.nextset()

			views = cursor.fetchall()

			cursor.nextset()

			fields = cursor.fetchall()

			cursor.nextset()

			edit_languages = cursor.fetchall()

			cursor.close()

		for k, g in groupby(fields, lambda x: x.CanShare):
			if k:
				fields = list(g)
			else:
				always_shared_fields = list(g)

		return dict(
			profile=profile, domain=domain,
			views=views, fields=fields, edit_languages=edit_languages,
			always_shared_fields=always_shared_fields,
			ProfileID=ProfileID)

	@view_config(match_param='action=edit', renderer=templateprefix + 'review.mak', custom_predicates=[lambda c, r: c.partnerreview])
	def partnerreview(self):
		request = self.request
		namespace = self._get_partner_review_data()

		request.model_state.form.data['ShareNotifyEmailAddresses'] = namespace['profile'].ShareNotifyEmailAddresses
		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(
			title, title, namespace, no_index=True)

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.SuperUser or not request.dboptions.OtherMembersActive:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'ProfileID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		domain = request.context.domain
		if not model_state.validate():
			self._error_page(_('Invalid ID', request), _('Manage Sharing Profiles', request))

		ProfileID = model_state.form.data['ProfileID']

		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(id_name='ProfileID', id_value=ProfileID, route='admin_sharingprofile', action='delete', domain=domain), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.SuperUser or not request.dboptions.OtherMembersActive:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'ProfileID': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request), _('Manage Sharing Profiles', request))

		ProfileID = model_state.form.data['ProfileID']

		domain = request.context.domain
		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			Declare @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_%s_SharingProfile_d ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' % domain.str

			cursor = conn.execute(sql, ProfileID, request.dboptions.MemberID)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('admin_sharingprofile_index', _query=[('InfoMsg', _('The Profile was successfully deleted.', request)), ('DM', domain.id)])

		if result.Return == 3:
			self._error_page(_('Unable to delete Sharing Profile:', request), _('Manage Sharing Profiles', request))

		self._go_to_route('admin_sharingprofile', action='edit', _query=[('ErrMsg', _('Unable to delete Sharing Profile: ', request) + result.ErrMsg), ('ProfileID', ProfileID), ('DM', domain.id)])

	@view_config(match_param='action=send', renderer=templateprefix + 'send.mak', custom_predicates=[lambda c, r: c.editable])
	def send(self):
		request = self.request
		context = request.context

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=context.domain), no_index=True)

	@view_config(match_param='action=send', renderer=templateprefix + 'send.mak', request_method='POST', custom_predicates=[lambda c, r: c.editable])
	def send_confrm(self):
		request = self.request
		context = request.context

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			Declare @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_%s_SharingProfile_u_Send ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' % context.domain.str

			cursor = conn.execute(sql, context.ProfileID, request.user.User_ID)

			emails = cursor.fetchone()

			if emails[0]:
				emails = [x.strip() for x in emails[0].split(',')]
			else:
				emails = None

			cursor.nextset()

			result = cursor.fetchone()

			cursor.close()

		query_args = [('ProfileID', context.ProfileID), ('DM', context.domain.id)]
		if not result.Return:

			if emails:
				profile = context.profile
				subject = _(_send_subject, request)
				message = _(_send_template, request) % {'MemberName': profile.SharingMemberName, 'ProfileName': profile.Name}
				message = format_message(message)

				send_email(
					request, getattr(request.dboptions, 'DefaultEmail%s' % context.domain.str),
					emails, subject, message)

				query_args.append(('InfoMsg', _('The Profile was successfully sent.', request)))
			else:
				query_args.append(('InfoMsg', _('The Profile is available to be accepted, but email notifications could not be sent.', request)))

		else:
			query_args.append(('ErrMsg', _('Unable to send Sharing Profile: ', request) + result.ErrMsg))

		self._go_to_route('admin_sharingprofile', action='edit', _query=query_args)

	@view_config(match_param='action=revoke', renderer=templateprefix + 'revoke.mak', request_method='POST', custom_predicates=[lambda c, r: c.addable or c.partnerreview])
	def revoke_confirm(self):
		request = self.request
		context = request.context

		min_date = date.today()
		if context.addable:
			min_date = min_date + timedelta(context.profile.RevocationPeriod)

		model_state = request.model_state
		model_state.schema = BaseSchema(RevocationDate=ciocvalidators.DateConverter(not_empty=True, min=min_date))

		if model_state.validate():
			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				Declare @ErrMsg as nvarchar(500),
				@RC as int

				EXECUTE @RC = dbo.sp_%s_SharingProfile_u_Revoke ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % context.domain.str

				cursor = conn.execute(sql, context.ProfileID, request.user.User_ID, model_state.value('RevocationDate'))

				emails = cursor.fetchone()
				
				if emails[0]:
					emails = [x.strip() for x in emails[0].split(',')]
				else:
					email = None

				cursor.nextset()

				result = cursor.fetchone()

				cursor.close()

			query_args = [('ProfileID', context.ProfileID), ('DM', context.domain.id)]
			if not result.Return:
				if emails:
					profile = context.profile
					vars = {
						'ExpireDate': format_date(model_state.value('RevocationDate'), request),
						'MemberName': profile.SharingMemberName if profile.MemberID == request.dboptions.MemberID else profile.ReceivingMemberName,
						'ProfileName': profile.Name
					}
					subject = _(_revoke_subject, request) % vars
					message = _(_revoke_template, request) % vars
					message = format_message(message)

					send_email(
						request, getattr(request.dboptions, 'DefaultEmail%s' % context.domain.str),
						emails, subject, message)

				query_args.append(('InfoMsg', _('The Sharing Profile was successfully revoked.', request)))

			else:
				query_args.append(('ErrMsg', _('Unable to revoke Sharing Profile: ') + result.ErrMsg))

			self._go_to_route('admin_sharingprofile', action='edit', _query=query_args)

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=context.domain), no_index=True, ErrMsg=_('There were validation errors.', request))

	@view_config(match_param='action=revoke', renderer=templateprefix + 'revoke.mak', custom_predicates=[lambda c, r: c.addable or c.partnerreview])
	def revoke(self):
		request = self.request
		context = request.context

		min_date = date.today()
		if context.addable:
			min_date = min_date + timedelta(context.profile.RevocationPeriod)

		request.model_state.form.data['RevocationDate'] = format_date(min_date, request)

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=context.domain, min_date=min_date), no_index=True)

	@view_config(match_param='action=accept', renderer=templateprefix + 'review.mak', request_method='POST', custom_predicates=[lambda c, r: c.partneracceptable])
	def accept(self):
		request = self.request
		context = request.context

		model_state = request.model_state
		model_state.schema = ShareEmailValidation()

		if not model_state.validate():
			namespace = self._get_partner_review_data()
			title = _('Manage Sharing Profiles', request)
			namespace['ErrMsg'] = _('There were validation errors.', request)
			return self._create_response_namespace(
				title, title, namespace, no_index=True)

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			Declare @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_%s_SharingProfile_u_Accept ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' % context.domain.str

			cursor = conn.execute(sql, context.ProfileID, request.user.User_ID, model_state.value('ShareNotifyEmailAddresses'))

			emails = cursor.fetchone()

			if emails[0]:
				emails = [x.strip() for x in emails[0].split(',')]
			else:
				emails = None

			cursor.nextset()

			result = cursor.fetchone()

			cursor.close()

		query_args = [('ProfileID', context.ProfileID), ('DM', context.domain.id)]
		if not result.Return:
			if emails:
				profile = context.profile
				vars = {
					'MemberName': profile.ReceivingMemberName,
					'ProfileName': profile.Name
				}
				subject = _(_accept_subject, request)
				message = _(_accept_template, request) % vars
				message = format_message(message)

				send_email(
					request, getattr(request.dboptions, 'DefaultEmail%s' % context.domain.str),
					emails, subject, message)

			query_args.append(('InfoMsg', _('The Profile was successfully accepted.', request)))

		else:
			query_args.append(('ErrMsg', _('Unable to accept Sharing Profile: ') + result.ErrMsg))

		self._go_to_route('admin_sharingprofile', action='edit', _query=query_args)

	@view_config(match_param='action=records', renderer=templateprefix + 'records.mak', custom_predicates=[lambda c, r: c.partnerreview or c.profile.MemberID == r.dboptions.MemberID])
	def records(self):
		request = self.request
		context = request.context

		domain = context.domain
		with request.connmgr.get_connection('admin') as conn:
			profile = context.profile
			records = conn.execute(
				'EXEC dbo.sp_%s_SharingProfile_s_Records ?, ?, ?' % domain.str,
				request.dboptions.MemberID, profile.ProfileID,
				getattr(request.viewdata, domain.str.lower()).ViewType).fetchall()

		min_date = date.today()
		if context.addable or context.partnerreview:
			if context.addable:
				min_date = min_date + timedelta(context.profile.RevocationPeriod)

			request.model_state.form.data['RevocationDate'] = format_date(min_date, request)

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=domain, records=records, min_date=min_date), no_index=True)

	@view_config(match_param='action=records', request_param='confirmed=on', renderer='cioc.web:templates/error.mak', request_method='POST', custom_predicates=[lambda c, r: c.editable or c.addable])
	def records_add_confirm(self):
		request = self.request
		context = request.context

		domain = context.domain
		if domain.id == const.DM_CIC:
			validator = ciocvalidators.CSVForEach(ciocvalidators.NumValidator())
		else:
			validator = ciocvalidators.CSVForEach(ciocvalidators.VNumValidator())

		model_state = request.model_state
		model_state.schema = BaseSchema(IDList=validator)
		if model_state.validate():
			IDList = ','.join(str(x).upper() for x in model_state.value('IDList'))

			with request.connmgr.get_connection('admin') as conn:
				result = conn.execute(
					'''
					DECLARE @RC int, @RecordsAdded int, @ErrMsg nvarchar(500)
					EXEC @RC = dbo.sp_%s_SharingProfile_u_RecordAdd ?, ?, ?, ?, @RecordsAdded OUTPUT, @ErrMsg OUTPUT

					SELECT @RC AS [Return], @ErrMsg AS ErrMsg, @RecordsAdded AS RecordsAdded
					''' % domain.str,
					request.dboptions.MemberID, context.ProfileID, request.user.Mod, IDList).fetchone()
			if not result.Return:
				self._go_to_route(
					'admin_sharingprofile', action='records', _query=[
						('InfoMsg', _('%d records were added.', request) % result.RecordsAdded),
						('ProfileID', context.ProfileID), ('DM', context.domain.id)
					])

			ErrMsg = result.ErrMsg

		else:
			ErrMsg = model_state.renderer.errorlist('IDList')

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ErrMsg=ErrMsg), no_index=True)

	@view_config(match_param='action=records', renderer=templateprefix + 'records_add.mak', request_method='POST', custom_predicates=[lambda c, r: c.editable or c.addable])
	def records_add(self):
		request = self.request
		context = request.context

		domain = context.domain
		if domain.id == const.DM_CIC:
			validator = ciocvalidators.CSVForEach(ciocvalidators.NumValidator())
		else:
			validator = ciocvalidators.CSVForEach(ciocvalidators.VNumValidator())

		model_state = request.model_state
		model_state.schema = BaseSchema(IDList=validator)
		ErrMsg = None
		if not model_state.validate():
			ErrMsg = model_state.renderer.errorlist('IDList')

		else:
			IDList = ','.join(str(x).upper() for x in model_state.value('IDList'))
			if not IDList:
				ErrMsg = _('No records were selected.', request)

		if not ErrMsg:
			with request.connmgr.get_connection('admin') as conn:
				add_info = conn.execute(
					'EXEC dbo.sp_%s_SharingProfile_s_RecordAdd ?, ?, ?' % domain.str,
					request.dboptions.MemberID, context.ProfileID, IDList).fetchone()

			if not add_info.WillBeAdded:
				ErrMsg = _('None of the selected records can be added to the Profile. %d records were already in the Profile, and %d records are in another Profile with this Member.', request) % (add_info.AlreadyAdded, add_info.OtherProfile)

		title = _('Manage Sharing Profiles', request)
		if ErrMsg:
			self._error_page(ErrMsg, title)

		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=domain, IDList=IDList, add_info=add_info), no_index=True)

	@view_config(match_param='action=records', request_param='Remove=on', renderer=templateprefix + 'records_remove.mak', custom_predicates=[lambda c, r: c.partnerreview or c.profile.MemberID == r.dboptions.MemberID])
	def remove_records_from_bulk(self):
		request = self.request
		context = request.context

		domain = context.domain
		if domain.id == const.DM_CIC:
			validator = ciocvalidators.CSVForEach(ciocvalidators.NumValidator())
		else:
			validator = ciocvalidators.CSVForEach(ciocvalidators.VNumValidator())

		model_state = request.model_state
		model_state.schema = BaseSchema(IDList=validator)
		ErrMsg = None
		if not model_state.validate():
			ErrMsg = model_state.renderer.errorlist('IDList')

		else:
			IDList = ','.join(str(x).upper() for x in model_state.value('IDList'))
			if not IDList:
				ErrMsg = _('No records were selected.', request)

		if not ErrMsg:
			with request.connmgr.get_connection('admin') as conn:
				remove_info = conn.execute(
					'EXEC dbo.sp_%s_SharingProfile_s_RecordRemove ?, ?, ?' % domain.str,
					request.dboptions.MemberID, context.ProfileID, IDList).fetchone()

			if not remove_info.WillBeRemoved:
				ErrMsg = _('No records were removed. They may already have been removed, or be scheduled for removal in the next few days.', request)

		title = _('Manage Sharing Profiles', request)
		if ErrMsg:
			self._error_page(ErrMsg, title)

		min_date = date.today()
		if context.addable or context.partnerreview:
			if context.addable:
				min_date = min_date + timedelta(context.profile.RevocationPeriod)

			request.model_state.form.data['RevocationDate'] = format_date(min_date, request)

		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=domain, IDList=IDList, remove_info=remove_info, min_date=min_date), no_index=True)

	@view_config(match_param='action=remove_records', renderer=templateprefix + 'records.mak', request_method='POST', custom_predicates=[lambda c, r: c.partnerreview or c.profile.MemberID == r.dboptions.MemberID])
	def remove_records(self):
		request = self.request
		context = request.context
		min_date = date.today()
		if context.addable:
			min_date = min_date + timedelta(context.profile.RevocationPeriod)

		domain = context.domain
		validator = {}
		if domain.id == const.DM_CIC:
			id_name = 'NUM'
			validator['NUM'] = ciocvalidators.CSVForEach(ciocvalidators.NumValidator())
		else:
			id_name = 'VNUM'
			validator['VNUM'] = ciocvalidators.CSVForEach(ciocvalidators.VNumValidator())

		if context.addable or context.partnerreview:

			validator['RevocationDate'] = ciocvalidators.DateConverter(not_empty=True, min=min_date)

		model_state = request.model_state
		model_state.schema = BaseSchema(**validator)

		if model_state.validate():
			IDList = ','.join(str(x).upper() for x in model_state.value(id_name))
			with request.connmgr.get_connection('admin') as conn:
				sql = '''
					DECLARE @RC int, @ErrMsg nvarchar(500)
					EXEC @RC = dbo.sp_%s_SharingProfile_u_RecordRemove ?, ?, ?, ?, @ErrMsg OUTPUT

					SELECT @RC AS [Return], @ErrMsg AS ErrMsg
				''' % domain.str

				args = (context.ProfileID, request.user.User_ID,
					IDList, model_state.value('RevocationDate'))

				cursor = conn.execute(
					sql, args)

				emails = cursor.fetchone()

				if emails[0]:
					emails = [x.strip() for x in emails[0].split(',')]
				else:
					emails = None

				cursor.nextset()

				domain_name = cursor.fetchone()

				cursor.nextset()

				records = '\n'.join(_(': ').join(x) for x in cursor.fetchall())

				cursor.nextset()

				result = cursor.fetchone()

				cursor.close()

			if not result.Return:
				if ((context.profile.Active and context.addable) or context.partnerreview) and records and emails:
					profile = context.profile
					vars = {
						'ExpireDate': format_date(model_state.value('RevocationDate'), request),
						'MemberName': profile.SharingMemberName if profile.MemberID == request.dboptions.MemberID else profile.ReceivingMemberName,
						'ProfileName': profile.Name,
						'ProfileURL': domain_name[0] + request.route_path('admin_sharingprofile', action='records', _query=[('ProfileID', str(context.ProfileID)), ('DM', str(domain.id))]) if domain_name else ''
					}

					subject = _(_revoke_records_subject, request) % vars
					message = _(_revoke_records_template, request) % vars
					message = format_message(message) % records

					send_email(
						request, getattr(request.dboptions, 'DefaultEmail%s' % context.domain.str),
						emails, subject, message)

				self._go_to_route('admin_sharingprofile', action='records', _query=[('ProfileID', context.ProfileID), ('DM', domain.id)])

			ErrMsg = result.ErrMsg
		else:
			ErrMsg = _('There were validation errors.', request)

		with request.connmgr.get_connection('admin') as conn:
			profile = context.profile
			records = conn.execute(
				'EXEC dbo.sp_%s_SharingProfile_s_Records ?, ?, ?' % domain.str,
				request.dboptions.MemberID, profile.ProfileID,
				getattr(request.viewdata, domain.str.lower()).ViewType).fetchall()

		model_state.form.data[id_name] = request.POST.getall(id_name)

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=domain, records=records, min_date=min_date, ErrMsg=ErrMsg), no_index=True)

	@view_config(match_param='action=changeemail', renderer=templateprefix + 'changeemail.mak', custom_predicates=[lambda c, r: c.partnerreview])
	def changeemail(self):
		request = self.request
		context = request.context

		domain = context.domain
		profile = context.profile

		request.model_state.form.data['ShareNotifyEmailAddresses'] = profile.ShareNotifyEmailAddresses

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=domain), no_index=True)

	@view_config(match_param='action=changeemail', renderer=templateprefix + 'changeemail.mak', request_method='POST', custom_predicates=[lambda c, r: c.partnerreview])
	def changeemail_save(self):
		request = self.request
		context = request.context

		model_state = request.model_state
		model_state.schema = ShareEmailValidation()

		if not model_state.validate():
			ErrMsg = _('There were validation errors.', request)
		else:

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				Declare @ErrMsg as nvarchar(500),
				@RC as int

				EXECUTE @RC = dbo.sp_%s_SharingProfile_u_ShareEmailAddresses ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % context.domain.str

				cursor = conn.execute(sql, context.ProfileID, request.dboptions.MemberID, model_state.value('ShareNotifyEmailAddresses'))

				result = cursor.fetchone()

				cursor.close()

			query_args = [('ProfileID', context.ProfileID), ('DM', context.domain.id)]
			if not result.Return:
				query_args.append(('InfoMsg', _('The Profile was successfully accepted.', request)))
				self._go_to_route('admin_sharingprofile', action='edit', _query=query_args)

			else:
				ErrMsg = _('Unable to save: ') + result.ErrMsg

		title = _('Manage Sharing Profiles', request)
		return self._create_response_namespace(title, title, dict(ProfileID=context.ProfileID, profile=context.profile, domain=context.domain, ErrMsg=ErrMsg), no_index=True)
