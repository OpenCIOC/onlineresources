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
<!--#include file="../../includes/core/adovbs.inc" -->
<!--#include file="../../includes/core/incVBUtils.asp" -->
<!--#include file="../../includes/validation/incBasicTypes.asp" -->
<!--#include file="../../includes/core/incRExpFuncs.asp" -->
<!--#include file="../../includes/core/incHandleError.asp" -->
<!--#include file="../../includes/core/incSetLanguage.asp" -->
<!--#include file="../../includes/core/incPassVars.asp" -->
<!--#include file="../../text/txtGeneral.asp" -->
<!--#include file="../../text/txtError.asp" -->
<!--#include file="../../includes/core/incConnection.asp" -->
<!--#include file="../../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", "EntryForm.LoginName")
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../text/txtUsers.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->

<% 
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
ElseIf user_bLoggedIn Then
	Call goToPageB("loginconflict.asp")
ElseIf vprofile_bLoggedIn Then
	Call goToPageB("start.asp")
End If

Call makePageHeader(TXT_VOL_PROFILE_PASSWORD_RESET, TXT_VOL_PROFILE_PASSWORD_RESET, True, True, True, True)
%>
<p class="Info"><%= TXT_INST_RESET_PW %></p>

<div class="max-width-sm">
<form action="resetpw2.asp" method="post" name="EntryForm" role="form" class="form-horizontal">
	<div style="display:none">
	<%=g_strCacheFormVals%>
	<input type="hidden" name="page" value=<%=AttrQs(Server.HTMLEncode(Trim(Ns(Request("page")))))%>>
	<input type="hidden" name="args" value=<%=AttrQs(Server.HTMLEncode(Trim(Ns(Request("args")))))%>>
	</div>
	<div class="form-group">
		<label for="LoginName" class="control-label col-sm-2"><%=TXT_EMAIL%></label>
		<div class="col-sm-10">
			<input name="LoginName" type="text" maxlength="100" class="form-control">
		</div>
	</div>
	<div class="form-group">
		<div class="col-sm-offset-2 col-sm-10">
			<input type="submit" class="btn btn-default" value="<%=TXT_EMAIL_MY_NEW_PW%>">
		</div>
	</div>
</form>
</div>

<%
Call makePageFooter(True)
%>
<!--#include file="../../includes/core/incClose.asp" -->


