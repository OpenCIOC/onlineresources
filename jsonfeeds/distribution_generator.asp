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
<%
Response.ContentType = "application/json"
Response.CacheControl = "no-cache"

Call run_response_callbacks()

Dim strSearch
strSearch = Left(Trim(Request("term")), 100)

If Nl(strSearch) Then
	Response.Write("[]")
Else
	Dim cmdDstFinder, rsDstFinder
	Set cmdDstFinder = Server.CreateObject("ADODB.Command")
	With cmdDstFinder
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_Distribution_Finder"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@searchStr", adVarChar, adParamInput, 100, strSearch)
	End With
	Set rsDstFinder = Server.CreateObject("ADODB.Recordset")
	With rsDstFinder
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdDstFinder

		Dim strJSONCon
		strJSONCon = vbNullString
		Response.Write("[")

		While Not .EOF
			Response.Write(strJSONCon & "{""chkid"":" & JSONQs(.Fields("DST_ID"), True) & _ 
					",""value"":" & JSONQs(.Fields("DistCode"), True) & _
					",""label"":" & JSONQs(.Fields("DistCode") & _
						StringIf(Not Nl(.Fields("Name")), _
							" (" & .Fields("Name") & ")"), True) & _
					"}")
			strJSONCon = ","
			.MoveNext
		Wend
		Response.Write("]")

		.Close
	End With
	
	Set rsDstFinder = Nothing
	Set cmdDstFinder = Nothing
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
