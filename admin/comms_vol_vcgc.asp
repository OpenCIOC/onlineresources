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
<!--#include file="../includes/list/incCommList.asp" -->
<!--#include file="../includes/list/incVOLCGCommunityList.asp" -->
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
	Call handleError(TXT_INVALID_CS, _
		"comms_vol.asp", vbNullString)
End If
%>
<%
Const FORM_ACTION = "<form action=""comms_vol_vcgc2.asp"" METHOD=""POST"">"
Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON

SUBMIT_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_ADD & """>"

Call openVOLCommunityGroupListRst(False, intCommunitySetID)

Dim strCommunitySetName

Call openVOLCGCommunityListRst(intCommunitySetID)

If rsListVOLCGCommunity.EOF Then
	Call handleError(TXT_INVALID_CS, "comms_vol.asp", vbNullString)
Else
	strCommunitySetName = rsListVOLCGCommunity.Fields("SetName")
	Set rsListVOLCGCommunity = rsListVOLCGCommunity.NextRecordset
End If

Call openCommListRst()

Call makePageHeader(TXT_VOLUNTEER_COMMUNITIES, TXT_VOLUNTEER_COMMUNITIES, True, False, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("comms_vol.asp")%>"><%= TXT_RETURN_TO_VC %></a> ]</p>
<h1><%=TXT_EDIT_VOLUNTEER_COMMUNITIES & TXT_COLON & "<br>" & strCommunitySetName%></h1>
<table class="BasicBorder cell-padding-4 max-width-lg">
<tr><th><%= TXT_COMMUNITY %></th><th><%= TXT_GROUP %></th><th><%=TXT_ACTION%></th></tr>
<%
With rsListVOLCGCommunity
	If Not .EOF Then
		While Not .EOF
%>
<%=FORM_ACTION%>
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="CGCMID" value="<%=.Fields("CG_CM_ID")%>">
<input type="hidden" name="CommunitySetID" value="<%=intCommunitySetID%>">
</div>
<tr>
	<td><%=Server.HTMLEncode(.Fields("Community"))%></td>
	<td><%=makeVolCommunityGroupList(.Fields("CommunityGroupID"),"CommunityGroupID",.Fields("Community") & TXT_COLON & TXT_GROUP,False)%></td>
	<td><%=SUBMIT_BUTTON%><%="&nbsp;" & DELETE_BUTTON%></td>
</tr>
</form>
<%
			.MoveNext
		Wend
	End If
End With
Call closeVolCGCommunityListRst()

%>
<%=FORM_ACTION%>
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="CommunitySetID" value="<%=intCommunitySetID%>">
</div>
<tr>
	<td colspan="3"><label for="VOLCMID"><%= TXT_INST_COM_ADD %></label></td>
</tr>
<tr>
	<td><%=makeCommList(vbNullString,"VOLCMID",False,False,Null,vbNullString)%></td>
	<td><%=makeVOLCommunityGroupList(vbNullString,"CommunityGroupID",TXT_GROUP,False)%></td>
	<td><%=ADD_BUTTON%></td>
</tr>
<%
Call closeCommListRst()
Call closeVolCommunityGroupListRst()
%>
</form>
</table>
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
