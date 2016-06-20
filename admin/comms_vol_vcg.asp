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
<!--#include file="../text/txtCommunitySets.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incBallList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incVOLCommunityGroupList.asp" -->
<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Dim intCommunitySetID
intCommunitySetID=Trim(Request("CommunitySetID"))
If IsIDType(intCommunitySetID) Then
	intCommunitySetID=CInt(intCommunitySetID)
Else
	Call handleError(TXT_INVALID_CS, "comms_vol.asp", vbNullString)
End If
%>
<%
Const FORM_ACTION = "<form action=""comms_vol_vcg2.asp"" METHOD=""POST"">"
Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON, _
	strCulture, _
	xmlDoc, _
	xmlNode, _
	strValue, _
	intCommunityGroupID

SUBMIT_BUTTON = "<input type=""submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input type=""submit"" name=""Submit"" value=""" & TXT_ADD & """>"

Dim strCommunitySetName

Call openVOLCommunityGroupListRst(True, intCommunitySetID)

If rsListVolCommunityGroup.EOF Then
	Call handleError(TXT_INVALID_CS, "comms_vol.asp", vbNullString)
Else
	strCommunitySetName = rsListVolCommunityGroup.Fields("SetName")
	Set rsListVolCommunityGroup = rsListVolCommunityGroup.NextRecordset
End If

Call openVolBallListRst()

Call makePageHeader(TXT_VOLUNTEER_COMMUNITY_GROUPS, TXT_VOLUNTEER_COMMUNITY_GROUPS, True, False, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("comms_vol.asp")%>"><%= TXT_RETURN_TO_VC %></a> ]</p>
<h1><%=TXT_EDIT_VOLUNTEER_COMMUNITY_GROUPS & TXT_COLON & "<br>" & strCommunitySetName%></h1>

<p><span class="AlertBubble"><%= TXT_INST_CG_DELETE %><a href="<%=makeLink("comms_vol_vcgc.asp","CommunitySetID=" & intCommunitySetID, vbNullString)%>"><%= TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS %></a></span></p>

<table class="BasicBorder cell-padding-4 max-width-lg">
<tr>
	<th class="RevTitleBox"><%= TXT_COMMUNITY_GROUP %></th>
</tr>
<%
With rsListVolCommunityGroup
	If Not .EOF Then
		While Not .EOF
			Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
			With xmlDoc
				.async = False
				.setProperty "SelectionLanguage", "XPath"
			End With
			xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"
%>
<tr>
	<td>
		<%=FORM_ACTION%>
		<div style="display:none">
		<%=g_strCacheFormVals%>
		<% intCommunityGroupID = .Fields("CommunityGroupID") %>
		<input type="hidden" name="CommunityGroupID" value="<%=intCommunityGroupID%>">
		<input type="hidden" name="CommunitySetID" value="<%=intCommunitySetID%>">
		</div>
		<table class="NoBorder cell-padding-3">
<%
	For Each strCulture In active_cultures()
		Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture,SQUOTE) & "]")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.getAttribute("CommunityGroupName")
		Else
			strValue = vbNullString
		End If
%>

		<tr>
			<td class="FieldLabelLeftClr"><label for="CommunityGroupName_<%= strCulture %><%=intCommunityGroupID%>"><%=TXT_NAME%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label></td>
			<td><input type="text" name="CommunityGroupName_<%= strCulture %>" id="CommunityGroupName_<%= strCulture %><%=intCommunityGroupID%>" value=<%=AttrQs(strValue)%> size="<%=TEXT_SIZE-15%>" maxlength="100"></td>
		</tr>
<% Next %>
		<tr><td class="FieldLabelLeftClr"><label for="BallID<%=intCommunityGroupID%>"><%= TXT_BALL %></label></td><td><%=makeVolBallList(.Fields("BallID"),"BallID","BallID" & intCommunityGroupID,True)%></td></tr>
		<tr><td class="FieldLabelLeftClr"><label for="ImageURL<%=intCommunityGroupID%>"><%= TXT_IMG_URL %></label></td><td><input type="text" name="ImageURL" id="ImageURL<%=intCommunityGroupID%>" value=<%=AttrQs(.Fields("ImageURL"))%> size="<%=TEXT_SIZE-20%>" maxlength="150"></td></tr></table>
		<%=SUBMIT_BUTTON%><%=StringIf(.Fields("UsageCount") = 0,"&nbsp;" & DELETE_BUTTON)%>
		</form>
	</td>
</tr>

<%
			.MoveNext
		Wend
	End If
End With
Call closeVolCommunityGroupListRst()

%>
<tr>
	<th><%=TXT_INST_CG_ADD %></th>
</tr>
<tr>
	<td>
		<%=FORM_ACTION%>
		<div style="display:none">
		<%=g_strCacheFormVals%>
		<input type="hidden" name="CommunitySetID" value="<%=intCommunitySetID%>">
		</div>
		<table class="NoBorder cell-padding-3">
<%
	For Each strCulture In active_cultures()
%>
		<tr>
			<td class="FieldLabelLeftClr"><label for="CommunityGroupName_<%= strCulture %>NEW"><%=TXT_NAME%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label></td>
			<td><input type="text" name="CommunityGroupName_<%= strCulture %>" id="CommunityGroupName_<%= strCulture %>NEW" size="<%=TEXT_SIZE-15%>" maxlength="100"></td>
		</tr>
<% Next %>
		<tr><td class="FieldLabelLeftClr"><label for="BallIDNEW"><%= TXT_BALL %></label></td><td><%=makeVolBallList(vbNullString,"BallID","BallIDNEW",True)%></td></tr>
		<tr><td class="FieldLabelLeftClr"><label for="ImageURLNEW"><%= TXT_IMG_URL %></label></td><td><input type="text" name="ImageURL" id="ImageURLNEW" size="<%=TEXT_SIZE-20%>" maxlength="150"></td></tr></table>
		<%=ADD_BUTTON%>
		</form>
	</td>
</tr>
</table>
<%
Call closeVolBallListRst()
%>
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
