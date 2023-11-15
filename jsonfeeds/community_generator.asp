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
Call setPageInfo(False, DM_GLOBAL, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtSearchBasic.asp" -->
<%
Response.ContentType = "application/json"
Response.CacheControl = "private"
Call Response.AddHeader("Access-Control-Allow-Origin", "*")

Call run_response_callbacks()

Dim strSearch, intCMID
strSearch = Left(Trim(Request("term")), 100)

intCMID = Trim(Request("CMID"))
If Nl(intCMID) Then
	intCMID = Null
ElseIf IsIDType(intCMID) Then
	intCMID = CInt(intCMID)
Else
	Response.Status = "400 Invalid parameter CMID"
	Response.Write("[]")
%>
	<!--#include file="../includes/core/incClose.asp" -->
<%
	Response.End()
End If



Dim cmdCommFinder, rsCommFinder
Set cmdCommFinder = Server.CreateObject("ADODB.Command")
With cmdCommFinder
	.ActiveConnection = getCurrentCICBasicCnn()
	If Not Nl(strSearch) Then
		.CommandText = "dbo.sp_GBL_Community_ls"
		.Parameters.Append .CreateParameter("@searchStr", adVarChar, adParamInput, 100, strSearch)
	ElseIf Not Nl(intCMID) Then
		.CommandText = "dbo.sp_GBL_Community_l_Children"
		.Parameters.Append .CreateParameter("@CMID", adInteger, adParamInput, 4, intCMID)
	Else
		.CommandText = "sp_CIC_View_Community_l"
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End If
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0

End With
Set rsCommFinder = Server.CreateObject("ADODB.Recordset")
With rsCommFinder
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdCommFinder
	Dim strJSONCon
	strJSONCon = vbNullString

	Dim fldCommunity, _
		fldDisplay, _
		fldParent

	If Nl(strSearch) Then
		Set fldCommunity = .Fields("Community")
		Set fldDisplay = .Fields("Community")
		fldParent = Null
	Else
		Set fldCommunity = .Fields("Community")
		Set fldDisplay = .Fields("Display")
		Set fldParent = .Fields("ParentCommunityName")
	End If

	Response.Write("[")
	While Not .EOF
		Response.Write(strJSONCon & "{""chkid"":" & JSONQs(.Fields("CM_ID"), True) & _
				",""value"":" & JSONQs(fldCommunity, True) & _
				",""label"":" & JSONQs(fldDisplay & _
					StringIf(Not Nl(fldParent), _
						" (" & TXT_IN & " " & fldParent & ")"), True) & _
				"}")
		strJSONCon = ","
		.MoveNext
	Wend
	Response.Write("]")
	.Close
End With

Set rsCommFinder = Nothing
Set cmdCommFinder = Nothing
%>
<!--#include file="../includes/core/incClose.asp" -->
