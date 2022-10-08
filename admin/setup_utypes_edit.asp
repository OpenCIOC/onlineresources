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
' Purpose: 		Form to edit values for User Types from each module.
'				Values are stored in tables: CIC_SecurityLevel, VOL_SecurityLevel.
'				Super User privileges for the given module are required.
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
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incViewList.asp" -->

<script language="Python" runat="server">
def offline_tools_enabled():
	try:
		return pyrequest.dboptions.UseOfflineTools
	except AttributeError:
		return False
</script>
<%
'Domain variables
Dim intDomain, _
	strType, _
	strStoredProcName, _
	user_bSuperUserGlobalDOM

'Retrieve current domain (module)
intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

'Ensure user has super user privileges for the given module
'Get stored procedure name for retrieving User Type data for this module
Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
		strStoredProcName = "dbo.sp_CIC_SecurityLevel_s"
		user_bSuperUserGlobalDOM = IIf(g_bUseCIC, user_bSuperUserGlobalCIC, user_bSuperUserGlobalVOL)
	Case DM_VOL
		If Not user_bSuperUserVOL And g_bUseVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
		strStoredProcName = "dbo.sp_VOL_SecurityLevel_s"
		user_bSuperUserGlobalDOM = user_bSuperUserGlobalVOL
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

'User Type status variables
Dim strUserTypeStatus, _
	bOkDelete
bOkDelete = True

'User Type Fields (all modules)
Dim	intSLID, _
	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strOwner, _
	strSecurityLevel, _
	strSecurityLevelName, _
	intViewType, _
	intViewTypeOffline, _
	bCanAddRecord, _
	bCanAddSQL, _
	bCanAssignFeedback, _
	bCanCopyRecord, _
	bCanDeleteRecord, _
	bCanDoBulkOps, _
	bCanDoFullUpdate, _
	intCanEditRecord, _
	bEditByViewList, _
	intCanEditVacancy, _
	bVacancyEditByViewList, _
	bCanManageUsers, _
	bCanRequestUpdate, _
	intCanViewStats, _
	bSuppressNotifyEmail, _
	bFeedbackAlert, _
	bCommentAlert, _
	bWebDeveloper, _
	bSuperUser, _
	bSuperUserGlobal, _
	strEditViews, _
	strVacancyEditViews, _
	strCanSeeViews, _
	strEditAgencies, _
	strVacancyEditAgencies, _
	strRecordTypes, _
	strExternalAPIs, _
	strCulture, _
	aEditLangs, _
	xmlDoc, _
	xmlNode

'If no User Type ID was given, this is a new User Type
'Otherwise, ensure ID is of a valid type.
Dim bNew
bNew = False
ReDim aEditLangs(0)

intSLID = Trim(Request("SLID"))
If Nl(intSLID) Then
	bNew = True
	intSLID = Null
ElseIf Not IsIDType(intSLID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSLID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_USER_TYPE, _
		"setup_utypes.asp", vbNullString)
Else
	intSLID = CLng(intSLID)
End If

'User Type Fields (CIC only)
Dim	intCanIndexTaxonomy, _
	intCanUpdatePubs, _
	intExportPermission, _
	bImportPermission

'User Type Fields (Volunteer only)
Dim bCanAccessProfiles, _
	bCanManageMembers, _
	bCanManageReferrals

Dim cmdSecurityLevel, rsSecurityLevel
Set cmdSecurityLevel = Server.CreateObject("ADODB.Command")
With cmdSecurityLevel
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	.Parameters.Append .CreateParameter("@SL_ID", adInteger, adParamInput, 4, intSLID)
End With
Set rsSecurityLevel = Server.CreateObject("ADODB.Recordset")
With rsSecurityLevel
	.LockType = adLockOptimistic
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdSecurityLevel
End With

With rsSecurityLevel
	If .EOF Then
		If Not bNew Then
			'There is no User Type for this module with the given ID
			Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intSLID) & "." & _
				vbCrLf & "<br>" & TXT_CHOOSE_USER_TYPE, _
				"setup_utypes.asp", vbNullString)
		End If
	Else
		'User Type data for all modules
		strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strOwner = .Fields("Owner")
		intViewType = .Fields("ViewType")
		bCanAddRecord = .Fields("CanAddRecord")
		bCanCopyRecord = .Fields("CanCopyRecord")
		intCanEditRecord = .Fields("CanEditRecord")
		bEditByViewList = .Fields("EditByViewList")
		bCanDoFullUpdate = .Fields("CanDoFullUpdate")
		bCanDoBulkOps = .Fields("CanDoBulkOps")
		bCanDeleteRecord = .Fields("CanDeleteRecord")
		bCanRequestUpdate = .Fields("CanRequestUpdate")
		bCanAssignFeedback = .Fields("CanAssignFeedback")
		bCanAddSQL = .Fields("CanAddSQL")
		intCanViewStats = .Fields("CanViewStats")
		bCanManageUsers = .Fields("CanManageUsers")
		bSuppressNotifyEmail = .Fields("SuppressNotifyEmail")
		bFeedbackAlert = .Fields("FeedbackAlert")
		bCommentAlert = .Fields("CommentAlert")
		bWebDeveloper = .Fields("WebDeveloper")
		bSuperUser = .Fields("SuperUser")
		bSuperUserGlobal = .Fields("SuperUserGlobal")
		aEditLangs = .Fields("EditLangs")
		If Nl(aEditLangs) Then
			ReDim aEditLangs(0)
		Else
			aEditLangs = Split(aEditLangs, ",")
		End If

		strSecurityLevelName = .Fields("SecurityLevelName")
		
		'User Type data for CIC only
		If intDomain = DM_CIC Then
			intViewTypeOffline = .Fields("ViewTypeOffline")
			bImportPermission = .Fields("ImportPermission")
			intExportPermission = .Fields("ExportPermission")
			intCanUpdatePubs = .Fields("CanUpdatePubs")
			intCanIndexTaxonomy = .Fields("CanIndexTaxonomy")
			intCanEditVacancy = .Fields("CanEditVacancy")
			bVacancyEditByViewList = .Fields("VacancyEditByViewList")
		End If
			
		'User Type data for Volunteer only
		If intDomain = DM_VOL Then
			bCanManageMembers = .Fields("CanManageMembers")
			bCanManageReferrals = .Fields("CanManageReferrals")
			bCanAccessProfiles = .Fields("CanAccessProfiles")
		End If

		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With
		xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"
	End If
