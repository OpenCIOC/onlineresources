<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================
'
' Purpose: 		Definitions for all global variables and constants.
'				Processes page-specific settings and loads application configuration values.
'				Contains procedure to fetch information about the current View.
'
'
%>

<%
'Set default characterset on http content-type header
Response.CodePage = 65001
Response.CharSet = "utf-8"

Dim g_bPrintMode
Sub SetPrintMode(bOn)
	If bOn Then
		g_bPrintMode = True
	Else
		g_bPrintMode = False
	End If
End Sub
%>

<script language="python" runat="server">
import cioc.core.dboptions as dboptions, cioc.core.syslanguage as syslanguage, cioc.core.pageinfo as pageinfo, cioc.core.viewdata as viewdata, cioc.core.constants as const, cioc.core.rootfactories as rootfactories
from cioc.core.connection import ConnectionError

DM_CIC = const.DM_CIC
DM_VOL = const.DM_VOL
DM_CCR = const.DM_CCR
DM_GLOBAL = const.DM_GLOBAL

DM_S_CIC = const.DM_S_CIC
DM_S_VOL = const.DM_S_VOL
DM_S_CCR = const.DM_S_CCR

#System Language Constants
LANG_ENGLISH = const.LANG_ENGLISH
LANG_GERMAN = const.LANG_GERMAN
LANG_FRENCH = const.LANG_FRENCH
LANG_JAPANESE = const.LANG_JAPANESE
LANG_SPANISH = const.LANG_SPANISH
LANG_ITALIAN = const.LANG_ITALIAN
LANG_DUTCH = const.LANG_DUTCH
LANG_NORWEGIAN = const.LANG_NORWEGIAN
LANG_PORTUGUESE = const.LANG_PORTUGUESE
LANG_SWEDISH = const.LANG_SWEDISH
LANG_CZECH = const.LANG_CZECH
LANG_HUNGARIAN = const.LANG_HUNGARIAN
LANG_POLISH = const.LANG_POLISH
LANG_ROMANIAN = const.LANG_ROMANIAN
LANG_CROATIAN = const.LANG_CROATIAN
LANG_SLOVAK = const.LANG_SLOVAK
LANG_SLOVENIAN = const.LANG_SLOVENIAN
LANG_GREEK = const.LANG_GREEK
LANG_BULGARIAN = const.LANG_BULGARIAN
LANG_RUSSIAN = const.LANG_RUSSIAN
LANG_TURKISH = const.LANG_TURKISH
LANG_LATVIAN = const.LANG_LATVIAN
LANG_LITHUANIAN = const.LANG_LITHUANIAN
LANG_TRADITIONAL_CHINESE = const.LANG_TRADITIONAL_CHINESE
LANG_KOREAN = const.LANG_KOREAN
LANG_SIMPLIFIED_CHINESE = const.LANG_SIMPLIFIED_CHINESE
LANG_THAI = const.LANG_THAI

#SQL Server Language Alias Constants
SQLALIAS_ENGLISH = const.SQLALIAS_ENGLISH
SQLALIAS_GERMAN = const.SQLALIAS_GERMAN
SQLALIAS_FRENCH = const.SQLALIAS_FRENCH
SQLALIAS_JAPANESE = const.SQLALIAS_JAPANESE
SQLALIAS_SPANISH = const.SQLALIAS_SPANISH
SQLALIAS_ITALIAN = const.SQLALIAS_ITALIAN
SQLALIAS_DUTCH = const.SQLALIAS_DUTCH
SQLALIAS_NORWEGIAN = const.SQLALIAS_NORWEGIAN
SQLALIAS_PORTUGUESE = const.SQLALIAS_PORTUGUESE
SQLALIAS_SWEDISH = const.SQLALIAS_SWEDISH
SQLALIAS_CZECH = const.SQLALIAS_CZECH
SQLALIAS_HUNGARIAN = const.SQLALIAS_HUNGARIAN
SQLALIAS_POLISH = const.SQLALIAS_POLISH
SQLALIAS_ROMANIAN = const.SQLALIAS_ROMANIAN
SQLALIAS_CROATIAN = const.SQLALIAS_CROATIAN
SQLALIAS_SLOVAK = const.SQLALIAS_SLOVAK
SQLALIAS_SLOVENIAN = const.SQLALIAS_SLOVENIAN
SQLALIAS_GREEK = const.SQLALIAS_GREEK
SQLALIAS_BULGARIAN = const.SQLALIAS_BULGARIAN
SQLALIAS_RUSSIAN = const.SQLALIAS_RUSSIAN
SQLALIAS_TURKISH = const.SQLALIAS_TURKISH
SQLALIAS_LATVIAN = const.SQLALIAS_LATVIAN
SQLALIAS_LITHUANIAN = const.SQLALIAS_LITHUANIAN
SQLALIAS_TRADITIONAL_CHINESE = const.SQLALIAS_TRADITIONAL_CHINESE
SQLALIAS_KOREAN = const.SQLALIAS_KOREAN
SQLALIAS_SIMPLIFIED_CHINESE = const.SQLALIAS_SIMPLIFIED_CHINESE
SQLALIAS_THAI = const.SQLALIAS_THAI

