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
log = logging.getLogger(__name__)

import collections
import xml.etree.cElementTree as ET

from formencode import Schema, validators, ForEach, All
from pyramid.view import view_config, view_defaults

from cioc.core import validators as ciocvalidators, constants as const, syslanguage

from cioc.core.i18n import gettext as _
from cioc.core.listformat import format_list, format_pub_list
from cioc.web.admin import viewbase

templateprefix = 'cioc.web.admin:templates/views/'

TopicSearchEditValues = collections.namedtuple('TopicSearchEditValues', 'ViewType TopicSearchID topic_search descriptions publications view_info is_edit')

CanSeeNonPublicPubOptions = {'A': True, 'P': False, 'S': None}
RCanSeeNonPublicPubOptions = dict((v, k) for k, v in six.iteritems(CanSeeNonPublicPubOptions))

SrchCommunityDefaultOptions = {'L': False, 'S': True}
RSrchCommunityDefaultOptions = dict((v, k) for k, v in six.iteritems(SrchCommunityDefaultOptions))

CCRFieldsOptions = {'P': False, 'A': True}
RCCRFieldsOptions = dict((v, k) for k, v in six.iteritems(CCRFieldsOptions))

QuickListMatchAllOptions = {'ALL': True, 'ANY': False}
RQuickListMatchAllOptions = dict((v, k) for k, v in six.iteritems(QuickListMatchAllOptions))


class QuickListType(validators.Int):
	min = 0
	max = 3


class ViewBaseSchema(Schema):
	if_key_missing = None

	CanSeeNonPublic = validators.Bool()
	CanSeeDeleted = validators.Bool()
	HidePastDueBy = validators.Int(min=1, max=999, if_empty=None)
	AlertColumn = validators.Bool()

	Template = ciocvalidators.IDValidator(not_empty=True)
	PrintTemplate = ciocvalidators.IDValidator()

	PrintVersionResults = validators.Bool()
	DataMgmtFields = validators.Bool()
	LastModifiedDate = validators.Bool()
	SocialMediaShare = validators.Bool()
	CommSrchWrapAt = validators.Int(min=0, max=ciocvalidators.MAX_TINY_INT, if_empty=0)

	ASrchAges = validators.Bool()
	ASrchBool = validators.Bool()
	ASrchEmail = validators.Bool()
	ASrchLastRequest = validators.Bool()
	ASrchOwner = validators.Bool()

	BSrchAutoComplete = validators.Bool()
	BSrchBrowseByOrg = validators.Bool()
	BSrchKeywords = validators.Bool()
	BSrchDefaultTab = validators.Int(min=0, max=ciocvalidators.MAX_TINY_INT, if_empty=0)

	DataUseAuth = validators.Bool()
	DataUseAuthPhone = validators.Bool()
	MyList = validators.Bool()
	ViewOtherLangs = validators.Bool()
	AllowFeedbackNotInView = validators.Bool()
	AssignSuggestionsTo = ciocvalidators.AgencyCodeValidator()
	AllowPDF = validators.Bool()
	GoogleTranslateWidget = validators.Bool()
	DefaultPrintProfile = ciocvalidators.IDValidator()

	Owner = ciocvalidators.AgencyCodeValidator()


class ViewBaseCICSchema(ViewBaseSchema):
	# CIC Only
	OtherCommunity = validators.Bool()
	RespectPrivacyProfile = validators.Bool()

	PB_ID = ciocvalidators.IDValidator()
	LimitedView = validators.Bool()
	VolunteerLink = validators.Bool()
	SrchCommunityDefault = validators.DictConverter(SrchCommunityDefaultOptions)

	ASrchAddress = validators.Bool()
	ASrchEmployee = validators.Bool()
	ASrchNear = validators.Bool()
	ASrchVacancy = validators.Bool()
	ASrchVOL = validators.Bool()

	BSrchAges = validators.Bool()
	BSrchNUM = validators.Bool()
	BSrchLanguage = validators.Bool()
	BSrchOCG = validators.Bool()
	BSrchVacancy = validators.Bool()
	BSrchVOL = validators.Bool()
	BSrchWWW = validators.Bool()
	BSrchNear2 = validators.Bool()
	BSrchNear5 = validators.Bool()
	BSrchNear10 = validators.Bool()
	BSrchNear15 = validators.Bool()
	BSrchNear25 = validators.Bool()
	BSrchNear50 = validators.Bool()
	BSrchNear100 = validators.Bool()

	CSrch = validators.Bool()
	CSrchBusRoute = validators.Bool()
	CSrchKeywords = validators.Bool()
	CSrchLanguages = validators.Bool()
	CSrchNear = validators.Bool()
	CSrchSchoolEscort = validators.Bool()
	CSrchSchoolsInArea = validators.Bool()
	CSrchSpaceAvailable = validators.Bool()
	CSrchSubsidy = validators.Bool()
	CSrchTypeOfProgram = validators.Bool()

	CCRFields = validators.DictConverter(CCRFieldsOptions, if_empty=False)
	QuickListDropDown = QuickListType(not_empty=True)
	QuickListWrapAt = validators.Int(min=1, max=9, not_empty=True)
	QuickListMatchAll = validators.DictConverter(QuickListMatchAllOptions, if_empy=False)
	QuickListSearchGroups = validators.Bool()
	QuickListPubHeadings = ciocvalidators.IDValidator()

	LinkOrgLevels = validators.Bool()
	CanSeeNonPublicPub = validators.DictConverter(CanSeeNonPublicPubOptions)
	UsePubNamesOnly = validators.Bool()
	UseNAICSView = validators.Bool()
	UseTaxonomyView = validators.Bool()
	TaxDefnLevel = validators.Int(min=0, max=5, if_empty=0)

	UseThesaurusView = validators.Bool()
	UseLocalSubjects = validators.Bool()
	UseZeroSubjects = validators.Bool()

	AlsoNotify = ciocvalidators.EmailValidator()

	NoProcessNotify = validators.Bool()
	UseSubmitChangesTo = validators.Bool()
	MapSearchResults = validators.Bool()
	AutoMapSearchResults = validators.Bool()
	ResultsPageSize = validators.Int(min=100, max=9999)
	ShowRecordDetailsSidebar = validators.Bool()

	CommSrchDropDown = validators.Bool()

	RefineField1 = ciocvalidators.IDValidator()
	RefineField2 = ciocvalidators.IDValidator()
	RefineField3 = ciocvalidators.IDValidator()
	RefineField4 = ciocvalidators.IDValidator()

	# PDFDetails = validators.Bool()


