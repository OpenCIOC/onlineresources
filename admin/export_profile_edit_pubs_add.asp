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
intPBID = Request("PBID")

If Nl(intPBID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUBLICATION, _
		"export_profile_edit_pubs.asp", "ProfileID=" & intProfileID)
ElseIf Not IsIDType(intPBID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPBID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PUBLICATION, _
		"export_profile_edit_pubs.asp", "ProfileID=" & intProfileID)
Else
	intPBID = CLng(intPBID)
End If

Dim objReturn, objErrMsg
Dim cmdAddPublication, rsAddPublication
Set cmdAddPublication = Server.CreateObject("ADODB.Command")
With cmdAddPublication
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ExportProfile_Pub_i"
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
	.Parameters.Append .CreateParameter("@PB_ID", adInteger, adParamInput, 4, intPBID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With

Set rsAddPublication = cmdAddPublication.Execute
Set rsAddPublication = rsAddPublication.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
			"export_profile_edit_pubs.asp", _
			"ProfileID=" & intProfileID, _
			False)
	Case Else
		Call makePageHeader(TXT_ADD_PUB_CODE_FAILED, TXT_ADD_PUB_CODE_FAILED, True, False, True, True)
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATE & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
		Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
		Call makePageFooter(False)
End Select
%>
<!--#include file="../includes/core/incClose.asp" -->
