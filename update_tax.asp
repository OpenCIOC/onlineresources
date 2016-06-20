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
' Purpose: 		Taxonomy Record Indexing (Update Service Categories).
'				This file provides a wrapper around the Taxonomy search file (tax.asp)
'				which is embedded into this page using an IFRAME. Terms can be selected
'				to build up lists of terms for adding to the record.
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
<!--#include file="text/txtFieldHistory.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtSearchTax.asp" -->
<!--#include file="text/txtTaxUpdate.asp" -->
<!--#include file="text/txtSearchResultsTax.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incIndexFieldList.asp" -->
<!--#include file="includes/taxonomy/incTaxPassVars.asp" -->
<!--#include file="includes/update/incFieldHistory.asp" -->
<%
'***************************************
' Begin Function getInitScript
'	Generate JavaScript commands to fill the appropriate array
'	with the Term Codes and Names so they can be displayed.
'		rsTerms - recordset containing the list of Term Codes, Names and Link IDs.
'***************************************
Function getInitScript(rsTerms)

	Dim strReturn, _
		strLink, _
		strLinkCon, _
		intPrevLink, _
		i, _
		j

	strLinkCon = vbNullString

	intPrevLink = -1

	'Build the JavaScript commands to fill the array
	With rsTerms
		If Not .EOF Then
			i = -1
			While Not .EOF
				If .Fields("BT_TAX_ID") <>  intPrevLink Then
					i = i + 1
					j = 0
					strReturn = strReturn & _
						"linkList['Index'].links[" & i & "] = new Array();" & vbCrLf 
				End If
				strReturn = strReturn & _
					"linkList['Index'].links[" & i & "][" & j & "] = new TermObj(" & JsQs(.Fields("Code")) & "," & JsQs(.Fields("Term")) & ");" & vbCrLf
				j = j + 1
				intPrevLink = .Fields("BT_TAX_ID")
				.MoveNext
			Wend 
		End If
	End With

	getInitScript = strReturn	
End Function
'***************************************
' End Function getInitScript
'***************************************

Dim bNUMError, _
	strErrorMsg
bNUMError = False

'Retreive the Record # of the record we are trying to update.
'If no Record # is given or the Record # is invalid, set an error message.
Dim strNUM
strNUM = Request("NUM")

If Nl(strNUM) Then
	bNUMError = True
	strErrorMsg = TXT_NO_RECORD_CHOSEN
ElseIf Not IsNUMType(strNUM) Then
	strErrorMsg = TXT_INVALID_ID & Server.HTMLEncode(strNUM) & "."
End If

Dim strOrgName, _
	strModifiedDate, _
	strModifiedBy

'If we have not encountered any other errors, 
'retrieve the list of Terms provided to index the given record.
If Not bNUMError Then

	Dim cmdListSelected, _
		rsListSelected
	
	Set cmdListSelected = Server.CreateObject("ADODB.Command")
	With cmdListSelected
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_CIC_NUMTaxonomy_sf"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		Set rsListSelected = .Execute
	End With
	
	If rsListSelected.EOF Then
		bNUMError = True
		strErrorMsg = TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strNUM) & "."
		
		rsListSelected.Close
		Set cmdListSelected = Nothing
		Set rsListSelected = Nothing
	ElseIf Not rsListSelected.Fields("CAN_INDEX") Then
		Call securityFailure()
	End If
End If

'If there is an error, print the details
If bNUMError Then
	Call makePageHeader(TXT_UPDATE_TAXONOMY_TITLE, TXT_UPDATE_TAXONOMY_TITLE, True, False, True, True)
	Call handleError(strErrorMsg, vbNullString, vbNullString)
	Call makePageFooter(True)
Else
	strOrgName = rsListSelected.Fields("ORG_NAME_FULL")
	strModifiedDate = IIf(Nl(rsListSelected("TAX_MODIFIED_DATE")),TXT_UNKNOWN,rsListSelected("TAX_MODIFIED_DATE"))
	strModifiedBy = IIf(Nl(rsListSelected("TAX_MODIFIED_BY")),TXT_UNKNOWN,rsListSelected("TAX_MODIFIED_BY"))
	
	Set rsListSelected = rsListSelected.NextRecordset

	'Add Taxonomy Style Sheet
	Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""" & ps_strPathToStart & "styles/taxonomy.css""/>")
	
	'Add script to initialize image and language constants.
	Call addToHeader("<script type='text/javascript'>" & vbCrLf & _
		"var xImage = '<img src=""" & ps_strPathToStart & "images/x.gif"" BORDER=""0"">';" & vbCrLf & _
		"var eImage = '<img src=""" & ps_strPathToStart & "images/edit.gif"" BORDER=""0"">';" & vbCrLf & _
		"var suggestURL = " & JsQs(makeLinkB(ps_strPathToStart & "tax.asp") & IIf(Nl(g_strCacheHTTPVals),"?","&")) & ";" & vbCrLf & _
		"var noTerms = " & JsQs(TXT_NO_TERMS) & ";" & vbCrLf & _
		"var noneChosen = " & JsQs(TXT_NO_TERMS_SELECTED) & " + '\n' + " & JsQs(TXT_ARE_YOU_SURE_SUBMIT) & ";" & vbCrLf & _
		"</script>")
	
	'Add scripts for adding terms to the Build List and Search Lists
	Call addScript(ps_strPathToStart & "scripts/taxBuildList.js", "text/javascript")
	Call addScript(ps_strPathToStart & "scripts/taxIndex.js", "text/javascript")
	Call addScript(ps_strPathToStart & "scripts/displayField.js", "text/javascript")
	
	'Add script to allow for display of existing Term indexing for this record
	Call addToHeader("<script type='text/javascript'>" & getInitScript(rsListSelected) & "</script>")
	
	rsListSelected.Close
	Set cmdListSelected = Nothing
	Set rsListSelected = Nothing

	Call makePageHeader(TXT_UPDATE_TAXONOMY_TITLE, TXT_UPDATE_TAXONOMY_TITLE, True, False, True, True)
