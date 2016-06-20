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
<!--#include file="../text/txtPageMsg.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incPageMsgList.asp" -->
<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_PAGE_MESSAGES, TXT_MANAGE_PAGE_MESSAGES, True, True, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> ]</p>
<form action="setup_page_msg_edit.asp" method="post">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><%=TXT_CREATE_EDIT_PAGE_MESSAGE%></th>
</tr>
<tr>
<%
	Call openPageMsgListRst()
%>
<td><%=makePageMsgList(vbNullString,"PageMsgID",True)%> <input type="submit" value="<%=TXT_VIEW_EDIT_MESSAGE%>"></td>
<%
	Call closePageMsgListRst()
%>
</tr>
</table>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