#Types of Update record privileges
UPDATE_NONE = const.UPDATE_NONE
UPDATE_OWNED = const.UPDATE_OWNED
UPDATE_OWNED_LIST = const.UPDATE_OWNED_LIST
UPDATE_ALL = const.UPDATE_ALL

# Types of View privileges
STATS_NONE = const.STATS_NONE
STATS_VIEW = const.STATS_VIEW
STATS_ALL = const.STATS_ALL

#Specialized Update Types for Update Publication privileges
UPDATE_RECORD = const.UPDATE_RECORD

#Types of Export record privileges
EXPORT_NONE = const.EXPORT_NONE
EXPORT_OWNED = const.EXPORT_OWNED
EXPORT_ALL = const.EXPORT_ALL
EXPORT_VIEW = const.EXPORT_VIEW

#Types of Geo-coding
GC_BLANK = const.GC_BLANK
GC_SITE = const.GC_SITE
GC_INTERSECTION = const.GC_INTERSECTION
GC_MANUAL = const.GC_MANUAL
GC_CURRENT = const.GC_CURRENT
GC_DONT_CHANGE = const.GC_DONT_CHANGE
MAP_PIN_MIN = const.MAP_PIN_MIN
MAP_PIN_MAX = const.MAP_PIN_MAX

# TODO this can be turned into normal attribute access after the site's been recycled
CIOC_TASK_NOTIFY_EMAIL = getattr(const, 'CIOC_TASK_NOTIFY_EMAIL', 'qw4afPcItA5KJ18NH4nV@cioc.ca')

#jQuery and jQueryUI versions
strJQueryVersion = const.JQUERY_VERSION
strJQueryUIVersion = const.JQUERY_UI_VERSION
g_strApplicationInstance = const._app_name


#***************************************
# Begin Sub getDbOptions
#	The getDbOptions Sub is called once from incSetup.asp, which is included
#	in every page of the software. If the bReset option is selected, or there
#	are no settings values currently stored in Application variables, then
#	this Sub retrieves a limited set of values from the single entry in the
#	table STP_Member (those used on many different pages in the software);
# 	The values retrieved are then used to set the Application variables.
#	The Application variables are used to set the global settings variables.
#***************************************
def get_db_option(opt):
	return getattr(pyrequest.dboptions, opt)

def get_db_option_current_lang(opt):
	return dboptions.get_best_lang(opt)

