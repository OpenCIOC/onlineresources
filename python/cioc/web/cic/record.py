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
import itertools
import tempfile
import os
from six.moves.urllib.parse import urlencode

import pyodbc
from xml.etree import cElementTree as ET
from lxml import html
from markupsafe import Markup
from pyramid.view import view_config

from cioc.core import i18n, constants as const, validators, searchlist, recordowner, renderpdf, googlemaps
from cioc.web.cic.viewbase import CicViewBase
from cioc.core.stat import insert_stat
from six.moves import range

gettext = i18n.gettext
ngettext = i18n.ngettext
log = logging.getLogger(__name__)

BASE_SKIP_FIELDS = frozenset(
	'RSN NUM RECORD_OWNER ORG_NUM DELETION_DATE MODIFIED_DATE UPDATE_DATE UPDATE_SCHEDULE'.split() +
	['ORG_LEVEL_%d' % t for t in range(1, 6)]
)

link_template = Markup('<a class="RecordDetailsHeaderText" href="%s">%s</a>')


def tidy_name(name):
	return Markup((name or u'').strip())


def should_link_levels(request):
	return request.viewdata.cic.LinkOrgLevels and not request.viewdata.PrintMode


def link_org_level(request, record, level):
	org_data = tidy_name(getattr(record, 'ORG_LEVEL_%d' % level))
	if not org_data:
		return u''

	if level <= record.LINK_ORG_TO and should_link_levels(request):
		crit = [(u'OL%d' % i, getattr(record, 'ORG_LEVEL_%d' % i, '') or '') for i in range(1, level + 1)]
		return link_template % (request.passvars.makeLink('~/bresults.asp', crit), org_data)

	return org_data


def link_service_name_level(request, record, level):
	org_data = tidy_name(getattr(record, 'SERVICE_NAME_LEVEL_%d' % level))
	loc_data = tidy_name(record.LOCATION_NAME)

	if not org_data:
		return u''

	if getattr(record, 'LINK_SERVICE_NAME_%d' % level) and not (org_data == loc_data and record.LINK_LOCATION_NAME) and should_link_levels(request):

		crit = [(u'ORGNUM', record.ORG_NUM or record.NUM), (u'SL%d' % level, org_data)]

		return link_template % (request.passvars.makeLink('~/bresults.asp', crit), org_data)

	if org_data != tidy_name(record.ORG_LEVEL_1) and org_data != loc_data:
		return org_data

	return u''


def link_location_name(request, record):
	org_data = tidy_name(record.LOCATION_NAME)

	if record.LINK_LOCATION_NAME and org_data and should_link_levels(request):
		crit = [(u'ORGNUM', record.ORG_NUM or record.NUM), ('LL1', org_data)]

		return link_template % (request.passvars.makeLink('~/bresults.asp', crit), org_data)

	if org_data != tidy_name(record.ORG_LEVEL_1):
		return org_data

	return u''


def parse_language_xml(record):
	if not record.RECORD_LANG:
		return []
	return ET.fromstring((u'<RECORD_LANG>' + (record.RECORD_LANG or u'') + u'</RECORD_LANG>').encode('utf-8'))


_active_template = Markup(u'<span class="NoWrap"><a class="NoLineLink" href="%(link)s"><img src="/images/%(culture)s.gif" aria-hidden="true" border="0"> %(name)s</a></span>')
_inactive_template = Markup(u'<span class="NoWrap"><a class="NoLineLink" href="%(link)s">%(name)s</a></span>')


def link_other_langs(request, lang_xml, num, cur_culture, number):
	templates = {
		u'1': _active_template,
		u'0': _inactive_template
	}

	makeDetailsLink = request.passvars.makeDetailsLink
	langs = []
	for language in lang_xml:
		culture = language.get('Culture')
		can_see = language.get('CAN_SEE')
		if can_see != u'1':
			continue
		if culture == cur_culture:
			continue

		active = language.get('Active', '0')
		ln_arg = 'Ln=' + culture
		if active != u'1':
			ln_arg = 'Tmp' + ln_arg

		if number is not None:
			ln_arg = 'Number=%d&%s' % (number, ln_arg)

		link = makeDetailsLink(num, ln_arg)
		langs.append(templates[active] % {'link': link, 'culture': culture, 'name': language.get('LanguageName')})

	return Markup(u' | ').join(langs)


