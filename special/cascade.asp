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
Call setPageInfo(False, DM_GLOBAL, DM_GLOBAL, "../", "special/", "EntryForm.LoginName")
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtUsers.asp" -->
<% 
Call makePageHeader(TXT_DATABASE_LOGIN, TXT_DATABASE_LOGIN, False, False, True, True)
%>
<!-- <p>[ <%If g_bUseCIC Or user_bLoggedIn Then%><a href="<%=makeLinkB(ps_strPathToStart)%>"><%=TXT_ORG_SEARCH%></a><%End If%><%If g_bUseVOL Then%> | <a href="<%=makeLinkB(ps_strPathToStart & "volunteer/")%>"><%=TXT_VOLUNTEER_SEARCH%></a><%End If%> ]</p> -->
<p class="Info"><%=TXT_INST_LOGIN_1%></p>
<p class="Alert"><%=TXT_INST_LOGIN_2%></p>
<form action="cascade2.asp" METHOD="post" name="EntryForm">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-3">
	<tr>
		<td class="FieldLabelLeft"><%=TXT_USER_NAME%></td>
		<td><input id="LoginName" name="LoginName" type="text" size="30" maxlength="30"></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_PASSWORD%></td>
		<td><input id="LoginPwd" name="LoginPwd" type="password" size="30"></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft">Sign in to...</td>
		<td>
			<table class="NoBorder cell-padding-2">
				<tr>
					<td>
						<input name="CascadeLogin" class="CascadeLogin" type="checkbox" value="https://haldimand.cioc.ca" checked data-statusui="haldimand">&nbsp;<a href="https://haldimand.cioc.ca/">Haldimand, Norfolk and Brant (haldimand.cioc.ca)</a>
					</td>
					<td>
						<span class="LoginStatusUI NotVisible" id="haldimand_loading">Loading...</span>
						<span class="LoginStatusUI NotVisible" id="haldimand_success">Success</span>
						<span class="LoginStatusUI NotVisible" id="haldimand_failure">Failure</span>
					</td>
				</tr>
				<tr>
					<td>
						<input name="CascadeLogin" class="CascadeLogin" type="checkbox" value="https://niagara.cioc.ca" checked data-statusui="niagara">&nbsp;<a href="https://niagara.cioc.ca/">Niagara (niagara.cioc.ca)</a>
					</td>
					<td>
						<span class="LoginStatusUI NotVisible" id="niagara_loading">Loading...</span>
						<span class="LoginStatusUI NotVisible" id="niagara_success">Success</span>
						<span class="LoginStatusUI NotVisible" id="niagara_failure">Failure</span>
					</td>
				</tr>
				<tr>
					<td>
						<input name="CascadeLogin" class="CascadeLogin" type="checkbox" value="https://informationhamilton.ca" checked data-statusui="hamilton">&nbsp;<a href="https://informationhamilton.ca/redbook">Hamilton (informationhamilton.ca/redbook)</a>
					</td>
					<td>
						<span class="LoginStatusUI NotVisible" id="hamilton_loading">Loading...</span>
						<span class="LoginStatusUI NotVisible" id="hamilton_success">Success</span>
						<span class="LoginStatusUI NotVisible" id="hamilton_failure">Failure</span>
					</td>
				</tr>
				<tr>
					<td>
						<input name="CascadeLogin" class="CascadeLogin" type="checkbox" value="https://halton.cioc.ca" checked data-statusui="halton">&nbsp;<a href="https://halton.cioc.ca/">Halton (halton.cioc.ca)</a>
					</td>
					<td>
						<span class="LoginStatusUI NotVisible" id="halton_loading">Loading...</span>
						<span class="LoginStatusUI NotVisible" id="halton_success">Success</span>
						<span class="LoginStatusUI NotVisible" id="halton_failure">Failure</span>
					</td>
				</tr>
				<!--
				<tr>
					<td>
						<input name="CascadeLogin" class="CascadeLogin" type="checkbox" value="https://waterlooregion.cioc.ca" checked data-statusui="waterloo">&nbsp;<a href="https://waterlooregion.cioc.ca/">Waterloo Region (waterlooregion.cioc.ca)</a>
					</td>
					<td>
						<span class="LoginStatusUI NotVisible" id="waterloo_loading">Loading...</span>
						<span class="LoginStatusUI NotVisible" id="waterloo_success">Success</span>
						<span class="LoginStatusUI NotVisible" id="waterloo_failure">Failure</span>
					</td>
				</tr>
				-->
				<tr>
					<td>
						<input name="CascadeLogin" class="CascadeLogin" type="checkbox" value="https://communitylinks.cioc.ca" checked data-statusui="guelph">&nbsp;<a href="https://communitylinks.cioc.ca/">Guelph-Wellington (communitylinks.cioc.ca)</a>
					</td>
					<td>
						<span class="LoginStatusUI NotVisible" id="guelph_loading">Loading...</span>
						<span class="LoginStatusUI NotVisible" id="guelph_success">Success</span>
						<span class="LoginStatusUI NotVisible" id="guelph_failure">Failure</span>
					</td>
				</tr>
				<tr>
					<td>
						<input name="CascadeLogin" class="CascadeLogin" type="checkbox" value="https://informationcnd.cioc.ca" checked data-statusui="cambridge">&nbsp;<a href="https://informationcnd.cioc.ca/">Waterloo Region (informationcnd.cioc.ca)</a>
					</td>
					<td>
						<span class="LoginStatusUI NotVisible" id="cambridge_loading">Loading...</span>
						<span class="LoginStatusUI NotVisible" id="cambridge_success">Success</span>
						<span class="LoginStatusUI NotVisible" id="cambridge_failure">Failure</span>
					</td>
				</tr>
			</table>
			<input id="uncheckall" type="button" value="Uncheck All">
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<input id="login" type="button" value="<%=TXT_SIGN_IN%>">
			<input id="logout" type="button" value="<%=TXT_LOGOUT%>">
		</td>
	</tr>