def getDbOptions(handleDBConnetionError):
	global dboptions, g_bMultiLingual, g_bMultiLingualRecords, g_bMultiLingualActive, \
		g_strDatabaseCode, g_strDatabaseNameCIC, g_strDatabaseNameVOL, \
		g_strMemberNameCIC, g_strMemberNameVOL, \
		g_bAllowPublicAccess, g_intDefaultPrintTemplate, \
		g_bPrintModePublic, g_bTrainingMode, g_bNoEmail, g_bUseInitials, \
		g_intDaysSinceLastEmail, g_strDefaultEmailCIC, g_strDefaultEmailVOL, \
		g_strBaseURLCIC, g_strBaseURLVOL, g_bUseCIC, g_bUseVOL, g_bUseTaxonomy, \
		g_bUseVolunteerProfiles, g_bOnlySpecificInterests, g_strClientTrackerIP, g_strClientTrackerRpcURL, \
		g_strVolProfilePrivacyPolicy, g_strVolProfilePrivacyPolicyOrgName, \
		g_bDownloadUncompressed, g_intCanDeleteRecordNoteCIC, \
		g_intCanDeleteRecordNoteVOL, g_intCanUpdateRecordNoteCIC, \
		g_intCanUpdateRecordNoteVOL, g_bRecordNoteTypeOptionalCIC, \
		g_bRecordNoteTypeOptionalVOL, g_intPreventDuplicateOrgNames, \
		g_strDefaultCountry, g_strDefaultProvState, \
		g_bContactOrgCIC, g_bContactPhone1CIC, g_bContactPhone2CIC, g_bContactPhone3CIC, g_bContactFaxCIC, g_bContactEmailCIC, \
		g_bContactOrgVOL, g_bContactPhone1VOL, g_bContactPhone2VOL, g_bContactPhone3VOL, g_bContactFaxVOL, g_bContactEmailVOL, \
		g_strSubsidyNamedProgram, \
		g_intMemberID, g_bOtherMembers, g_bOtherMembersActive, g_bSSL, g_intLoginRetryLimit

	try:
		dboptions = pyrequest.dboptions
	except ConnectionError:
		handleDBConnetionError()

	g_bMultiLingualActive = pyrequest.multilingual_active
	g_bMultiLingualRecords = pyrequest.multilingual_records
	g_bMultiLingual = pyrequest.multilingual

	g_strDatabaseCode = dboptions.DatabaseCode
	g_strDatabaseNameCIC = dboptions.get_best_lang('DatabaseNameCIC')
	g_strDatabaseNameVOL = dboptions.get_best_lang('DatabaseNameVOL')
	g_strMemberNameCIC = dboptions.get_best_lang('MemberNameCIC')
	g_strMemberNameVOL = dboptions.get_best_lang('MemberNameVOL')
	g_strSubsidyNamedProgram = dboptions.get_best_lang('SubsidyNamedProgram')

	g_bAllowPublicAccess = dboptions.AllowPublicAccess
	g_intDefaultPrintTemplate = dboptions.DefaultPrintTemplate
	g_bPrintModePublic = dboptions.PrintModePublic
	g_bTrainingMode = dboptions.TrainingMode
	g_bNoEmail = dboptions.NoEmail
	g_bUseInitials = dboptions.UseInitials
	g_intDaysSinceLastEmail = dboptions.DaysSinceLastEmail
	g_strDefaultEmailCIC = dboptions.DefaultEmailCIC
	g_strDefaultEmailVOL = dboptions.DefaultEmailVOL
	g_strBaseURLCIC = dboptions.BaseURLCIC
	g_strBaseURLVOL = dboptions.BaseURLVOL
	g_bUseCIC = dboptions.UseCIC
	g_bUseVOL = dboptions.UseVOL
	g_bUseTaxonomy = dboptions.UseTaxonomy
	g_bUseVolunteerProfiles = dboptions.UseVolunteerProfiles
	g_bOnlySpecificInterests = dboptions.OnlySpecificInterests
	g_strClientTrackerIP = dboptions.ClientTrackerIP
	g_strClientTrackerRpcURL = dboptions.ClientTrackerRpcURL
	g_strVolProfilePrivacyPolicy = dboptions[pycurent_lang.Culture].VolProfilePrivacyPolicy
	g_strVolProfilePrivacyPolicyOrgName = dboptions[pycurent_lang.Culture].VolProfilePrivacyPolicyOrgName
	g_bDownloadUncompressed = dboptions.DownloadUncompressed
	g_intCanDeleteRecordNoteCIC = dboptions.CanDeleteRecordNoteCIC
	g_intCanDeleteRecordNoteVOL = dboptions.CanDeleteRecordNoteVOL
	g_intCanUpdateRecordNoteCIC = dboptions.CanUpdateRecordNoteCIC
	g_intCanUpdateRecordNoteVOL = dboptions.CanUpdateRecordNoteVOL
	g_bRecordNoteTypeOptionalCIC = dboptions.RecordNoteTypeOptionalCIC
	g_bRecordNoteTypeOptionalVOL = dboptions.RecordNoteTypeOptionalVOL
	g_intPreventDuplicateOrgNames = dboptions.PreventDuplicateOrgNames
	g_intMemberID = dboptions.MemberID
	g_bOtherMembers = dboptions.OtherMembers
	g_bOtherMembersActive = dboptions.OtherMembersActive
	g_intLoginRetryLimit = dboptions.LoginRetryLimit
	g_strDefaultCountry = dboptions.DefaultCountry
	g_strDefaultProvState = dboptions.DefaultProvince

	#temporary formatting to avoid ResetDb requirement
	g_bContactOrgCIC = getattr(dboptions,"ContactOrgCIC",True)
	g_bContactPhone1CIC = getattr(dboptions,"ContactPhone1CIC",True)
	g_bContactPhone2CIC = getattr(dboptions,"ContactPhone2CIC",True)
	g_bContactPhone3CIC = getattr(dboptions,"ContactPhone3CIC",True)
	g_bContactFaxCIC = getattr(dboptions,"ContactFaxCIC",True)
	g_bContactEmailCIC = getattr(dboptions,"ContactEmailCIC",True)
	g_bContactOrgVOL = getattr(dboptions,"ContactOrgVOL",True)
	g_bContactPhone1VOL = getattr(dboptions,"ContactPhone1VOL",True)
	g_bContactPhone2VOL = getattr(dboptions,"ContactPhone2VOL",True)
	g_bContactPhone3VOL = getattr(dboptions,"ContactPhone3VOL",True)
	g_bContactFaxVOL = getattr(dboptions,"ContactFaxVOL",True)
	g_bContactEmailVOL = getattr(dboptions,"ContactEmailVOL",True)

	g_bSSL = not not pyrequest.headers.get('CIOC-USING-SSL')

