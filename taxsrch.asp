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
'Purpose: 		Advanced Taxonomy Record Search.
'				This file provides a wrapper around the Taxonomy search file (tax.asp)
'				which is embedded into this page using an IFRAME. Terms can be selected
'				to build up lists of terms for searching.
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
<!--#include file="text/txtSearchResultsTax.asp" -->
<!--#include file="text/txtSearchTax.asp" -->
<!--#include file="includes/search/incCommSrchCIC.asp" -->
<!--#include file="includes/taxonomy/incTaxPassVars.asp" -->
<%
'***************************************
' Begin Function getInitScript
'	Retrieve Term information based on a list of codes,
'	and generate JavaScript commands to fill the appropriate array
'	with the Term Codes and Names so they can be displayed.
'		strTermList - List of Taxonomy Codes (list of linked lists)
'		strListName - Name of the list (for array)
'***************************************
Function getInitScript(strTermList, strListName)

	Dim strReturn, _
		strLink, _
		strLinkCon, _
		intPrevLink, _
		aLinks, _
		i, _
		j
		
	Dim cmdListDisplay, _
		rsListDisplay, _
		strTLSQL

	aLinks = Split(strTermList,",")
	strLinkCon = vbNullString
	strTLSQL = vbNullString

	'Generate SQL to get a list of Term names for all the valid Codes in each linked set of Terms
	For i = 0 To UBound(aLinks)
		strLink = reReplace(aLinks(i),"\s*~\s*",",",False,False,True,False)
		
		If IsTaxCodeList(strLink) Then
			strTLSQL = strTLSQL & strLinkCon & "SELECT DISTINCT " & i & " AS LNK_ID, tm.Code, " & _
					"CASE WHEN tmd.LangID=@@LANGID THEN ISNULL(tmd.AltTerm,tmd.Term) ELSE '[' + ISNULL(tmd.AltTerm,tmd.Term) + ']' END" & _
					" AS Term" & vbCrLf & _
				"FROM TAX_Term tm " & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
				"	ON tm.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE tmd.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
				"WHERE tm.Code IN ('" & Replace(strLink,",","','") & "') AND tm.Active IS NOT NULL"
			strLinkCon = vbCrLf & "UNION "
		End If
	Next
	
	intPrevLink = -1
	If Not Nl(strTLSQL) Then
		strTLSQL = "SET NOCOUNT ON" & vbCrLf & strTLSQL & vbCrLf & "ORDER BY LNK_ID, Term SET NOCOUNT OFF"

		Set cmdListDisplay = Server.CreateObject("ADODB.Command")
		With cmdListDisplay
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdText
			.CommandText = strTLSQL
			.CommandTimeout = 0
			Set rsListDisplay = .Execute
		End With
		
		'Build the JavaScript commands to fill the array
		With rsListDisplay
			If Not .EOF Then
				i = -1
				While Not .EOF
					If .Fields("LNK_ID") <>  intPrevLink Then
						i = i + 1
						j = 0
						strReturn = strReturn & _
							"linkList['" & strListName & "'].links[" & i & "] = new Array();" & vbCrLf 
					End If
					strReturn = strReturn & _
						"linkList['" & strListName & "'].links[" & i & "][" & j & "] = new TermObj(" & JsQs(.Fields("Code")) & "," & JsQs(.Fields("Term")) & ");" & vbCrLf
					j = j + 1
					intPrevLink = .Fields("LNK_ID")
					.MoveNext
				Wend 
			End If
			.Close
		End With
	End If

	Set cmdListDisplay = Nothing
	Set rsListDisplay = Nothing

	getInitScript = strReturn	
End Function
'***************************************
' End Function getInitScript
'***************************************


'Add Taxonomy Style Sheet
Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""" & ps_strPathToStart & makeAssetVer("styles/taxonomy.css") & """/>")

'Add script to initialize image and language constants.
Call addToHeader("<script type='text/javascript'>" & vbCrLf & _
	"var xImage = '<img src=""" & ps_strPathToStart & "images/x.gif"" BORDER=""0"">';" & vbCrLf & _
	"var eImage = '<img src=""" & ps_strPathToStart & "images/edit.gif"" BORDER=""0"">';" & vbCrLf & _
	"var suggestURL = " & JsQs(makeLinkB(ps_strPathToStart & "tax.asp") & IIf(Nl(g_strCacheHTTPVals),"?","&")) & ";" & vbCrLf & _
	"var noTerms = " & JsQs(TXT_NO_TERMS) & ";" & vbCrLf & _
	"var noneChosen = " & JsQs(TXT_NO_TERMS_SELECTED) & ";" & vbCrLf & _
	"</script>")

'Add scripts for adding terms to the Build List and Search Lists
Call addToHeader(JSVerScriptTag("scripts/taxBuildList.js"))
Call addToHeader(JSVerScriptTag("scripts/taxAdvSearch.js"))

'If we are editing an existing search, fetch the existing Search parameters
Dim strTMC, _
	strATMC, _
	bTMCRestricted
	
strTMC = Trim(Request("TMC"))
strATMC = Trim(Request("ATMC"))
bTMCRestricted = Request("TMCR") = "on"

Dim strMatchScript

