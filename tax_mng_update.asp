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
<!--#include file="text/txtSearchTax.asp" -->
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%
Server.ScriptTimeOut = 2400

Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""" & ps_strPathToStart & makeAssetVer("styles/taxonomy.css") & """/>")

'Ensure user has super user privileges
If Not user_bSuperUserCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_TAXONOMY, TXT_MANAGE_TAXONOMY, True, False, True, True)
%>
<p>[
<a href="<%=makeLink("tax.asp","ST=0",vbNullString)%>" class="TaxLink"><%=TXT_KEYWORD%></a>
| <a href="<%=makeLink("tax.asp","ST=1",vbNullString)%>" class="TaxLink"><%=TXT_CODE_SEARCH%></a>
| <a href="<%=makeLink("tax.asp","ST=2",vbNullString)%>" class="TaxLink"><%=TXT_DRILL_DOWN_SEARCH%></a>
| <a href="<%=makeLink("tax.asp","ST=3",vbNullString)%>" class="TaxLink"><%=TXT_RELATED_CONCEPT_SEARCH%></a>
| <a href="<%=makeLinkB("tax_mng.asp")%>" class="TaxLink"><%=TXT_MANAGE_TAXONOMY%></a>
]</p>
<%
Dim cmdUpdateTaxonomy, rsUpdateTaxonomy
Set cmdUpdateTaxonomy = Server.CreateObject("ADODB.Command")
With cmdUpdateTaxonomy
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_TAX_UPDATER_Info"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Execute
End With

Set rsUpdateTaxonomy = cmdUpdateTaxonomy.Execute

If rsUpdateTaxonomy.EOF Then
%>
<%=TXT_UNABLE_TO_RETRIEVE_TAXONOMY_INFO%>
<%
Else
%>
<p><%=TXT_SYNCHRONIZE_RELEASE%></p>
<table class="BasicBorder cell-padding-2">
<%
	With rsUpdateTaxonomy
		While Not .EOF
%>
<tr>
	<td><%=.Fields("Country")%></td>
	<td><%=.Fields("Language")%></td>
	<td><%=DateTimeString(.Fields("ReleaseDate"),True)%></td>
</tr>
<%
			.MoveNext
		Wend
	End With
%>
</table>
<%
	
	Set rsUpdateTaxonomy = rsUpdateTaxonomy.NextRecordSet

	If rsUpdateTaxonomy.EOF Then
	%>
	<%=TXT_UNABLE_TO_RETRIEVE_TAXONOMY_INFO%>
	<%
	Else
		If Not Nl(rsUpdateTaxonomy.Fields("ReleaseNotes")) Then
%>
<p><%=rsUpdateTaxonomy.Fields("ReleaseNotes")%></p>
<%
		End If
%>
<h4><%=TXT_STATUS%></h4>
<%
		If rsUpdateTaxonomy.Fields("NOT_UP_TO_DATE") Then
%>
<p class="Alert"><%=TXT_TAXONOMY_NOT_UPTODATE%></p>
<%
		Else
%>
<p class="Info"><%=TXT_TAXONOMY_UPTODATE%></p>
<%
		End If
%>
<form action="tax_mng_update2.asp" action="post">
<%=g_strCacheFormVals%>
<p><input type="submit" value="<%=TXT_UPDATE%>"></p>
</form>
<%
	End If
End If

Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
