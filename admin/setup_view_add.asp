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
<!--#include file="../text/txtView.asp" -->
<%
Dim intDomain, _
	strType, _
	strStoredProcName

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Or (Not g_bUseCIC And user_bSuperUserVOL) Then
			Call securityFailure()
		End If
		strType = TXT_CIC
		strStoredProcName = "dbo.sp_CIC_View_i"
	Case DM_VOL
		If Not user_bSuperUserVOL And g_bUseVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
		strStoredProcName = "dbo.sp_VOL_View_i"
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim strViewName, _
	intViewType
	
intViewType = Request("ViewType")

If Nl(intViewType) Then
	intViewType = Null
ElseIf Not IsIDType(intViewType) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intViewType) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_VIEW, _
		"view", "DM=" & intDomain)
Else
	intViewType = CLng(intViewType)
End If

strViewName = Left(Trim(Request("ViewName")),100)

If Nl(strViewName) Then
	Call handleError(TXT_SPECIFY_VIEW_NAME, _
		"view", "DM=" & intDomain)
End If

Dim objReturn, objErrMsg
Dim cmdInsertView, rsInsertView
Set cmdInsertView = Server.CreateObject("ADODB.Command")
With cmdInsertView
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@ViewName", adVarChar, adParamInput, 100, strViewName)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInputOutput, 4, intViewType)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsInsertView = cmdInsertView.Execute
Set rsInsertView = rsInsertView.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_VIEW_ADDED, _
			"view/edit", _
			"ViewType=" & cmdInsertView.Parameters("@ViewType") & "&DM=" & intDomain, _
			False)
	Case Else
		Call handleError(TXT_VIEW_NOT_ADDED & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"view", _
			"DM=" & intDomain)
End Select
%>
<!--#include file="../includes/core/incClose.asp" -->
