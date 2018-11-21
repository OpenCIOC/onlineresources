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
<!--#include file="../text/txtPageMsg.asp" -->
<!--#include file="../includes/validation/incDisplayOrder.asp" -->
<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Dim bNew
bNew = False

Dim strError

Dim	intPageMsgID, _
	strMsgTitle, _
	intLangID, _
	bVisiblePrintMode, _
	bLoginOnly, _
	strPageMsg, _
	strCICViewList, _
	strVOLViewList, _
	strPageList

intPageMsgID = Trim(Request("PageMsgID"))
If Nl(intPageMsgID) Then
	bNew = True
	intPageMsgID = Null
ElseIf Not IsIDType(intPageMsgID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPageMsgID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_MESSAGE, _
		"setup_page_msg.asp", vbNullString)
Else
	intPageMsgID = CLng(intPageMsgID)
End If

Call getDisplayOrder()

If Request("Submit") = TXT_DELETE Then
	Call goToPage("setup_page_msg_delete.asp","PageMsgID=" & intPageMsgID,vbNullString)
End If

strMsgTitle = Request("MsgTitle")
If Nl(strMsgTitle) Then
	strMsgTitle = Null
End If

intLangID = Trim(Request("LangID"))
If Nl(intLangID) Then
	intLangID = Null
	strError = TXT_ERR_MESSAGE_LANGUAGE
ElseIf Not IsNumeric(intLangID) Then
	strError = TXT_ERR_MESSAGE_LANGUAGE & " " & TXT_INVALID_ID & Server.HTMLEncode(intLangID) & "."
ElseIf Not intLangID >= 0 And intLangID <= MAX_SMALL_INT Then
	strError = TXT_ERR_MESSAGE_LANGUAGE & " " & TXT_INVALID_ID & Server.HTMLEncode(intLangID) & "."
Else
	intLangID = CLng(intLangID)
End If

bVisiblePrintMode = Request("VisiblePrintMode")="on"
bLoginOnly = Request("LoginOnly")="on"

strPageMsg = Trim(Request("PageMsg"))
If Len(strPageMsg) > 4000 Then
	strError = TXT_ERR_PAGE_MESSAGE
End If
If Nl(strPageMsg) Then
	strPageMsg = Null
End If

strCICViewList = Request("CICViewType")
If Nl(strCICViewList) Then
	strCICViewList = vbNullString
ElseIf Not IsIDList(strCICViewList) Then
	strError = TXT_ERR_VIEW_LIST
	strCICViewList = vbNullString
End If

strVOLViewList = Request("VOLViewType")
If Nl(strVOLViewList) Then
	strVOLViewList = vbNullString
ElseIf Not IsIDList(strVOLViewList) Then
	strError = TXT_ERR_VIEW_LIST
	strVOLViewList = vbNullString
End If

strPageList = Request("PageName")
If Nl(strPageList) Then
	strPageList = vbNullString
ElseIf Not IsStringList(strPageList) Then
	strError = TXT_ERR_PAGE_LIST
	strPageList = vbNullString
End If

If Nl(strError) Then
	Dim objReturn, objErrMsg
	Dim cmdPageInfo, rsPageInfo
	Set cmdPageInfo = Server.CreateObject("ADODB.Command")
	With cmdPageInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_GBL_PageMsg_u"
		.CommandTimeout = 0
		.Prepared = False
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@PageMsgID", adInteger, adParamInputOutput, 4, intPageMsgID)
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
		.Parameters.Append .CreateParameter("@UseCIC", adBoolean, adParamInput, 1, IIf(user_bSuperUserCIC,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@UseVOL", adBoolean, adParamInput, 1, IIf(user_bSuperUserVOL,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@MsgTitle", adVarWChar, adParamInput, 50, strMsgTitle)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 4, intLangID)
		.Parameters.Append .CreateParameter("@VisiblePrintMode", adBoolean, adParamInput, 1, IIf(bVisiblePrintMode, SQL_TRUE, SQL_FALSE))
		.Parameters.Append .CreateParameter("@LoginOnly", adBoolean, adParamInput, 1, IIf(bLoginOnly, SQL_TRUE, SQL_FALSE))
		.Parameters.Append .CreateParameter("@DisplayOrder", adInteger, adParamInput, 1, intDisplayOrder)
		.Parameters.Append .CreateParameter("@PageMsg", adVarWChar, adParamInput, 4000, strPageMsg)
		.Parameters.Append .CreateParameter("@CICViewList", adLongVarChar, adParamInput, -1, strCICViewList)
		.Parameters.Append .CreateParameter("@VOLViewList", adLongVarChar, adParamInput, -1, strVOLViewList)
		.Parameters.Append .CreateParameter("@PageList", adLongVarChar, adParamInput, -1, strPageList)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsPageInfo = cmdPageInfo.Execute
	Set rsPageInfo = rsPageInfo.NextRecordset
		
	Select Case objReturn.Value
		Case 0
			If Nl(intPageMsgID) Then
				intPageMsgID = cmdPageInfo.Parameters("@PageMsgID")
			End If
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
				"setup_page_msg_edit.asp", _
				"PageMsgID=" & intPageMsgID, _
				False)
		Case Else
			strError = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End Select
	
	Set rsPageInfo = Nothing
	Set cmdPageInfo = Nothing
End If

If Not Nl(strError) Then
	Call makePageHeader(TXT_UPDATE_MESSAGE_FAILED, TXT_UPDATE_MESSAGE_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strError, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->