End With

Set rsSecurityLevel = rsSecurityLevel.NextRecordset
With rsSecurityLevel
	While Not .EOF
		strExternalAPIs = strExternalAPIs & _
			"<br><label title=""" & Server.HTMLEncode(Ns(.Fields("Description"))) & """>" & _
			"<input type=""checkbox"" name=""APIID"" value=""" & .Fields("API_ID") & """" & Checked(.Fields("SELECTED")) & ">&nbsp;" & Server.HTMLEncode(Ns(.Fields("Name"))) & _
			"</label>"
		If Not Nl(.Fields("SchemaLocation")) Then
			strExternalAPIs = strExternalAPIs & _
				" [ <a href=""" & ps_strPathToStart & .Fields("SchemaLocation") & """>" & TXT_XML_SCHEMA & "</a> ]"
		End If
		.MoveNext
	Wend
End With

Dim intEditByViewType, intCurrentViewType, strCurrentViewName, bCurrentViewSelected, strViewCon
	
strEditViews = vbNullString
strCanSeeViews = vbNullString
strViewCon = vbNullString
strVacancyEditViews = vbNullString

Set rsSecurityLevel = rsSecurityLevel.NextRecordset
With rsSecurityLevel
	If Not .EOF Then
		intCurrentViewType = .Fields("ViewType")
		strCurrentViewName = .Fields("ViewName")
		bCurrentViewSelected = .Fields("SELECTED")
		.MoveNext
	End If
	While Not .EOF
		intEditByViewType = .Fields("ViewType")
		strEditViews = strEditViews & _
			"<li><input type=""checkbox"" name=""EditByViewType"" id=""EditByViewType_" & intEditByViewType & """ value=""" & intEditByViewType & """" & Checked(.Fields("SELECTED")) & ">&nbsp;<label for=""EditByViewType_" & intEditByViewType & """>#" & intEditByViewType & " - " & .Fields("ViewName") & "</label></li>"
		If intDomain = DM_CIC Then
			strVacancyEditViews = strVacancyEditViews & _
				"<li><input type=""checkbox"" name=""VacancyEditByViewType"" id=""VacancyEditByViewType_" & intEditByViewType & """ value=""" & intEditByViewType & """" & Checked(.Fields("VacancySelected")) & ">&nbsp;<label for=""VacancyEditByViewType_" & intEditByViewType & """>#" & intEditByViewType & " - " & .Fields("ViewName") & "</label></li>"
		End If
		strCanSeeViews = strCanSeeViews & strViewCon & "#" & intEditByViewType & " - " & .Fields("ViewName")
		strViewCon = " ; "
		.MoveNext
	Wend
End With

Dim strEditAgencyCode

Set rsSecurityLevel = rsSecurityLevel.NextRecordset
With rsSecurityLevel
	If .RecordCount > 1 Or (.RecordCount = 1 And Nz(.Fields("SELECTED"), False)) Then
		strEditAgencies = "<div class=""row clear-line-below"">"
		While Not .EOF
			strEditAgencyCode = .Fields("AgencyCode")
			strEditAgencies = strEditAgencies & vbCrLf & _
				"<div class=""col-xs-4 col-sm-3 col-md-2"">" & _
				"<label class=""control-label"" for=" & AttrQs("EditAgency_" & strEditAgencyCode) & ">" & _
				"<input type=""checkbox"" name=""EditAgency""" & _
					" id=" & AttrQs("EditAgency_" & strEditAgencyCode) & _
					" value=" & AttrQs(strEditAgencyCode) & _
					" " & Checked(.Fields("SELECTED")) & "> " & strEditAgencyCode & "</label>" & _
				"</div>"
			If intDomain = DM_CIC Then
				strVacancyEditAgencies = strVacancyEditAgencies & _
					"<li><label for=""VacancyEditAgency_" & strEditAgencyCode & """><input type=""checkbox"" name=""VacancyEditAgency"" id=""VacancyEditAgency_" & strEditAgencyCode & """ value=""" & strEditAgencyCode & """" & Checked(.Fields("VacancySelected")) & ">&nbsp;" & strEditAgencyCode & "</label></li>"
			End If
			.MoveNext
		Wend
		strEditAgencies = strEditAgencies & "</div>"
		strVacancyEditAgencies = Replace(strEditAgencies,"EditAgency","VacancyEditAgency")
	End If