_reminder_template = Markup(u'<span class="HideNoJs"> | <a id="reminders" style="cursor: pointer;" class="NoLineLink%s" title="%s">%s%s</a></span>')
_past_due_icon = Markup(u'<span class="ui-state-error" style="border: none; background: inherit"><span style="display: inline-block; vertical-align: text-bottom;" class="ui-icon ui-icon-alert"></span> </span>')
_reminder_icon = Markup(u'<img src="/images/remind.gif" aria-hidden="true">')


def get_reminder_notice(request, record):
	total = 0
	past_due = 0
	if record.REMINDERS:
		reminders = ET.fromstring(record.REMINDERS.encode('utf-8')).attrib
		total = int(reminders.get('Total', 0))
		past_due = int(reminders.get('PastDue', 0))

	alert = ''
	title = ngettext(u'There is %d reminder.', u'There are %d reminders.', total, request) % total
	icon = ''
	if past_due:
		title += u' ' + ngettext('%d is due.', '%d are due.', past_due, request) % past_due
		alert = u' Alert'
		icon = _past_due_icon
	elif total:
		icon = _reminder_icon

	title += u' ' + gettext('Click to view.', request)

	return _reminder_template % (alert, title, icon, gettext('REMINDERS', request))


_optgroup_template = Markup(u'<optgroup label="%s">%s</optgroup>')
_option_template = Markup(u'<option id="%s" href="%s"%s>%s</option>')


def build_nav_dropdown(request, record, num_link, num_number_link, idlist_link, lang_xml, cur_culture, restore_culture):
	optgroups = []
	options = []

	makeLink = request.passvars.makeLink
	cicuser = request.user.cic
	_ = gettext

	# Data Management
	if record.CAN_UPDATE == 1:
		options.append(('AL_Update', makeLink('~/entryform.asp', num_number_link + ('' if cur_culture == restore_culture else '&UpdateLn=' + cur_culture)), '', _('Update Record', request)))

	if request.multilingual:
		for lang in lang_xml:
			culture = lang.get('Culture')
			if lang.get('HAS_LANG') == '0' and lang.get('CAN_UPDATE') == '1':
				options.append(('AL_Equivalent' + culture, makeLink('~/copy.asp', num_number_link + '&CopyLn=' + culture), '', _('Create Equivalent - %s', request) % lang.get('LanguageName')))

	if request.dboptions.UseCIC and record.CAN_UPDATE != 0 and cicuser.CanCopyRecord:
		options.append(('AL_Copy', makeLink('~/copy.asp', num_link), '', _('Copy Record', request)))

	if (cicuser.SuperUser or cicuser.CanDeleteRecord) and record.CAN_UPDATE == 1:
		if not record.DELETION_DATE:
			options.append(('AL_Delete', makeLink('~/delete_mark.asp', 'IdList=%d' % record.BTD_ID), '', _('Delete Record', request)))
		else:
			options.append(('AL_Restore', makeLink('~/delete_mark.asp', 'IdList=%d&Unmark=on' % record.BTD_ID), '', _('Restore Record', request)))

	if options:
		optgroups.append((_('Data Management', request), Markup(u'').join(_option_template % x for x in options)))

		options = []

	if request.dboptions.UseCIC:
		# Classification
		if request.viewdata.cic.UseTaxonomyView and record.CAN_INDEX:
			options.append(('AL_Taxonomy', makeLink('~/update_tax.asp', num_number_link), '', _('Update Service Categories', request)))

		if cicuser.CanUpdatePubs != const.UPDATE_NONE:
			if not cicuser.LimitedView:
				options.append(('AL_Pubs', makeLink('~/update_pubs.asp', num_number_link), '', _('Update Publications', request)))
			elif record.CAN_UPDATE_PUB:
				options.append(('AL_Headings', makeLink('~/updatepubs/edit', num_number_link + '&BTPBID=%d' % record.BT_PB_ID), '', _('Update Description/Headings', request)))

		if options:
			optgroups.append((_('Classification', request), Markup(u'').join(_option_template % x for x in options)))
			options = []

		# Request Update
		if cicuser.CanRequestUpdate and (cicuser.SuperUser or request.user.Agency == record.RECORD_OWNER) and (record.MemberID == request.dboptions.MemberID or record.CAN_UPDATE == 1):
			if record.CAN_EMAIL and not request.dboptions.NoEmail:
				options.append(('AL_EmailUpdate', makeLink('~/admin/email_prep.asp', idlist_link + '&DM=%d' % const.DM_CIC), '', _('Email Update Request', request)))

			options.append(('AL_MailForm', makeLink('~/mailform.asp', num_number_link + '&PrintMd=on'), ' newwindow', _('Mail Form (New Window)', request)))

		if options:
			optgroups.append((_('Request Update', request), Markup(u'').join(_option_template % x for x in options)))

			options = []

	# Volunteer
	log.debug('%s %s %s', request.dboptions.UseVOL, request.viewdata.cic.VolunteerLink, request.user.vol.CanAddRecord)
	if request.dboptions.UseVOL and request.viewdata.cic.VolunteerLink and request.user.vol.CanAddRecord:
		options.append(('AL_CreateOpp', makeLink('~/volunteer/entryform.asp', num_link), '', _('Create Volunteer Opportunity', request)))

		if request.user.vol.CanRequestUpdate and not request.dboptions.NoEmail:
			options.append(('AL_EmailUpdateAllOpp', makeLink('~/admin/email_prep.asp', idlist_link + '&MR=1&DM=%d' % const.DM_VOL), '', _('Email Update All Volunteer Opportunities Request', request)))

		if options:
			optgroups.append((_('Volunteer', request), Markup(u'').join(_option_template % x for x in options)))
			options = []

	if optgroups:
		return Markup(u'').join(_optgroup_template % x for x in optgroups)

	return ''