#***************************************
# End Sub getDbOptions
#***************************************

# Retrieve the global database settings. To force a reset from the values in
# the settings table, add the ResetDb=True parameter to any page.

#***************************************
# Begin Sub setPageInfo
#	Each page in the software calls this function to indicate whether
#		bLogin - the user requires a login to view the page
#		intDomain - the page is specific to one module, or global
#		intDbArea - the page's look and feel are module-specific or in the admin area
#		strPathToStart - the path to the folder containing the CIC start page from this page
#		strPathFromStart - the path to this page from the folder containing the CIC start page
#		strFocus - the full name of a control in a form that should be given the cursor focus
#
#	The Sub also retrieves any page help or page message information associated with the current page.
#***************************************
def l_setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus, RedirectAndTidy, MemberName, bAllowAPILogin):
	global ps_strThisPage, ps_strThisPageFull, ps_bLogin, ps_intDomain, \
		ps_intDbArea, ps_strPathToStart, ps_strFocus, ps_strRootPath, ps_strTitle, \
		ps_bHasHelp, g_strMemberNameDOM

	pyrequest.context = rootfactories.BaseRootFactory()
	pyrequest.context.allow_api_login = bAllowAPILogin
	page_info = pageinfo.PageInfo(pyrequest, intDomain, intDbArea)
	pyrequest.pageinfo = page_info

	ps_strThisPage = page_info.ThisPage
	ps_strThisPageFull = page_info.ThisPageFull
	ps_bLogin = bLogin
	ps_intDomain = page_info.Domain
	ps_intDbArea = page_info.DbArea
	ps_strPathToStart = page_info.PathToStart
	ps_strFocus = strFocus
	ps_strRootPath = page_info.RootPath
	if ps_intDbArea == DM_CIC:
		g_strMemberNameDOM = dboptions.get_best_lang('MemberNameCIC')
	elif ps_intDbArea == DM_VOL:
		g_strMemberNameDOM = dboptions.get_best_lang('MemberNameVOL')
	else:
		g_strMemberNameDOM = MemberName

#***************************************
# End Sub setPageInfo
#***************************************


def get_view_data_cic(strName):
	return getattr(pyrequest.viewdata.cic, strName, None)