class ViewBaseVOLSchema(ViewBaseSchema):
	# VOL Only
	CommunitySetID = ciocvalidators.IDValidator(not_empty=True)

	CanSeeExpired = validators.Bool()
	SuggestOpLink = validators.Bool()

	BSrchBrowseAll = validators.Bool()
	BSrchBrowseByInterest = validators.Bool()
	BSrchStepByStep = validators.Bool()
	BSrchStudent = validators.Bool()
	BSrchWhatsNew = validators.Bool()
	BSrchCommunity = validators.Bool()
	BSrchCommitmentLength = validators.Bool()
	BSrchSuitableFor = validators.Bool()

	ASrchDatesTimes = validators.Bool()
	ASrchOSSD = validators.Bool()
	SSrchIndividualCount = validators.Bool()
	SSrchDatesTimes = validators.Bool()

	UseProfilesView = validators.Bool()


class ViewDescriptionSchema(Schema):
	if_key_missing = None

	ViewName = ciocvalidators.UnicodeString(max=100, not_empty=True)
	Notes = ciocvalidators.UnicodeString()
	Title = ciocvalidators.UnicodeString(max=255)

	BottomMessage = ciocvalidators.UnicodeString()

	MenuMessage = ciocvalidators.UnicodeString()
	MenuTitle = ciocvalidators.UnicodeString(max=100)
	MenuGlyph = ciocvalidators.String(max=30)

	FeedbackBlurb = ciocvalidators.UnicodeString(max=2000)

	SearchLeftTitle = ciocvalidators.UnicodeString(max=100)
	SearchLeftGlyph = ciocvalidators.String(max=30)
	SearchLeftMessage = ciocvalidators.UnicodeString()

	SearchCentreTitle = ciocvalidators.UnicodeString(max=100)
	SearchCentreGlyph = ciocvalidators.String(max=30)
	SearchCentreMessage = ciocvalidators.UnicodeString()

	SearchRightTitle = ciocvalidators.UnicodeString(max=100)
	SearchRightGlyph = ciocvalidators.String(max=30)
	SearchRightMessage = ciocvalidators.UnicodeString()

	SearchAlertTitle = ciocvalidators.UnicodeString(max=100)
	SearchAlertGlyph = ciocvalidators.String(max=30)
	SearchAlertMessage = ciocvalidators.UnicodeString()

	OtherSearchTitle = ciocvalidators.UnicodeString(max=100)
	OtherSearchGlyph = ciocvalidators.String(max=30)

	KeywordSearchTitle = ciocvalidators.UnicodeString(max=100)
	KeywordSearchGlyph = ciocvalidators.String(max=30)

	TermsOfUseURL = ciocvalidators.URLWithProto(max=200)
	InclusionPolicy = ciocvalidators.IDValidator()
	SearchTips = ciocvalidators.IDValidator()
	SearchPromptOverride = ciocvalidators.UnicodeString(max=255)

	PDFBottomMessage = ciocvalidators.UnicodeString()
	PDFBottomMargin = ciocvalidators.String(max=20)

	GoogleTranslateDisclaimer = validators.UnicodeString(max=1000)

	TagLine = ciocvalidators.UnicodeString(max=300)
	NoResultsMsg = ciocvalidators.UnicodeString(max=2000)


class ViewDescriptionCICSchema(ViewDescriptionSchema):
	CSrchText = ciocvalidators.UnicodeString(max=255)

	QuickListName = ciocvalidators.UnicodeString(max=25)

	QuickSearchTitle = ciocvalidators.UnicodeString(max=100)
	QuickSearchGlyph = ciocvalidators.String(max=30)

	# label override fields
	SearchTitleOverride = ciocvalidators.UnicodeString(max=255)
	OrganizationNames = ciocvalidators.UnicodeString(max=100)
	OrganizationsWithWWW = ciocvalidators.UnicodeString(max=100)
	OrganizationsWithVolOps = ciocvalidators.UnicodeString(max=100)
	BrowseByOrg = ciocvalidators.UnicodeString(max=100)
	FindAnOrgBy = ciocvalidators.UnicodeString(max=100)
	ViewProgramsAndServices = ciocvalidators.UnicodeString(max=100)
	ClickToViewDetails = ciocvalidators.UnicodeString(max=100)
	OrgProgramNames = ciocvalidators.UnicodeString(max=100)
	Organization = ciocvalidators.UnicodeString(max=100)
	MultipleOrgWithSimilarMap = ciocvalidators.UnicodeString(max=100)
	OrgLevel1Name = validators.UnicodeString(max=100)
	OrgLevel2Name = validators.UnicodeString(max=100)
	OrgLevel3Name = validators.UnicodeString(max=100)


