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
' Purpose: 		Process data from form to edit values for User Types from each module.
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
<!--#include file="../text/txtUsers.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<%
'Domain variables
Dim intDomain, _
	strStoredProcName, _
	user_bSuperUserGlobalDOM

'Retrieve current domain (module)
intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

'Ensure user has super user privileges for the given module
'Get stored procedure name for updating User Type data for this module
Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strStoredProcName = "dbo.sp_CIC_SecurityLevel_u"
		user_bSuperUserGlobalDOM = user_bSuperUserGlobalCIC
	Case DM_VOL
		If Not user_bSuperUserVOL And g_bUseVOL Then
			Call securityFailure()
		End If
		strStoredProcName = "dbo.sp_VOL_SecurityLevel_u"
		user_bSuperUserGlobalDOM = user_bSuperUserGlobalVOL
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

'Error variables
Dim strErrorMessage

'User Type Fields (all modules)
Dim	intSLID, _
	bOwner, _
	strSecurityLevel, _
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
	strEditAgencies, _
	strVacancyEditViews, _
	strVacancyEditAgencies, _
	strRecordTypes, _
	strDescriptions, _
	strCulture, _
	strAPIID, _
	strEditLangs, _
	objReturn, _
	objErrMsg

'If no User Type ID was given, this is a new User Type
'Otherwise, ensure ID is of a valid type.
Dim bNew
bNew = False

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

'If the User Type record is being deleted, redirect to the page for deleting a User Type
If Request("Submit") = TXT_DELETE Then
	Call goToPage("setup_utypes_delete.asp","SLID=" & intSLID & "&DM=" & intDomain,vbNullString)
End If

bOwner = IIf(Request("Owner") = "on",SQL_TRUE,SQL_FALSE)

strDescriptions = vbNullString
For Each strCulture In active_cultures()
	strSecurityLevel = Left(Trim(Request("SecurityLevel_" & strCulture)),100)
	If Not Nl(strSecurityLevel) Then
		strDescriptions = strDescriptions & _
			"<DESC><Culture>" & strCulture & "</Culture><SecurityLevel>" & _
			XMLEncode(strSecurityLevel) & "</SecurityLevel></DESC>"
	End If
Next
If Not Nl(strDescriptions) Then
	strDescriptions = "<DESCS>" & strDescriptions & "</DESCS>"
End If
strEditLangs = Request("EditLang")
If Nl(strEditLangs) Then
	strEditLangs = Null
End If

intViewType = Null
If Not Nl(Request("ViewType")) Then intViewType = Request("ViewType")

intViewTypeOffline = Null
If Not Nl(Request("ViewTypeOffline")) Then intViewTypeOffline = Request("ViewTypeOffline")

bCanAddRecord = CbToSQLBool("CanAddRecord")
bCanCopyRecord = CbToSQLBool("CanCopyRecord")

intCanEditRecord = Request("CanEditRecord")
If Nl(intCanEditRecord) Then
	intCanEditRecord = UPDATE_NONE
ElseIf Not IsPosTinyInt(intCanEditRecord) Then
	intCanEditRecord = UPDATE_NONE
End If

If intCanEditRecord = UPDATE_OWNED_LIST Then
	strEditAgencies = Trim(Request("EditAgency"))
Else
	strEditAgencies = Null
End If

bEditByViewList = Trim(Request("EditByViewList"))
Select Case bEditByViewList
	Case CStr(SQL_TRUE)
		bEditByViewList = SQL_TRUE
	Case CStr(SQL_FALSE)
		bEditByViewList = SQL_FALSE
	Case Else
		bEditByViewList = Null
End Select

strEditViews = Request("EditByViewType")
If Not IsIDList(strEditViews) Then
	strEditViews = Null
End If

intCanEditVacancy = Request("CanEditVacancy")
If Nl(intCanEditVacancy) Then
	intCanEditVacancy = UPDATE_NONE
ElseIf Not IsPosTinyInt(intCanEditVacancy) Then
	intCanEditVacancy = UPDATE_NONE
End If

If intCanEditVacancy = UPDATE_OWNED_LIST Then
	strVacancyEditAgencies = Trim(Request("VacancyEditAgency"))
Else
	strVacancyEditAgencies = Null
End If

bVacancyEditByViewList = Trim(Request("VacancyEditByViewList"))
Select Case bVacancyEditByViewList
	Case CStr(SQL_TRUE)
		bVacancyEditByViewList = SQL_TRUE
	Case CStr(SQL_FALSE)
		bVacancyEditByViewList = SQL_FALSE
	Case Else
		bVacancyEditByViewList = Null
