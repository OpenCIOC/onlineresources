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
' Purpose:		Deletes page information
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
' setPageMsg(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtPageMsg.asp" -->
<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

Dim intPageMsgID
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

If Not bConfirmed Then
	Call makePageHeader(TXT_DELETE_MESSAGE, TXT_DELETE_MESSAGE, True, False, True, True)
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE_DELETE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="PageMsgID" value="<%=intPageMsgID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(False)
Else

Dim objReturn, objErrMsg
Dim cmdDeletePageMsg, rsInsertPageMsg
Set cmdDeletePageMsg = Server.CreateObject("ADODB.Command")
With cmdDeletePageMsg
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PageMsg_d"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@PageMsgID", adInteger, adParamInput, 4, intPageMsgID)
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
End With
Set rsInsertPageMsg = cmdDeletePageMsg.Execute
Set rsInsertPageMsg = rsInsertPageMsg.NextRecordset

Select Case objReturn.Value
	Case 0
		Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
			"setup_page_msg.asp", _
			vbNullString, _
			False)
	Case Else
		Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			"setup_page_msg_edit.asp", _
			"PageMsgID=" & intPageMsgID)
End Select

End If
%>
<!--#include file="../includes/core/incClose.asp" -->