End With

Dim intRTID

If intDomain = DM_CIC Then
	Set rsSecurityLevel = rsSecurityLevel.NextRecordset
	With rsSecurityLevel
		While Not .EOF
			intRTID = .Fields("RT_ID")
			strRecordTypes = strRecordTypes & _
				"<br><input type=""checkbox"" name=""RTID"" id=""RTID_" & intRTID & """ value=""" & intRTID & """" & Checked(.Fields("LIMITED")) & ">&nbsp;<label for=""RTID_" & intRTID & """>(" & .Fields("RecordType") & ") " & Nz(.Fields("RecordTypeName"),vbNullString) & "</label>"
			.MoveNext
		Wend
	End With
End If
	
Set rsSecurityLevel = rsSecurityLevel.NextRecordset
With rsSecurityLevel
	If .EOF Then
		'The User Type is not being used by any users.
		strUserTypeStatus = TXT_STATUS_NO_USE
	Else
		'Create a list of the users associated with the given User Type
		strUserTypeStatus = TXT_STATUS_USE
		While Not .EOF
			strUserTypeStatus = strUserTypeStatus & _
				"<strong>" & Replace(.Fields("UserName")," ","&nbsp;") & "</strong>; "
			.MoveNext
		Wend
		'Because there are users associated with this User Type, it cannot be deleted.
		bOkDelete = False
	End If
End With
	
'All information from the User Type recordsets has been retrieved
Set rsSecurityLevel = Nothing
Set cmdSecurityLevel = Nothing

If Not Nl(strOwner) And strOwner <> user_strAgency Then
	Call securityFailure()
End If

'Is the record okay to delete? Add to status report list.
If bOkDelete Then
	strUserTypeStatus = strUserTypeStatus & "<br>" & TXT_STATUS_DELETE
Else
	strUserTypeStatus = strUserTypeStatus & "<br>" & TXT_STATUS_NO_DELETE
End If

'Print header information (depends on whether we are editing a new or existing record)
If Not bNew Then
	Dim strSecurityLevelDisp
	strSecurityLevelDisp = strSecurityLevelName

	Call makePageHeader(TXT_EDIT_USER_TYPE & " (" & strType & ")" & TXT_COLON & "<br>" & strSecurityLevelDisp, TXT_EDIT_USER_TYPE & " (" & strType & ")" & TXT_COLON & strSecurityLevelDisp, True, False, True, True)
Else
	Call makePageHeader(TXT_CREATE_USER_TYPE & " (" & strType & ")", TXT_CREATE_USER_TYPE & " (" & strType & ")", True, False, True, True)
End If
%>

<div class="btn-group" role="group">
	<a role="button" class="btn btn-default" href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a>
	<a role="button" class="btn btn-default" href="<%=makeLink("setup_utypes.asp","DM=" & intDomain,vbNullString)%>"><%=TXT_RETURN_USER_TYPES%> (<%=strType%>)</a>
</div>
<div class="clear-line-below"></div>

<form action="setup_utypes_edit2.asp" method="GET">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="SLID" value="<%=intSLID%>">


<div class="panel panel-default max-width-lg">
<div class="panel-heading"><h2><%=TXT_CREATE_EDIT_USER_TYPE%></h2></div>
<div class="panel-body no-padding">
<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
<%
If Not bNew Then
%>
<tr>
	<td class="field-label-cell"><%=TXT_STATUS%></td>
	<td class="field-data-cell"><%=strUserTypeStatus%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_DATE_CREATED%></td>
	<td class="field-data-cell"><%=strCreatedDate%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_CREATED_BY%></td>
	<td class="field-data-cell"><%=strCreatedBy%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_LAST_MODIFIED%></td>
	<td class="field-data-cell"><%=strModifiedDate%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_MODIFIED_BY%></td>
	<td class="field-data-cell"><%=strModifiedBy%></td>
</tr>
<%
End If
%>
<tr>
	<td class="field-label-cell"><%=TXT_RECORD_OWNER%></td>
	<td class="field-data-cell"><label for="Owner"><input type="checkbox" id="Owner" name="Owner"<%=Checked(Not Nl(strOwner))%>> <%=TXT_EXCLUSIVELY_OWNED_BY & user_strAgency%></label></td>
</tr>
<%
	For Each strCulture In active_cultures()
	If Not bNew Then
		Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture, SQUOTE) & "]")
	Else
		Set xmlNode = Nothing
	End If
	If xmlNode IS Nothing Then
		strSecurityLevel = vbNullString
	Else 
		strSecurityLevel = xmlNode.getAttribute("SecurityLevel")
	End If
