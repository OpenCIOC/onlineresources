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
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtExportProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
'On Error Resume Next

If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"export_profile.asp", vbNullString)
Else
	intProfileID = CLng(intProfileID)
End If

Dim intPBID
intPBID = Request("ExportPubID")

If Nl(intPBID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUBLICATION, _
		"export_profile_edit_pubs.asp", "ProfileID=" & intProfileID)
ElseIf Not IsIDType(intPBID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPBID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUBLICATION, _
		"export_profile_edit_pubs.asp", "ProfileID=" & intProfileID)
Else
	intProfileID = CLng(intProfileID)
End If

If Request("Submit") = TXT_DELETE Then

Dim objReturn, objErrMsg
Dim cmdDeletePublication, rsDeletePublication
Set cmdDeletePublication = Server.CreateObject("ADODB.Command")
With cmdDeletePublication
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ExportProfile_Pub_d"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@ExportPubID", adInteger, adParamInput, 4, intPBID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsDeletePublication = cmdDeletePublication.Execute

If objReturn.Value = 0 And Err.Number = 0 Then
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
			"export_profile_edit_pubs.asp", _
			"ProfileID=" & intProfileID, _
			False)
Else
	Dim strErrorMessage
	If Err.Number <> 0 Then
		strErrorMessage = Err.Description
	Else
		strErrorMessage = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & strErrorMessage, _
		"export_profile_edit_pubs.asp", _
		"ProfileID=" & intProfileID)
End If

Else

Dim bIncludeDescription, _
	bIncludeHeadings
	
bIncludeDescription = Request("IncludeDescription") = "on"
bIncludeHeadings = Request("IncludeHeadings") = "on"

Dim cmdProfilePubs, rsProfilePubs
Set cmdProfilePubs = Server.CreateObject("ADODB.Command")
With cmdProfilePubs
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdStoredProc
	.CommandText = "dbo.sp_CIC_ExportProfile_Pub_u"
	.Parameters.Append .CreateParameter("@ExportPubID", adInteger, adParamInput, 4, intPBID)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@IncludeDescription", adBoolean, adParamInput, 1, IIf(bIncludeDescription,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@IncludeHeadings", adBoolean, adParamInput, 1, IIf(bIncludeHeadings,SQL_TRUE,SQL_FALSE))
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
	.Execute
	.CommandTimeout = 0
End With

If Err.Number = 0 Then
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
		"export_profile_edit_pubs.asp", _
		"ProfileID=" & intProfileID, _
		False)
Else
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & Err.Description & ".", _
		"export_profile_edit_pubs.asp", _
		"ProfileID=" & intProfileID)
End If

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
