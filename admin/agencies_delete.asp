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
' Purpose:		Delete existing agency
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
<% 'End Base includes %>
<!--#include file="../text/txtAgency.asp" -->
<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Dim intAgencyID
intAgencyID = Trim(Request("AgencyID"))

If Nl(intAgencyID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_AGENCY, _
		"agencies.asp", vbNullString)
ElseIf Not IsIDType(intAgencyID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intAgencyID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_AGENCY, _
		"agencies.asp", vbNullString)
Else
	intAgencyID = CLng(intAgencyID)

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

If Not bConfirmed Or Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
	Call makePageHeader(TXT_CONFIRM_DELETE_AGENCY, TXT_CONFIRM_DELETE_AGENCY, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="AgencyID" value="<%=intAgencyID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(False)

Else


Dim objReturn, objErrMsg
Dim cmdDeleteAgency, rsDeleteAgency
Set cmdDeleteAgency = Server.CreateObject("ADODB.Command")
With cmdDeleteAgency
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_Agency_d"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, IIf(user_bSuperUserGlobal, Null, g_intMemberID))
	.Parameters.Append .CreateParameter("@AgencyID", adInteger, adParamInput, 4, intAgencyID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsDeleteAgency = cmdDeleteAgency.Execute
Set rsDeleteAgency = rsDeleteAgency.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_AGENCY_DELETED, _
			"agencies.asp", _
			vbNullString, _
			False)
	Case Else
		Call handleError(TXT_AGENCY_NOT_DELETED & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"agencies_edit.asp", _
			"AgencyID=" & intAgencyID)
End Select

Set rsDeleteAgency = Nothing
Set cmdDeleteAgency = Nothing

End If

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
