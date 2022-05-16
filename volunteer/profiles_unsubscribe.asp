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
Call setPageInfo(True, DM_VOL, DM_VOL, "../", "volunteer/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../text/txtVOLProfile.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not (user_bCanAccessProfiles And g_bUseVolunteerProfiles) Then
	Call securityFailure()
End If

Dim bError
bError = False

Dim strProfileID
strProfileID = Left(Trim(Request("ProfileID")),38)

If Not IsGUIDType(strProfileID) Then
	strProfileID = Null
End If

If Nl(strProfileID) Then
	Call handleError(TXT_NO_VOL_PROFILE_EMAIL, "profiles.asp", vbNullString)
End If

If LCase(Request.ServerVariables("REQUEST_METHOD")) <> "post" Then 
	Call goToPage("profiles_details.asp", "ProfileID=" & strProfileID, vbNullString)
End If


Dim objReturn, objErrMsg
Dim cmdProfileInfo, rsProfileInfo
Set cmdProfileInfo = Server.CreateObject("ADODB.Command")
With cmdProfileInfo
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "sp_VOL_Profile_u_Unsubscribe_Staff"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ProfileID", adGUID, adParamInput, 16, strProfileID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsProfileInfo = Server.CreateObject("ADODB.Recordset")
With rsProfileInfo
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdProfileInfo
End With

If objReturn.Value <> 0 Then
	Call handleError(TXT_ERROR & cmdProfileInfo.Parameters("@ErrMsg"), "profiles_details.asp", "ProfileID=" & strProfileID)
Else 
	Call handleMessage(TXT_PROFILE_WAS & " " & TXT_UNSUBSCRIBED, "profiles_details.asp", "ProfileID=" & strProfileID, False)
End If

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
