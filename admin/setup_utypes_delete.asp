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
<% 'End Base includes %>
<!--#include file="../text/txtUsers.asp" -->
<%
Dim intDomain, _
	strStoredProcName

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not (user_bSuperUserCIC Or (Not g_bUseCIC And user_bSuperUserVOL)) Then
			Call securityFailure()
		End If
		strStoredProcName = "dbo.sp_CIC_SecurityLevel_d"
	Case DM_VOL
		If Not user_bSuperUserVOL And g_bUseVOL Then
			Call securityFailure()
		End If
		strStoredProcName = "dbo.sp_VOL_SecurityLevel_d"
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim intUserTypeID
intUserTypeID = Trim(Request("SLID"))

If Nl(intUserTypeID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_USER_TYPE, _
		"setup_utypes.asp", vbNullString)
ElseIf Not IsIDType(intUserTypeID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intUserTypeID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_USER_TYPE, _
		"setup_utypes.asp", vbNullString)
Else
	intUserTypeID = CLng(intUserTypeID)

Dim objReturn, objErrMsg
Dim cmdDeleteUserType, rsDeleteUserType
Set cmdDeleteUserType = Server.CreateObject("ADODB.Command")
With cmdDeleteUserType
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@SL_ID", adInteger, adParamInput, 4, intUserTypeID)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsDeleteUserType = cmdDeleteUserType.Execute
Set rsDeleteUserType = rsDeleteUserType.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_USER_TYPE_DELETED, _
			"setup_utypes.asp", _
			"DM=" & intDomain, _
			False)
	Case Else
		Call handleError(TXT_USER_TYPE_NOT_DELETED & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"setup_utypes_edit.asp", _
			"SLID=" & intUserTypeID & "&DM=" & intDomain)
End Select

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
