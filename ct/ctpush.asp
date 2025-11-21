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
' Purpose:		Generate and XML file for the given NUM and push it to
'				the client tracker. Return result to in JSON format to 
'				the browser.
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
Call setPageInfo(False, DM_CIC, DM_CIC, "../", "ct/", vbNullString)
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
%>
<%
Sub PageContent()
Dim strID, strNUMErrorMsg, strRemove, strDomain
strID = Request("ID")
strRemove = Request("RemoveItem")

If Not ctHasBeenLaunched() Then
%>
{ "fail": true, "errinfo": <%=JSONQs(TXT_CT_NOT_LAUNCHED, True)%> }
<%
	Exit Sub

ElseIf Nl(strID) Then
%>
{ "fail": true, "errinfo": <%=JSONQs(TXT_NO_RECORD_CHOSEN, True)%> }
<%
	Exit Sub

ElseIf Not (IsNUMType(strID) or IsIDType(strID) or (Not Nl(strRemove) And strID = "all")) Then
%>
{ "fail" : true, "errinfo": <%=JSONQs(TXT_INVALID_ID & Server.HTMLEncode(strID) & ".", True)%> }
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

Dim strXML
If Not Nl(strRemove) Then
	strXML = "<?xml version=""1.0"" encoding=""UTF-8""?>" & vbCrLf & _
	"<pushResourceRemove xmlns=""http://clienttracker.cioc.ca/schema/"">" & vbCrLf & _
	"	<login>" & XMLEncode(getSessionValue("ct_login")) & "</login>" & vbCrLf & _
	"	<key>" & XMLEncode(getSessionValue("ct_key")) & "</key>" & vbCrLf & _
	"	<ctid>" & XMLEncode(getSessionValue("ct_id")) & "</ctid>" & vbCrLf & _
	"	<resourceItem>" & vbCrLf & _
	"		<id>" & XMLEncode(strID) & "</id>" & vbCrLf & _
	"	</resourceItem>" & vbCrLf & _
	"</pushResourceRemove>"
	
Else 

	Dim strSQL, strIDField
	strIDField = "NUM"
	strSQL = "SELECT bt.NUM," & _
		"dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL" 

	If strDomain = "VOL" Then
		strIDField = "VNUM"
		strSQL = strSQL & ", vo.VNUM, vod.POSITION_TITLE"
	End If

	strSQL = strSQL & vbCrLf & "FROM GBL_BaseTable bt " & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf

	If strDomain = "VOL" Then
		strSQL = strSQL & "INNER JOIN VOL_Opportunity vo ON bt.NUM=vo.NUM" & vbCrLf & _
				"WHERE vo.VNUM = " & strID 
	Else
		strSQL = strSQL & "WHERE bt.NUM=" & QsNl(strID)
	End If


	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandType = adCmdText
		.CommandText = strSQL
		.CommandTimeout = 0
		Set rsOrg = .Execute
	End With

	If rsOrg.EOF Then
	%>
	{ "fail": true, "errinfo": <%=TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strID)%> }
	<%
		Exit Sub
	End If

	Dim strOrgName
	strOrgName = rsOrg.Fields("ORG_NAME_FULL") 

	If strDomain = "VOL" Then
		strOrgName = rsOrg.Fields("POSITION_TITLE") & " (" & strOrgName & ")"
	End If

	strXML = "<?xml version=""1.0"" encoding=""UTF-8""?>" & vbCrLf & _
	"<pushResource xmlns=""http://clienttracker.cioc.ca/schema/"">" & vbCrLf & _
	"	<login>" & XMLEncode(getSessionValue("ct_login")) & "</login>" & vbCrLf & _
	"	<key>" & XMLEncode(getSessionValue("ct_key")) & "</key>" & vbCrLf & _
	"	<ctid>" & XMLEncode(getSessionValue("ct_id")) & "</ctid>" & vbCrLf & _
	"	<resourceItem>" & vbCrLf & _
	"		<id>" & XMLEncode(rsOrg(strIDField)) & "</id>" & vbCrLf & _
	"		<name>" & XMLEncode(strOrgName) & "</name>" & vbCrLf & _
	"		<url>" & XMLEncode(IIf(g_bSSL, "https://", "http://") & Request.ServerVariables("HTTP_HOST") & Left(Request.ServerVariables("PATH_INFO"),Len(Request.ServerVariables("PATH_INFO"))-Len(ps_strThisPageFull)) & makeDetailsLink(strID,vbNullString,vbNullString)) & "</url>" & vbCrLf & _
	"	</resourceItem>" & vbCrLf & _
	"</pushResource>"

End If

Dim objCtHttp
Set objCtHttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
objCtHttp.setTimeouts 5000, 15000, 10000, 10000 
objCtHttp.Open "POST", g_strClientTrackerRpcURL & IIf(Not Nl(strRemove), "remove_resource", "add_resource"), False
objCtHttp.SetRequestHeader "Content-Type", "application/xml"
objCtHttp.Send strXML

If objCtHttp.Status <> 200 Then
%>
{ "fail": true, "errinfo": "<%=JSONQs(TXT_CT_ERR_SERVER_COMMUNICATION, False)%>:\n<%=JSONQs(objCtHttp.Status & " " & objCtHttp.StatusText, True)%>" }
<%
	Exit Sub
ElseIF Err.Number <> 0 Then
%>
{ "fail": true, "errinfo": "<%=JSONQs(TXT_CT_ERR_SERVER_COMMUNICATION,False)%>:\n<%=JSONQs(Err.Description, False)%>" }
<%
	Exit Sub
End If


Dim objXML, objSuccess, objError

Set objXML = Server.CreateObject("MSXML2.DOMDocument.6.0")
objXML.async = false
objXML.setProperty "SelectionNamespaces", "xmlns:ct='http://clienttracker.cioc.ca/schema/'"
objXML.setProperty "SelectionLanguage", "XPath"

If Not objXML.loadXML(objCtHttp.responseText) Then
%>
{ "fail": true, "errinfo": "<%=JSONQs(TXT_CT_ERR_SERVER_INVALID, False)%>:\n<%=JSONQs(objXML.parseError.reason, False)%>" }
<%

	Exit Sub
End If

Set objSuccess = objXML.selectNodes("/ct:response/ct:success")
Set objError = objXML.selectNodes("/ct:response/ct:error")
If objError.length > 0 Then
%>
{ "fail": true, "errinfo": "<%=JSONQs(TXT_CT_ERR_SERVER_MSG, False)%>:\n<%=JSONQs(objError(0).text, False)%>" }
<%
	Exit Sub

ElseIf objSuccess.length = 0 Then
%>
{ "fail": true, "errinfo": <%=JSONQs(TXT_CT_ERR_SERVER_INVALID, True)%> }
<%
	Exit Sub
End If


'No errors. Return Success to calling page.
%>
{ "fail": false, "ids": [ <%
Dim strIDCon
strIDCon = vbNullString
For Each strID in objXML.selectNodes("/ct:response/ct:ids/ct:id")
Response.Write(strIDCon & JSONQs(strID.text, True))
strIDCon = ", "
Next
%> ]}
<%

End Sub

Call run_response_callbacks()

Call PageContent()
%>

<!--#include file="../includes/core/incClose.asp" -->

