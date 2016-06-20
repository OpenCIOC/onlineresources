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
<!--#include file="../../text/txtFormDataCheck.asp" -->
<!--#include file="../../text/txtGeneralForm.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<!--#include file="../../includes/validation/incFormDataCheck.asp" -->
<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
ElseIf Not vprofile_bLoggedIn Then
	Call goToPageB("login.asp")
End If

Dim bSQLError, _
	bValidationError, _
	strErrorList

bSQLError = False
bValidationError = False
strErrorList = vbNullString

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"


If Not bConfirmed Or Request.ServerVariables("REQUEST_METHOD") <> "POST" Then 
	Call makePageHeader(TXT_CONFIRM_DEACTIVATE_ACCOUNT, TXT_CONFIRM_DEACTIVATE_ACCOUNT, True, False, True, True)
	%>
	<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DEACTIVATE_ACCOUNT%></span></p>
	<form action="<%=ps_strThisPage%>" method="post">
	<%=g_strCacheFormVals%>
	<input type="hidden" name="Confirmed" value="on">
	<input type="submit" name="Submit" value="<%=TXT_DEACTIVATE%>">
	</form>
	<%
	Call makePageFooter(False)
Else
	Dim objReturn, objErrMsg
	Dim cmdDeactivateProfile, rsDeactivateProfile
	Set cmdDeactivateProfile = Server.CreateObject("ADODB.Command")
	With cmdDeactivateProfile
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandText = "sp_VOL_Profile_u_Deactivate"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, vprofile_strID)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsDeactivateProfile = cmdDeactivateProfile.Execute()
	If rsDeactivateProfile.State <> 0 Then
		rsDeactivateProfile.Close()
	End If

	If objReturn.Value <> 0 Then
		bSQLError = True
		strErrorList = Nz(objErrMsg.Value,TXT_UNKNOWN_ERROR_OCCURED)
	End If
	Set rsDeactivateProfile = Nothing
	Set cmdDeactivateProfile = Nothing


	Call makePageHeader(TXT_DEACTIVATE_ACCOUNT, TXT_DEACTIVATE_ACCOUNT, True, False, True, True)
	If Not Nl(strErrorList) Then
		Call handleError(strErrorList, vbNullString, vbNullString)
	Else
		Call clearVProfileCookies()
		Call handleMessage(TXT_SUCCESS_DEACTIVATE, vbNullString, vbNullString, False)
	End If
	Call makePageFooter(False)
End If

%>
<!--#include file="../../includes/core/incClose.asp" -->