_first_prev_template = Markup(u'''<span style="white-space: nowrap"><a id="first_link_top" class="NoLineLink DetailsLink" data-num="%(first_num)s" href="%(first_url)s"><img src="/images/first.gif" aria-hidden="true" border="0">&nbsp;%(first)s</a></span>
				<span class="NoWrap"><a id="prev_link_top" class="NoLineLink DetailsLink" data-num="%(prev_num)s" href="%(prev_url)s"><img src="/images/previous.gif" aria-hidden="true" border="0">&nbsp;%(previous)s</a></span>''')
_next_last_template = Markup(u'''<span class="NoWrap"><a id="next_link_top" class="NoLineLink DetailsLink" data-num="%(next_num)s" href="%(next_url)s">%(next)s&nbsp;<img src="/images/next.gif" aria-hidden="true" border="0"></a></span>
				<span class="NoWrap"><a id="last_link_top" class="NoLineLink DetailsLink" data-num="%(last_num)s" href="%(last_url)s">%(last)s&nbsp;<img src="/images/last.gif" aria-hidden="true" border="0"></a></span>''')
_other_results_template = Markup(u'''<strong>%(other_results)s</strong><br class="visible-xs-inline visible-sm-inline"> ''')
_total_template = Markup(u'''<span class="NoWrap">(%(human_number)s %(of)s %(length)s
		<a id="total_link_top" class="NoLineLink SearchTotalLink" href="%(total_url)s">%(total)s</a>)</span>''')


def get_search_list_top(request, search_list, number):
	if request.viewdata.PrintMode or not search_list or number is None:
		return ''

	_ = gettext
	makeDetailsLink = request.passvars.makeDetailsLink

	search_list_ui = [_other_results_template % {'other_results': _('Other Search Results:', request)}]

	if len(search_list) > 1 and number > 0:
		search_list_ui.append(_first_prev_template % {
			'first_num': search_list[0],
			'first_url': makeDetailsLink(search_list[0], "Number=0"),
			'prev_num': search_list[number - 1],
			'prev_url': makeDetailsLink(search_list[number - 1], "Number=%d" % (number - 1)),
			'first': _(u'First', request),
			'previous': _(u'Previous', request),
		})

	if number < len(search_list) - 1:
		if len(search_list_ui) > 1:
			search_list_ui.append(u' | ')

		search_list_ui.append(_next_last_template % {
			'next_num': search_list[number + 1],
			'next_url': makeDetailsLink(search_list[number + 1], "Number=%d" % (number + 1)),
			'last_num': search_list[-1],
			'last_url': makeDetailsLink(search_list[-1], "Number=%d" % (len(search_list) - 1)),
			'next': _('Next', request),
			'last': _('Last', request),
		})

	search_list_ui.append(_total_template % {
		'human_number': number + 1,
		'of': _('of', request),
		'length': len(search_list),
		'total_url': request.passvars.makeLink('~/presults.asp'),
		'total': _('Total', request),
	})

	return Markup(u' ').join(search_list_ui)


def get_search_list_and_number(request, record):
	search_list = searchlist.get_search_list(request, const.DM_CIC)
	number = None
	if search_list:
		try:
			number = search_list.index(record.NUM)
		except ValueError:
			pass

	return search_list, number


