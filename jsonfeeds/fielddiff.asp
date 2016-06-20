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
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtFieldHistory.asp" -->
<!--#include file="../text/txtFieldView.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->

<%
'Set response type headers
Response.ContentType = "application/json"
Response.CacheControl = "Private"
Response.Expires=-1

Call run_response_callbacks()
%>

<%
Sub PageContent()

Dim	strFieldName, _
	intDomain,_
	intRev, _
	intComp, _
	strText1, _
	strText2, _
	bCompare, _
	bNoData


bNoData = False
bCompare = True

intDomain = TrimAll(Request("DM"))
If IsIDType(intDomain) Then
	intDomain = CInt(intDomain)
Else
	intDomain = DM_CIC
End If

strFieldName = Trim(Request("FIELD"))
If Nl(strFieldName) Then
%>
{ fail: true, errinfo: <%=JSONQs(TXT_CANNOT_PRINT_FIELD_DATA & TXT_NO_FIELD_SELECTED, True)%> }
<%
	Exit Sub
End If

intRev = Request("REV")
If Not IsIDType(intRev) Then
%>
{ fail: true, errinfo: <%=JSONQs(TXT_INVALID_ID & Server.HTMLEncode(intRev), True)%> }
<%
	Exit Sub
End If

intComp = Request("COMP")
If Nl(intComp) Then
	intComp = Null
	bCompare = False
ElseIf Not IsIDType(intComp) Then
%>
{ fail: true, errinfo: <%=JSONQs(TXT_INVALID_ID & Server.HTMLEncode(intComp), True)%> }
<%
	Exit Sub
End If


	Dim cmdFieldContent, rsFieldContent, objHstIdParam
	Set cmdFieldContent = Server.CreateObject("ADODB.Command")
	With cmdFieldContent
		.ActiveConnection = getCurrentAdminCnn()
		If intDomain = DM_VOL Then
		.CommandText = "dbo.sp_VOL_Opportunity_History_s"
		Else
		.CommandText = "dbo.sp_GBL_BaseTable_History_s"
		End If

		.CommandType = adCmdStoredProc
		.CommandTimeout = 0

		Set objHstIdParam = .CreateParameter("@HST_ID", adInteger, adParamInput, 4, intRev)
		.Parameters.Append objHstIdParam
		.Parameters.Append .CreateParameter("@UserID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, IIf(intDomain=DM_VOL, g_intViewTypeVOL, g_intViewTypeCIC))
	End With

	Set rsFieldContent = cmdFieldContent.Execute 

	Dim bCanSeeHistory
	With rsFieldContent
		If Not .EOF Then
			bCanSeeHistory = .Fields("CAN_SEE_HISTORY")
		Else
			bCanSeeHistory = False
		End If
	End With

	If Not bCanSeeHistory Then
		rsFieldContent.Close()
		Set rsFieldContent = Nothing
		Set cmdFieldContent = Nothing
%>
{ fail: true, errinfo: <%=JSONQs(TXT_CANNOT_PRINT_FIELD_DATA & TXT_CANNOT_ACCESS_RECORD, True)%> }
<%
		Exit Sub
	End If

	Set rsFieldContent = rsFieldContent.NextRecordset

	strText1 = rsFieldContent("FieldDisplay")
	If Nl(strText1) Then
		strText1 = vbNullString
	End If

	rsFieldContent.Close
	Set rsFieldContent = Nothing

	If bCompare Then
		objHstIdParam.Value = intComp

		Set rsFieldContent = cmdFieldContent.Execute

		With rsFieldContent
			If Not .EOF Then
				bCanSeeHistory = .Fields("CAN_SEE_HISTORY")
			Else
				bCanSeeHistory = False
			End If
		End With

		If Not bCanSeeHistory Then
			rsFieldContent.Close()
			Set rsFieldContent = Nothing
			Set cmdFieldContent = Nothing
	%>
	{ fail: true, errinfo: <%=JSONQs(TXT_CANNOT_PRINT_FIELD_DATA & TXT_CANNOT_ACCESS_RECORD, True)%> }
	<%
			Exit Sub
		End If

		Set rsFieldContent = rsFieldContent.NextRecordset

		strText2 = rsFieldContent("FieldDisplay")
		If Nl(strText2) Then
			strText2 = vbNullString
		End If

		rsFieldContent.Close
		Set rsFieldContent = Nothing

	End If

	Set cmdFieldContent = Nothing

'No errors. Return inrequest to calling page.
%>
{ "fail": false, "compare": <%=IIf(bCompare, "true", "false") %>, 
<% If bCompare Then %>
	"text1": <%= JSONQs(strText1, True) %>, "text2": <%=JSONQs(strText2, True)%>
<% Else %>
	"text1": <%= JSONQs(textToHTML(strText1), True) %>
<% End If %>
} <%

End Sub

Call PageContent()
%>
<!--#include file="../includes/core/incClose.asp" -->
