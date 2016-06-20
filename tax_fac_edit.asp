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
' Purpose:		Form to edit values for a Taxonomy Facet.
'				Values are stored in table: TAX_Facet.
'				Super User privileges for CIC are required.
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
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%
'Ensure user has super user privileges
If Not user_bSuperUserCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Dim SUBMIT_BUTTON, _
	DELETE_BUTTON, _
	ADD_BUTTON

SUBMIT_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_UPDATE & """>"
DELETE_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_DELETE & """>"
ADD_BUTTON = "<input type=""Submit"" name=""Submit"" value=""" & TXT_ADD & """>"

Call makePageHeader(TXT_MANAGE_SOURCES_TITLE, TXT_MANAGE_SOURCES_TITLE, True, False, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("tax_mng.asp")%>"><%=TXT_RETURN_MANAGE_TAXONOMY%></a> ]</p>
<%
'Open this list of all Facets and print a table of the values
Dim cmdListTaxonomyFacet, rsListTaxonomyFacet
Set cmdListTaxonomyFacet = Server.CreateObject("ADODB.Command")
With cmdListTaxonomyFacet
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_TAX_Facet_lf"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With
Set rsListTaxonomyFacet = Server.CreateObject("ADODB.Recordset")
With rsListTaxonomyFacet
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdListTaxonomyFacet
End With

Dim xmlDoc, xmlNode, strCulture, strValue, intIdentifier

%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th class="RevTitleBox"><%=TXT_NAME%></th>
	<th class="RevTitleBox"><%=TXT_USAGE%></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<%
intIdentifier = 0
With rsListTaxonomyFacet
	While Not .EOF
		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With

		xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"
%>
<form action="tax_fac_edit2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="FCID" value="<%=.Fields("FC_ID")%>">
<tr>
	<td><table class="NoBorder cell-padding-2">
<%
For Each strCulture in active_cultures()
	Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture, SQUOTE) & "]")
	If xmlNode IS Nothing Then
		strValue = vbNullString
	Else 
		strValue = Server.HTMLEncode(Ns(xmlNode.getAttribute("Facet")))
	End If
%>
	<tr>
		<td class="FieldLabelLeftClr"><label for="Facet_<%=strCulture & "_" & intIdentifier%>"><%=Application("Culture_" & strCulture & "_LanguageName")%></label></td>
		<td><input type="text" size="<%=TEXT_SIZE%>" maxlength="100" name="Facet_<%=strCulture%>" id="Facet_<%=strCulture & "_" & intIdentifier%>" value=<%=AttrQs(strValue)%>></td>
	</tr>
<%
intIdentifier = intIdentifier + 1
Next
%>
	</table></td>
	<td><%=.Fields("UsageCount")%></td>
	<td><%=SUBMIT_BUTTON%><%If .Fields("UsageCount")=0 Then%>&nbsp;<%=DELETE_BUTTON%><%End If%></td>
</tr>
</form>
<%
		.MoveNext
	Wend
End With
%>
<form action="tax_fac_edit2.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
</div>
<tr>
	<td colspan="2"><table class="NoBorder cell-padding-2">
<%
For Each strCulture in active_cultures()
%>
	<tr>
		<td class="FieldLabelLeftClr"><label for="Facet_<%=strCulture%>"><%=Application("Culture_" & strCulture & "_LanguageName")%></label></td>
		<td><input type="text" size="<%=TEXT_SIZE%>" maxlength="100" name="Facet_<%=strCulture%>" id="Facet_<%=strCulture%>"></td>
	</tr>
<%
Next
%>
	</table></td>
	<td><%=ADD_BUTTON%></td>
</tr>
</form>
</table>
<%
If rsListTaxonomyFacet.State <> adStateClosed Then
	rsListTaxonomyFacet.Close
End If
Set cmdListTaxonomyFacet = Nothing
Set rsListTaxonomyFacet = Nothing
%>

<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