End Select

strVacancyEditViews = Request("VacancyEditByViewType")
If Not IsIDList(strVacancyEditViews) Then
	strVacancyEditViews = Null
End If

bCanAddSQL = CbToSQLBool("CanAddSQL")
bCanAssignFeedback = CbToSQLBool("CanAssignFeedback")
bCanDeleteRecord = CbToSQLBool("CanDeleteRecord")
bCanDoBulkOps = CbToSQLBool("CanDoBulkOps")
bCanDoFullUpdate = CbToSQLBool("CanDoFullUpdate")
bCanManageUsers = CbToSQLBool("CanManageUsers")
bCanRequestUpdate = CbToSQLBool("CanRequestUpdate")
bSuppressNotifyEmail = CbToSQLBool("SuppressNotifyEmail")
bFeedbackAlert = CbToSQLBool("FeedbackAlert")
bCommentAlert = CbToSQLBool("CommentAlert")
bWebDeveloper = CbToSQLBool("WebDeveloper")
bSuperUser = CbToSQLBool("SuperUser")
If user_bSuperUserGlobalDOM Then
	bSuperUserGlobal = CbToSQLBool("SuperUserGlobal")
Else
	bSuperUserGlobal = Null
End If

intCanViewStats = Request("CanViewStats")
If Nl(intCanViewStats) Then
	intCanViewStats = UPDATE_NONE
End If

strAPIID = Request("APIID")
If Nl(strAPIID) Then
	strAPIID = Null
End If

'User Type variables (CIC only)
Dim	intCanIndexTaxonomy, _
	intCanUpdatePubs, _
	intExportPermission, _
	bImportPermission

intCanIndexTaxonomy = Request("CanIndexTaxonomy")
If Nl(intCanIndexTaxonomy) Then
	intCanIndexTaxonomy = UPDATE_NONE
End If

intCanUpdatePubs = Request("CanUpdatePubs")
If Nl(intCanUpdatePubs) Then
	intCanUpdatePubs = UPDATE_NONE
End If

intExportPermission = Request("ExportPermission")
If Nl(intExportPermission) Then
	intExportPermission = EXPORT_NONE
End If

bImportPermission = IIf(Not Nl(Request("ImportPermission")), SQL_TRUE, SQL_FALSE)

'User Type variables (Volunteer only)
Dim bCanAccessProfiles, _
	bCanManageMembers, _
	bCanManageReferrals

bCanAccessProfiles = CbToSQLBool("CanAccessProfiles")
bCanManageMembers = CbToSQLBool("CanManageMembers")
bCanManageReferrals = CbToSQLBool("CanManageReferrals")

strRecordTypes = Request("RTID")
If Not IsIDList(strRecordTypes) Then
	strRecordTypes = Null
End If