class ViewDescriptionVOLSchema(ViewDescriptionSchema):
	HighlightOpportunity = validators.String(max=10)

label_override_fields = {
	'SearchTitleOverride',
	'OrganizationNames',
	'OrganizationsWithWWW',
	'OrganizationsWithVolOps',
	'BrowseByOrg',
	'FindAnOrgBy',
	'ViewProgramsAndServices',
	'ClickToViewDetails',
	'OrgProgramNames',
	'Organization',
	'MultipleOrgWithSimilarMap',
	'OrgLevel1Name',
	'OrgLevel2Name',
	'OrgLevel3Name',
	'SearchPromptOverride'
}


class DisplayOptionSchema(Schema):
	if_key_missing = None

	ShowID = validators.Bool()
	ShowOwner = validators.Bool()
	ShowAlert = validators.Bool()
	ShowOrg = validators.Bool()
	ShowCommunity = validators.Bool()
	ShowUpdateSchedule = validators.Bool()
	LinkUpdate = validators.Bool()
	LinkEmail = validators.Bool()
	LinkSelect = validators.Bool()
	LinkWeb = validators.Bool()
	LinkListAdd = validators.Bool()
	OrderBy = validators.Int(not_empty=True)
	OrderByCustom = ciocvalidators.IDValidator()
	OrderByDesc = validators.StringBool(if_empy=False, if_missing=False)
	TableSort = validators.Bool()
	GLinkMail = validators.Bool()
	GLinkPub = validators.Bool()
	ShowTable = validators.Bool()
	VShowPosition = validators.Bool()
	VShowDuties = validators.Bool()

	FieldIDs = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))


class ViewSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	if_key_missing = None

	ViewType = ciocvalidators.IDValidator(not_empty=True)

	Views = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))
	dopts = DisplayOptionSchema()

	AdvSearchCheckLists = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))
	HasLabelOverrides = validators.Bool()


class ViewSchemaCIC(ViewSchema):

	pre_validators = [viewbase.cull_extra_cultures('descriptions', ensure_active_cultures=False, record_cultures=False)]

	item = ViewBaseCICSchema()
	descriptions = ciocvalidators.CultureDictSchema(ViewDescriptionCICSchema())

	PUB_ID = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))
	ADDPUB_ID = All(validators.Set(use_set=True), ForEach(ciocvalidators.IDValidator()))


class ViewSchemaVOL(ViewSchema):

	pre_validators = [viewbase.cull_extra_cultures('descriptions', ensure_active_cultures=False, record_cultures=False)]

	item = ViewBaseVOLSchema()
	descriptions = ciocvalidators.CultureDictSchema(ViewDescriptionVOLSchema())


class StepValidator(validators.Int):
	min = 1
	max = 6


class TopicSearchBaseSchema(Schema):
	TopicSearchTag = validators.String(max=20, not_empty=True)
	DisplayOrder = validators.Int(min=0, max=255)
	PB_ID1 = ciocvalidators.IDValidator(not_empty=True)
	Heading1Step = StepValidator(not_empty=True)
	Heading1ListType = QuickListType(not_empty=True)
	PB_ID2 = ciocvalidators.IDValidator()
	Heading2Step = StepValidator()
	Heading2ListType = QuickListType()
	Heading2Required = validators.Bool()
	CommunityStep = StepValidator()
	CommunityRequired = validators.Bool()
	CommunityListType = validators.StringBool()
	AgeGroupStep = StepValidator()
	AgeGroupRequired = validators.Bool()
	LanguageStep = StepValidator()
	LanguageRequired = validators.Bool()


class TopicSearchDescriptionSchema(Schema):
	SearchTitle = validators.UnicodeString(max=100, not_empty=True)
	SearchDescription = validators.UnicodeString(max=1000, not_empty=True)
	Heading1Title = validators.UnicodeString(max=255)
	Heading2Title = validators.UnicodeString(max=255)
	Heading1Help = validators.UnicodeString(max=4000)
	Heading2Help = validators.UnicodeString(max=4000)
	CommunityHelp = validators.UnicodeString(max=4000)
	AgeGroupHelp = validators.UnicodeString(max=4000)
	LanguageHelp = validators.UnicodeString(max=4000)


class TopicSearchSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True

	topic_search = TopicSearchBaseSchema()
	descriptions = ciocvalidators.CultureDictSchema(TopicSearchDescriptionSchema())


