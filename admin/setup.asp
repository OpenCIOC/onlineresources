<%@LANGUAGE="VBSCRIPT"%>
<%Option Explicit%>

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
' Purpose:		Main setup menu
'
%>

<% 'Base includes %>
<!--#include file="../includes/core/adovbs.inc" -->
<!--#include file="../includes/core/incVBUtils.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<!--#include file="../includes/core/incRExpFuncs.asp" -->
<!--#include file="../includes/core/incHandleError.asp" -->
<!--#include file="../includes/core/incSetLanguage.asp" -->
<!--#include file="../includes/core/incPassVars.asp" -->
<!--#include file="../text/txtGeneral.asp" -->
<!--#include file="../text/txtError.asp" -->
<!--#include file="../includes/core/incConnection.asp" -->
<!--#include file="../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtChecklist.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<script language="Python" runat="server">
def offline_tools_enabled():
	try:
		return pyrequest.dboptions.UseOfflineTools
	except AttributeError:
		return False
</script>
<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Call makePageHeader(TXT_DATABASE_SETUP, TXT_DATABASE_SETUP, True, True, True, True)
%>
<p class="AlertBubble"><%=TXT_INST_SHARED_LISTS%></p>
<%
	Dim cmdChkNameData, rsChkNameData
	Set cmdChkNameData = Server.CreateObject("ADODB.Command")
	With cmdChkNameData
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_FieldOption_l_Chk"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsChkNameData = Server.CreateObject("ADODB.Recordset")
	With rsChkNameData
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdChkNameData
	End With
%>

