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
Call setPageInfo(False, DM_VOL, DM_VOL, "../../", "volunteer/profile/", vbNullString)
%>
<!--#include file="../../includes/core/incCrypto.asp" -->
<!--#include file="../../includes/core/incSecurity.asp" -->
<!--#include file="../../includes/core/incHeader.asp" -->
<!--#include file="../../includes/core/incFooter.asp" -->
<!--#include file="../../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../../text/txtAgencyContact.asp" -->
<!--#include file="../../text/txtCommonForm.asp" -->
<!--#include file="../../text/txtEntryForm.asp" -->
<!--#include file="../../text/txtFormSecurity.asp" -->
<!--#include file="../../text/txtGeneralForm.asp" -->
<!--#include file="../../text/txtReferral.asp" -->
<!--#include file="../../text/txtUsers.asp" -->
<!--#include file="../../text/txtVOLProfile.asp" -->
<!--#include file="../../includes/vprofile/incPersonalForm.asp" -->
<!--#include file="../../includes/vprofile/incProfileSecurity.asp" -->
<!--#include file="../../includes/core/incFormat.asp" -->

<%
If Not g_bUseVolunteerProfiles Then
	Call goToPageB(ps_strPathToStart & "volunteer/")
ElseIf vprofile_bLoggedIn Then
	Call handleError(TXT_LOGOUT_BEFORE_CREATE, "start.asp", vbNullString)
End If
Call makePageHeader(TXT_CREATE_VOL_PROFILE, TXT_CREATE_VOL_PROFILE, True, False, True, True)
%>
<h1><%= TXT_CREATE_NEW_VOL_PROFILE %></h1>
<p><%= TXT_CREATE_PROFILE_BENEFITS_1 %></p>
<ul>
	<li><%= TXT_CREATE_PROFILE_BENEFITS_2 %></li>
	<li><%= TXT_CREATE_PROFILE_BENEFITS_3 %></li>
	<li><%= TXT_CREATE_PROFILE_BENEFITS_4 %></li>
</ul>
<p><strong><em><%= TXT_DO_YOU_HAVE_A_PROFILE_ALREADY %></em></strong> <a href="<%=makeLinkB("login.asp")%>"><%= TXT_LOGIN_NOW %></a></p>
<%
Dim dicBasicInfo
Set dicBasicInfo = Server.CreateObject("Scripting.Dictionary")

Call VOLProfilePersonalForm(True, dicBasicInfo)

Call makePageFooter(True)
%>



<!--#include file="../../includes/core/incClose.asp" -->


