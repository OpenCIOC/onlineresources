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
<!--#include file="../includes/list/incVOLCommunitySetList.asp" -->
<%
If Not user_bSuperUserVOL Then
	Call securityFailure()
End If

Dim strCommSetSelect, strCommSetForm

Call openVOLCommunitySetListRst(CSET_BASIC, vbNullString)
strCommSetSelect = makeVolCommunitySetList(0, "CommunitySetID", False)
Call closeVolCommunitySetListRst()

strCommSetForm = "<form action=""[ACTION]"" method=""get"" class=""form-inline"">" & vbCrLf & _
	g_strCacheFormVals & vbCrLf & _
	strCommSetSelect & _
	"<input class=""btn btn-default"" type=""submit"" value=""" & TXT_EDIT & """>" & vbCrLf & _
	"</form>"

Call makePageHeader(TXT_VOLUNTEER_COMMUNITIES, TXT_VOLUNTEER_COMMUNITIES, True, False, True, True)
%>
<div class="btn-group" role="group">
	<a role="button" class="btn btn-default" href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a>
</div>

<h2><%= TXT_SETUP & TXT_COLON & TXT_VOLUNTEER_COMMUNITIES %></h2>
<hr />
<h4><a href="<%=makeLinkB("comms_vol_vcs.asp")%>"><%= TXT_VOLUNTEER_COMMUNITY_SETS %></a></h4>
<hr />
<h4><%= TXT_VOLUNTEER_COMMUNITY_GROUPINGS %></h4>
<%=Replace(strCommSetForm, "[ACTION]","comms_vol_vcg.asp")%>
<hr />
<h4><%= TXT_VOLUNTEER_COMMUNITY_GROUP_MEMBERS_FOR %></h4>
<%=Replace(strCommSetForm, "[ACTION]","comms_vol_vcgc.asp")%>
<hr />
<h4><a href="<%=makeLinkB("comms_vol_opcm.asp")%>"><%= TXT_VOL_OP_CS_MANAGMENT %></a></h4>
<hr />
<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
