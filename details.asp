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
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
Dim bIsSEFriendlyURL, _
	bInlineResults

bInlineResults = Request("InlineResults")="on"

If Request.ServerVariables("HTTP_CIOC_FRIENDLY_RECORD_URL") = "on" And Not (bInlineResults) Then
	bIsSEFriendlyURL = True
Else
	bIsSEFriendlyURL = False
End If

' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtDetails.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtRecordPages.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/update/incAgencyUpdateInfo.asp" -->

<%	

'On Error Resume Next

Dim intRSN, _
	strNUM, _
	bNUMError
	
intRSN = Request("RSN")
strNUM = UCase(Trim(Request("NUM")))
bNUMError = False

If Nl(intRSN) Then
	Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	bNUMError = True
ElseIf Not IsIDType(intRSN) Then
	Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
	If Not IsNUMType(strNUM) Then
		Call handleError(TXT_INVALID_RSN & intRSN & ".", vbNullString, vbNullString)
	End If
	bNUMError = True
Else 
	intRSN = CLng(intRSN)
	Dim cmdGetNUM, rsGetNUM
	Set cmdGetNUM = Server.CreateObject("ADODB.Command")
	With cmdGetNUM
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandType = adCmdText
		.CommandText = "SELECT NUM FROM GBL_BaseTable bt WHERE bt.RSN=" & intRSN
		.CommandTimeout = 0
		Set rsGetNUM = .Execute
	End With
	If Not rsGetNUM.EOF Then
		strNUM = rsGetNUM("NUM")
		Response.Status = "301 Moved Permanently"
		Response.AddHeader "Location", makeDetailsLink(strNUM, vbNullString, vbNullString) 
		%><!--#include file="includes/core/incClose.asp" --><%
		Response.End
	Else
		Call makePageHeader(TXT_RECORD_DETAILS, TXT_RECORD_DETAILS, True, False, True, True)
		Call handleError(TXT_NO_RECORD_EXISTS_RSN & intRSN & ".", vbNullString, vbNullString)
		bNUMError = True
	End If
	intRSN = Null
End If

Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->