class CicDetailsSchema(validators.Schema):
	TmpLn = validators.ActiveCulture(record_cultures=True, if_error=None)
	InlineResults = validators.Bool()
	UseCICVwTmp = validators.IDValidator(if_error=None)


@view_config(route_name='cic_pdf_details')
@view_config(route_name='cic_details')
class CicDetails(CicViewBase):
	def __init__(self, request, require_login=False):
		CicViewBase.__init__(self, request, require_login)

	def __call__(self):
		request = self.request

		num = request.matchdict.get('num')

		is_pdf = request.matched_route.name == 'cic_pdf_details'

		_ = gettext

		model_state = request.model_state
		model_state.schema = CicDetailsSchema()
		model_state.method = None

		if not model_state.validate():
			# clear incorrect values
			for error in model_state.form.errors:
				try:
					del model_state.form.data[error]
				except KeyError:
					pass

		cur_culture = model_state.value('TmpLn')
		restore_culture = request.language.Culture
		if cur_culture:
			request.language.setSystemLanguage(cur_culture)
		else:
			cur_culture = restore_culture

		viewdata = request.viewdata.cic
		cic_view_type = viewdata.ViewType
		user = request.user
		user_cic = user.cic
		with request.connmgr.get_connection() as conn:
			cursor = conn.execute(
				'EXEC sp_CIC_View_DisplayFields @NUM=?, @ViewType=?, @WebEnable=?, @LoggedIn=?, @HTTPVals=?, @PathToStart=?',
				num,
				cic_view_type,
				not request.viewdata.PrintMode,
				not not user,
				request.passvars.cached_url_vals or None,
				request.pageinfo.PathToStart
			)

			field_list = cursor.fetchall()

			cursor.close()

			skip_fields = set(BASE_SKIP_FIELDS)
			if viewdata.DataMgmtFields:
				skip_fields.add('CREATED_DATE')
			if user_cic.CanRequestUpdate:
				skip_fields.add('EMAIL_UPDATE_DATE')

			more_skip = set()
			if viewdata.ShowRecordDetailsSidebar:
				more_skip = {
					'LOCATION_SERVICES',
					'LOCATION_SERVICES_STAFF',
					'ORG_LOCATIONS',
					'ORG_LOCATIONS_STAFF',
					'ORG_NUM_DETAIL',
					'ORG_SERVICES',
					'ORG_SERVICES_STAFF',
					'SERVICE_LOCATIONS',
					'SERVICE_LOCATIONS_STAFF'
				}
				skip_fields.update(more_skip)

				sidebar_sql = """
SELECT bt.NUM, dbo.fn_GBL_DisplayFullOrgName_Agency(bt.NUM,@@LangID) AS ORG_NAME,
dbo.fn_CIC_RecordInView(bt.NUM,@ViewTypeCIC,@@LangID,0,GETDATE()) AS InView,
ISNULL(CMP_OrgDescriptionShort, CMP_DescriptionShort) + CASE WHEN RIGHT(ISNULL(btd.CMP_OrgDescriptionShort, btd.CMP_DescriptionShort), 4) = ' ...' AND bt.NUM<>@NUM THEN ' ' + cioc_shared.dbo.fn_SHR_GBL_Link_Record(bt.NUM,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('More',@@LANGID) + ']',@HTTPVals,@PathToStart) ELSE '' END AS SUMMARY, 0 AS CheckHTML, 0 AS Deleted, btd.NON_PUBLIC
FROM GBL_BaseTable bt
INNER JOIN GBL_BaseTable_Description btd
	ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
WHERE bt.NUM=@ORG_NUM

SELECT bt.*, 1 AS CheckHTML
FROM dbo.fn_GBL_NUMToOrgLocations_Details_rst(ISNULL(@ORG_NUM, @NUM), @ViewTypeCIC, @Staff) bt
ORDER BY bt.Deleted, ORG_NAME

SELECT bt.*, 0 AS CheckHTML
FROM dbo.fn_GBL_NUMToOrgServices_Details_rst(ISNULL(@ORG_NUM, @NUM), @ViewTypeCIC, @Staff, @HTTPVals, @PathToStart) bt
ORDER BY bt.Deleted, ORG_NAME

SELECT bt.*, 0 AS CheckHTML
FROM dbo.fn_GBL_NUMToLocationServices_Details_rst(@NUM, @ORG_NUM, @ViewTypeCIC, @Staff, @HTTPVals, @PathToStart) bt
ORDER BY bt.Deleted, ORG_NAME

SELECT bt.*, 1 AS CheckHTML
FROM dbo.fn_GBL_NUMToServiceLocations_Details_rst(@NUM, @ORG_NUM, @ViewTypeCIC, @Staff) bt
ORDER BY bt.Deleted, ORG_NAME

SELECT bt.*, 1 AS CheckHTML
FROM dbo.fn_GBL_NUMToSimilarServices_rst(@NUM, ISNULL(@ORG_NUM, @NUM), @ViewTypeCIC, @Staff) bt
"""
			else:
				sidebar_sql = ''

			field_sql = '\n'.join('%s, ' % x.FieldSelect for x in field_list if x.FieldName not in skip_fields)

			logged_in_sql = ''
			lang_can_update = ''
			if user:
				lang_can_update = ',dbo.fn_CIC_CanCreateEquivalent(bt.NUM,@UserID,@ViewTypeCIC,LangID,GETDATE(),@@LANGID) AS CAN_UPDATE'
				# SQL for information Flags:
				# - Can the user update this record?
				# - Can an Email update request be sent to this record?
				# - Does this record have feedback?
				# - Does this record have Publication feedback?
				# - Can the user index this record with the Taxonomy?
				logged_in_sql = """\
dbo.fn_CIC_CanUpdateRecord(bt.NUM,@UserID,@ViewTypeCIC,@@LANGID,GETDATE()) AS CAN_UPDATE,
CASE WHEN ((btd.E_MAIL IS NOT NULL OR bt.UPDATE_EMAIL IS NOT NULL) AND bt.NO_UPDATE_EMAIL=0)
	THEN 1 ELSE 0 END AS CAN_EMAIL,
CASE WHEN EXISTS(SELECT * FROM GBL_FeedbackEntry fbe WHERE fbe.NUM=bt.NUM
		AND (EXISTS(SELECT * FROM GBL_Feedback fb WHERE fbe.FB_ID=fb.FB_ID) OR EXISTS(SELECT * FROM CIC_Feedback fb WHERE fbe.FB_ID=fb.FB_ID)))
	THEN 1 ELSE 0 END AS HAS_FEEDBACK,
CASE WHEN EXISTS(SELECT * FROM CIC_BT_PB pbr INNER JOIN CIC_Feedback_Publication pf ON pbr.BT_PB_ID=pf.BT_PB_ID WHERE pbr.NUM=bt.NUM)
	THEN 1 ELSE 0 END AS HAS_PUB_FEEDBACK,
dbo.fn_CIC_CanIndexRecord(bt.NUM,@UserID,@ViewTypeCIC,@@LANGID,GETDATE()) AS CAN_INDEX,
dbo.fn_CIC_Reminders(bt.NUM,@UserID,@@LANGID,GETDATE()) AS REMINDERS,
"""

			check_update_pub = user_cic.CanUpdatePubs != const.UPDATE_NONE and user_cic.LimitedView and user_cic.PB_ID == viewdata.PB_ID
			record_sql = """\
SET NOCOUNT ON

DECLARE @NUM varchar(8) = ?, @ViewTypeCIC int  = ?, @UserID int = ?, @PB_ID int = ?, @Staff bit = ?, @ORG_NUM varchar(8), @HTTPVals nvarchar(50) = ?, @PathToStart nvarchar(100) = ?
SET @ORG_NUM=(SELECT ORG_NUM FROM GBL_BaseTable WHERE NUM=@NUM)

SELECT bt.MemberID, btd.BTD_ID,
dbo.fn_CIC_LinkOrgLevel(@ViewTypeCIC,bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,GETDATE()) AS LINK_ORG_TO,
dbo.fn_CIC_LinkLocationName(@ViewTypeCIC,bt.NUM,bt.ORG_NUM,btd.LOCATION_NAME,GETDATE()) AS LINK_LOCATION_NAME,
dbo.fn_CIC_LinkServiceNameLevel(@ViewTypeCIC,bt.NUM,bt.ORG_NUM,btd.SERVICE_NAME_LEVEL_1,GETDATE()) AS LINK_SERVICE_NAME_1,
dbo.fn_CIC_LinkServiceNameLevel(@ViewTypeCIC,bt.NUM,bt.ORG_NUM,btd.SERVICE_NAME_LEVEL_2,GETDATE()) AS LINK_SERVICE_NAME_2,
%(submit_changes_to)s
dbo.fn_CIC_RecordInView(bt.NUM,@ViewTypeCIC,btd.LangID,0,GETDATE()) AS IN_VIEW,
%(in_default_view)s
%(logged_in_sql)s
/* SQL information for all required display fields */
bt.RSN, bt.NUM, bt.RECORD_OWNER,
dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_LOCATION_NAME, bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
LOCATION_NAME,
SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2,
CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=bt.NUM) THEN 1 ELSE 0 END AS bit) AS IS_AGENCY,
CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('SERVICE','TOPIC') WHERE pr.NUM=bt.NUM) THEN 1 ELSE 0 END AS bit) AS IS_SERVICE,
CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('SITE') WHERE pr.NUM=bt.NUM) THEN 1 ELSE 0 END AS bit) AS IS_SITE,
bt.ORG_NUM, btd.NON_PUBLIC,
cioc_shared.dbo.fn_SHR_GBL_DateString(btd.MODIFIED_DATE) AS MODIFIED_DATE,
cioc_shared.dbo.fn_SHR_GBL_DateString(btd.UPDATE_DATE) AS UPDATE_DATE,
btd.UPDATE_SCHEDULE AS UPDATE_SCHEDULE,
btd.DELETION_DATE AS DELETION_DATE,
%(data_mgmt_fields)s
%(can_request_update)s
%(can_update_pub)s
%(vol_ops)s
(SELECT Culture,LangID,LanguageName,LanguageAlias,LCID,Active,
CASE WHEN EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=bt.NUM AND LangID=LANG.LangID) THEN 1 ELSE 0 END AS HAS_LANG,
dbo.fn_CIC_RecordInView(bt.NUM,@ViewTypeCIC,LangID,0,GETDATE()) AS CAN_SEE
%(lang_can_update)s
FROM STP_Language LANG WHERE
%(other_lang_condition)s
ORDER BY CASE WHEN Active=1 THEN 0 ELSE 1 END, LanguageName FOR XML AUTO) AS RECORD_LANG,
%(field_sql)s
btd.NUM AS LangNUM
FROM GBL_BaseTable bt
LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM
LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID
LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM
LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID
WHERE bt.NUM=@NUM

%(sidebar_sql)s

SET NOCOUNT OFF
			""" % {
				'submit_changes_to': "ISNULL(btd.SUBMIT_CHANGES_TO_PROTOCOL, 'https://') + btd.SUBMIT_CHANGES_TO AS FEEDBACK_LINK," if viewdata.UseSubmitChangesTo else '',
				'in_default_view': 'dbo.fn_CIC_RecordInView(bt.NUM,?,@@LANGID,0,GETDATE()) AS IN_DEFAULT_VIEW,' if user_cic else '0 AS IN_DEFAULT_VIEW,',
				'logged_in_sql': logged_in_sql,
				'lang_can_update': lang_can_update,
				'data_mgmt_fields': 'cioc_shared.dbo.fn_SHR_GBL_DateString(btd.CREATED_DATE) AS CREATED_DATE,' if viewdata.DataMgmtFields else '',
				'can_request_update': 'cioc_shared.dbo.fn_SHR_GBL_DateString(bt.EMAIL_UPDATE_DATE) AS EMAIL_UPDATE_DATE,' if user_cic.CanRequestUpdate else '',
				# Information for updating publication data
				'can_update_pub': 'dbo.fn_CIC_PubRelationID(bt.NUM,@PB_ID) AS BT_PB_ID, dbo.fn_CIC_CanUpdatePub(bt.NUM,@PB_ID,@UserID,@ViewTypeCIC,@@LANGID,GETDATE()) AS CAN_UPDATE_PUB,' if check_update_pub else 'CAST(0 AS bit) AS CAN_UPDATE_PUB,',
				# Does this record have an Equivalent Record
				'other_lang_condition': 'ActiveRecord=1' if viewdata.ViewOtherLangs else 'EXISTS(SELECT * FROM CIC_View_Description WHERE ViewType=@ViewTypeCIC AND LangID=LANG.LangID)',
				# Does this record have Volunteer Opportunities?
				'vol_ops': ('CASE WHEN EXISTS(SELECT vo.VNUM FROM VOL_Opportunity vo INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM WHERE vo.NUM=bt.NUM AND ' + ("(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE()) AND " if request.viewdata.vol.CanSeeExpired else '') + request.viewdata.WhereClauseVOLNoDel + ') THEN 1 ELSE 0 END AS HAS_VOL,') if request.dboptions.UseVOL and viewdata.VolunteerLink else '',
				'field_sql': field_sql,
				'sidebar_sql': sidebar_sql,
			}

			params = [
				num, cic_view_type, user.User_ID, viewdata.PB_ID, bool(user.User_ID),
				request.passvars.cached_url_vals or None, request.pageinfo.PathToStart
			]

			if user_cic:
				params.append(user_cic.ViewType)

			#log.debug('SQL %s', record_sql)
			#log.debug('Params %s', params)

			try:
				cursor = conn.execute(record_sql, params)
			except pyodbc.Error:
				log.exception('Error running SQL with params(%s):\n%s', params, record_sql)
				self._error_page(_('Error: An unkown error occurred', request), title=_('Record Details', request))

			record = cursor.fetchone()

			if viewdata.ShowRecordDetailsSidebar:
				cursor.nextset()

				agency = cursor.fetchall()

				cursor.nextset()

				org_locations = cursor.fetchall()

				cursor.nextset()

				org_services = cursor.fetchall()

				cursor.nextset()

				location_services = cursor.fetchall()

				cursor.nextset()

				service_locations = cursor.fetchall()

				cursor.nextset()

				similar_services = cursor.fetchall()

			else:
				agency = []
				org_locations = []
				org_services = []
				location_services = []
				service_locations = []
				similar_services = []

		request.language.setSystemLanguage(restore_culture)
		if record is None:
			request.response.status = '404 Not Found'
			return self._render_to_response(
				'cioc.web:templates/error.mak', _('Record Details', request), _('Record Details', request),
				{'ErrMsg': _('Error: No record exists with the ID: %s.', request) % num})

		if record.BTD_ID is None:
			# not available in requested language
			lang_xml = parse_language_xml(record)
			search_list, number = get_search_list_and_number(request, record)
			other_langs_links = link_other_langs(request, lang_xml, num, cur_culture, number)
			errmsg = _('Error: This record is not available in the selected language.', request)
			if other_langs_links:
				errmsg = errmsg + Markup('<br>') + _('Record Details:', request) + ' ' + other_langs_links
			self._error_page(errmsg, title=_('Record Details', request))

		elif not (record.IN_DEFAULT_VIEW or record.IN_VIEW):
			errmsg = _('Error: The record you requested (%s) exists in the database, but access to it has been restricted from this area. This record may be incomplete or waiting to be updated, the program or service may no longer be offered, or the type of service may have changed making it no longer appropriate for the record to be listed here.', request)
			title = _('Record Details', request)
			record_owner = recordowner.get_record_owner_info(request, record.RECORD_OWNER, const.DM_CIC)
			return self._render_to_response(
				'cioc.web.cic:templates/record_contact_agency.mak', title, title,
				dict(ErrMsg=errmsg % record.ORG_NAME_FULL, record=record, record_owner=record_owner),
				no_index=True, show_message=True)

		request.language.setSystemLanguage(cur_culture)

		search_list, number = get_search_list_and_number(request, record)
		num = record.NUM
		num_link = 'NUM=' + num
		number_link = '' if number is None else ('&Number=%d' % number)
		num_number_link = num_link + number_link
		idlist_link = 'IDList=' + num + number_link

		views = []
		if user.cic:
			with request.connmgr.get_connection('admin') as conn:
				views = conn.execute('EXEC sp_CIC_Views_l_Change ?, ?, ?', request.dboptions.MemberID, user.User_ID, viewdata.ViewType).fetchall()

		field_groups = []
		more_skip.add('LOGO_ADDRESS')
		for key, group in itertools.groupby(field_list, key=lambda x: (x.DisplayFieldGroupID, x.DisplayFieldGroupName)):
			g = ((x, getattr(record, x.FieldName)) for x in group if x.FieldName not in more_skip)
			g = [(x, y) for x, y in g if y]
			if g:
				field_groups.append((key[1], g))

		search_list_top = ''
		search_list_bottom = ''
		if number is not None:
			search_list_top = get_search_list_top(request, search_list, number)
			search_list_bottom = search_list_top.replace('_list_top', '_list_bottom')

		lang_xml = parse_language_xml(record)
		reminder_notice = ''
		nav_dropdown = ''
		if request.user:
			reminder_notice = get_reminder_notice(request, record)
			nav_dropdown = build_nav_dropdown(request, record, num_link, num_number_link, idlist_link, lang_xml, cur_culture, restore_culture)

		other_langs_links = link_other_langs(request, lang_xml, num, cur_culture, number)

		if len(org_locations) == 1 and org_locations[0].NUM == record.NUM and len(org_services) == 1 and org_services[0].NUM == record.NUM:
			org_locations = []
			org_services = []

		context = {
			'cur_culture': cur_culture,
			'restore_culture': restore_culture,
			'num': num,
			'inline_results': model_state.value('InlineResults'),
			'num_link': num_link,
			'num_number_link': num_number_link,
			'idlist_link': idlist_link,
			'record': record,
			'field_groups': field_groups,
			'logo_link': getattr(record, 'LOGO_ADDRESS', None),
			'org_level_1_linked': link_org_level(request, record, 1),
			'org_level_2to5_linked': Markup(u', ').join(x for x in (link_org_level(request, record, i) for i in range(2, 6)) if x),
			'service_levels_linked': Markup(u', ').join(x for x in (link_service_name_level(request, record, i) for i in range(1, 3)) if x),
			'location_name_linked': link_location_name(request, record),
			'other_langs_links': (Markup(u' | ') + other_langs_links) if other_langs_links else u'',
			'reminder_notice': reminder_notice,
			'nav_dropdown': nav_dropdown,
			'search_list_top': search_list_top,
			'search_list_bottom': search_list_bottom,
			'views': views,
			'agency': agency,
			'org_locations': org_locations,
			'org_services': org_services,
			'location_services': location_services,
			'service_locations': service_locations,
			'similar_services': similar_services,
		}

		if viewdata.UseSubmitChangesTo and record.FEEDBACK_LINK:
			context['feedback_link'] = record.FEEDBACK_LINK
		else:
			context['feedback_link'] = request.passvars.makeLink(
				'~/feedback.asp', context['num_link'] + '&UpdateLn=' + cur_culture)

		if not request.viewdata.PrintMode and not request.params.get('UseCICVwTmp'):
			insert_stat(request, record.RSN, record.NUM)

		namespace = self._create_response_namespace(_('Record Details', request),
				record.ORG_NAME_FULL, context, show_message=True)
		result = self._render('cioc.web.cic:templates/record.mak', namespace)

		if is_pdf:
			request.response.content_type = 'application/pdf'
			document = html.document_fromstring(result)
			document.make_links_absolute(request.path_url, False)
			for map_canvas in document.xpath("//div[@id='map_canvas']"):
				lat, lng = map_canvas.get('latitude'), map_canvas.get('longitude')
				if lat and lng and googlemaps.hasGoogleMapsAPI(request):
					maps_key = googlemaps.getGoogleMapsKeyArg(request)
					map_canvas[:] = []
					# Disable static map printing because we need to sign map links
					if False:
						map_canvas.tag = 'img'
						map_canvas.attrib['src'] = 'https://maps.googleapis.com/maps/api/staticmap?zoom=13&size=300x300&center=%s,%s&markers=color:red%%7Clabel:A%%7C%s,%s&%s' % (lat, lng, lat, lng, maps_key)
						map_canvas.attrib['class'] = 'DetailsMapCanvas'
						map_canvas.attrib['style'] = 'float: right;'

			doctree = document.getroottree()
			result = html.tostring(doctree, doctype=doctree.docinfo.doctype)

			if request.params.get('DebugPDF') != 'True':
				params = dict(list(request.GET.items()))
				vw_tmp = params.pop(u'UseCICVwTmp', None)
				if vw_tmp:
					params[u'UseCICVw'] = vw_tmp
				exclude = [u'Number', u'InlineResults', 'ErrMsg', 'InfoMsg']
				params = [(x.encode('utf-8'), y.encode('utf-8')) for x, y in params.items() if x not in exclude]
				params = urlencode(params)

				url = request.path_url.replace('/pdf', '') + (('?' + params) if params else '')

				namespace['srcurl'] = url

				footer_html = self._render('cioc.web:templates/pdffooter.mak', namespace)
				fd, name = tempfile.mkstemp(suffix='.html')
				try:
					with os.fdopen(fd, 'w') as footer:
						footer.write(footer_html)
					result = renderpdf.render_to_pdf(request, result, name)
				except:
					os.unlink(name)
					raise
			else:
				request.response.content_type = 'text/html'
			request.response.app_iter = [result]

		else:
			request.response.content_type = 'text/html'
			request.response.text = result

		return request.response
