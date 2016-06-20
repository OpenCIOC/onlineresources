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
'
' Purpose: 		Display the form for editing an existing Taxonomy Term, or creating a new Term
'
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
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="text/txtTaxPreferred.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/taxonomy/incTaxConceptList.asp" -->
<%
'Ensure user has super user privileges
If Not user_bSuperUserGlobalCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_PREFERRED_TERM_LIST, TXT_MANAGE_PREFERRED_TERM_LIST, True, False, True, True)
%>
<p>[ <a href="<%=makeLinkB("tax_mng.asp")%>"><%=TXT_RETURN_MANAGE_TAXONOMY%></a> ]</p>

<form action="tax_preferred_add2.asp" method="post" class="form">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-4 form-table responsive-table clear-line-below max-width-lg">
<tr><th class="TitleBox" colspan="2"><%=TXT_MANAGE_PREFERRED_TERM_LIST%></th></tr>
<tr>
	<td class="field-label-cell"><label for="TermList"><%=TXT_TERM_LIST%></label></td>
	<td class="field-data-cell"><span class="SmallNote"><%=TXT_ENTER_LIST_OF_TERMS%></span>
		<br><textarea name="TermList" id="TermList" wrap="soft" rows="<%=TEXTAREA_ROWS_XLONG%>" class="form-control"></textarea></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_RESET%></td>
	<td class="field-data-cell"><label for="RefreshAll_On"><input type="radio" name="RefreshAll" id="RefreshAll_On" value="on">&nbsp;<%=TXT_RESET_ALL%></label>
		<br><label for="RefreshAll"><input type="radio" name="RefreshAll" id="RefreshAll" value="" checked>&nbsp;<%=TXT_ADD_NEW_ONLY%></label></td>
</tr>

</table>
	<input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>" class="btn btn-default">
	<input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default">
</form>
<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
