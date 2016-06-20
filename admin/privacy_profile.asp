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
<!--#include file="../text/txtPrivacyProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incPrivacyProfileList.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_PROFILES , TXT_MANAGE_PROFILES, True, True, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> ]</p>
<form action="privacy_profile_edit.asp" method="get" class="form-inline">
<%=g_strCacheFormVals%>
<h2><%=TXT_EDIT_PROFILE%></h2>
<%
Call openPrivacyProfileListRst(Null)
%>
<% If rsListPrivacyProfile.EOF Then %>
<%= TXT_NO_VALUES_AVAILABLE %>
<% Else %>
<%=makePrivacyProfileList(vbNullString,"ProfileID",False)%>
<input type="submit" value="<%=TXT_VIEW_EDIT_PROFILE%>" class="btn btn-default">
<% End If %>
</form>

<form action="privacy_profile_add.asp" method="post" class="form-horizontal">
<%=g_strCacheFormVals%>
<h2><%=TXT_CREATE_PROFILE%></h2>
<p><%=TXT_INST_ADD_PROFILE%></p>
<div class="max-width-sm">
	<div class="form-group row">
		<label for="ProfileName" class="control-label col-sm-3 col-md-2"><%=TXT_NAME%></label>
		<div class="col-sm-9 col-md-10">
			<input type="text" name="ProfileName" id="ProfileName" maxlength="50" class="form-control">
		</div>
	</div>
	<div class="form-group row">
		<label for="ProfileName" class="control-label col-sm-3 col-md-2"><%=TXT_COPY_PROFILE%></label>
		<div class="col-sm-9 col-md-10">
			<%=makePrivacyProfileList(vbNullString,"ProfileID",True)%>
		</div>
	</div>
	<input type="submit" value="<%=TXT_ADD_PROFILE%>" class="btn btn-default">
</div>
</form>
<%
Call closePrivacyProfileListRst()
%>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