<div class="row">
	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span> <%=TXT_DATABASE_SETUP%></h2></div>
			<div class="panel-body">
				<ul class="simple-list">
					<li><a href="<%=makeLinkB("general")%>"><%=TXT_GENERAL_OPTIONS%></a></li>
					<li><a href="<%=makeLinkB("agencies.asp")%>"><%=TXT_AGENCIES%></a></li>
					<li><a href="<%=makeLinkB("setup_inclusion.asp")%>"><%=TXT_INCLUSION_POLICIES%></a></li>
					<li><a href="<%=makeLinkB("domainmap")%>"><%=TXT_DOMAIN_NAME_MAPPING%></a></li>
					<li><a href="<%=makeLinkB("ganalytics")%>"><%=TXT_GOOGLE_ANALYTICS%></a></li>
					<li><a href="<%=IIf(user_bSuperUserGlobal,makeLinkB("pagetitle"),makeLink("notices/new","AreaCode=PAGETITLE",vbNullString))%>"><%=TXT_PAGE_TITLES%></a></li>
				</ul>
			</div>
		</div>
	</div>

	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-lock" aria-hidden="true"></span> <%=TXT_SECURITY_PRIVACY%></h2></div>
			<div class="panel-body">
				<ul class="simple-list">
					<li><a href="<%=makeLinkB("users.asp")%>"><%=TXT_MANAGE_USERS%></a></li>
					<%If user_bSuperUserCIC Then%>
					<li><a href="<%=makeLink("setup_utypes.asp","DM=" & DM_CIC,vbNullString)%>"><%=TXT_USER_TYPES & TXT_COLON & TXT_CIC%></a></li>
					<%End If%>
					<%If user_bSuperUserVOL Then%>
					<li><a href="<%=makeLink("setup_utypes.asp","DM=" & DM_VOL,vbNullString)%>"><%=TXT_USER_TYPES & TXT_COLON & TXT_VOLUNTEER%></a></li>
					<%End If%>
					<%If user_bSuperUserCIC Then%>
					<li><a href="<%=makeLink("privacy_profile.asp",vbNullString,vbNullString)%>"><%=TXT_PRIVACY_PROFILES%></a></li>
					<%End If%>
				</ul>
			</div>
		</div>
	</div>
	
	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-envelope" aria-hidden="true"></span> <%=TXT_EMAIL%></h2></div>
			<div class="panel-body">
				<ul class="simple-list">

					<%If user_bSuperUserCIC Then%>
					<li><a href="<%=makeLink("email","DM=" & DM_CIC,vbNullString)%>"><%=TXT_STANDARD_EMAIL_TEXT & TXT_COLON & TXT_CIC%></a></li>
					<%End If%>
					
					<%If user_bSuperUserVOL Then%>
					<li><a href="<%=makeLink("email","DM=" & DM_VOL,vbNullString)%>"><%=TXT_STANDARD_EMAIL_TEXT & TXT_COLON & TXT_VOLUNTEER%></a></li>
					<li><a href="<%=makeLink("email","MR=1&DM=" & DM_VOL,vbNullString)%>"><%=TXT_OPPORTUNITIES_EMAIL_TEXT%></a></li>
					<%End If%>
				</ul>
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-sm-12">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-modal-window" aria-hidden="true"></span> <%=TXT_VIEWS_TEMPLATES_SEARCH%></h2></div>
			<div class="panel-body">
				<div class="row">
					<div class="col-sm-<%If user_bSuperUserVOL And user_bSuperUserCIC Then%>4<%Else%>6<%End If%>">
						<h3><%=TXT_GENERAL_SHARED%></h3>
						<ul class="simple-list">
							<li><a href="<%=makeLinkB("layout")%>"><%=TXT_TEMPLATE_LAYOUTS%></a></li>
							<li><a href="<%=makeLinkB("template")%>"><%=TXT_DESIGN_TEMPLATES%></a></li>
							<li><a href="<%=makeLinkB("setup_page_msg.asp")%>"><%=TXT_PAGE_MESSAGES%></a></li>
						</ul>
					</div>
					<%If user_bSuperUserCIC Then%>
					<div class="col-sm-<%If user_bSuperUserVOL Then%>4<%Else%>6<%End If%>">
						<h3><%=TXT_CIC%></h3>
						<ul class="simple-list">
							<li><a href="<%=makeLink("view","DM=" & DM_CIC,vbNullString)%>"><%=TXT_VIEWS%></a></li>
							<li><a href="<%=makeLink("setup_searchtips.asp","DM=" & DM_CIC,vbNullString)%>"><%=TXT_SEARCH_TIPS%></a></li>
							<li><a href="<%=makeLink("checklist", "chk=ag", vbNullString)%>"><%=TXT_SEARCH_AGE_GROUPS%></a></li>
							<li><a href="<%=makeLink("pages", "DM=" & DM_CIC, vbNullString)%>"><%=TXT_PAGES%></a></li>
						</ul>
					</div>
					<%End If%>

					<%If user_bSuperUserVOL Then%>
					<div class="col-sm-<%If user_bSuperUserCIC Then%>4<%Else%>6<%End If%>">
						<h3><%=TXT_VOLUNTEER%></h3>
						<ul class="simple-list">
							<li><a href="<%=makeLink("view","DM=" & DM_VOL,vbNullString)%>"><%=TXT_VIEWS%></a></li>
							<li><a href="<%=makeLink("setup_searchtips.asp","DM=" & DM_VOL,vbNullString)%>"><%=TXT_SEARCH_TIPS%></a></li>
							<li><a href="<%=makeLinkB("comms_vol.asp")%>"><%=TXT_COMMUNITIES%></a></li>
							<li><a href="<%=makeLink("pages", "DM=" & DM_VOL, vbNullString)%>"><%=TXT_PAGES%></a></li>
							<li><a href="<%=makeLink("applicationsurvey", vbNullString, vbNullString)%>"><%=TXT_APPLICATION_SURVEYS%></a></li>
						</ul>
					</div>
					<%End If%>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-tags" aria-hidden="true"></span> <%=TXT_CLASSIFICATION_SYSTEMS%></h2></div>
			<div class="panel-body">

				<h3><%=TXT_GENERAL_SHARED%></h3>
				<ul class="simple-list">
					<li><a href="<%=IIf(user_bSuperUserGlobal,makeLinkB("community"),makeLinkB("community/list"))%>"><%=TXT_COMMUNITIES%></a></li>
				</ul>

				<%If user_bSuperUserCIC Then%>
				<h3><%=TXT_CIC%></h3>
				<ul class="simple-list">
					<li><a href="<%=makeLinkB(ps_strPathToStart & "publication")%>"><%=TXT_PUBLICATIONS%></a></li>
					<%If g_bUseTaxonomy Then%>
					<li><a href="<%=makeLinkB(ps_strPathToStart & "tax_mng.asp")%>"><%=TXT_TAXONOMY%></a></li>
					<%End If%>
					<li><a href="<%=makeLinkB("thesaurus.asp")%>"><%=TXT_THESAURUS%></a></li>
					<li><a href="<%=IIf(user_bSuperUserGlobalCIC,makeLinkB("naics"),makeLink("notices/new","AreaCode=NAICS",vbNullString))%>"><%=TXT_NAICS_SETUP%></a></li>
				</ul>
				<%End If%>

				<%If user_bSuperUserVOL Then%>
				<h3><%=TXT_VOLUNTEER%></h3>
				<ul class="simple-list">
					<li><a href="<%=makeLinkB("interests")%>"><%= TXT_SPECIFIC_AREAS_OF_INTEREST %></a></li>
					<li><a href="<%=makeLink("checklist", "chk=ig", vbNullString)%>"><%= TXT_GENERAL_AREAS_OF_INTEREST %></a></li>
				</ul>
				<%End If%>
			</div>
		</div>
	</div>

	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-share" aria-hidden="true"></span> <%=TXT_APIS_SHARING_EXPORT%></h2></div>
			<div class="panel-body">

				<h3><%=TXT_GENERAL_SHARED%></h3>
				<ul class="simple-list">
					<li><a href="<%=makeLinkB("datafeedapikey")%>"><%=TXT_DATA_FEED_API_KEY%></a></li>
					<li><a href="<%=makeLinkB(ps_strPathToStart & "shortcodes")%>"><%= TXT_SHORT_CODE_GENERATOR %></a></li>
				</ul>

				<%If user_bSuperUserCIC Then%>
				<h3><%=TXT_CIC%></h3>
				<ul class="simple-list">
					<li><a href="<%=makeLinkB("excelprofile")%>"><%=TXT_EXCEL_PROFILES%></a></li>
					<li><a href="<%=makeLink("export_profile.asp","DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXPORT_PROFILES%></a></li>
					<%If offline_tools_enabled() Then %>
					<li><a href="<%=makeLinkB("offlinetools")%>"><%=TXT_OFFLINE_TOOLS%></a></li>
					<% End If %>
					<%If g_bOtherMembersActive Then%>
					<li><a href="<%=makeLink("sharingprofile","DM=" & DM_CIC,vbNullString)%>"><%=TXT_SHARING_PROFILES%></a></li>
					<%End If%>
				</ul>
				<%End If%>

				<%If user_bSuperUserVOL And g_bOtherMembersActive Then%>
				<h3><%=TXT_VOLUNTEER%></h3>
				<ul class="simple-list">
					<%If g_bOtherMembersActive Then%>
					<li><a href="<%=makeLink("sharingprofile","DM=" & DM_VOL,vbNullString)%>"><%=TXT_SHARING_PROFILES%></a></li>
					<%End If%>
				</ul>
				<%End If%>
			</div>
		</div>
	</div>

	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-map-marker" aria-hidden="true"></span> <%=TXT_MAPPING%></h2></div>
			<div class="panel-body">
				<ul class="simple-list">
					<li><a href="<%=makeLink("checklist", "chk=mc", vbNullString)%>"><%=TXT_MAPPING_CATEGORIES%></a></li>
					<li><a href="<%=IIf(user_bSuperUserGlobal,makeLinkB("mappingsystem"),makeLink("notices/new","AreaCode=MAPSYSTEM",vbNullString))%>"><%=TXT_MAPPING_SYSTEMS%></a></li>
				</ul>
			</div>
		</div>

		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-print" aria-hidden="true"></span> <%=TXT_PRINT_PROFILES%></h2></div>
			<div class="panel-body">
				<ul class="simple-list">
					<%If user_bSuperUserCIC Then%>
					<li><a href="<%=makeLink("print_profile.asp","DM=" & DM_CIC,vbNullString)%>"><%=TXT_PRINT_PROFILES & TXT_COLON & TXT_CIC%></a></li>
					<%End If%>
					<%If user_bSuperUserVOL Then%>
					<li><a href="<%=makeLink("print_profile.asp","DM=" & DM_VOL,vbNullString)%>"><%=TXT_PRINT_PROFILES & TXT_COLON & TXT_VOLUNTEER%></a></li>
					<%End If%>
				</ul>
			</div>
		</div>
	</div>
