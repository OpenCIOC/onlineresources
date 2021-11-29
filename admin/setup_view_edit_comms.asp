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
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtView.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
If Not (user_bSuperUserCIC Or (Not g_bUseCIC And user_bSuperUserVOL)) Then
	Call securityFailure()
End If

Const FORM_ACTION = "<form action=""setup_view_edit_comms2.asp"" METHOD=""POST"">"

Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON

SUBMIT_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_ADD & """>"

Dim intViewType, _
	strViewName, _
	bError, _
	strErrMessage

bError = False

intViewType = Trim(Request("ViewType"))

If Nl(intViewType) Then
	bError = True
	strErrMessage = TXT_NO_RECORD_CHOSEN
ElseIf Not IsIDType(intViewType) Then
	bError = True
	strErrMessage = TXT_INVALID_ID & Server.HTMLEncode(intViewType) & "."
Else
	intViewType = CLng(intViewType)
End If

If Not bError Then

Dim cmdSrchComm, rsSrchComm
Set cmdSrchComm = Server.CreateObject("ADODB.Command")
With cmdSrchComm
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_View_Community_lf"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set rsSrchComm = .Execute
End With

If Not rsSrchComm.EOF Then
	strViewName = rsSrchComm.Fields("ViewName")
Else
	bError = True
	strErrMessage = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intViewType) & "."
End If

End If

If Not bError Then

Set rsSrchComm = rsSrchComm.NextRecordSet

Call makePageHeader(TXT_EDIT_VIEW_COMMS, TXT_EDIT_VIEW_COMMS, False, False, True, False)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>
<h1><%=TXT_EDIT_VIEW_COMMS%> (<%=strViewName%>)</h1>
<table class="BasicBorder cell-padding-3">
<tr><th><%=TXT_NAME%></th><th><%=TXT_ORDER%></th><th><%=TXT_ACTION%></th></tr>
<%
With rsSrchComm
	If Not .EOF Then
		While Not .EOF
%>
<%=FORM_ACTION%>
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ViewType" value="<%=intViewType%>">
<input type="hidden" name="CMID" value="<%=.Fields("CM_ID")%>">
</div>
<tr>
	<td><b><%=.Fields("Community")%></b><%=.Fields("ProvinceState")%><% If Not Nl(.Fields("ParentCommunityName")) Then%> (<%=TXT_IN & " " & .Fields("ParentCommunityName")%>)<%End If %></td>
	<td><input type="text" size="3" maxlength="3" name="DisplayOrder" title=<%=AttrQs(.Fields("Community") & TXT_COLON & TXT_ORDER)%> value="<%=.Fields("DisplayOrder")%>"></td>
	<td><%=SUBMIT_BUTTON%>&nbsp;<%=DELETE_BUTTON%></td>
</tr>
</form>
<%
			.MoveNext
		Wend
	End If
End With
%>
</table>
<br>
<%=FORM_ACTION%>
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ViewType" value="<%=intViewType%>">
</div>
<table class="BasicBorder cell-padding-3">
<tr><th><%=TXT_NAME%></th><th><%=TXT_ORDER%></th><th><%=TXT_ACTION%></th></tr>
<tr>
	<td colspan="3"><%=TXT_INST_COMMS%></td>
</tr>
<tr>
	<td><input type="text" name="AddCommunity" title=<%=AttrQs(TXT_NAME & TXT_COLON & TXT_NEW_COMMUNITY)%> id="AddCommunity" size="50" maxlength="200"><input type="hidden" name="AddCommunityID" id="AddCommunityID"></td>
	<td><input type="text" name="DisplayOrder" title=<%=AttrQs(TXT_ORDER & TXT_COLON & TXT_NEW_COMMUNITY)%> size="3" maxlength="3" value="0"/></td>
	<td><%=ADD_BUTTON%></td>
</tr>
</table>
</form>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/bsearch.js") %>
<% 
g_bListScriptLoaded = True
%>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<script type="text/javascript">
(function() {
jQuery(function($) {
	init_cached_state('form:not(#stateForm):last');

	init_community_autocomplete($, 'AddCommunity', "<%= makeLinkB("~/jsonfeeds/community_generator.asp") %>", 3, '#AddCommunityID');

	restore_cached_state();
	});
})();
</script>
<%
Call makePageFooter(False)

Else
	Call makePageHeader(TXT_COMM_WAS_NOT & TXT_UPDATED, TXT_COMM_WAS_NOT & TXT_UPDATED, False, False, True, False)
	Call handleError(strErrMessage, vbNullString, vbNullString)
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%
	Call makePageFooter(False)
End If
%>
<!--#include file="../includes/core/incClose.asp" -->
