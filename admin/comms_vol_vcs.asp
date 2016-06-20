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
Call setPageInfo(True, DM_VOL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtCommunitySets.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incVOLCommunitySetList.asp" -->

<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Call makePageHeader(TXT_VOLUNTEER_COMMUNITY_SETS, TXT_VOLUNTEER_COMMUNITY_SETS, True, False, True, True)
%>
<%
Const FORM_ACTION = "<form action=""comms_vol_vcs2.asp"" method=""post"">"
Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON, _
	strCulture, _
	xmlDoc, _
	xmlNode, _
	strValue

SUBMIT_BUTTON = "<input type=""submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input type=""submit"" name=""Submit"" value=""" & TXT_ADD & """>"

Call openVOLCommunitySetListRst(CSET_FULL, vbNullString)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("comms_vol.asp")%>"><%= TXT_RETURN_TO_VC %></a> ]</p>
<h1><%= TXT_EDIT_VOLUNTEER_COMMUNITY_SETS %></h1>
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th class="RevTitleBox"><%= TXT_SET_NAME %></th>
	<th class="RevTitleBox"><%= TXT_AREAS_SERVED %></th>
	<th class="RevTitleBox"><%= TXT_USAGE %></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<tr>
	<td colspan="4"><span class="Alert"><%= TXT_NOTE %>:</span> <%= TXT_INST_DELETE %></td>
</tr>
<%
With rsListVolCommunitySet
	If Not .EOF Then
		While Not .EOF
			Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
			With xmlDoc
				.async = False
				.setProperty "SelectionLanguage", "XPath"
			End With
			xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"
%>
<%=FORM_ACTION%>
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="CommunitySetID" value="<%=.Fields("CommunitySetID")%>">
</div>
<tr>
	<td><table class="NoBorder cell-padding-2">
<%
	For Each strCulture In active_cultures()
		Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture,SQUOTE) & "]")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.getAttribute("SetName")
		Else
			strValue = vbNullString
		End If
%>
	<tr><td class="FieldLabelLeftClr"><%= Application("Culture_" & strCulture & "_LanguageName") %></td>

		<td><input type="text" name="SetName_<%= strCulture %>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_SET_NAME)%> value=<%=AttrQs(strValue)%> size="<%=(TEXT_SIZE-25)/2%>" maxlength="100"></td></tr>
<%
Next
%>
</table></td>
	<td><table class="NoBorder cell-padding-2">
<%
	For Each strCulture In active_cultures()
		Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture,SQUOTE) & "]")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.getAttribute("AreaServed")
		Else
			strValue = vbNullString
		End If
%>
	<tr><td class="FieldLabelLeftClr"><%= Application("Culture_" & strCulture & "_LanguageName") %></td>
	<td><input type="text" name="AreaServed_<%=strCulture%>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_AREAS_SERVED)%> value=<%=AttrQs(strValue)%> size="<%=(TEXT_SIZE-10)/2%>" maxlength="100"></td></tr>
<%
Next
%>
</table></td>
	<td>Records: <%=.Fields("UsageCountRecords")%>; Views: <%=.Fields("UsageCountViews")%></td>
	<td><%=submit_button%><%If .Fields("UsageCountRecords") + .Fields("UsageCountViews") = 0 Then%>&nbsp;<%=DELETE_BUTTON%><%End If%></td>
</tr>
</form>
<%
			.MoveNext
		Wend
	End If
End With
Call closeVOLCommunitySetListRst()

%>
<%=FORM_ACTION%>
<div style="display:none">
<%=g_strCacheFormVals%>
</div>
<tr>
	<td colspan="4"><%= TXT_INST_ADD %></td>
</tr>
<tr>
	<td><table class="NoBorder cell-padding-2">
<%
For Each strCulture In active_cultures()
%>
	<tr>
	<td class="FieldLabelLeftClr"><%= Application("Culture_" & strCulture & "_LanguageName") %></td>
	<td><input type="text" name="SetName_<%=strCulture %>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_SET_NAME)%> size="<%=(TEXT_SIZE-25)/2%>" maxlength="100"></td>
	</tr>
<%
Next
%>
	</table></td>
	<td><table class="NoBorder cell-padding-2">
<%
For Each strCulture In active_cultures()
%>
	<tr>
	<td class="FieldLabelLeftClr"><%= Application("Culture_" & strCulture & "_LanguageName") %></td>
	<td><input type="text" name="AreaServed_<%=strCulture %>" title=<%=AttrQs(Application("Culture_" & strCulture & "_LanguageName") & TXT_COLON & TXT_AREAS_SERVED)%> size="<%=(TEXT_SIZE-10)/2%>" maxlength="100"></td>
	</tr>
<%
Next
%>
	</table></td>
	<td>&nbsp;</td>
	<td><%=ADD_BUTTON%></td>
</tr>
</form>
</table>
<%
Call makePageFooter(True)
%>



<!--#include file="../includes/core/incClose.asp" -->


