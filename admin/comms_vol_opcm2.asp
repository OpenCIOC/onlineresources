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
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incCommListVOL.asp" -->
<!--#include file="../includes/list/incVOLCommunitySetList.asp" -->
<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If
Dim intCommunitySetID, strSetName
intCommunitySetID=Trim(Request("CommunitySetID"))
If IsIDType(intCommunitySetID) Then
	intCommunitySetID=CInt(intCommunitySetID)
Else
	Call handleError(TXT_INVALID_CS, _
		"comms_vol_opcm.asp", vbNullString)
End If
strSetName=Request("SetName")


Call makePageHeader(TXT_ADD_REMOVE_OPPS, TXT_ADD_REMOVE_OPPS, True, False, True, True)


Dim strCommSetSelect, strCommSetForm
Call openVOLCommunitySetListRst(CSET_BASIC, vbNullString)
strCommSetSelect = makeVolCommunitySetList(vbNullString, "InSet", True)
Call closeVOLCommunitySetListRst()


Call openVolCommListRst()
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("comms_vol.asp")%>"><%= TXT_RETURN_TO_VC %></a> | <a href="<%= makeLinkB("comms_vol_opcm.asp")%>"><%= TXT_RETURN_TO_OPP_CS_MGMT %></a> ]</p>
<h1><%= TXT_ADD_REMOVE_OPPS %> <em><%=strSetName%></em></h1>
<p><%= TXT_INST_SEARCH_OPPS %></p>
<form action="comms_vol_opcm3.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="CommunitySetID" value="<%=intCommunitySetID%>">
<input type="hidden" name="SetName" value=<%=AttrQs(strSetName)%>>
<p><label><%= TXT_SHOW_OPPS_IN_SET %><%=strCommSetSelect%></label></p>
<p><%= TXT_SHOW_OPPS_NEED_IN_COMMS %><span class="Alert">*</span>:</p>
<table>
<% 
Dim fldCMID, _
	fldSEARCHCMID, _
	bNewRow
	
bNewRow = True	

With rsListVolComm
	Set fldCMID = .Fields("CM_ID")
	Set fldSEARCHCMID = .Fields("SEARCH_CM_ID")
	While Not .EOF
		If bNewRow Then
%>
<tr>
<%
		End If
		%><td><label for="InCommunity<%=fldCMID.Value%>"><input id="InCommunity<%=fldCMID.Value%>"type="checkbox" name="InCommunity" value="<%=fldSEARCHCMID.Value%>">&nbsp;<%=.Fields("Community")%></label></td><%
		If Not bNewRow Then
%>
</tr>
<%
		End If
		bNewRow = Not bNewRow
		.MoveNext
	Wend
End With
%>
</table>
<p>3. <label for="InclDel"><input type="checkbox" id="InclDel" name="InclDel">&nbsp;<%= TXT_SHOW_OPPS_DELETED %></label></p>
<p>4. <label for="InclExp"><input type="checkbox" id="InclExp" name="InclExp" checked>&nbsp;<%= TXT_SHOW_OPPS_EXPIRED %></label></p>
<p><%= TXT_FIND_OPPS_TO %>
<label for="AddRemoveA"><input type="radio" id="AddRemoveA" name="AddRemove" value="A" checked>&nbsp;<%=TXT_ADD%></label>
<label for="AddRemoveR"><input type="radio" id="AddRemoveR" name="AddRemove" value="R">&nbsp;<%= TXT_REMOVE %></label></p>
<input type="submit" name="Submit" value="<%=TXT_SUBMIT%>"> <input type="reset" value="<%=TXT_CLEAR_FORM%>">
</form>
<%
Call closeVOLCommListRst()

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->


