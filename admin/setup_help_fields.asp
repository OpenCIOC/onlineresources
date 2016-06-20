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
<!--#include file="../text/txtField.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incFieldList.asp" -->
<%
Dim intDomain, _
	strType, _
	bSuperUserGlobal, _
	strTitle

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		bSuperUserGlobal = user_bSuperUserGlobalCIC
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		bSuperUserGlobal = user_bSuperUserGlobalVOL
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

If bSuperUserGlobal Then
	strTitle = TXT_UPDATE_FIELD_HELP & " (" & strType & ")"
Else
	strTitle = TXT_UPDATE_LOCAL_FIELD_HELP & " (" & strType & ")"
End If

Call makePageHeader(strTitle, strTitle, True, True, True, True)

Call openFieldListRst(intDomain)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a>
<% If not bSuperUserGlobal Then %>
| <a href="<%= makeLink("~/admin/notices/new", "AreaCode=FIELDHELP&DM=" & intDomain, vbNullString) %>"><%= TXT_REQUEST_CHANGE %></a>
<% End If %>
]</p>
<form action="fieldhelp/edit" method="get" id="field_help_form">
<div class="NotVisible">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%= intDomain %>">
</div>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><%=strTitle%></th>
</tr>
<tr>
<td>
<%
Dim Culture
For Each Culture in Application("Cultures")
If Application("Culture_" & Culture & "_ActiveRecord") Then
%>
<div>
<a href="<%=makeLink("setup_help_fields_list.asp","PrintMd=on&DM=" & intDomain & "&HelpLn=" & Culture,vbNullString)%>" target="_BLANK"><%=TXT_PRINT_VERSION & " - " & Application("Culture_" & Culture & "_LanguageName") %></a> - <a href="<%=makeLink("setup_help_fields_list.asp","PrintMd=on&DM=" & intDomain & "&HelpLn=" & Culture & "&Global=on",vbNullString)%>" target="_BLANK"><%= TXT_GLOBAL_HELP %></a>
</div>
<%
End If
Next
%>
</tr>
<tr>
<td><%=makeFieldList(vbNullString,"FieldID",True,False)%> <input type="submit" value="<%=TXT_VIEW_EDIT_FIELD_HELP%>"></td>
</tr>
</table>
</form>
<%
Call closeFieldListRst()

Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->