%>
<tr>
	<td class="field-label-cell"><label for="SecurityLevel_<%= strCulture %>"><%=TXT_USER_TYPE_NAME%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label> <span class="Alert">*</span></td>
	<td class="field-data-cell"><input class="form-control" type="text" name="SecurityLevel_<%= strCulture %>" id="SecurityLevel_<%= strCulture %>" value=<%=AttrQs(strSecurityLevel)%> size="50" maxlength="100"> 
	<p><%=TXT_INST_USER_TYPE_NAME%></p></td>
</tr>
<%
	Next
Call openViewListRst(intDomain, user_strAgency, intViewType)
%>
<tr>
	<td class="field-label-cell"><%=TXT_DEFAULT_VIEW%> <span class="Alert">*</span></td>
	<td class="field-data-cell"><%=makeViewList(intViewType,"ViewType",True, False)%>
	<p><%=TXT_INST_VIEW_TYPE%></p>
	<%If Not Nl(strCanSeeViews) Then%>
	<p><%=TXT_BASED_ON_EXISTING_VIEW_1%><em>#<%=intCurrentViewType & " - " & strCurrentViewName%></em><%=TXT_BASED_ON_EXISTING_VIEW_2%><em><%=strCanSeeViews%></em><%=TXT_BASED_ON_EXISTING_VIEW_3%></p>
	<%End If%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_EDITORIAL_VIEW%></td>
	<td class="field-data-cell">
	<%=TXT_INST_VIEW_TYPE_EDITORIAL_1%>
	<br><label for="EditByViewList_Default"><input type="radio" name="EditByViewList" id="EditByViewList_Default" value="" <%If Nl(bEditByViewList) Then%>checked<%End If%>> <%=TXT_DEFAULT_VIEW%></label>
	<br><label for="EditByViewList_AnyViewCanAccess"><input type="radio" name="EditByViewList" id="EditByViewList_AnyViewCanAccess" value="<%=SQL_FALSE%>" <%If Not Nl(bEditByViewList) And Not bEditByViewList Then%>checked<%End If%>> <%=TXT_ANY_VIEW_THE_USER_CAN_ACCESS%></label>
	<%If Not bNew And Not Nl(strEditViews) Then%>
	<br><label for="EditByViewlist_SpecificViews"><input type="radio" name="EditByViewList" id="EditByViewlist_SpecificViews" value="<%=SQL_TRUE%>" <%If bEditByViewList Then%>checked<%End If%>> <%=TXT_ANY_OF_THE_FOLLOWING%></label>
	<ul style="list-style-type:none">
	<li><label for="EditByViewType_<%=intCurrentViewType%>"><input type="checkbox" name="EditByViewType" id="EditByViewType_<%=intCurrentViewType%>" value="<%=intCurrentViewType%>" <%If bCurrentViewSelected Then%>checked<%End If%>>&nbsp;#<%=intCurrentViewType%> - <%=strCurrentViewName%></label></li>
	<%=strEditViews%>
	</ul>
	<%End If%>
	<p><%=TXT_INST_VIEW_TYPE_EDITORIAL_2%></p>
	<p class="Alert"><%=TXT_INST_UPDATE_RECORD_2%></p></td>
</tr>
<% If intDomain = DM_CIC And offline_tools_enabled() Then %>
<tr>
	<td class="field-label-cell"><%=TXT_VIEW_OFFLINE%> <span class="Alert">*</span></td>
	<td class="field-data-cell"><%=makeViewList(intViewTypeOffline,"ViewTypeOffline",True, False)%>
	<p><%=TXT_INST_VIEW_TYPE_OFFLINE%></p></td>
</tr>
<%
End If
Call closeViewListRst()
%>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_ADD_RECORD%></td>
	<td class="field-data-cell"><p><label for="CanAddRecord"><input type="checkbox" name="CanAddRecord" id="CanAddRecord" <%If bCanAddRecord Then%>checked<%End If%>> <%=TXT_INST_ADD_RECORD_1%></label></p>
	<p class="Alert"><%=TXT_INST_ADD_RECORD_2%></p></td>
</tr>
<% If intDomain = DM_VOL Or g_bUseCIC Then %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_COPY_RECORD%></td>
	<td class="field-data-cell"><p><label for="CanCopyRecord"><input type="checkbox" name="CanCopyRecord" id="CanCopyRecord" <%If bCanCopyRecord Then%>checked<%End If%>> <%=TXT_INST_COPY_RECORD_1%></label></p>
	<p class="Alert"><%=TXT_INST_COPY_RECORD_2%></p></td>