def get_view_data_vol(strName):
	return getattr(pyrequest.viewdata.vol, strName, None)

#***************************************
# Begin Sub getViewData
#	This Sub retrieves all information about the current View for each module
#	in the database. If the View has been changed temporarily or permanently
#	that View may be used instead of the default View for the current user,
#	depending on security permissions. The current URL may also imply that a
#	special View should be used for one or more modules.
#
#	Default values are set first, which would apply to a page set as belonging
#	to the Admin (shared) section of the database. The View data retrieved for
#	each module is stored in the global View variables. If the current page
#	is associated with a specific module of the database, some of that View's
#	data is also assigned to the domain-specific View variables, whose values
#	are associated with the module of the current page.
#
#	The View values retrieved are used as the basis for a call to the Sub
#	getWhereClauses(), which sets restrictions for which records are
#	currently available in each module.
#***************************************
def getViewData(SetPrintMode, handleDBConnetionError):
	global ps_strDbAreaTitle, ps_strDbAreaBottomMsg, ps_strDbAreaDefaultPath, \
		ps_strDbArea, ps_intDbAreaViewType, g_intViewTypeDOM, g_bCanSeeDeletedDOM, \
		ps_strTitle, ps_bHasHelp

	global g_intViewTypeCIC, g_strViewNameCIC, g_bCanSeeNonPublicCIC, \
		g_bCanSeeDeletedCIC, g_intHidePastDueByCIC, g_bAlertColumnCIC, \
		g_intDesignCIC, g_intPrintDesignCIC, g_bPrintVersionResultsCIC, \
		g_bDataMgmtFieldsCIC, g_bLastModifiedDateCIC, g_bSocialMediaShareCIC, g_intCommSrchWrapAtCIC, \
		g_bOtherCommunityCIC, g_bRespectPrivacyProfile, g_intPBID, g_bLimitedView, \
		g_bVolunteerLink, g_strQuickListName, g_bQuickListDropDown, \
		g_intQuickListWrapAt, g_bLinkOrgLevels, g_bCanSeeNonPublicPub, \
		g_bUsePubNamesOnly, g_bUseNAICSView, g_bUseTaxonomyView, g_intTaxDefnLevel, \
		g_bUseThesaurusView, g_bUseLocalSubjects, g_bUseZeroSubjects, \
		g_bMapSearchResults, g_bAutoMapSearchResults, g_bUseSubmitChangesTo, \
		g_bHasExcelProfile, g_bHasExportProfile, g_bMyListCIC, g_dicCulturesCIC, g_strAlsoNotifyCIC, \
		g_bViewOtherLangsCIC, g_bAllowFeedbackNotInViewCIC, g_strAssignSuggestionsToCIC

	global g_intViewTypeVOL, g_strViewNameVOL, g_intCommunitySetID, \
		g_strAreaServed, g_bUseOSSD, g_bUseIndividualCount, g_bCanSeeNonPublicVOL, g_bCanSeeDeletedVOL, \
		g_bCanSeeExpired, g_intHidePastDueByVOL, g_bAlertColumnVOL, g_intDesignVOL, \
		g_intPrintDesignVOL, g_bPrintVersionResultsVOL, g_bSuggestOpLink, \
		g_bDataMgmtFieldsVOL, g_bLastModifiedDateVOL, g_bSocialMediaShareVOL, g_intCommSrchWrapAtVOL, \
		g_bUseProfilesView, g_bMyListVOL, g_dicCulturesVOL, g_strAlsoNotifyVOL, \
		g_bViewOtherLangsVOL, g_bAllowFeedbackNotInViewVOL, g_strAssignSuggestionsToVOL, \
		g_bUseDatesTimes

	try:
		vd = pyrequest.viewdata
	except ConnectionError:
		handleDBConnetionError()

	# we finally have enough info to fetch things like the page title and page help
	pyrequest.pageinfo.fetch()

	pi = pyrequest.pageinfo

	ps_strTitle = pi.PageTitle
	ps_bHasHelp = pi.HasHelp
	ps_strDbAreaTitle = pi.DbAreaTitle
	ps_strDbAreaBottomMsg = pi.DbAreaBottomMsg
	ps_strDbAreaDefaultPath = pi.DbAreaDefaultPath
	ps_strDbArea = pi.DbAreaS
	ps_intDbAreaViewType = pi.DbAreaViewType
	g_intViewTypeDOM = vd.ViewType
	g_bCanSeeDeletedDOM = vd.CanSeeDeleted

	#CIC View Settings; Set by CIC Super User from Setup > CIC > Views
	g_intViewTypeCIC = vd.cic.ViewType
	g_strViewNameCIC = vd.cic.ViewName
	g_bCanSeeNonPublicCIC = vd.cic.CanSeeNonPublic
	g_bCanSeeDeletedCIC = vd.cic.CanSeeDeleted
	g_intHidePastDueByCIC = vd.cic.HidePastDueBy
	g_bAlertColumnCIC = vd.cic.AlertColumn
	g_intDesignCIC = vd.cic.Template
	g_intPrintDesignCIC = vd.cic.PrintTemplate
	g_bPrintVersionResultsCIC = vd.cic.PrintVersionResults
	g_bDataMgmtFieldsCIC = vd.cic.DataMgmtFields
	g_bLastModifiedDateCIC = vd.cic.LastModifiedDate
	g_bSocialMediaShareCIC = vd.cic.SocialMediaShare
	g_intCommSrchWrapAtCIC = vd.cic.CommSrchWrapAt
	g_bOtherCommunityCIC = vd.cic.OtherCommunity
	g_bRespectPrivacyProfile = vd.cic.RespectPrivacyProfile
	g_intPBID = vd.cic.PB_ID
	g_bLimitedView = vd.cic.LimitedView
	g_bVolunteerLink = vd.cic.VolunteerLink
	g_strQuickListName = vd.cic.QuickListName
	g_bQuickListDropDown = vd.cic.QuickListDropDown
	g_intQuickListWrapAt = vd.cic.QuickListWrapAt
	g_bLinkOrgLevels = vd.cic.LinkOrgLevels
	g_bCanSeeNonPublicPub = vd.cic.CanSeeNonPublicPub
	g_bUsePubNamesOnly = vd.cic.UsePubNamesOnly
	g_bUseNAICSView = vd.cic.UseNAICSView
	g_bUseTaxonomyView = vd.cic.UseTaxonomyView
	g_intTaxDefnLevel = vd.cic.TaxDefnLevel
	g_bUseThesaurusView = vd.cic.UseThesaurusView
	g_bUseLocalSubjects = vd.cic.UseLocalSubjects
	g_bUseZeroSubjects = vd.cic.UseZeroSubjects
	g_bMapSearchResults = vd.cic.MapSearchResults
	g_bAutoMapSearchResults = vd.cic.AutoMapSearchResults
	g_bUseSubmitChangesTo = vd.cic.UseSubmitChangesTo
	g_bHasExcelProfile = vd.cic.HasExcelProfile
	g_bHasExportProfile = vd.cic.HasExportProfile
	g_bMyListCIC = vd.cic.MyList
	g_strAlsoNotifyCIC = vd.cic.AlsoNotify
	g_bViewOtherLangsCIC = vd.cic.ViewOtherLangs
	g_bAllowFeedbackNotInViewCIC = vd.cic.AllowFeedbackNotInView
	g_strAssignSuggestionsToCIC = vd.cic.AssignSuggestionsTo

	g_intViewTypeVOL = vd.vol.ViewType
	g_strViewNameVOL = vd.vol.ViewName
	g_intCommunitySetID = vd.vol.CommunitySetID
	g_strAreaServed = vd.vol.AreaServed
	g_bUseOSSD = vd.vol.ASrchOSSD
	g_bUseIndividualCount = vd.vol.SSrchIndividualCount
	g_bUseDatesTimes = vd.vol.SSrchDatesTimes
	g_bCanSeeNonPublicVOL = vd.vol.CanSeeNonPublic
	g_bCanSeeDeletedVOL = vd.vol.CanSeeDeleted
	g_bCanSeeExpired = vd.vol.CanSeeExpired
	g_intHidePastDueByVOL = vd.vol.HidePastDueBy
	g_bAlertColumnVOL = vd.vol.AlertColumn
	g_intDesignVOL = vd.vol.Template
	g_intPrintDesignVOL = vd.vol.PrintTemplate
	g_bPrintVersionResultsVOL = vd.vol.PrintVersionResults
	g_bDataMgmtFieldsVOL = vd.vol.DataMgmtFields
	g_bLastModifiedDateVOL = vd.vol.LastModifiedDate
	g_bSocialMediaShareVOL = vd.vol.SocialMediaShare
	g_intCommSrchWrapAtVOL = vd.vol.CommSrchWrapAt
	g_bSuggestOpLink = vd.vol.SuggestOpLink
	g_bUseProfilesView = vd.vol.UseProfilesView
	g_bMyListVOL = vd.vol.MyList
	g_strAlsoNotifyVOL = None
	g_bViewOtherLangsVOL = vd.vol.ViewOtherLangs
	g_bAllowFeedbackNotInViewVOL = vd.vol.AllowFeedbackNotInView
	g_strAssignSuggestionsToVOL = vd.vol.AssignSuggestionsTo

	SetPrintMode(vd.PrintMode)

	setWhereClauses()