</div>

<div class="row">
	<div class="col-sm-<%If user_bSuperUserVOL And user_bSuperUserCIC Then%>8<%Else%>4<%End If%>">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-tasks" aria-hidden="true"></span> <%=TXT_FIELD_SETUP%></h2></div>
			<div class="panel-body">
				<div class="row">

				<%If user_bSuperUserCIC Then%>
					<div class="col-sm-<%If user_bSuperUserVOL Then%>6<%Else%>12<%End If%>">
						<h3><%=TXT_CIC%></h3>
						<ul class="simple-list">
							<li><a href="<%=makeLink("fielddisplay", "DM=" & DM_CIC, vbNullString)%>"><%=TXT_FIELD_DISPLAY%></a></li>
							<li><a href="<%=makeLink("fieldhide", "DM=" & DM_CIC, vbNullString)%>"><%=TXT_FIELD_HIDE%></a></li>
							<li><a href="<%=makeLink("setup_help_fields.asp","DM=" & DM_CIC,vbNullString)%>"><%=TXT_FIELD_HELP%></a></li>
							<li><a href="<%=makeLink("fieldradio", "DM=" & DM_CIC, vbNullString)%>"><%= TXT_FIELD_DISPLAY_YES_NO %></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=l&DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_CHECKLIST%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=d&DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_DATE%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=p&DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_DROPDOWN%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=e&DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_EMAIL%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=r&DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_RADIO%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=t&DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_TEXT%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=w&DM=" & DM_CIC,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_WWW%></a></li>
						</ul>
					</div>
				<%End If%>

				<%If user_bSuperUserVOL Then%>
					<div class="col-sm-<%If user_bSuperUserCIC Then%>6<%Else%>12<%End If%>">
						<h3><%=TXT_VOLUNTEER%></h3>
						<ul class="simple-list">
							<li><a href="<%=makeLink("fielddisplay", "DM=" & DM_VOL, vbNullString)%>"><%=TXT_FIELD_DISPLAY%></a></li>
							<li><a href="<%=makeLink("fieldhide", "DM=" & DM_VOL, vbNullString)%>"><%=TXT_FIELD_HIDE%></a></li>
							<li><a href="<%=makeLink("setup_help_fields.asp","DM=" & DM_VOL,vbNullString)%>"><%=TXT_FIELD_HELP%></a></li>
							<li><a href="<%=makeLink("fieldradio", "DM=" & DM_VOL, vbNullString)%>"><%= TXT_FIELD_DISPLAY_YES_NO %></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=l&DM=" & DM_VOL,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_CHECKLIST%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=d&DM=" & DM_VOL,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_DATE%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=p&DM=" & DM_VOL,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_DROPDOWN%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=e&DM=" & DM_VOL,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_EMAIL%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=r&DM=" & DM_VOL,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_RADIO%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=t&DM=" & DM_VOL,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_TEXT%></a></li>
							<li><a href="<%=makeLink("setup_extrafield.asp","FType=w&DM=" & DM_VOL,vbNullString)%>"><%=TXT_EXTRA_FIELD_SETUP & " - " & TXT_WWW%></a></li>
						</ul>
					</div>
				<%End If%>
				</div>
			</div>
		</div>
	</div>

	<%If user_bSuperUserCIC Then%>
	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-home" aria-hidden="true"></span> <%=TXT_VACANCY_SETUP%></h2></div>
			<div class="panel-body">
				<ul class="simple-list">
					<li><a href="<%=makeLinkB("setup_vacancy.asp")%>"><%=TXT_VACANCY_FORM_CONFIG%></a></li>
					<li><a href="<%=makeLink("checklist", "chk=vst", vbNullString)%>"><%=TXT_CHK_VACANCY_SERVICE_TITLE%></a></li>
					<li><a href="<%=makeLink("checklist", "chk=vtp", vbNullString)%>"><%=TXT_CHK_VACANCY_TARGET_POPULATION%></a></li>
					<li><a href="<%=makeLink("checklist", "chk=vut", vbNullString)%>"><%=TXT_CHK_VACANCY_UNIT_TYPE%></a></li>
					<li><a href="<%=makeLinkB("vacancy/history")%>"><%=TXT_VACANCY_HISTORY_DOWNLOAD%></a></li>
				</ul>
			</div>
		</div>
	</div>
	<%End If%>

	<div class="col-sm-<%If user_bSuperUserVOL And user_bSuperUserCIC Then%>12<%Else%>8<%End If%>">
		<div class="panel panel-default">
			<div class="panel-heading"><h2><span class="glyphicon glyphicon-check" aria-hidden="true"></span> <%=TXT_CHECKLISTS%></h2></div>
			<div class="panel-body">
				<div class="row">
					<div class="col-sm-<%If user_bSuperUserVOL And user_bSuperUserCIC Then%>4<%Else%>6<%End If%>">
						<h3><%=TXT_GENERAL_SHARED%></h3>
						<ul class="simple-list">
							<li><a href="<%=IIf(user_bSuperUserGlobal,makeLinkB("socialmedia"),makeLink("notices/new","AreaCode=SOCIALMEDIA",vbNullString))%>"><%=TXT_SOCIAL_MEDIA_TYPES%></a></li>
							<li><a href="<%=IIf(user_bSuperUserGlobal,makeLink("checklist", "chk=ba", vbNullString),makeLink("notices/new","AreaCode=BILLADDRTYPE",vbNullString))%>"><%=TXT_CHK_BILLING_ADDRESS_TYPE%></a></li>
							<li><a href="<%=makeLink("listvalues","list=bt",vbNullString)%>"><%=TXT_CHK_BOX_TYPE%></a></li>
							<li><a href="<%=IIf(user_bSuperUserGlobal,makeLink("checklist", "chk=nt", vbNullString),makeLink("notices/new","AreaCode=NOTETYPE",vbNullString))%>"><%=TXT_CHK_NOTE_TYPE%></a></li>
							<li><a href="<%=makeLink("listvalues","list=st",vbNullString)%>"><%=TXT_CHK_STREETTYPE%></a></li>
							<li><a href="<%=makeLink("listvalues","list=ch",vbNullString)%>"><%=TXT_CHK_CONTACT_HONORIFIC%></a></li>
							<li><a href="<%=makeLink("listvalues","list=cpt",vbNullString)%>"><%=TXT_CHK_CONTACT_PHONE_TYPE%></a></li>