</tr>
<% End If %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_UPDATE_RECORD%></td>
	<td class="field-data-cell"><label for="CanEditRecord_UPDATE_NONE"><input type="radio" name="CanEditRecord" id="CanEditRecord_UPDATE_NONE" value="<%=UPDATE_NONE%>" <%If intCanEditRecord=UPDATE_NONE Then%>checked<%End If%>> <%=TXT_INST_UPDATE_RECORD_OPT_1%></label>
	<br><label for="CanEditRecord_UPDATE_ALL"><input type="radio" name="CanEditRecord" id="CanEditRecord_UPDATE_ALL" value="<%=UPDATE_ALL%>" <%If intCanEditRecord=UPDATE_ALL Then%>checked<%End If%>> <%=TXT_INST_UPDATE_RECORD_OPT_2%></label>
	<br><label for="CanEditRecord_UPDATE_OWNED"><input type="radio" name="CanEditRecord" id="CanEditRecord_UPDATE_OWNED" value="<%=UPDATE_OWNED%>" <%If intCanEditRecord=UPDATE_OWNED Then%>checked<%End If%>> <%=TXT_INST_UPDATE_RECORD_OPT_3%></label>
	<%If Not Nl(strEditAgencies) Then%>
	<br><label for="CanEditRecord_UPDATE_OWNED_LIST"><input type="radio" name="CanEditRecord" id="CanEditRecord_UPDATE_OWNED_LIST" value="<%=UPDATE_OWNED_LIST%>" <%If intCanEditRecord=UPDATE_OWNED_LIST Then%>checked<%End If%>> <%=TXT_INST_UPDATE_RECORD_OPT_4%></label>
	<%=strEditAgencies%>
	<%End If%>
<%
If g_bUseCIC And Not Nl(strRecordTypes) Then
%>
	<p><%=TXT_INST_UPDATE_RECORD_1%>
	<%=strRecordTypes%></p>
<%
End If
%>
	<p><%= TXT_INST_UPDATE_RECORD_3 %>
	<%
	Dim bEditLangActive
	For Each strCulture In active_record_cultures()
		bEditLangActive = UBound(Filter(aEditLangs, strCulture, True)) = 0
%>
		<br><label><input type="checkbox" name="EditLang" id="EditLang_<%= strCulture %>" value="<%= strCulture %>" <%= Checked(bEditLangActive) %>> <%= Application("Culture_" & strCulture & "_LanguageName") %></label>
<%
	Next
%>

	</p>
	<p class="Alert"><%=TXT_INST_UPDATE_RECORD_2%></p></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_FULL_UPDATE%></td>
	<td class="field-data-cell"><label for="CanDoFullUpdate"><input type="checkbox" name="CanDoFullUpdate" id="CanDoFullUpdate" <%If bCanDoFullUpdate Then%>checked<%End If%>> <%=TXT_INST_FULL_UPDATE_1%></label>
	<p><%=TXT_INST_FULL_UPDATE_2%></p><p class="Alert"><%=TXT_INST_FULL_UPDATE_3%></p></td>
</tr>

<% If g_bUseCIC And intDomain = DM_CIC Then %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_UPDATE_VACANCY%></td>
	<td class="field-data-cell"><%=TXT_INST_UPDATE_VACANCY_1%>
	<p>
	<label for="CanEditVacancy_UPDATE_NONE"><input type="radio" name="CanEditVacancy" id="CanEditVacancy_UPDATE_NONE" value="<%=UPDATE_NONE%>" <%If intCanEditVacancy=UPDATE_NONE Then%>checked<%End If%>> <%=TXT_INST_UPDATE_VACANCY_OPT_1%></label>
	<br><label for="CanEditVacancy_UPDATE_ALL"><input type="radio" name="CanEditVacancy" id="CanEditVacancy_UPDATE_ALL" value="<%=UPDATE_ALL%>" <%If intCanEditVacancy=UPDATE_ALL Then%>checked<%End If%>> <%=TXT_INST_UPDATE_VACANCY_OPT_2%></label>
	<br><label for="CanEditVacancy_UPDATE_OWNED"><input type="radio" name="CanEditVacancy" id="CanEditVacancy_UPDATE_OWNED" value="<%=UPDATE_OWNED%>" <%If intCanEditVacancy=UPDATE_OWNED Then%>checked<%End If%>> <%=TXT_INST_UPDATE_VACANCY_OPT_3%></label>
	<%If Not Nl(strVacancyEditAgencies) Then%>
	<br><label for="CanEditVacancy_UPDATE_OWNED_LIST"><input type="radio" name="CanEditVacancy" id="CanEditVacancy_UPDATE_OWNED_LIST" value="<%=UPDATE_OWNED_LIST%>" <%If intCanEditVacancy=UPDATE_OWNED_LIST Then%>checked<%End If%>> <%=TXT_INST_UPDATE_VACANCY_OPT_4%></label>	
	<%' Must close this here to avoid having strVacancyEditAgencies open a table within a p tag %>	
	</p>
	<%=strVacancyEditAgencies%>
	<%Else%>
	<%' When the if is not run the p tag must close %>
	</p>
	<%End If%>

	<p>
	<%=TXT_INST_VIEW_TYPE_EDITORIAL_1%>
	<br><label for="VacancyEditByViewList_Default"><input type="radio" name="VacancyEditByViewList" id="VacancyEditByViewList_Default" value="" <%If Nl(bVacancyEditByViewList) Then%>checked<%End If%>> <%=TXT_DEFAULT_VIEW%></label>
	<br><label for="VacancyEditByViewList_AnyViewCanAccess"><input type="radio" name="VacancyEditByViewList" id="VacancyEditByViewList_AnyViewCanAccess" value="<%=SQL_FALSE%>" <%If Not Nl(bVacancyEditByViewList) And Not bVacancyEditByViewList Then%>checked<%End If%>> <%=TXT_ANY_VIEW_THE_USER_CAN_ACCESS%></label>
	<%If Not bNew And Not Nl(strEditViews) Then%>
	<br><label for="VacancyEditByViewList_SpecificViews"><input type="radio" name="VacancyEditByViewList" id="VacancyEditByViewList_SpecificViews" value="<%=SQL_TRUE%>" <%If bVacancyEditByViewList Then%>checked<%End If%>> <%=TXT_ANY_OF_THE_FOLLOWING%></label>
	<%' Must close this here to avoid the <ul> within a p tag %>	
	</p>
	<ul style="list-style-type:none">
	<li><label for="VacancyEditByViewType_<%=intCurrentViewType%>"><input type="checkbox" name="VacancyEditByViewType" id="VacancyEditByViewType_<%=intCurrentViewType%>" value="<%=intCurrentViewType%>" <%If bCurrentViewSelected Then%>checked<%End If%>>&nbsp;#<%=intCurrentViewType%> - <%=strCurrentViewName%></label></li>
	<%=strVacancyEditViews%>
	</ul>
	<%Else%>
	<%' When the if is not run the p tag must close %>
	</p>
	<%End If%>
	

	<p class="Alert"><%=TXT_INST_UPDATE_VACANCY_2%></p></td>
