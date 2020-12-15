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
<!--#include file="../text/txtDisplayOrder.asp" -->
<!--#include file="../text/txtView.asp" -->
<!--#include file="../includes/validation/incDisplayOrder.asp" -->
<%
'On Error Resume Next

If Not user_bSuperUserCIC Or (Not g_bUseCIC And user_bSuperUserVOL) Then
	Call securityFailure()
End If

Dim strError

Const ACTION_UPDATE = 1
Const ACTION_DELETE = 2
Const ACTION_ADD = 3

Dim intViewType
intViewType = Trim(Request("ViewType"))

Dim intActionType, _
	strActionType, _
	bConfirmed, _
	intCMID, _
	strNewCommunity

If Nl(intViewType) Then
	Call handleError(TXT_COMM_WAS_NOT & TXT_UPDATED & TXT_COLON & TXT_NO_RECORD_CHOSEN, _
		"setup_view_edit_comms.asp", vbNullString)
ElseIf Not IsIDType(intViewType) Then
	Call handleError(TXT_COMM_WAS_NOT & TXT_UPDATED & TXT_COLON & TXT_INVALID_ID & Server.HTMLEncode(intViewType) & ".", _
		"setup_view_edit_comms.asp", vbNullString)
Else
	intViewType = CLng(intViewType)
End If

Select Case Request("Submit")
	Case TXT_UPDATE
		intActionType = ACTION_UPDATE
		strActionType = TXT_UPDATED
	Case TXT_DELETE
		bConfirmed = Request("Confirmed") = "on"
		intActionType = ACTION_DELETE
		strActionType = TXT_DELETED
	Case TXT_ADD
		intActionType = ACTION_ADD
		strActionType = TXT_ADDED
	Case Else
		Call handleError(TXT_NO_ACTION, _
			"setup_view_edit_comms.asp", _
			"ViewType=" & intViewtype)
End Select

If intActionType <> ACTION_ADD Then
	intCMID = Trim(Request("CMID"))
	strNewCommunity = Null
Else
	intCMID = Trim(Request("AddCommunityID"))
	strNewCommunity = Left(Trim(Request("AddCommunity")),200)
	If Nl(intCMID) Then
		intCMID = Null
	End If
End IF

If intActionType <> ACTION_DELETE Then
	getDisplayOrder()
End If
If Not Nl(strError) Then
	Call handleError(TXT_COMM_WAS_NOT & TXT_UPDATED & TXT_COLON & Server.HTMLEncode(strError) & ".", _
		"setup_view_edit_comms.asp", "ViewType=" & intViewType)
End If

Dim objReturn, objErrMsg
Dim cmdViewComms, rsViewComms
Set cmdViewComms = Server.CreateObject("ADODB.Command")
With cmdViewComms
	.ActiveConnection = getCurrentAdminCnn()
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
	.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	.Parameters.Append .CreateParameter("@CM_ID", adInteger, adParamInput, 4, intCMID)
	If Nl(strError) Then
		Select Case intActionType
			Case ACTION_DELETE
				.CommandText = "dbo.sp_CIC_View_Community_d"
			Case Else
				.Parameters.Append .CreateParameter("@Community", adVarChar, adParamInput, 200, strNewCommunity)
				.Parameters.Append .CreateParameter("@DisplayOrder", adInteger, adParamInput, 4, intDisplayOrder)
				.Parameters.Append .CreateParameter("@IsNew", adBoolean, adParamInput, 1, IIf(intActionType = ACTION_ADD, SQL_TRUE, SQL_FALSE))
				.CommandText = "dbo.sp_CIC_View_Community_u"
		End Select
	End If
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With

Set rsViewComms = cmdViewComms.Execute
Set rsViewComms = rsViewComms.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_COMM_SUCCESSFULLY & strActionType, _
			"setup_view_edit_comms.asp", _
			"ViewType=" & intViewType, _
			False)
	Case Else
		Call handleError(TXT_COMM_WAS_NOT & strActionType & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"setup_view_edit_comms.asp", _
			"ViewType=" & intViewType)
End Select
%>
<!--#include file="../includes/core/incClose.asp" -->