#***************************************
# End Sub getViewData
#***************************************

#***************************************
# Begin Sub setWhereClauses
#***************************************
def setWhereClauses():
	#SQL "WHERE" clause with restrictions on which records are available in the current View for each module
	global g_strWhereClauseCIC, g_strWhereClauseCICNoDel, g_strWhereClauseVOL, \
		g_strWhereClauseVOLNoDel

	vd = pyrequest.viewdata

	g_strWhereClauseCIC = vd.WhereClauseCIC
	g_strWhereClauseCICNoDel = vd.WhereClauseCICNoDel

	g_strWhereClauseVOL = vd.WhereClauseVOL
	g_strWhereClauseVOLNoDel = vd.WhereClauseVOLNoDel

#***************************************
# End Sub setWhereClauses
#***************************************

def get_default_print_profile():
	view = pyrequest.viewdata.dom
	if pyrequest.user or view.DefaultPrintProfilePublic:
		return view.DefaultPrintProfile
	return None

</script>

<%
Call getDbOptions(GetRef("handleDBConnetionError"))

Dim g_strMemberName
If g_strMemberNameCIC = g_strMemberNameVOL Then
	g_strMemberName = g_strMemberNameCIC
ElseIf Nl(g_strMemberNameCIC) Then
	g_strMemberName = g_strMemberNameVOL
