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
<!--#include file="../text/txtSearchTips.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incSearchTipsList.asp" -->
<%
Dim intDomain, _
	strType

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Call makePageHeader(TXT_MANAGE_SEARCH_TIPS & " (" & strType & ")", TXT_MANAGE_SEARCH_TIPS & " (" & strType & ")", True, True, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> ]</p>
<form action="setup_searchtips_edit.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
</div>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><%=TXT_CREATE_EDIT_SEARCH_TIPS & " (" & strType & ")"%></th>
</tr>
<tr>
<%
	Call openSearchTipsListRst(intDomain)
%>
<td><%=makeSearchTipsList(vbNullString,"SearchTipsID",False,True)%> <input type="submit" value="<%=TXT_VIEW_SEARCH_TIPS%>"></td>
<%
	Call closeSearchTipsListRst()
%>
</tr>
</table>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
