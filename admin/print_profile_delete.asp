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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<%
Dim intDomain, _
	strType

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

If Not bConfirmed Then
	Call makePageHeader(TXT_CONFIRM_DELETE_PROFILE, TXT_CONFIRM_DELETE_PROFILE, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(False)
Else

Dim objReturn, objErrMsg
Dim cmdDeleteProfile, rsDeleteProfile
Set cmdDeleteProfile = Server.CreateObject("ADODB.Command")
With cmdDeleteProfile
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PrintProfile_d"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsDeleteProfile = cmdDeleteProfile.Execute
Set rsDeleteProfile = rsDeleteProfile.NextRecordset

If objReturn.Value = 0 And Err.Number = 0 Then
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
		"print_profile.asp", _
		"DM=" & intDomain, _
		False)
Else
	Dim strError
	If Err.Number <> 0 Then
		strError = Err.Description
	Else
		strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & strError, _
		"print_profile_edit.asp", _
		"ProfileID=" & cmdDeleteProfile.Parameters("@ProfileID") & "&DM=" & intDomain)
End If

End If

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