%>
<h2><%=TXT_EDIT_SERVICE_CATEGORIES_FOR%>
<br><a href="<%=makeDetailsLink(strNUM, StringIf(intCurSearchNumber >= 0,"Number=" & intCurSearchNumber),vbNullString)%>"><%=strOrgName%></a></h2>
<table class="NoBorder cell-padding-2"><tr>
	<td class="FieldLabelLeftClr"><%=TXT_LAST_MODIFIED%><%=TXT_COLON%></td><td><%=strModifiedDate%></td>
	<td>&nbsp;</td>
	<td class="FieldLabelLeftClr"><%=TXT_MODIFIED_BY%></td><td><%=TXT_COLON%><%=strModifiedBy%></td>
	<td>&nbsp;</td>
<%
	Call openIndexFieldRst(strNUM)
%>
	<td class="FieldLabelLeftClr"><%=TXT_SHOW_FIELD%></td><td><%=makeIndexFieldList("ShowField",strNUM)%></td>
<%
	Call closeIndexFieldRst()
%>
	<td>&nbsp;</td>
	<td class="FieldLabelLeftClr"><%=TXT_HISTORY%></td><td><img src="<%=ps_strPathToStart%>images/versions.gif" width="17" height="17" class="ShowVersions SimulateLink" data-ciocid="<%= strNUM %>" data-ciocfield="TAXONOMY" data-ciocfielddisplay="<%= TXT_SERVICE_CATEGORIES %>" border="0"></td>
</tr></table>
<span id="FieldContents"></span>
<br>
<table class="NoBorder" cellpadding="0" cellspacing="0" width="100%">
<tr valign="TOP">
	<td width="70%"><iframe id="searchFrame" name="searchFrame" src="<%=makeLink("tax.asp","MD=" & MODE_INDEX,vbNullString)%>" frameborder="0" vspace="3" hspace="0" class="Search"></iframe></td>
	<td width="15"><img src="images/spacer.gif" width="15" height="1"></td>
	<td style="vertical-align: top;"><form name="Search" method="GET" action="update_tax2.asp">
	<%=g_strCacheFormVals%>
<%	If intCurSearchNumber >= 0 Then%>
	<input type="hidden" name="Number" value="<%=intCurSearchNumber%>">
<%	End If%>
	<input type="hidden" name="NUM" value="<%=strNUM%>">
	<input type="hidden" name="TMC" id="IndexInput">
	<div class="TermListTitle"><%=TXT_BUILD_TERM_LIST%></div>
	<div class="TermList"><span id="BuildTermList"></span></div>
	<div id="SelectDiv" style="display:none;"><a href="#javascript" class="ButtonLink" onClick="sendBuildToLinkList('Index')"><%=TXT_ADD_TERMS%></a></div>
	<div id="SuggestDiv" style="display:none;"><br style="clear:left;"><a href="#javascript" class="ButtonLink" onClick="suggestLink()"><%=TXT_SUGGEST_LINK%></a>
	<a href="#javascript" class="ButtonLink" onClick="suggestTerm()"><%=TXT_SUGGEST_TERM%></a></div>
	<div class="TermListTitle" style="clear:left"><%=TXT_TERMS_FOR_THIS_RECORD & TXT_COLON%></div>
	<div class="TermList"><span id="IndexTermList"></span></div>
	<div><a href="#javascript" class="ButtonLink" onClick="submitForm()"><%=TXT_SUBMIT_UPDATES%></a>
	<a href="#javascript" class="ButtonLink" onClick="resetForm()"><%=TXT_RESET_FORM%></a></div>
	</form></td>
</tr>
</table>

<%= makeJQueryScriptTags() %>
<%
	Call printHistoryDialog(strNUM)
	
	Call makePageFooter(True)
End If
%>
<!--#include file="includes/core/incClose.asp" -->
