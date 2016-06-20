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


import logging
log = logging.getLogger(__name__)

import xml.etree.cElementTree as ET

from formencode import Schema, validators, variabledecode
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const

from cioc.core.i18n import gettext as _
from cioc.core.listformat import format_list, format_pub_list
from cioc.web.admin.viewbase import AdminViewBase


RecordNoteSettings = {'N': 0, 'A': 1, 'S': 2}
RRecordNoteSettings = dict((v, k) for k, v in RecordNoteSettings.iteritems())

PreventDuplicateOrgNamesSettings = {'A': 0, 'W': 1, 'D': 2}
RPreventDuplicateOrgNamesSettings = dict((v, k) for k, v in PreventDuplicateOrgNamesSettings.iteritems())

DefaultGCTypeSettings = {'B': const.GC_BLANK, 'S': const.GC_SITE,
						'I': const.GC_INTERSECTION, 'M': const.GC_MANUAL}
RDefaultGCTypeSettings = dict((v, k) for k, v in DefaultGCTypeSettings.iteritems())


def IsCICSuperUser(value_dict, state):
	try:
		return state.request.user.cic.SuperUser
	except:
		return False


def IsVOLSuperUser(value_dict, state):
	try:
		return state.request.user.vol.SuperUser
	except:
		return False


def IsVOLSuperUserAndProfiles(value_dict, state):
	try:
		return state.request.user.vol.SuperUser and state.request.dboptions.UseVolunteerProfiles
	except:
		return False


class GeneralBaseSchema(Schema):
	if_key_missing = None

	DefaultViewCIC = ciocvalidators.IDValidator()
	DefaultViewVOL = ciocvalidators.IDValidator()
	DefaultTemplate = ciocvalidators.IDValidator(not_empty=True)
	DefaultPrintTemplate = ciocvalidators.IDValidator(not_empty=True)
	PrintModePublic = validators.Bool()
	TrainingMode = validators.Bool()
	UseInitials = validators.Bool()
	SiteCodeLength = validators.Int(min=0, max=255, if_empty=0)
	DaysSinceLastEmail = validators.Int(min=0, max=ciocvalidators.MAX_SMALL_INT)
	DefaultEmailCIC = ciocvalidators.EmailValidator()
	DefaultEmailVOL = ciocvalidators.EmailValidator()
	DefaultEmailVOLProfile = ciocvalidators.EmailValidator()
	BaseURLCIC = ciocvalidators.Url(max=100)
	BaseURLVOL = ciocvalidators.Url(max=100)
	DefaultGCType = validators.DictConverter(DefaultGCTypeSettings, if_empty=0)
	CanDeleteRecordNoteCIC = validators.DictConverter(RecordNoteSettings)
	CanUpdateRecordNoteCIC = validators.DictConverter(RecordNoteSettings)
	CanDeleteRecordNoteVOL = validators.DictConverter(RecordNoteSettings)
	CanUpdateRecordNoteVOL = validators.DictConverter(RecordNoteSettings)
	RecordNoteTypeOptionalCIC = validators.Bool()
	RecordNoteTypeOptionalVOL = validators.Bool()
	PreventDuplicateOrgNames = validators.DictConverter(PreventDuplicateOrgNamesSettings)
	UseLowestNUM = validators.Bool()
	UseOfflineTools = validators.Bool()
	OnlySpecificInterests = validators.Bool()
	LoginRetryLimit = validators.Int(max=20)

	chained_validators = [
		ciocvalidators.RequireIfPredicate(IsCICSuperUser, [
			'DefaultViewCIC', 'DefaultEmailCIC', 'BaseURLCIC',
			'CanDeleteRecordNoteCIC', 'CanUpdateRecordNoteCIC',
		]),
		ciocvalidators.RequireIfPredicate(IsVOLSuperUser, [
			'DefaultViewVOL', 'DefaultEmailVOL', 'DefaultEmailVOLProfile', 'BaseURLVOL',
			'CanDeleteRecordNoteVOL', 'CanUpdateRecordNoteVOL'
		])
	]


class GeneralDescriptionSchema(Schema):
	if_key_missing = None

	DatabaseNameCIC = ciocvalidators.UnicodeString(max=255)
	DatabaseNameVOL = ciocvalidators.UnicodeString(max=255)
	FeedbackMsgCIC = ciocvalidators.UnicodeString(max=2000)
	FeedbackMsgVOL = ciocvalidators.UnicodeString(max=2000)
	VolProfilePrivacyPolicyOrgName = ciocvalidators.UnicodeString(max=255)
	VolProfilePrivacyPolicy = ciocvalidators.UnicodeString()

	chained_validators = [
		ciocvalidators.RequireIfPredicate(IsCICSuperUser, [
			'DatabaseNameCIC', 'FeedbackMsgCIC'
		]),
		ciocvalidators.RequireIfPredicate(IsVOLSuperUser, [
			'DatabaseNameVOL', 'FeedbackMsgVOL'
		]),
		ciocvalidators.RequireIfPredicate(IsVOLSuperUserAndProfiles, [
			'VolProfilePrivacyPolicyOrgName', 'VolProfilePrivacyPolicy'
		])
	]


class GeneralSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	settings = GeneralBaseSchema()
	descriptions = ciocvalidators.CultureDictSchema(GeneralDescriptionSchema())