</tr>
<% End If %>


<% If intDomain = DM_VOL Or g_bUseCIC  Then %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_DO_BULK%></td>
	<td class="field-data-cell"><p><label for="CanDoBulkOps"><input type="checkbox" name="CanDoBulkOps" id="CanDoBulkOps" <%If bCanDoBulkOps Then%>checked<%End If%>> <%=TXT_INST_DO_BULK_1%></label></p>
	<p class="Alert"><%=TXT_INST_DO_BULK_2%></p></td>
</tr>
<% End If %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_DELETE%></td>
	<td class="field-data-cell"><p><label for="CanDeleteRecord"><input type="checkbox" name="CanDeleteRecord" id="CanDeleteRecord" <%If bCanDeleteRecord Then%>checked<%End If%>> <%=TXT_INST_DELETE_1%></label></p>
	<p class="Alert"><%=TXT_INST_DELETE_2%></p></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_SUPPRESS_EMAIL%></td>
	<td class="field-data-cell"><label for="SuppressNotifyEmail"><input type="checkbox" name="SuppressNotifyEmail" id="SuppressNotifyEmail" <%If bSuppressNotifyEmail Then%>checked<%End If%>> <%=TXT_INST_SUPPRESS_EMAIL_1%></label>
	<p><%=TXT_INST_SUPPRESS_EMAIL_2%></p><p class="Alert"><%=TXT_INST_SUPPRESS_EMAIL_3%></p></td>
</tr>
<% If intDomain = DM_VOL Or g_bUseCIC  Then %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_REQUEST_UPDATE%></td>
	<td class="field-data-cell"><p><label for="CanRequestUpdate"><input type="checkbox" name="CanRequestUpdate" id="CanRequestUpdate" <%If bCanRequestUpdate Then%>checked<%End If%>> <%=TXT_INST_REQUEST_UPDATE_1%></label></p>
	<p class="Alert"><%=TXT_INST_REQUEST_UPDATE_2%></p></td>
</tr>
<% End If %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_ASSIGN_FEEDBACK%></td>
	<td class="field-data-cell"><p><label for="CanAssignFeedback"><input type="checkbox" name="CanAssignFeedback" id="CanAssignFeedback" <%If bCanAssignFeedback Then%>checked<%End If%>> <%=TXT_INST_ASSIGN_FEEDBACK_1%></label></p>
	<p class="Alert"><%=TXT_INST_ASSIGN_FEEDBACK_2%></p></td>
</tr>
<%
If intDomain = DM_CIC And g_bUseCIC Then
%>
<tr>
	<td class="field-label-cell"><%=TXT_EXPORT_PERMISSIONS%></td>
	<td class="field-data-cell"><p><label for="ExportPermission_NONE"><input type="radio" name="ExportPermission" id="ExportPermission_NONE" value="<%=EXPORT_NONE%>" <%If intExportPermission=EXPORT_NONE Then%>checked<%End If%>> <%=TXT_INST_EXPORT_1%></label>
	<br><label for="ExportPermission_OWNED"><input type="radio" name="ExportPermission" id="ExportPermission_OWNED" value="<%=EXPORT_OWNED%>" <%If intExportPermission=EXPORT_OWNED Then%>checked<%End If%>> <%=TXT_INST_EXPORT_2%></label>
	<br><label for="ExportPermission_VIEW"><input type="radio" name="ExportPermission" id="ExportPermission_VIEW" value="<%=EXPORT_VIEW%>" <%If intExportPermission=EXPORT_VIEW Then%>checked<%End If%>> <%=TXT_INST_EXPORT_3%></label>
	<br><label for="ExportPermission_ALL"><input type="radio" name="ExportPermission" id="ExportPermission_ALL" value="<%=EXPORT_ALL%>" <%If intExportPermission=EXPORT_ALL Then%>checked<%End If%>> <%=TXT_INST_EXPORT_4%></label></p>
	<p class="Alert"><%=TXT_INST_EXPORT_5%></p></td>