</table>

</form>
<div style="display: none;">
<form id="hidden_form" action="cascade2.asp" target="theIframe" method="post">
<%
Dim strAccessURL
strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPageFull,"$1",True,False,False,False)
strAccessURL = IIf(g_bSSL, "https://", "http://") & Request.ServerVariables("HTTP_HOST") & strAccessURL
%>
<input id="srcdb" type="hidden" name="srcdb" value="<%=strAccessURL%>">
<input id="log_in_out" type="hidden" name="log_in_out">
<input id="hidden_name" type="hidden" name="LoginName">
<input id="hidden_pwd" type="hidden" name="LoginPwd">
</form>

<iframe name="theIframe" id="hiddenIframe"></iframe>
</div>

<%= makeJQueryScriptTags() %>
<script type="text/javascript">
(function() {
	var $ = jQuery,
	login_sites = [],
	current_timeout = null,
	next_login = function() {
		if (current_timeout) {
			clearTimeout(current_timeout);
			current_timeout = null;
		}
		if ( login_sites.length === 0) {
			current_site = null;
			return;
		}

		current_site = login_sites.shift();

		var prefix = '#' + $(current_site).data('statusui');

		$(prefix + '_loading').show();
		current_timeout = setTimeout(login_timeout, 10000);
		$('#hidden_form').attr('action', current_site.value + '/special/cascade2.asp').submit();
	
	},
	login_callback = function(success_fail) {
		return function() {
			var prefix = '#' + $(current_site).data('statusui');
			$(prefix + '_loading').hide();
			$(prefix + success_fail).show();
			next_login();
		}
	},
	login_success = login_callback('_success'),
	login_failure = login_callback('_failure'),
	login_timeout = function() {
		current_timeout = null;
		$('#hiddenIframe').src = "";
		login_failure();
	},
	do_remote_action = function(action) {
		return function(event) {
			$('#log_in_out')[0].value = action;
			$('#hidden_name')[0].value = $('#LoginName')[0].value;
			$('#hidden_pwd')[0].value = $('#LoginPwd')[0].value;

			$('span.LoginStatusUI').hide();

			login_sites = $('input.CascadeLogin:checked').get();

			next_login();
			return false;
		}
	};

	window['login_success'] = login_success;
	window['login_failure'] = login_failure;

	$(function($) {
		$('#login').click(do_remote_action('Login'));
		$('#logout').click(do_remote_action('Logout'));
		$('#uncheckall').click(function() {
			$('input.CascadeLogin:checked').attr('checked', false);
		})
	});
})();
</script>

<%
Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
