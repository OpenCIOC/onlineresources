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
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtExportProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incExportProfileList.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_PROFILES, TXT_MANAGE_PROFILES, True, True, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> ]</p>
<form action="export_profile_edit.asp" method="get">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><label for="ProfileID"><%=TXT_EDIT_PROFILE%></label></th>
</tr>
<%
Call openExportProfileListRst(True,True)
%>
<tr>
<td>
<% If rsListExportProfile.EOF Then %>
<%= TXT_NO_VALUES_AVAILABLE %>
<% Else %>
<%=makeExportProfileList(vbNullString,"ProfileID","ProfileID",False)%> <input type="submit" value="<%=TXT_VIEW_EDIT_PROFILE%>">
<% End If %>
</td>
</tr>
</table>
</form>
<br>
<form action="export_profile_edit2.asp" method="post">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_CREATE_PROFILE%></th>
</tr>
<tr>
	<td colspan="2"><%=TXT_INST_ADD_PROFILE%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="ProfileName"><%=TXT_NAME%></label></td>
	<td><input type="text" name="ProfileName" id="ProfileName" size="50" maxlength="50"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="NewProfileID"><%=TXT_COPY_PROFILE%></label></td>
	<td><%=makeExportProfileList(vbNullString,"ProfileID","NewProfileID",True)%></td>
</tr>
<tr>
	<td colspan="2" align="center"><input type="submit" name="Submit" value="<%=TXT_ADD_PROFILE%>"></td>
</tr>
</table>
</form>
<%
Call closeExportProfileListRst()
%>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