</tr>
<tr>
	<td class="field-label-cell"><%=TXT_IMPORT_PERMISSIONS%></td>
	<td class="field-data-cell"><p><label for="ImportPermission"><input type="checkbox" name="ImportPermission" id="ImportPermission" <%If bImportPermission Then%>checked<%End If%>> <%=TXT_INST_IMPORT_1%></label></p>
	<p class="Alert"><%=TXT_INST_IMPORT_2%></p>
	</td>
</tr>
<%
Else
%>
<div style="display:none"><input type="hidden" name="ExportPermission" value="<%=intExportPermission%>"></div>
<%
End If
If Not Nl(strExternalAPIs) Then
If intDomain = DM_VOL Or g_bUseCIC  Then %>
<tr>
	<td class="field-label-cell"><%=TXT_EXTERNAL_APIS%></td>
	<td class="field-data-cell"><%= TXT_INST_EXTERNAL_API %> <br>
	<%= strExternalAPIs %>
	</td>
</tr>

<% End If
End If
%>
<%
If intDomain = DM_CIC Then
	If g_bUseCIC Then
%>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_UPDATE_PUBS%></td>
	<td class="field-data-cell"><label for="CanUpdatePubs_NONE"><input type="radio" name="CanUpdatePubs" id="CanUpdatePubs_NONE" value="<%=UPDATE_NONE%>" <%If intCanUpdatePubs=UPDATE_NONE Then%>checked<%End If%>> <%=TXT_INST_UPDATE_PUBS_1%></label>
	<br><label for="CanUpdatePubs_RECORD"><input type="radio" name="CanUpdatePubs" id="CanUpdatePubs_RECORD" value="<%=UPDATE_RECORD%>" <%If intCanUpdatePubs=UPDATE_RECORD Then%>checked<%End If%>> <%=TXT_INST_UPDATE_PUBS_2%></label>
	<br><label for="CanUpdatePubs_ALL"><input type="radio" name="CanUpdatePubs" id="CanUpdatePubs_ALL" value="<%=UPDATE_ALL%>" <%If intCanUpdatePubs=UPDATE_ALL Then%>checked<%End If%>> <%=TXT_INST_UPDATE_PUBS_3%></label>
	<p><%=TXT_INST_UPDATE_PUBS_4%></p><p class="Alert"><%=TXT_INST_UPDATE_PUBS_5%></p></td>
</tr>
<%
		If g_bUseTaxonomy Then
%>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_INDEX_TAXONOMY%></td>
	<td class="field-data-cell"><p><label for="CanIndexTaxonomy_NONE"><input type="radio" name="CanIndexTaxonomy" id="CanIndexTaxonomy_NONE" value="<%=UPDATE_NONE%>" <%If intCanIndexTaxonomy=UPDATE_NONE Then%>checked<%End If%>> <%=TXT_INST_INDEX_TAXONOMY_1%></label>
	<br><label for="CanIndexTaxonomy_OWNED"><input type="radio" name="CanIndexTaxonomy" id="CanIndexTaxonomy_OWNED" value="<%=UPDATE_OWNED%>" <%If intCanIndexTaxonomy=UPDATE_OWNED Then%>checked<%End If%>> <%=TXT_INST_INDEX_TAXONOMY_2%></label>
	<br><label for="CanIndexTaxonomy_ALL"><input type="radio" name="CanIndexTaxonomy" id="CanIndexTaxonomy_ALL" value="<%=UPDATE_ALL%>" <%If intCanIndexTaxonomy=UPDATE_ALL Then%>checked<%End If%>> <%=TXT_INST_INDEX_TAXONOMY_3%></label></p>
	<p class="Alert"><%=TXT_INST_INDEX_TAXONOMY_4%></p></td>
</tr>
<%
		Else
%>
<input type="hidden" name="CanIndexTaxonomy" value="<%=intCanIndexTaxonomy%>">
<%
		End If
	Else
%>
<input type="hidden" name="CanUpdatePubs" value="<%=intCanUpdatePubs%>">
<input type="hidden" name="CanIndexTaxonomy" value="<%=intCanIndexTaxonomy%>">
<%
	End If
End If
%>
<%If intDomain = DM_VOL Or g_bUseCIC  Then %>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_ADD_SQL%></td>
	<td class="field-data-cell"><p><label for="CanAddSQL"><input type="checkbox" name="CanAddSQL" id="CanAddSQL" <%If bCanAddSQL Then%>checked<%End If%>> <%=TXT_INST_ADD_SQL_1%></label></p>
	<p class="Alert"><%=TXT_INST_ADD_SQL_2%></p></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_VIEW_STATS%></td>
	<td class="field-data-cell"><label for="CanViewStatsN"><input type="radio" name="CanViewStats" id="CanViewStatsN" value="<%=STATS_NONE%>" <%If intCanViewStats=STATS_NONE Then%>checked<%End If%>> <%=TXT_INST_VIEW_STATS_1%></label>
	<br><label for="CanViewStatsV"><input type="radio" name="CanViewStats" id="CanViewStatsV" value="<%=STATS_VIEW%>" <%If intCanViewStats=STATS_VIEW Then%>checked<%End If%>> <%=TXT_INST_VIEW_STATS_2%></label>
	<br><label for="CanViewStatsA"><input type="radio" name="CanViewStats" id="CanViewStatsA" value="<%=STATS_ALL%>" <%If intCanViewStats=STATS_ALL Then%>checked<%End If%>> <%=TXT_INST_VIEW_STATS_3%></label>
	<p class="Alert"><%=TXT_INST_VIEW_STATS_4%></p></td>
