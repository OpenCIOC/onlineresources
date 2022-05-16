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
<!--#include file="../../includes/core/adovbs.inc" -->
<!--#include file="../../includes/core/incVBUtils.asp" -->
<!--#include file="../../includes/validation/incBasicTypes.asp" -->
<!--#include file="../../includes/core/incRExpFuncs.asp" -->
<!--#include file="../../includes/core/incHandleError.asp" -->
<!--#include file="../../includes/core/incSetLanguage.asp" -->
<!--#include file="../../includes/core/incPassVars.asp" -->
<!--#include file="../../text/txtGeneral.asp" -->
<!--#include file="../../text/txtError.asp" -->
<!--#include file="../../includes/core/incConnection.asp" -->
<!--#include file="../../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", vbNullString)
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../text/txtReferral.asp" -->
<!--#include file="../../text/txtUsers.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->

<% 
If Not g_bUseVolunteerProfiles Then
	'TODO should we positively confirm that they won't get emails?
	Call goToPageB(ps_strPathToStart & "volunteer/")
End If

Call makePageHeader(TXT_VOL_PROFILE_UNSUBSCRIBE, TXT_VOL_PROFILE_UNSUBSCRIBE, True, False, True, True)
Dim strEmail, _
	strUnsubscribeToken, _
	bConfirmed

strEmail = Left(Ns(Trim(Request("email"))), 60)
strUnsubscribeToken = Left(Ns(Trim(Request("token"))), 36)

Sub SomethingWentWrong()
	Call handleError(Replace(TXT_UNSUBSCRIBE_SOMETHING_WENT_WRONG, "[LOGIN_URL]", makeLinkB("login.asp")),vbNullString, vbNullString)
	Call makePageFooter(True)
	%><!--#include file="../../includes/core/incClose.asp" --><%
    Response.End()
End Sub
If Nl(strEmail) or Nl(strUnsubscribeToken) Then
	Call SomethingWentWrong()
End If

bConfirmed = Request("Confirmed") = "on"

If Not bConfirmed Or Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
%>
<p class="InfoBubble max-width-sm"><%=Replace(Replace(TXT_INST_UNSUBSCRIBE,"[LOGIN_URL]", makeLinkB("login.asp")), "[EMAIL]", Server.HTMLEncode(strEmail))%></p>

<div class="max-width-sm">
<form action="unsubscribe.asp" method="post" name="EntryForm" role="form" class="form-horizontal">
	<%=g_strCacheFormVals%>
	<div style="display:none">
	<input type="hidden" name="email" value=<%=AttrQs(Server.HTMLEncode(strEmail))%>>
	<input type="hidden" name="token" value=<%=AttrQs(Server.HTMLEncode(strUnsubscribeToken))%>>
	<input type="hidden" name="Confirmed" value="on">
	</div>
	<div class="form-group">
		<div class="col-sm-offset-2 col-sm-10">
			<input type="submit" class="btn btn-default" value="<%=TXT_UNSUBSCRIBE_ME%>">
		</div>
	</div>
</form>
</div>
<%
Else
	Dim objReturn, objErrMsg
	Dim cmdProfileInfo, rsProfileInfo
	Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
	With cmdProfileInfo
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_Profile_u_Unsubscribe"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Email", adVarChar, adParamInput, 60, strEmail)
		.Parameters.Append .CreateParameter("@UnsubscribeToken", adVarChar, adParamInput, 36, strUnsubscribeToken)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsProfileInfo = cmdProfileInfo.Execute()
	If rsProfileInfo.State <> 0 Then
		rsProfileInfo.Close()
	End If

	If objReturn.Value <> 0 Then
		Call SomethingWentWrong()
	End If
	Set rsProfileInfo = Nothing
	Set cmdProfileInfo = Nothing
	
	Call handleMessage(TXT_UNSUBSCRIBE_SUCCESSFUL,vbNullString, vbNullString, False)
End If

Call makePageFooter(True)
%>
<!--#include file="../../includes/core/incClose.asp" -->
