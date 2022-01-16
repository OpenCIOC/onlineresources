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
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtSearchTax.asp" -->
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="includes/taxonomy/incTaxConceptList.asp" -->
<%
Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""" & ps_strPathToStart & makeAssetVer("styles/taxonomy.css") & """/>")

'Ensure user has super user privileges
If Not user_bSuperUserCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_TAXONOMY, TXT_MANAGE_TAXONOMY, True, False, True, True)
%>
<p>[
<%If g_bUseTaxonomyView Then%>
<a href="<%=makeLink("tax.asp","ST=0",vbNullString)%>" class="TaxLink"><%=TXT_KEYWORD%></a>
| <a href="<%=makeLink("tax.asp","ST=1",vbNullString)%>" class="TaxLink"><%=TXT_CODE_SEARCH%></a>
| <a href="<%=makeLink("tax.asp","ST=2",vbNullString)%>" class="TaxLink"><%=TXT_DRILL_DOWN_SEARCH%></a>
| <a href="<%=makeLink("tax.asp","ST=3",vbNullString)%>" class="TaxLink"><%=TXT_RELATED_CONCEPT_SEARCH%></a>
|
<%End If%>
<span class="HighLight"><%=TXT_MANAGE_TAXONOMY%></span>
]</p>

<table class="BasicBorder cell-padding-2">
<tr><th class="TitleBox" colspan="2"><%=TXT_MANAGE_TAXONOMY%></th></tr>
<%If user_bSuperUserGlobalCIC Then%>
<tr>
	<td>
		<a href="<%=makeLinkB("tax_mng_update.asp")%>"><%=TXT_UPDATE_TAXONOMY%></a>
		<br><a href="<%=makeLinkB("tax_src_edit.asp")%>"><%=TXT_MANAGE_SOURCES%></a>
		<br><a href="<%=makeLinkB("tax_fac_edit.asp")%>"><%=TXT_MANAGE_FACETS%></a>
		<br><a href="<%=makeLinkB("tax_edit.asp")%>"><%=TXT_CREATE_NEW_TERM%></a>
		<br><%=TXT_TO_EDIT_EXISTING_TERM%>
	</td>
</tr>
<form action="tax_rc_edit.asp" method="get">
<div style="display:none">
<%=g_strCacheFormVals%>
</div>
<tr><th class="RevTitleBox" colspan="2"><%=TXT_MANAGE_RELATED_CONCEPTS%></th></tr>
<%
	Call openRelatedConceptListRst(True)
%>
<tr>
	<td><span class="SmallNote"><%=TXT_BRACKETS_ONLY_IN & IIf(g_objCurrentLang.LangID=2,TXT_ENGLISH,TXT_FRENCH)%></span>
	<br><%=makeRelatedConceptList(vbNullString,"RCID",False,True)%> <input type="submit" value="<%=TXT_VIEW_EDIT_CONCEPT%>"></td>
</tr>
<%
	Call closeRelatedConceptListRst()
%>
</form>
<%End If%>
<tr><th class="RevTitleBox" colspan="2"><%=TXT_ACTIVATION_TOOLKIT%></th></tr>
<tr>
	<td>
		<a href="<%=makeLinkB("taxonomy/currentactivation")%>"><%=TXT_CURRENT_ACTIVATION%></a>
		<br><a href="<%=makeLinkB("taxonomy/activations")%>"><%=TXT_ACTIVATION_TOOL%></a>
<%If user_bSuperUserGlobalCIC Then%>
		<br><a href="<%=makeLinkB("tax_preferred_add.asp")%>"><%=TXT_MANAGE_PREFERRED_TERM_LIST%></a>
<%End If%>
		<br><a href="<%=makeLinkB("taxonomy/preferredcompliance")%>"><%=TXT_PREFERRED_TERM_COMPLIANCE_REPORT%></a>
		<br><a href="<%=makeLinkB("taxonomy/multilevelreport")%>"><%=TXT_MULTILEVEL_REPORT%></a>
		<br><a href="<%=makeLinkB("taxonomy/activationrec")%>"><%=TXT_ACTIVATION_RECOMENDATIONS%></a>
	</td>
</tr>
</table>


<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