'Send the updated information to the selected procedure
Dim cmdUpdateUserType, rsUpdateUserType
Set cmdUpdateUserType = Server.CreateObject("ADODB.Command")
With cmdUpdateUserType
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	'Parameters for all modules
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@SL_ID", adInteger, adParamInputOutput, 4, intSLID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	.Parameters.Append .CreateParameter("@Owner", adBoolean, adParamInput, 1, bOwner)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
	.Parameters.Append .CreateParameter("@CanAddRecord", adBoolean, adParamInput, 1, bCanAddRecord)
	.Parameters.Append .CreateParameter("@CanAddSQL", adBoolean, adParamInput, 1, bCanAddSQL)
	.Parameters.Append .CreateParameter("@CanAssignFeedback", adBoolean, adParamInput, 1, bCanAssignFeedback)
	.Parameters.Append .CreateParameter("@CanCopyRecord", adBoolean, adParamInput, 1, bCanCopyRecord)
	.Parameters.Append .CreateParameter("@CanDeleteRecord", adBoolean, adParamInput, 1, bCanDeleteRecord)
	.Parameters.Append .CreateParameter("@CanDoBulkOps", adBoolean, adParamInput, 1, bCanDoBulkOps)
	.Parameters.Append .CreateParameter("@CanDoFullUpdate", adBoolean, adParamInput, 1, bCanDoFullUpdate)
	.Parameters.Append .CreateParameter("@CanEditRecord", adInteger, adParamInput, 1, intCanEditRecord)
	.Parameters.Append .CreateParameter("@CanManageUsers", adBoolean, adParamInput, 1, bCanManageUsers)
	.Parameters.Append .CreateParameter("@CanRequestUpdate", adBoolean, adParamInput, 1, bCanRequestUpdate)
	.Parameters.Append .CreateParameter("@CanViewStats", adInteger, adParamInput, 4, intCanViewStats)
	'CIC parameters
	If intDomain = DM_CIC Then
		.Parameters.Append .CreateParameter("@CanIndexTaxonomy", adInteger, adParamInput, 1, intCanIndexTaxonomy)
		.Parameters.Append .CreateParameter("@CanUpdatePubs", adInteger, adParamInput, 1, intCanUpdatePubs)
		.Parameters.Append .CreateParameter("@ExportPermission", adInteger, adParamInput, 4, intExportPermission)
		.Parameters.Append .CreateParameter("@ImportPermission", adBoolean, adParamInput, 1, bImportPermission)
		.Parameters.Append .CreateParameter("@RecordTypes", adLongVarChar, adParamInput, -1, strRecordTypes)
		.Parameters.Append .CreateParameter("@ViewTypeOffline", adInteger, adParamInput, 4, intViewTypeOffline)
		.Parameters.Append .CreateParameter("@CanEditVacancy", adInteger, adParamInput, 1, intCanEditVacancy)
		.Parameters.Append .CreateParameter("@VacancyEditByViewList", adBoolean, adParamInput, 1, bVacancyEditByViewList)
		.Parameters.Append .CreateParameter("@VacancyEditByViewType", adLongVarChar, adParamInput, -1, strVacancyEditViews)
		.Parameters.Append .CreateParameter("@VacancyEditAgencies", adLongVarChar, adParamInput, -1, strVacancyEditAgencies)
	End If
	'Volunteer parameters
	If intDomain = DM_VOL Then
		.Parameters.Append .CreateParameter("@CanAccessProfiles", adBoolean, adParamInput, 1, bCanAccessProfiles)
		.Parameters.Append .CreateParameter("@CanManageMembers", adBoolean, adParamInput, 1, bCanManageMembers)
		.Parameters.Append .CreateParameter("@CanManageReferrals", adBoolean, adParamInput, 1, bCanManageReferrals)
	End If
	'Parameters for all modules
	.Parameters.Append .CreateParameter("@EditByViewList", adBoolean, adParamInput, 1, bEditByViewList)
	.Parameters.Append .CreateParameter("@EditByViewType", adLongVarChar, adParamInput, -1, strEditViews)
	.Parameters.Append .CreateParameter("@EditAgencies", adLongVarChar, adParamInput, -1, strEditAgencies)
	.Parameters.Append .CreateParameter("@EditLangs", adLongVarChar, adParamInput, -1, strEditLangs)
	.Parameters.Append .CreateParameter("@APIIDs", adVarChar, adParamInput, -1, strAPIID)
	.Parameters.Append .CreateParameter("@SuppressNotifyEmail", adBoolean, adParamInput, 1, bSuppressNotifyEmail)
	.Parameters.Append .CreateParameter("@FeedbackAlert", adBoolean, adParamInput, 1, bFeedbackAlert)
	.Parameters.Append .CreateParameter("@CommentAlert", adBoolean, adParamInput, 1, bCommentAlert)
	.Parameters.Append .CreateParameter("@WebDeveloper", adBoolean, adParamInput, 1, bWebDeveloper)
	.Parameters.Append .CreateParameter("@SuperUser", adBoolean, adParamInput, 1, bSuperUser)
	.Parameters.Append .CreateParameter("@SuperUserGlobal", adBoolean, adParamInput, 1, bSuperUserGlobal)
	.Parameters.Append .CreateParameter("@Descriptions", adVarWChar, adParamInput, -1, strDescriptions)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsUpdateUserType = cmdUpdateUserType.Execute
Set rsUpdateUserType = rsUpdateUserType.NextRecordset

'If there was no error from running the stored procedure, return to the User Type Edit page;
'Otherwise, grab the error message if any so it can be printed to the user.
If objReturn.Value = 0 And Err.Number = 0 Then
	If bNew Then
		intSLID = cmdUpdateUserType.Parameters("@SL_ID").Value
	End If
	Call handleMessage(TXT_USER_TYPE_UPDATED, _
			"setup_utypes_edit.asp", _
			"SLID=" & intSLID & "&DM=" & intDomain, _
			False)
Else
	If Err.Number <> 0 Then
		strErrorMessage = Err.Description
	Else
		strErrorMessage = objErrMsg.Value
	End If
	Call makePageHeader(TXT_UPDATE_USER_TYPE_FAILED, TXT_UPDATE_USER_TYPE_FAILED, True, False, True, True)
	Call handleError(TXT_USER_TYPE_NOT_UPDATED & strErrorMessage, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