ElseIf Nl(g_strMemberNameVOL) Then
	g_strMemberName = g_strMemberNameCIC
Else
	g_strMemberName = g_strMemberNameCIC & TXT_MEMBER_NAME_SEP & g_strMemberNameVOL
End If

Dim ps_strMsg

Dim g_bAllowAPILogin
g_bAllowAPILogin = False

Dim g_bListScriptLoaded
g_bListScriptLoaded = False

Sub setPageInfo(ByVal bLogin, ByVal intDomain, ByVal intDbArea, ByVal strPathToStart, ByVal strPathFromStart, ByVal strFocus)
	Call l_setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus, GetRef("RedirectAndTidy"), g_strMemberName, g_bAllowAPILogin)
End Sub

Sub RedirectAndTidy(strToURL)
%>
<!-- #include file="incClose.asp" -->
<%
	Response.Redirect(strToURL)
End Sub

'***************************************
' External Asset Management
'***************************************
%>
<script language="python" runat="server">
def makeAssetVer(strScriptName):
	return pyrequest.assetmgr.makeAssetVer(six.text_type(strScriptName))

def JSVerScriptTag(strScriptName):
	return pyrequest.assetmgr.JSVerScriptTag(six.text_type(strScriptName))

def makeSingletonScriptTag(strScriptName):
	return pyrequest.assetmgr.makeSingletonScriptTag(six.text_type(strScriptName))
def makeJQueryScriptTags():
	return pyrequest.assetmgr.makeJQueryScriptTags()
</script>
<%
'***************************************
' End External Asset Management
'***************************************
%>


<script language="python" runat="server">
import cioc.core.clienttracker as clienttracker
def ctHasBeenLaunched():
	return clienttracker.has_been_launched(pyrequest)
</script>

