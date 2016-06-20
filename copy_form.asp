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
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtCopyForm.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incAgencyList.asp" -->
<!--#include file="includes/list/incRecordTypeList.asp" -->
<!--#include file="includes/update/incCICCopyFormPrint.asp" -->
<%
If Not user_bCopyCIC Then
	Call securityFailure()
End If

Dim strNUM, _
	intCopyRTID, _
	bNUMError

bNUMError = False
strNUM = Request("NUM")
intCopyRTID = Request("RT")


Response.CacheControl = "no-cache"
%>
<!doctype html>
<html>
<body>
<div id="content_to_insert">
<%
If Not IsNUMType(strNUM) Then
	bNUMError = True
	'Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, False, True, True, False)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strNUM) & ".", vbNullString, vbNullString)
	'Call makePageFooter(False)
ElseIf Not IsIDType(intCopyRTID) Then
	'Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, False, True, True, False)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intCopyRTID) & ".", vbNullString, vbNullString)
	'Call makePageFooter(False)
Else
	Dim dicOrgName
	Set dicOrgName = Server.CreateObject("Scripting.Dictionary")

	dicOrgName("ORG_LEVEL_1") = vbNullString
	dicOrgName("ORG_LEVEL_2") = vbNullString
	dicOrgName("ORG_LEVEL_3") = vbNullString
	dicOrgName("ORG_LEVEL_4") = vbNullString
	dicOrgName("ORG_LEVEL_5") = vbNullString
	dicOrgName("LOCATION_NAME") = vbNullString
	dicOrgName("SERVICE_NAME_LEVEL_1") = vbNullString
	dicOrgName("SERVICE_NAME_LEVEL_2") = vbNullString

	'Call makePageHeader(TXT_COPY_RECORD, TXT_COPY_RECORD, False, True, True, False)
	Call printCopyFieldsForm(intCopyRTID, strNUM, vbNullString)
	'Call makePageFooter(False)
End If
%>
</div>
</body>
</html>


<!--#include file="includes/core/incClose.asp" -->