<%
	With rsChkNameData
		Do While Not .EOF
			If .Fields("FieldType") <> "GBL" Then
				Exit Do
			End If
			If .Fields("ChecklistSearch") <> "ols" Then
%>
							<li><a href="<%=makeLink("checklist", "chk=" & .Fields("ChecklistSearch"), vbNullString)%>"><%=.Fields("FieldDisplay")%></a></li>
<%
			End If
			.MoveNext
		Loop
	End With
%>
						</ul>
					</div>

					<%If user_bSuperUserCIC Then%>
					<div class="col-sm-<%If user_bSuperUserVOL Then%>4<%Else%>6<%End If%>">
						<h3><%=TXT_CIC%></h3>
						<ul class="simple-list">
							<li><a href="<%=IIf(user_bSuperUserGlobal,makeLink("checklist", "chk=as", vbNullString),makeLink("notices/new","AreaCode=ACTIVITYSTATUS",vbNullString))%>"><%=TXT_ACTIVITY_STATUS%></a></li>

<%
	With rsChkNameData
		Dim intSchoolCount
		intSchoolCount = 0
		Do While Not .EOF
			If .Fields("FieldType") = "VOL" Then
				Exit Do
			End If
			If .Fields("ChecklistSearch") = "sch" Then
				intSchoolCount = intSchoolCount + 1
			End If
%>
							<li><a href="<%=makeLink("checklist", "chk=" & .Fields("ChecklistSearch"), vbNullString)%>"><%=.Fields("FieldDisplay")%></a></li>
<%
			.MoveNext
		Loop
	End With
%>
						</ul>
						<% If intSchoolCount > 0 Then %>
						<p class="InfoMsg"><%= TXT_INST_SCH_CHKLIST %></p>
						<%End If%>
					</div>
					<%End If%>

					<%If user_bSuperUserVOL Then%>
					<div class="col-sm-<%If user_bSuperUserCIC Then%>4<%Else%>6<%End If%>">
						<h3><%=TXT_VOLUNTEER%></h3>
						<ul class="simple-list">
<%
	With rsChkNameData

		Do While Not .EOF
			If .Fields("FieldType") = "VOL" Then
%>
							<li><a href="<%=makeLink("checklist", "chk=" & .Fields("ChecklistSearch"), vbNullString)%>"><%=.Fields("FieldDisplay")%></a></li>
<%
			End If
			.MoveNext
		Loop
	End With
%>
						</ul>
					</div>
					<%End If%>
				</div>
			</div>
		</div>
	</div>
</div>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->