</tr>
<%End If%>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_MANAGE_USERS%></td>
	<td class="field-data-cell"><p><label for="CanManageUsers"><input type="checkbox" name="CanManageUsers" id="CanManageUsers" <%If bCanManageUsers Then%>checked<%End If%>> <%=TXT_INST_MANAGE_USERS_1%></label></p>
	<p class="Alert"><%=TXT_INST_MANAGE_USERS_2%></p></td>
</tr>
<%
If intDomain = DM_VOL Then
%>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_MANAGE_MEMBERS%></td>
	<td class="field-data-cell"><label for="CanManageMembers"><input type="checkbox" name="CanManageMembers" id="CanManageMembers" <%If bCanManageMembers Then%>checked<%End If%>> <%=TXT_INST_MANAGE_MEMBERS_1%></label>
	<p class="Alert"><%=TXT_INST_MANAGE_MEMBERS_2%></p></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_MANAGE_REFERRALS%></td>
	<td class="field-data-cell"><label for="CanManageReferrals"><input type="checkbox" name="CanManageReferrals" id="CanManageReferrals" <%If bCanManageReferrals Then%>checked<%End If%>> <%=TXT_INST_MANAGE_REFERRALS_1%></label>
	<p class="Alert"><%=TXT_INST_MANAGE_REFERRALS_2%></p></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_CAN_ACCESS_PROFILES%></td>
	<td class="field-data-cell"><label for="CanAccessProfiles"><input type="checkbox" name="CanAccessProfiles" id="CanAccessProfiles" <%If bCanAccessProfiles Then%>checked<%End If%>> <%=TXT_INST_ACCESS_PROFILES_1%></label>
	<p><%=TXT_INST_ACCESS_PROFILES_2%></p>
	<p class="Alert"><%=TXT_INST_ACCESS_PROFILES_3%></p></td>
</tr>
<%
End If
%>
<tr>
	<td class="field-label-cell"><%=TXT_VIEW_FEEDBACK%></td>
	<td class="field-data-cell"><p><label for="FeedbackAlert"><input type="checkbox" name="FeedbackAlert" id="FeedbackAlert" <%If bFeedbackAlert Then%>checked<%End If%>> <%=TXT_INST_FEEDBACK_1%></label></p>
	<p class="Alert"><%=TXT_INST_FEEDBACK_2%></p></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_COMMENT_ALERT%></td>
	<td class="field-data-cell"><label for="CommentAlert"><input type="checkbox" name="CommentAlert" id="CommentAlert" <%If bCommentAlert Then%>checked<%End If%>> <%=TXT_INST_COMMENT%></label></td>
</tr>
<%If intDomain = DM_VOL Or g_bUseCIC  Then %>
<tr>
	<td class="field-label-cell"><%=TXT_WEB_DEVELOPER%></td>
	<td class="field-data-cell"><label for="WebDeveloper"><input type="checkbox" name="WebDeveloper" id="WebDeveloper" <%If bWebDeveloper Then%>checked<%End If%>> <%=TXT_INST_WEB_DEVELOPER_1%></label>
	<p><%=TXT_INST_WEB_DEVELOPER_2%></p></td>
</tr>
<%End If%>
<tr>
	<td class="field-label-cell"><%=TXT_SUPER_USER%></td>
	<td class="field-data-cell"><label for="SuperUser"><input type="checkbox" name="SuperUser<%=StringIf(Not g_bOtherMembersActive,"Global")%>" id="SuperUser" <%If bSuperUser Then%>checked<%End If%>> <%=TXT_INST_SUPER_USER_1%></label>
	<p><%=TXT_INST_SUPER_USER_2%></p>
	<% If g_bOtherMembersActive Then %>
	<p><%=TXT_INST_SUPER_USER_3%></p>
	<% End If %>
	</td>
</tr>
<% If user_bSuperUserGlobalDOM And g_bOtherMembersActive Then %>
<tr>
	<td class="field-label-cell"><%=TXT_SUPER_USER_GLOBAL%></td>
	<td class="field-data-cell"><label for="SuperUserGlobal"><input type="checkbox" name="SuperUserGlobal" id="SuperUserGlobal" <%If bSuperUserGlobal Then%>checked<%End If%>> <%=TXT_INST_SUPER_USER_GLOBAL_1%></label>
	<p><%=TXT_INST_SUPER_USER_GLOBAL_2%></p></td>
</tr>
<% End If %>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>"> <%If bOkDelete Then%><input type="submit" name="Submit" value="<%=TXT_DELETE%>"> <%End If%><input type="reset" value="<%=TXT_RESET_FORM%>"></td>
</tr>
</table>
</div>
</div>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