@view_defaults(route_name='admin_generalsetup', renderer='cioc.web.admin:templates/generalsetup.mak')
class GeneralSetup(AdminViewBase):

	@view_config(request_method="POST")
	def save(self):
		request = self.request

		user = request.user

		if not user.SuperUser:
			self._security_failure()

		extra_validators = {}
		model_state = request.model_state

		model_state.schema = GeneralSchema(**extra_validators)
		model_state.form.variable_decode = True

		if model_state.validate():
			# valid. Save changes and redirect

			settings = model_state.form.data['settings'] or {}

			args = [request.dboptions.MemberID, user.Mod, user.Agency, user.cic.SuperUser, user.vol.SuperUser]

			fields = GeneralBaseSchema.fields.keys()

			kwargs = ", ".join(k.join(("@", "=?")) for k in fields)

			args.extend((settings.get(k) for k in fields))

			root = ET.Element('DESCS')

			for culture, data in model_state.form.data['descriptions'].iteritems():
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in data.iteritems():
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root))

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int

				EXECUTE @RC = dbo.sp_STP_Member_u ?,?,?,?,?, %s, @Descriptions=?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % (kwargs)

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:

				self.request.dboptions._invalidate()
				self._go_to_route('admin_generalsetup', action='edit', _query=(('InfoMsg', _('The General Setup Options were successfully updated.', request)),))

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			ErrMsg = _('There were validation errors.')

		settings = None
		templates = []
		cic_views = []
		publications = []
		vol_views = []

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_STP_Member_s_FormLists ?, ?, ?, ?',
						request.dboptions.MemberID, user.Agency, user.cic.SuperUser, user.vol.SuperUser)

			templates = cursor.fetchall()

			if user.cic.SuperUser:

				cursor.nextset()
				cic_views = cursor.fetchall()

				cursor.nextset()

				publications = cursor.fetchall()

			if user.vol.SuperUser:
				cursor.nextset()

				vol_views = cursor.fetchall()
			cursor.close()

			cursor = conn.execute('EXEC dbo.sp_STP_Member_sf ?', request.dboptions.MemberID)
			settings = cursor.fetchone()
			cursor.close()

		dms = []
		if user.cic.SuperUser:
			dms.append('CIC')
		if user.vol.SuperUser:
			dms.append('VOL')

		data = variabledecode.variable_decode(request.POST)
		submitted_settings = data.get('settings', {})
		data = model_state.form.data
		for dm in dms:
			for action in ['Delete', 'Update']:
				field = ''.join(('Can', action, 'RecordNote', dm))
				val = submitted_settings.get(field)

				data['settings.' + field] = RRecordNoteSettings.get(val, val)

		if user.cic.SuperUser:
			val = submitted_settings.get('PreventDuplicateOrgNames')
			data['settings.PreventDuplicateOrgNames'] = RPreventDuplicateOrgNamesSettings.get(val, val)
			val = submitted_settings.get('DefaultGCType')
			data['settings.DefaultGCType'] = RDefaultGCTypeSettings.get(val, val)

		title = _('General Setup Options', request)
		return self._create_response_namespace(
			title, title,
			dict(
				action=action, settings=settings, templates=format_list(templates),
				cic_views=format_list(cic_views), publications=format_pub_list(publications, True),
				vol_views=format_list(vol_views), ErrMsg=ErrMsg
			), no_index=True)

	@view_config()
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		settings = None
		settings_descriptions = {}
		templates = []
		cic_views = []
		publications = []
		vol_views = []

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_STP_Member_sf ?', request.dboptions.MemberID)
			settings = cursor.fetchone()
			if settings:
				cursor.nextset()
				for lng in cursor.fetchall():
					settings_descriptions[lng.Culture.replace('-', '_')] = lng

			cursor.close()

			if not settings:
				# not found
				self._error_page(_('Member Not Found', request))

			cursor = conn.execute('EXEC dbo.sp_STP_Member_s_FormLists ?, ?, ?, ?',
						request.dboptions.MemberID, user.Agency, user.cic.SuperUser, user.vol.SuperUser)

			templates = cursor.fetchall()

			if user.cic.SuperUser:

				cursor.nextset()
				cic_views = cursor.fetchall()

				cursor.nextset()

				publications = cursor.fetchall()

			if user.vol.SuperUser:
				cursor.nextset()

				vol_views = cursor.fetchall()

			cursor.close()

		model_state = request.model_state
		model_state.form.data['settings'] = settings
		model_state.form.data['descriptions'] = settings_descriptions

		dms = []
		if user.cic.SuperUser:
			dms.append('CIC')
		if user.vol.SuperUser:
			dms.append('VOL')

		data = model_state.form.data
		for dm in dms:
			for action in ['Delete', 'Update']:
				field = ''.join(('Can', action, 'RecordNote', dm))
				val = getattr(settings, field)

				data['settings.' + field] = RRecordNoteSettings.get(val, val)

		if user.cic.SuperUser:
			val = settings.PreventDuplicateOrgNames
			data['settings.PreventDuplicateOrgNames'] = RPreventDuplicateOrgNamesSettings.get(val, val)

			val = settings.DefaultGCType
			data['settings.DefaultGCType'] = RDefaultGCTypeSettings.get(val, val)

		title = _('General Setup Options', request)
		return self._create_response_namespace(
			title, title,
			dict(
				action=action, settings=settings, templates=format_list(templates),
				cic_views=format_list(cic_views), publications=format_pub_list(publications, True),
				vol_views=format_list(vol_views)
			), no_index=True)