@view_defaults(route_name='admin_view')
class View(viewbase.AdminViewBase):

	@view_config(route_name='admin_view_index', renderer=templateprefix + 'index.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
		else:
			user_dm = user.vol

		if not user_dm.SuperUser:
			self._security_failure()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_%s_View_l ?, ?, 1, NULL' % domain.str, request.dboptions.MemberID, user.Agency)
			views = cursor.fetchall()
			cursor.close()

		title = _('Manage Views (%s)', request) % _(domain.label, request)
		return self._create_response_namespace(title, title, dict(views=views, domain=domain), no_index=True)

	@view_config(match_param='action=edit', request_method="POST", renderer=templateprefix + 'edit.mak')
	def save(self):
		request = self.request

		if request.POST.get('Delete'):
			self._go_to_route('admin_view', action='delete', _query=[('ViewType', request.POST.get('ViewType')), ('DM', request.POST.get('DM'))])

		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params, ensure_active_cultures=False, record_cultures=False)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
			schema = ViewSchemaCIC()
		else:
			user_dm = user.vol
			schema = ViewSchemaVOL()

		if not user_dm.SuperUser:
			self._security_failure()

		model_state = request.model_state

		model_state.schema = schema
		model_state.form.variable_decode = True

		if domain.id == const.DM_CIC and not request.dboptions.UseCIC:
			request.POST['item.QuickListDropDown'] = 1
			request.POST['item.QuickListWrapAt'] = 1
			request.POST['item.QuickListMatchAll'] = 'ANY'

		if model_state.validate():
			# valid. Save changes and redirect
			form_data = model_state.form.data
			ViewType = form_data['ViewType']

			args = [ViewType, user.Mod, request.dboptions.MemberID, user.Agency]

			view_fields = list(schema.fields['item'].fields.keys())
			view = form_data.get('item', {})

			args.extend(view.get(k) for k in view_fields)

			dopts_fields = list(DisplayOptionSchema.fields.keys())
			dopts_fields.remove('FieldIDs')
			dopts = form_data.get('dopts', {})

			args.extend(dopts.get(k) for k in dopts_fields)

			argnames = view_fields + dopts_fields

			if domain.id == const.DM_CIC:
				root = ET.Element('PubIDs')
				if view.get('CanSeeNonPublicPub') is None:
					for pub in form_data['PUB_ID']:
						ET.SubElement(root, "PBID").text = six.text_type(pub)

				args.append(ET.tostring(root, encoding='unicode'))
				argnames.append('Publications')

				root = ET.Element('PubIDs')
				for pub in form_data['ADDPUB_ID']:
					ET.SubElement(root, "PBID").text = six.text_type(pub)

				args.append(ET.tostring(root, encoding='unicode'))
				argnames.append('AddPublications')

			root = ET.Element('DESCS')

			has_label_overrides = form_data.get('HasLabelOverrides')
			for culture, data in six.iteritems((form_data['descriptions'] or {})):
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, "Culture").text = culture.replace('_', '-')
				for name, value in six.iteritems(data):
					if not has_label_overrides and name in label_override_fields:
						continue
					if value:
						ET.SubElement(desc, name).text = six.text_type(value)

			args.append(ET.tostring(root, encoding='unicode'))

			root = ET.Element('VIEWS')
			for view_type in form_data['Views']:
				ET.SubElement(root, 'VIEW').text = six.text_type(view_type)

			args.append(ET.tostring(root, encoding='unicode'))

			root = ET.Element('AdvSearchCheckLists')
			for field in form_data['AdvSearchCheckLists']:
				ET.SubElement(root, "Chk").text = six.text_type(field)

			args.append(ET.tostring(root, encoding='unicode'))

			args.append(",".join(str(x) for x in dopts['FieldIDs']))

			argnames.extend(['Descriptions', 'Views', 'AdvSrchCheckLists', 'DisplayOptFields'])

			argnames = ', '.join(k.join(('@', '=?')) for k in argnames)

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int

				EXECUTE @RC = dbo.sp_%s_View_u ?, ?, ?, ?, %s, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg AS ErrMsg
				''' % (domain.str, argnames)

				cursor = conn.execute(sql, *args)
				result = cursor.fetchone()
				cursor.close()

			if not result.Return:
				self._go_to_route('admin_view', action='edit', _query=[('InfoMsg', _('The View has been successfully updated.', request)), ("ViewType", ViewType), ('DM', domain.id)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			if model_state.is_error('ViewType'):
				self._error_page(_('Invalid View ID', request))

			ErrMsg = _('There were validation errors.')
			log.debug('errors: %s', model_state.form.errors)

		usage = None
		security_levels = []
		view_cultures = set()
		templates = []
		agencies = []
		view_descs = []
		chk_field_descs = []
		inclusion_policies = []
		search_tips = []
		disp_opt_field_descs = []
		print_profiles = []

		publication_descs = []

		community_sets = []

		facet_field_descs = []

		ViewType = model_state.value('ViewType')
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_%s_View_s_FormLists ?, ?, ?' % domain.str, request.dboptions.MemberID, user.Agency, ViewType)

			usage = cursor.fetchone()

			cursor.nextset()

			security_levels = cursor.fetchall()

			cursor.nextset()

			view_cultures = set(x.Culture for x in cursor.fetchall())

			cursor.nextset()

			templates = [tuple(x) for x in cursor.fetchall()]

			cursor.nextset()

			agencies = [tuple(x) for x in cursor.fetchall()]

			cursor.nextset()

			view_descs = cursor.fetchall()

			cursor.nextset()

			chk_field_descs = cursor.fetchall()

			cursor.nextset()

			inclusion_policies = cursor.fetchall()

			cursor.nextset()

			search_tips = cursor.fetchall()

			cursor.nextset()

			disp_opt_field_descs = cursor.fetchall()

			cursor.nextset()

			print_profiles = cursor.fetchall()

			if domain.id == const.DM_CIC:
				cursor.nextset()

				publication_descs = cursor.fetchall()

				cursor.nextset()

				facet_field_descs = cursor.fetchall()

			else:
				cursor.nextset()

				community_sets = [tuple(x) for x in cursor.fetchall()]

			cursor.close()

		data = model_state.form.data

		publications = []
		auto_add_pubs = []
		if domain.id == const.DM_CIC:
			val = model_state.value('item.CanSeeNonPublicPub')
			data['item.CanSeeNonPublicPub'] = RCanSeeNonPublicPubOptions.get(val, val)

			val = model_state.value('item.QuickListMatchAll')
			data['item.QuickListMatchAll'] = RQuickListMatchAllOptions.get(val, val)

			val = model_state.value('item.SrchCommunityDefault')
			data['item.SrchCommunityDefault'] = RSrchCommunityDefaultOptions.get(val, val)

			val = model_state.value('item.CCRFields')
			data['item.CCRFields'] = RCCRFieldsOptions.get(val, val)

			data['PUB_ID'] = publications = request.POST.getall('PUB_ID')
			data['ADDPUB_ID'] = auto_add_pubs = request.POST.getall('ADDPUB_ID')

			pubs_with_headings = [x for x in publication_descs if x.HasHeadings]

		data['Views'] = request.POST.getall('Views')
		data['AdvSearchCheckLists'] = request.POST.getall('AdvSearchCheckLists')
		data['dopts.FieldIDs'] = request.POST.getall('dopts.FieldIDs')

		title = _('Manage Views (%s)', request) % _(domain.label, request)
		return self._create_response_namespace(
			title, title,
			dict(ViewType=ViewType, usage=usage,
				security_levels=security_levels,
				view_cultures=view_cultures, templates=templates, agencies=agencies,
				community_sets=community_sets, publications=publications,
				auto_add_pubs=auto_add_pubs,
				publication_descs=format_pub_list(publication_descs, True),
				pubs_with_headings=format_pub_list(pubs_with_headings, True),
				facet_field_descs=format_list(facet_field_descs),
				inclusion_policies=inclusion_policies, domain=domain,
				search_tips=search_tips, chk_field_descs=chk_field_descs,
				view_descs=view_descs, ErrMsg=ErrMsg,
				disp_opt_field_descs=[tuple(x) for x in disp_opt_field_descs],
				print_profiles=[tuple(x) for x in print_profiles]),
			no_index=True)

	@view_config(match_param='action=edit', renderer=templateprefix + 'edit.mak')
	def edit(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
		else:
			user_dm = user.vol

		if not user_dm.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {
			'ViewType': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid ViewType

			self._error_page(_('Invalid ID', request))

		ViewType = model_state.form.data.get('ViewType')

		view = None
		descriptions = {}
		views = []
		publications = []
		auto_add_pubs = []
		chk_fields = []
		disp_opt = None
		disp_opt_fields = []
		print_profiles = []

		usage = None
		security_levels = []
		view_cultures = set()
		templates = []
		agencies = []
		view_descs = []
		chk_field_descs = []
		inclusion_policies = []
		search_tips = []
		disp_opt_field_descs = []

		publication_descs = []

		pubs_with_headings = []

		community_sets = []

		facet_field_descs = []

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC dbo.sp_%s_View_s ?, ?' % domain.str, ViewType, request.dboptions.MemberID)
			view = cursor.fetchone()
			if view:
				cursor.nextset()
				for lng in cursor.fetchall():
					descriptions[lng.Culture.replace('-', '_')] = lng

				cursor.nextset()

				views = [str(x[0]) for x in cursor.fetchall()]

				cursor.nextset()

				chk_fields = [str(x[0]) for x in cursor.fetchall()]

				cursor.nextset()

				disp_opt = cursor.fetchone()

				cursor.nextset()

				disp_opt_fields = set(x[0] for x in cursor.fetchall())

				if domain.id == const.DM_CIC:
					cursor.nextset()

					publications = [str(x[0]) for x in cursor.fetchall()]

					cursor.nextset()

					auto_add_pubs = [str(x[0]) for x in cursor.fetchall()]

			cursor.close()

			if not view:
				# not found
				self._error_page(_('View Not Found', request))

			cursor = conn.execute('EXEC dbo.sp_%s_View_s_FormLists ?, ?, ?' % domain.str, request.dboptions.MemberID, user.Agency, ViewType)

			usage = cursor.fetchone()

			cursor.nextset()

			security_levels = cursor.fetchall()

			cursor.nextset()

			view_cultures = set(x.Culture for x in cursor.fetchall())

			cursor.nextset()

			templates = [tuple(x) for x in cursor.fetchall()]

			cursor.nextset()

			agencies = [tuple(x) for x in cursor.fetchall()]

			cursor.nextset()

			view_descs = cursor.fetchall()

			cursor.nextset()

			chk_field_descs = cursor.fetchall()

			cursor.nextset()

			inclusion_policies = cursor.fetchall()

			cursor.nextset()

			search_tips = cursor.fetchall()

			cursor.nextset()

			disp_opt_field_descs = cursor.fetchall()

			cursor.nextset()

			print_profiles = cursor.fetchall()

			if domain.id == const.DM_CIC:
				cursor.nextset()

				publication_descs = cursor.fetchall()

				cursor.nextset()

				facet_field_descs = cursor.fetchall()

			else:
				cursor.nextset()

				community_sets = [tuple(x) for x in cursor.fetchall()]

			cursor.close()

		data = model_state.form.data
		data['item'] = view
		data['descriptions'] = descriptions
		data['Views'] = views
		data['AdvSearchCheckLists'] = chk_fields
		data['dopts'] = disp_opt
		data['dopts.FieldIDs'] = disp_opt_fields
		data['HasLabelOverrides'] = any(getattr(x, y, None) for x in descriptions.values() for y in label_override_fields)

		if domain.id == const.DM_CIC:
			data['PUB_ID'] = publications
			data['ADDPUB_ID'] = auto_add_pubs

			val = view.CanSeeNonPublicPub
			data['item.CanSeeNonPublicPub'] = RCanSeeNonPublicPubOptions.get(val, val)

			val = view.QuickListMatchAll
			data['item.QuickListMatchAll'] = RQuickListMatchAllOptions.get(val, val)

			val = view.SrchCommunityDefault
			data['item.SrchCommunityDefault'] = RSrchCommunityDefaultOptions.get(val, val)

			val = view.CCRFields
			data['item.CCRFields'] = RCCRFieldsOptions.get(val, val)

			pubs_with_headings = [x for x in publication_descs if x.HasHeadings]

		title = _('Manage Views (%s)', request) % _(domain.label, request)
		return self._create_response_namespace(
			title, title,
			dict(
				view=view, descriptions=descriptions, ViewType=ViewType,
				usage=usage, security_levels=security_levels,
				view_cultures=view_cultures, templates=templates, agencies=agencies,
				community_sets=community_sets, publications=publications,
				auto_add_pubs=auto_add_pubs,
				publication_descs=format_pub_list(publication_descs, True),
				pubs_with_headings=format_pub_list(pubs_with_headings, True),
				facet_field_descs=format_list(facet_field_descs),
				inclusion_policies=inclusion_policies, domain=domain,
				search_tips=search_tips, disp_opt_field_descs=[tuple(x) for x in disp_opt_field_descs],
				print_profiles=[tuple(x) for x in print_profiles],
				chk_field_descs=chk_field_descs, view_descs=view_descs),
			no_index=True)

	@view_config(match_param='action=delete', renderer='cioc.web:templates/confirmdelete.mak')
	def delete(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
		else:
			user_dm = user.vol

		if not user_dm.SuperUser:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'ViewType': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		ViewType = model_state.form.data['ViewType']

		request.override_renderer = 'cioc.web:templates/confirmdelete.mak'

		title = _('Manage Views (%s)', request) % _(domain.label, request)
		return self._create_response_namespace(title, title, dict(id_name='ViewType', id_value=ViewType, route='admin_view', action='delete', domain=domain), no_index=True)

	@view_config(match_param='action=delete', request_method="POST")
	def delete_confirm(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
		else:
			user_dm = user.vol

		if not user_dm.SuperUser:
			self._security_failure()

		model_state = request.model_state

		model_state.validators = {
			'ViewType': ciocvalidators.IDValidator(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid ID', request))

		ViewType = model_state.form.data['ViewType']

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_%s_View_d ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' % domain.str

			cursor = conn.execute(sql, ViewType, request.dboptions.MemberID, user.Agency)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('admin_view_index', _query=[('InfoMsg', _('View Deleted', request)), ('DM', domain.id)])

		if result.Return == 3:
			self._error_page(_('Unable to delete View: ', request) + result.ErrMsg)

		self._go_to_route('admin_view', action='edit', _query=[('ErrMsg', _('Unable to delete View: ') + result.ErrMsg), ('ViewType', ViewType), ('DM', domain.id)])

	@view_config(match_param='action=add_lang')
	def add_lang(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
		else:
			user_dm = user.vol

		if not user_dm.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {
			'ViewType': ciocvalidators.IDValidator(not_empty=True),
			'Culture': ciocvalidators.ActiveCulture(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid ViewType or Culture

			if 'ViewType' in model_state.form.errors:
				self._error_page(_('Invalid ID', request))

			else:
				self._error_page(_('Invalid Request', request))

		ViewType = model_state.form.data.get('ViewType')
		Culture = model_state.form.data.get('Culture')

		LangID = syslanguage.culture_map()[Culture].LangID

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_%s_View_i_Lang ?, ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' % domain.str

			cursor = conn.execute(sql, ViewType, user.Mod, request.dboptions.MemberID, user.Agency, LangID)
			result = cursor.fetchone()
			cursor.close()

		query = [('ViewType', ViewType), ('DM', domain.id)]
		if result.Return:
			query.append(('ErrMsg', result.ErrMsg))

		self._go_to_route('admin_view', action='edit', _query=query)

	@view_config(match_param="action=delete_lang", renderer=templateprefix + 'delete_lang.mak')
	def delete_lang(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
		else:
			user_dm = user.vol

		if not user_dm.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {
			'ViewType': ciocvalidators.IDValidator(not_empty=True),
			'Culture': ciocvalidators.ActiveCulture(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid ViewType or Culture

			if 'ViewType' in model_state.form.errors:
				self._error_page(_('Invalid ID', request))

			else:
				self._error_page(_('Invalid Request', request))

		ViewType = model_state.form.data.get('ViewType')
		Culture = model_state.form.data.get('Culture')

		title = _('Manage Views (%s)', request) % _(domain.label, request)
		return self._create_response_namespace(title, title, dict(ViewType=ViewType, Culture=Culture, domain=domain), no_index=True)

	@view_config(match_param='action=delete_lang', request_method="POST")
	def delete_lang_confirm(self):
		request = self.request
		user = request.user

		if not user.SuperUser:
			self._security_failure()

		domain, shown_cultures = viewbase.get_domain_and_show_cultures(request.params)
		if not domain:
			self._error_page(_('Invalid Domain', request))

		if domain.id == const.DM_CIC:
			user_dm = user.cic if request.dboptions.UseCIC else user.vol
		else:
			user_dm = user.vol

		if not user_dm.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {
			'ViewType': ciocvalidators.IDValidator(not_empty=True),
			'Culture': ciocvalidators.ActiveCulture(not_empty=True)
		}
		model_state.method = None

		if not model_state.validate():
			# XXX invalid ViewType or Culture

			if 'ViewType' in model_state.form.errors:
				self._error_page(_('Invalid ID', request))

			else:
				self._error_page(_('Invalid Request', request))

		ViewType = model_state.form.data.get('ViewType')
		Culture = model_state.form.data.get('Culture')

		LangID = syslanguage.culture_map()[Culture].LangID

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_%s_View_d_Lang ?, ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			''' % domain.str

			cursor = conn.execute(sql, ViewType, request.dboptions.MemberID, user.Agency, LangID)
			result = cursor.fetchone()
			cursor.close()

		query = [('ViewType', ViewType), ('DM', domain.id)]
		if result.Return:
			query.append(('ErrMsg', result.ErrMsg))

		self._go_to_route('admin_view', action='edit', _query=query)

	@view_config(match_param='action=topicsearches', renderer=templateprefix + 'topicsearches.mak')
	def topicsearch(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.method = None
		model_state.validators = {
			'ViewType': ciocvalidators.IDValidator(not_empty=True),
		}

		if not model_state.validate():
			if 'ViewType' in model_state.form.errors:
				self._error_page(_('Invalid ID', request))

			else:
				self._error_page(_('Invalid Request', request))

		ViewType = model_state.form.data.get('ViewType')

		with request.connmgr.get_connection('admin') as conn:
			sql = '''EXECUTE dbo.sp_CIC_View_TopicSearch_l ?, ?, ?'''

			cursor = conn.execute(sql, request.dboptions.MemberID, user.Agency, ViewType)
			view_info = cursor.fetchone()
			cursor.nextset()

			topic_searches = cursor.fetchall()

			cursor.close()

		if not view_info:
			return self._error_page(_('View Not Found', request))

		title = _('Manage Topic Searches For %s', request) % _(view_info.ViewName, request)
		return self._create_response_namespace(title, title, dict(ViewType=ViewType, topic_searches=topic_searches), no_index=True, print_table=False)

	@view_config(match_param='action=topicsearch', request_method='POST', renderer=templateprefix + 'topicsearch.mak')
	def topicsearch_edit_save(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		ViewType, TopicSearchID = self._get_topicsearch_id()
		is_edit = not not TopicSearchID

		if request.POST.get('Delete'):
			if not is_edit:
				return self._error_page(_('Topic Search Not Found'))

			self._go_to_route('admin_view', action='topicsearch_delete', _query=[('ViewType', ViewType), ('TopicSearchID', TopicSearchID)])

		model_state = request.model_state
		model_state.form.variable_decode = True
		model_state.schema = TopicSearchSchema()

		if model_state.validate():
			data = model_state.form.data
			ts_data = data.get('topic_search', {})
			fields = list(TopicSearchBaseSchema.fields.keys())
			args = [TopicSearchID, user.Mod, request.dboptions.MemberID, user.Agency, ViewType] + [ts_data.get(f) for f in fields]

			root = ET.Element('DESCS')

			for culture, description in six.iteritems((data['descriptions'] or {})):
				desc = ET.SubElement(root, 'DESC')
				ET.SubElement(desc, 'Culture').text = culture.replace('_', '-')
				for name, value in six.iteritems(description):
					if value:
						ET.SubElement(desc, name).text = value

			args.append(ET.tostring(root, encoding='unicode'))

			sql = '''
				DECLARE @ErrMsg as nvarchar(500),
				@RC as int,
				@TopicSearchID as int

				SET @TopicSearchID = ?

				EXEC @RC = dbo.sp_CIC_View_TopicSearch_u @TopicSearchID OUTPUT, ?, ?, ?, @ViewType=?, %s, @Descriptions=?, @ErrMsg=@ErrMsg OUTPUT

				SELECT @RC as [Return], @ErrMsg as ErrMsg, @TopicSearchID as TopicSearchID
			''' % ', '.join('@%s=?' % f for f in fields)

			with request.connmgr.get_connection('admin') as conn:
				result = conn.execute(sql, *args).fetchone()

			if not result.Return:
				TopicSearchID = result.TopicSearchID
				if is_edit:
					msg = _('The Topic Search was successfully updated.', request)
				else:
					msg = _('The Topic Search was successfully added.', request)

				self._go_to_route('admin_view', action='topicsearch', _query=[('InfoMsg', msg), ("TopicSearchID", TopicSearchID), ("ViewType", ViewType)])

			ErrMsg = _('Unable to save: ') + result.ErrMsg

		else:
			log.debug('Validation Errors')
			ErrMsg = _('There were validation errors.')
			log.debug('errors: %s', model_state.form.errors)

		edit_info = self._get_topic_search_edit_info(ViewType, TopicSearchID)
		template_values = edit_info._asdict()
		template_values['ErrMsg'] = ErrMsg

		title = _('Manage Topic Searches For %s', request) % _(edit_info.view_info.ViewName, request)
		return self._create_response_namespace(
			title, title,
			template_values,
			no_index=True,
			print_table=False
		)

	@view_config(match_param='action=topicsearch', renderer=templateprefix + 'topicsearch.mak')
	def topicsearch_edit(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		ViewType, TopicSearchID = self._get_topicsearch_id()
		edit_info = self._get_topic_search_edit_info(ViewType, TopicSearchID)

		if edit_info.is_edit:

			request.model_state.defaults = {
				'topic_search': edit_info.topic_search,
				'descriptions': {k.replace('-', '_'): v for k, v in edit_info.descriptions.items()},
			}

		title = _('Manage Topic Searches For %s', request) % _(edit_info.view_info.ViewName, request)
		return self._create_response_namespace(
			title, title,
			edit_info._asdict(),
			no_index=True,
			print_table=False
		)

	def _get_topicsearch_id(self, required=False):
		validator = ciocvalidators.IDValidator(not_empty=required)
		try:
			TopicSearchID = validator.to_python(self.request.params.get('TopicSearchID'))
		except validators.Invalid:
			self._error_page(_('Topic Search Not Found', self.request))

		validator = ciocvalidators.IDValidator(not_empty=True)
		try:
			ViewType = validator.to_python(self.request.params.get('ViewType'))
		except validators.Invalid:
			self._error_page(_('View Not Found', self.request))

		return ViewType, TopicSearchID

	def _get_topic_search_edit_info(self, ViewType, TopicSearchID):
		request = self.request
		user = request.user
		is_edit = not not TopicSearchID

		publications = []
		topic_search = None
		descriptions = {}
		with request.connmgr.get_connection('admin') as conn:
			sql = '''EXECUTE dbo.sp_CIC_View_TopicSearch_s ?, ?, ?, ?'''

			cursor = conn.execute(sql, TopicSearchID, ViewType, user.Agency, request.dboptions.MemberID)
			view_info = cursor.fetchone()
			cursor.nextset()

			topic_search = cursor.fetchone()

			cursor.nextset()

			for lng in cursor.fetchall():
				descriptions[lng.Culture] = lng

			cursor.nextset()

			publications = cursor.fetchall()

			cursor.close()

		if not view_info:
			return self._error_page(_('View Not Found', request))

		if is_edit and not topic_search:
			return self._error_page(_('Topic Search Not Found', request))

		return TopicSearchEditValues(ViewType, TopicSearchID, topic_search, descriptions, format_pub_list(publications, True), view_info, is_edit)

	@view_config(match_param='action=topicsearch_delete', renderer='cioc.web:templates/confirmdelete.mak')
	def topicsearch_delete(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		ViewType, TopicSearchID = self._get_topicsearch_id()
		if not TopicSearchID:
			self._error_page(_('Invalid Topic Search', request))

		if not ViewType:
			self._error_page(_('Invalid View', request))

		title = _('Delete Topic Search', request)
		return self._create_response_namespace(title, title, dict(id_name='TopicSearchID', id_value=TopicSearchID, route='admin_view', action='topicsearch_delete', extra_values=[('ViewType', ViewType)]), no_index=True, print_table=False)

	@view_config(match_param='action=topicsearch_delete', request_method="POST")
	def topicsearch_delete_confirm(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		ViewType, TopicSearchID = self._get_topicsearch_id()
		if not TopicSearchID:
			self._error_page(_('Invalid Topic Search', request))

		if not ViewType:
			self._error_page(_('Invalid View', request))

		with request.connmgr.get_connection('admin') as conn:
			sql = '''
			DECLARE @ErrMsg as nvarchar(500),
			@RC as int

			EXECUTE @RC = dbo.sp_CIC_View_TopicSearch_d ?, ?, ?, @ErrMsg=@ErrMsg OUTPUT

			SELECT @RC as [Return], @ErrMsg AS ErrMsg
			'''

			cursor = conn.execute(sql, TopicSearchID, request.dboptions.MemberID, user.Agency)
			result = cursor.fetchone()
			cursor.close()

		if not result.Return:
			self._go_to_route('admin_view', action='topicsearches', _query=[('InfoMsg', _('Topic Search Deleted', request)), ('ViewType', ViewType)])

		if result.Return == 3:
			self._error_page(_('Unable to delete Topic Search: ', request) + result.ErrMsg)

		self._go_to_route('admin_view', action='topicsearch', _query=[('ErrMsg', _('Unable to delete Topic Search: ') + result.ErrMsg), ('ViewType', ViewType), ('TopicSearchID', TopicSearchID)])
