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
<p><span class="AlertBubble"><%=TXT_WARNING_INCOMPLETE%></span></p>
<p><%=TXT_TAXONOMY_UPDATE_STARTED_AT & Time()%>
<p>
<%
Response.Write(". ")
Response.Flush()

Dim cmdUpdateTaxonomy
Set cmdUpdateTaxonomy = Server.CreateObject("ADODB.Command")
With cmdUpdateTaxonomy
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_TAX_UPDATER_1"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Execute
End With

Response.Write(". ")
Response.Flush()
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_2"
	.Execute
End With

Response.Write(". ")
Response.Flush()
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_3"
	.Execute
End With

Response.Write(". ")
Response.Flush()
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_4"
	.Execute
End With

Response.Write(". ")
Response.Flush()
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_5"
	.Execute
End With

Response.Write(". ")
Response.Flush()
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_6"
	.Execute
End With

Response.Write(". ")
Response.Flush()
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_7"
	.Execute
End With

Response.Write(". ")
Response.Flush()
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_8"
	.Execute
End With

Dim cmdUpdateTaxSrch, rsUpdateTaxSrch, objTopCount
Set cmdUpdateTaxSrch = Server.CreateObject("ADODB.Command")
With cmdUpdateTaxSrch
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_SRCH_TAX_u"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Prepared = True
	Set objTopCount = .CreateParameter("@TOP", adInteger, adParamInputOutput, 4, 200)
	.Parameters.Append objTopCount
End With

While objTopCount.Value > 0
	Response.Write(". ")
	Response.Flush()
	objTopCount.Value = 500
	Set rsUpdateTaxSrch = cmdUpdateTaxSrch.Execute
	Set rsUpdateTaxSrch = rsUpdateTaxSrch.NextRecordset
Wend

Response.Write(". ")
Response.Flush()

With cmdUpdateTaxSrch
	.CommandText = "dbo.sp_CIC_SRCH_PubTax_u"
	objTopCount.Value = 200
	.Parameters.Delete "@TOP"
	.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 9, Null)
	.Parameters.Append objTopCount
End With

While objTopCount.Value > 100
	Response.Write(". ")
	Response.Flush()
	objTopCount.Value = 500
	Set rsUpdateTaxSrch = cmdUpdateTaxSrch.Execute
	Set rsUpdateTaxSrch = rsUpdateTaxSrch.NextRecordset
Wend

Response.Write(". ")
Response.Flush()

With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_9"
	.Execute
End With

%>
</p>
<p><%=TXT_TAXONOMY_UPDATE_FINISHED_AT & Time()%></p>

<%
With cmdUpdateTaxonomy
	.CommandText = "dbo.sp_TAX_UPDATER_Term_s_Code_Unmatched"
End With

Dim rsUpdateTaxonomy
Set rsUpdateTaxonomy  = Server.CreateObject("ADODB.Recordset")
With rsUpdateTaxonomy
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdUpdateTaxonomy
End With

With rsUpdateTaxonomy
	If Not .EOF Then
%>
<p><span class="AlertBubble"><%=TXT_TAXONOMY_UPDATE_INCOMPLETE%></span></p>
<table class="BasicBorder cell-padding-2">
	<thead>
		<tr>
			<th class="RevTitleBox"><%=TXT_CODE%></th>
			<th class="RevTitleBox"><%=TXT_NAME%></th>
			<th class="RevTitleBox"><%=TXT_USAGE%></th>
			<th class="RevTitleBox"><%=TXT_HEADINGS%></th>
			<th class="RevTitleBox"><%=TXT_RECOMMENDED_REPLACEMENTS%></th>
		</tr>
	</thead>
	<tbody>
<%
		While Not .EOF
%>
<tr>
	<td><%=.Fields("Code")%></td>
	<td><%=IIf(g_objCurrentLang.Culture=CULTURE_FRENCH_CANADIAN,Nz(.Fields("TermEq"),.FieldS("Term")),Nz(.Fields("Term"),.Fields("TermEq")))%></td>
	<td><a href="<%=makeLink("results.asp","IncDel=on&TMCR=on&TMC=" & .Fields("Code"),vbNullString)%>"><%=.Fields("USAGE_COUNT")%></a></td>
	<td><%=.Fields("HEADING_USAGE_COUNT")%></td>
	<td><%=.Fields("NewCode")%></td>
</tr>
<%
			.MoveNext
		Wend
%>
	</tbody>
</table>
<%
	End If
	.Close
End With

Set rsUpdateTaxonomy = Nothing
Set cmdUpdateTaxonomy = Nothing

Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