'If we have parameters for the "Must match" list,
'generate javascript to fill the "Must match" box with the Terms
If IsLinkedTaxCodeList(strTMC) Then
	strMatchScript = strMatchScript & getInitScript(strTMC,"All")
Else
	strTMC = Null
End If

'If we have parameters for the "Match at least one from" list,
'generate javascript to fill the "Match at least one from" box with the Terms
If IsLinkedTaxCodeList(strATMC) Then
	strMatchScript = strMatchScript & getInitScript(strATMC,"Any")
Else
	strATMC = Null
End If

'Add any the script to insert any existing search parameters
Call addToHeader("<script type='text/javascript'>" & strMatchScript & "</script>")

Call makePageHeader(TXT_ADVANCED_TAXONOMY_SEARCH, TXT_ADVANCED_TAXONOMY_SEARCH, True, False, True, True)

Dim	bSrchCommunityDefault

' Get Advanced Search View data
Dim cmdASrchViewData, rsASrchViewData
Set cmdASrchViewData = Server.CreateObject("ADODB.Command")
With cmdASrchViewData
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_View_s_ASrch"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
End With
Set rsASrchViewData = cmdASrchViewData.Execute

' CIC View data
With rsASrchViewData
	If Not .EOF Then
		bSrchCommunityDefault = .Fields("SrchCommunityDefault")
	End If
End With

%>
<form name="Search" method="GET">
<%=g_strCacheFormVals%>
<input type="hidden" name="TMC" id="MustMatchInput">
<input type="hidden" name="ATMC" id="MatchAnyInput">
<table border="0" class="NoBorder" cellpadding="0" cellspacing="0" width="100%">
<tr valign="TOP">
	<td width="70%"><iframe id="searchFrame" name="searchFrame" src="<%=makeLink("tax.asp","MD=" & MODE_ADVANCED,vbNullString)%>" frameborder="0" vspace="3" hspace="0" class="Search"></iframe></td>
	<td width="15"><img src="images/spacer.gif" width="15" height="1"></td>
	<td style="vertical-align: top;">
	<div class="TermListTitle"><%=TXT_BUILD_TERM_LIST%></div>
	<div class="TermList"><span id="BuildTermList"></span></div>
	<div id="SelectDiv" style="display:none;"><a href="#javascript" class="ButtonLink" onClick="sendBuildToLinkList('All')"><%=TXT_MUST_MATCH%></a>
	<a href="#javascript" class="ButtonLink" onClick="sendBuildToLinkList('Any')"><%=TXT_MATCH_ANY%></a></div>
	<div id="SuggestDiv" style="display:none;"><br style="clear:left;"><a href="#javascript" class="ButtonLink" onClick="suggestLink()"><%=TXT_SUGGEST_LINK%></a>
	<a href="#javascript" class="ButtonLink" onClick="suggestTerm()"><%=TXT_SUGGEST_TERM%></a></div>
	<div class="TermListTitle" style="clear:left"><%=TXT_MUST_MATCH_TERMS%></div>
	<div class="TermList"><span id="MustMatchTermList"></span></div>
	<div class="TermListTitle"><%=TXT_MATCH_ANY_TERMS%></div>
	<div class="TermList"><span id="MatchAnyTermList"></span></div>
	<div class="TermListTitle"><input type="checkbox" name="TMCR"<%If bTMCRestricted Then%> checked<%End If%>>&nbsp;<%=TXT_RESTRICT%></div>
<%
Dim strCommTable, bEmptyCommTable
strCommTable = makeCommSrchTableTax(bEmptyCommTable)

If Not bEmptyCommTable Then
%>
<%=strCommTable%>
<%
End If
%>
	<p><a href="#javascript" class="ButtonLink" onClick="submitForm('SearchResults')"><%=TXT_SEARCH%></a>
	<a href="#javascript" class="ButtonLink" onClick="submitForm('AdvancedSearch')"><%=TXT_ADD_CRITERIA%></a>
	<a href="#javascript" class="ButtonLink" onClick="clearLists()"><%=TXT_CLEAR_FORM%></a></p>
	<%If Not (Nl(strTMC) And Nl(strATMC) And Not bTMCRestricted) Then%><a href="#javascript" class="ButtonLink" onClick="resetForm()"><%=TXT_RESET_FORM%></a><%End If%>
	</td>
</tr>
</table>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/taxsrch.js") %>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<script type="text/javascript">
	jQuery(function($) {
		init_cached_state('#Search');
		init_pre_fill_search_parameters();
		init_community_autocomplete($, 'OComm', "<%= makeLinkB("~/jsonfeeds/community_generator.asp") %>", 3, "#OCommID");
		var any_button = $('#community-any-button'),
			checklist_ui = $('#CommunitySelections'),
			show_hide_communities = function() {
				if (any_button.prop('checked')) {
					if (checklist_ui.is(':visible')){
						checklist_ui.hide('fast').find('input').prop('disable', true);
					}
				} else {
					if (!checklist_ui.is(':visible')) {
						checklist_ui.find('input').prop('disable', false);
						checklist_ui.show('fast');
					}
				}
			};
		$('.CommunityList').on('click', ':radio', show_hide_communities);
		restore_cached_state();

		show_hide_communities();
	});
</script>
<%
g_bListScriptLoaded = True
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
