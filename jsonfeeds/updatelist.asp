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
' Purpose:		Add a num to the saved list	
'
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
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_GLOBAL, DM_GLOBAL, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtClientTracker.asp" -->
<!--#include file="../includes/search/incMyList.asp" -->
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
If Not Nl(Request("SessionTest")) Then

	%>
{ "has_session": <%= IIf(getSessionValue("session_test") = "ok", "true", "false") %> }
	<%
	Exit Sub
End If

Dim strID, strRemove, strDomain
strID = Request("ID")

strRemove = Request("RemoveItem")

If Nl(strID) Then
%>
{ "fail": true, "errinfo": <%=JSONQs(TXT_NO_RECORD_CHOSEN, True)%> }
<%
	Exit Sub

ElseIf Not (IsNUMType(strID) Or IsVNUMType(strID) Or (Not Nl(strRemove) And strID = "all")) Then
%>
{ "fail": true, "errinfo": <%=JSONQs(TXT_INVALID_ID & Server.HTMLEncode(strID) & ".", True)%> }
<%
	Exit Sub

End If
If Not Nl(strRemove) Then
	strDomain = strRemove
ElseIf IsNUMType(strID) Then
	strDomain = "CIC"
Else
	strDomain = "VOL"
End If

Dim aRecordList,intUBound, aTmp

aRecordList = getSessionValue(strDomain & "RecordList")
If Not Nl(aRecordList) Then
	aRecordList = Split(aRecordList, ",")
End If
If Nl(strRemove) Then ' Add
	If Not IsArray(aRecordList) Then
		aRecordList = Array(strID)
	Else
		aTmp = Filter(aRecordList, strID)
		If UBound(aTmp) < 0 Then
			intUBound = UBound(aRecordList) + 1
			ReDim Preserve aRecordList(intUBound)
			aRecordList(intUBound) = strID
		End If
	End If
ElseIf strID = "all" Then ' remove all
	aRecordList = Array()
Else ' remove one
	If IsArray(aRecordList) Then
		aRecordList = Filter(aRecordList, strID, False)
	Else
		aRecordList = Array()
	End If
End If

Call setSessionValue(strDomain & "RecordList", Join(aRecordList,","))

'No errors. Return Success to calling page.
%>
{ "fail": false, "count": <%= UBound(aRecordList) + 1 %> }
<%

End Sub

Call PageContent()
%>

<!--#include file="../includes/core/incClose.asp" -->
