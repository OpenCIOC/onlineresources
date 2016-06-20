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
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
g_bPageShouldUseSSL = True
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(False, DM_GLOBAL, DM_GLOBAL, vbNullString, vbNullString, "EntryForm.LoginName")
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtUsers.asp" -->
<script language="python" runat="server">
try:
	from cioc.core.security import needs_ssl_domains, render_ssl_domain_list
except ImportError:
	def needs_ssl_domains(request):
		return False
	
def l_needs_ssl_domains():
	return needs_ssl_domains(pyrequest)

def l_render_ssl_domain_list():
	return render_ssl_domain_list(pyrequest)
</script>
<% 
Call EnsureSSL()

Call makePageHeader(TXT_DATABASE_LOGIN, TXT_DATABASE_LOGIN, True, False, True, True)
Call setSessionValue("session_test","ok")

Dim intTriesLeft
intTriesLeft = Request("TriesLeft")
If Not IsPosSmallInt(intTriesLeft) Then
	intTriesLeft = Null
End If
If Not Nl(intTriesLeft) Then
	If intTriesLeft > 0 And intTriesLeft < 3 Then
%>
<p class="AlertBubble"><%=Replace(TXT_ACCOUNT_WILL_BE_LOCKED,"[#]",Server.HTMLEncode(intTriesLeft))%></p>
<%
	End If
End If
If l_needs_ssl_domains() Then
%>
<p class="AlertBubble"><%= TXT_CANT_LOGIN_NON_SECURE_DOMAIN %></p>
<p><%= TXT_SECURE_DOMAIN_LIST %></p>
<%= l_render_ssl_domain_list() %>
<%
Else
%>
<p>[ <%If g_bUseCIC Or user_bLoggedIn Then%><a href="<%=makeLinkB("~/")%>"><%=TXT_ORG_SEARCH%></a><%End If%><%If g_bUseVOL Then%> | <a href="<%=makeLinkB("volunteer/")%>"><%=TXT_VOLUNTEER_SEARCH%></a><%End If%> ]</p>
<p class="InfoBubble"><%=TXT_INST_LOGIN_1%> <span class="Alert"> <%=TXT_INST_LOGIN_2%></span></p>
<div class="max-width-sm">
<form action="login_check.asp" method="post" name="EntryForm" role="form" class="form-horizontal">
	<%=g_strCacheFormVals%>
	<div class="form-group">
		<label for="LoginName" class="control-label col-sm-2"><%=TXT_USER_NAME%></label>
		<div class="col-sm-10">
			<input name="LoginName" type="text" maxlength="60" class="form-control">
		</div>
	</div>
	<div class="form-group">
		<label for="LoginPwd" class="control-label col-sm-2"><%=TXT_PASSWORD%></label>
		<div class="col-sm-10">
			<input name="LoginPwd" type="password" class="form-control">
		</div>
	</div>
	<div class="form-group">
		<div class="col-sm-offset-2 col-sm-10">
			<input type="submit" class="btn btn-default" value="<%=TXT_SIGN_IN%>">
		</div>
	</div>
</form>
</div>
<%
End If
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
