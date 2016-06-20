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
' Purpose:		Form to edit values for a Taxonomy Term.
'				Values are stored in tables: TAX_Term, TAX_Unused, TAX_TM_RC.
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
<!--#include file="text/txtFinder.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtSearchTax.asp" -->
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/list/incSysLanguageList.asp" -->
<!--#include file="includes/taxonomy/incTaxConceptTermList.asp" -->
<!--#include file="includes/taxonomy/incTaxFacetList.asp" -->
<!--#include file="includes/taxonomy/incTaxSeeAlsoTermList.asp" -->
<!--#include file="includes/taxonomy/incTaxSourceList.asp" -->
<!--#include file="includes/taxonomy/incTaxUnusedTermList.asp" -->
<%
'Ensure user has Super User privileges
If Not user_bSuperUserCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Dim bNew
bNew = False

'Term fields
Dim	intTMID, _
	strCode, _
	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strCdLvl1, _
	strCdLvl2, _
	strCdLvl3, _
	strCdLvl4, _
	strCdLvl5, _
	strCdLvl6, _
	intSource, _
	bAuthorized, _
	bPreferred, _
	intFacet, _
	strIconURL, _
	bActive, _
	bCanActivate, _
	bCanDeactivate, _
	bCanRollUp, _
	intUsageCountLocal, _
	intUsageCountOther, _
	intUsageCountShared, _
	intUsageCountTotal, _
	strTermStatus, _
	bOKDelete, _
	intFieldLen, _
	strIndTerm, _
	fldActive, _
	fldID, _
	fldCode, _
	fldName, _
	fldAuthorized, _
	fldLangID, _
	strValue, _
	strCulture, _
	dicDescriptions, _
	xmlDoc, _
	xmlNode, _
	xmlFieldNode, _
	xmlCultureNode

bOkDelete = True

'Check if we are editing and existing Term
strCode = Trim(Request("TC"))
If Nl(strCode) Then
	'This is a new Term
	strCode = Null
	bNew = True
	bOkDelete = False
Else
	If Not IsTaxonomyCodeType(strCode) Then
		Call handleError(TXT_INVALID_CODE & strCode & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_TERM, _
		"tax_mng.asp", vbNullString)
		strCode = Null
	End If
End If

'If this is not a new record, retrieve the current info
If Not bNew Then
	Dim cmdTaxTerm, rsTaxTerm
	Set cmdTaxTerm = Server.CreateObject("ADODB.Command")
	With cmdTaxTerm
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_Term_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 21, strCode)
		Set rsTaxTerm = .Execute
	End With

	With rsTaxTerm
		If Not .EOF Then
			intTMID = .Fields("TM_ID")
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCode = .Fields("Code")
			strCdLvl1 = .Fields("CdLvl1")
			strCdLvl2 = .Fields("CdLvl2")
			strCdLvl3 = .Fields("CdLvl3")
			strCdLvl4 = .Fields("CdLvl4")
			strCdLvl5 = .Fields("CdLvl5")
			strCdLvl6 = .Fields("CdLvl6")
			intSource = .Fields("Source")
			bAuthorized = .Fields("Authorized")
			bPreferred = .Fields("PreferredTerm")
			bActive = .Fields("Active")
			bCanActivate = .Fields("CAN_ACTIVATE")
			bCanDeactivate = .Fields("CAN_DEACTIVATE")
			bCanRollUp = .Fields("CAN_ROLLUP")
			intFacet = .Fields("Facet")
			strIconURL = .FieldS("IconURL")
			intUsageCountLocal = .Fields("UsageCountLocal")
			intUsageCountOther = .Fields("UsageCountOther")
			intUsageCountShared = .Fields("UsageCountShared")
			intUsageCountTotal = intUsageCountLocal + intUsageCountOther

			Set dicDescriptions = Server.CreateObject("Scripting.Dictionary")
			Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
			With xmlDoc
				.async = False
				.setProperty "SelectionLanguage", "XPath"
			End With
			xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"

			For Each xmlNode in xmlDoc.selectNodes("//DESC")
				Set xmlCultureNode = xmlNode.selectSingleNode("Culture")
				If Not xmlCultureNode Is Nothing Then
					Set dicDescriptions(xmlCultureNode.text) = xmlNode
				End If
			Next
		Else
			Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(strCode) & _
				vbCrLf & "<br>" & TXT_CHOOSE_TERM, _
				"tax_mng.asp", vbNullString)
		End If
	End With

	'Is this Term being used by any records? If so, it cannot be deleted.
	If intUsageCountTotal > 0 Then
		If g_bOtherMembers Then
			strTermStatus = strTermStatus & _
				Replace(Replace(TXT_STATUS_USE_RECORDS_LOCALSHARED,"%d1",intUsageCountLocal),"%d2",intUsageCountShared) & _
				" [ <a href=""" & makeLink("results.asp","TMC=" & strCode & "&TMCR=on&IncDel=on",vbNullString) & """>" & TXT_SEARCH & "</a> ]" & _
				"<br>" & Replace(TXT_STATUS_USE_RECORDS_TOTAL,"%d",intUsageCountTotal)
		Else
			strTermStatus = strTermStatus & "<strong>" & Replace(TXT_STATUS_USE_RECORDS_TOTAL,"%d",intUsageCountTotal) & "</strong>"  & _
				" [ <a href=""" & makeLink("results.asp","TMC=" & strCode & "&TMCR=on&IncDel=on",vbNullString) & """>" & TXT_SEARCH & "</a> ]"
		End If
		bOkDelete = False
	Else
		strTermStatus = strTermStatus & TXT_STATUS_NO_USE_RECORDS
	End If
	
	'Can this Term be deleted?
	If bOkDelete Then
		strTermStatus = strTermStatus & "<br>" & TXT_STATUS_DELETE
	Else
		strTermStatus = strTermStatus & "<br>" & TXT_STATUS_NO_DELETE
	End If

	Set rsTaxTerm = Nothing
	Set cmdTaxTerm = Nothing
End If

If bNew Then
	Call makePageHeader(TXT_CREATE_NEW_TERM_TITLE, TXT_CREATE_NEW_TERM_TITLE, True, False, True, True)
Else
	Call makePageHeader(TXT_EDIT_TERM & strCode, TXT_EDIT_TERM & strCode, True, False, True, True)
End If

%>
<p>[ <a href="<%=makeLinkB("tax_mng.asp")%>"><%=TXT_RETURN_MANAGE_TAXONOMY%></a> ]</p>
<%If bNew Or Not bAuthorized Then%>
<p><span class="AlertBubble"><%=TXT_LOCAL_WARNING%></span></p>
<%End If%>
<form action="tax_edit2.asp" method="post" class="form">
<%=g_strCacheFormVals%>
<%If Not bNew Then%>
<input type="hidden" name="TC" value="<%=strCode%>">
<input type="hidden" name="TMID" value="<%=intTMID%>">
<%End If%>
<table class="BasicBorder cell-padding-4 form-table max-width-lg clear-line-below">
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_USE_FORM_FOR_TERM%> <%=IIf(bNew,TXT_NEW_TERM,strCode)%></th>
</tr>
<%If Not bNew Then%>
<tr>
	<td class="field-label-cell"><%=TXT_STATUS%></td>
	<td class="field-data-cell"><%=strTermStatus%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_DATE_CREATED%></td>
	<td class="field-data-cell"><%=strCreatedDate%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_CREATED_BY%></td>
	<td class="field-data-cell"><%=strCreatedBy%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_LAST_MODIFIED%></td>
	<td class="field-data-cell"><%=strModifiedDate%></td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_MODIFIED_BY%></td>
	<td class="field-data-cell"><%=strModifiedBy%></td>
</tr>
<%End If%>
<tr>
	<td class="field-label-cell"><%=TXT_CODE%></td>
	<td class="field-data-cell">
		<div class="input-group form-inline form-inline-always">
			<input name="CdLvl1" title=<%=AttrQs(TXT_CODE_SECTION & TXT_COLON & "1")%> type="text" value=<%=AttrQs(strCdLvl1)%> size="2" maxlength="1" class="form-control">
			<input name="CdLvl2" title=<%=AttrQs(TXT_CODE_SECTION & TXT_COLON & "2")%> type="text" value=<%=AttrQs(strCdLvl2)%> size="2" maxlength="1" class="form-control">
			<div class="input-group-addon">-</div>
			<input name="CdLvl3" title=<%=AttrQs(TXT_CODE_SECTION & TXT_COLON & "3")%> type="text" value=<%=AttrQs(strCdLvl3)%> size="4" maxlength="4" class="form-control">
			<div class="input-group-addon">.</div>
			<input name="CdLvl4" title=<%=AttrQs(TXT_CODE_SECTION & TXT_COLON & "4")%> type="text" value=<%=AttrQs(strCdLvl4)%> size="4" maxlength="4" class="form-control">
			<div class="input-group-addon">-</div>
			<input name="CdLvl5" title=<%=AttrQs(TXT_CODE_SECTION & TXT_COLON & "5")%> type="text" value=<%=AttrQs(strCdLvl5)%> size="3" maxlength="3" class="form-control">
			<div class="input-group-addon">.</div>
			<input name="CdLvl6" title=<%=AttrQs(TXT_CODE_SECTION & TXT_COLON & "6")%> type="text" value=<%=AttrQs(strCdLvl6)%> size="2" maxlength="2" class="form-control">
		</div>
	</td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_AUTHORIZED%></td>
	<td class="field-data-cell">
		<label for="Authorized_Yes"><input type="radio" name="Authorized" id="Authorized_Yes" value="on"<%=IIf(bAuthorized," checked",vbNullString)%>><%=TXT_YES%></label>
		<label for="Authorized_No"><input type="radio" name="Authorized" id="Authorized_No" value=""<%=IIf(Not bAuthorized," checked",vbNullString)%>><%=TXT_NO%></label>
	</td>
</tr>
<tr>
	<td class="field-label-cell"><%=TXT_PREFERRED_TERM%></td>
	<td class="field-data-cell"><%If bPreferred Then%><%=TXT_YES%><%Else%><%=TXT_NO%><%End If%></td>
</tr>
<%
For Each strCulture In active_cultures()
	strValue = vbNullString
	If Not bNew Then
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("Term")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
	End If
%>
<tr>
	<td class="field-label-cell">
		<label for="Term_<%= strCulture %>"><%=TXT_TERM_NAME%> (<%=Application("Culture_" & strCulture & "_LanguageName")%>)</label>
	</td>
	<td class="field-data-cell">
		<input name="Term_<%= strCulture %>" id="Term_<%= strCulture %>" type="text" value=<%=AttrQs(strValue)%> maxlength="255" class="form-control">
	</td>
</tr>
<%
Next
Call openTaxonomySourceListRst()
%>
<tr>
	<td class="field-label-cell">
		<label for="Source"><%=TXT_TAX_SOURCE%></label>
	</td>
	<td class="field-data-cell">
		<%=makeTaxonomySourceList(intSource,"Source","Source",True,False,False)%>
	</td>
</tr>
<%
Call closeTaxonomySourceListRst()
%>
<%
For Each strCulture In active_cultures()
	strValue = vbNullString
	If Not bNew Then
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("Definition")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
	End If
If Nl(strValue) Then
	intFieldLen = 0
Else
	intFieldLen = Len(strValue)
	strValue = Server.HTMLEncode(strValue)
End If
%>
<tr>
	<td class="field-label-cell"><label for="Definition_<%= strCulture %>">
		<%=TXT_DEFINITION%> (<%=Application("Culture_" & strCulture & "_LanguageName")%>)</label>
	</td>
	<td class="field-data-cell">
		<span class="SmallNote"><%=TXT_INST_MAX_4000%>&nbsp;<%=TXT_HTML_ALLOWED%></span>
		<br><textarea name="Definition_<%= strCulture %>" id="Definition_<%= strCulture %>" rows="<%=getTextAreaRows(intFieldLen,TEXTAREA_ROWS_SHORT)%>" class="form-control"><%=strValue%></textarea>
	</td>
</tr>
<%
Next

Call openTaxonomyFacetListRst()
%>
<tr>
	<td class="field-label-cell"><label for="Facet"><%=TXT_FACET%></label></td>
	<td class="field-data-cell"><%=makeTaxonomyFacetList(intFacet,"Facet","Facet",True,False,False)%></td>
</tr>
<%
Call closeTaxonomyFacetListRst()
%>
<%
'Fetch the list of ENGLISH "Use References" (Unused Terms) associated with this Term
Call openSysLanguageListRst(True)

Call openUnusedTermsRst(strCode)
%>
<tr>
	<td class="field-label-cell"><%=TXT_USE_REFERENCES%></td>
	<td class="field-data-cell"><table class="BasicBorder cell-padding-2">
<tr>
	<th><%=TXT_TERM_NAME%></th>
	<th><%=TXT_AUTHORIZED%></th>
	<th><%=TXT_ACTIVE%></th>
	<th><%=TXT_LANGUAGE%></th>
</tr>
<%
	With rsUnusedTerms
		If Not .EOF Then
			Set fldID = .FieldS("UT_ID")
			Set fldName = .Fields("Term")
			Set fldAuthorized = .Fields("Authorized")
			Set fldActive = .Fields("Active")
			Set fldLangID = .Fields("LangID")
			While Not .EOF
%>
<div style="display:none"><input type="hidden" name="UT_ID" value="<%=fldID.Value%>"></div>
<tr>
	<td><input type="text" name="UT_TERM_<%=fldID.Value%>" title=<%=AttrQs(fldName.Value & TXT_COLON & TXT_TERM_NAME)%> size="<%=TEXT_SIZE-20%>" maxlength="255" value="<%=fldName.Value%>" class="form-control"></td>
	<td align="center"><input type="checkbox" name="UT_AUTH_<%=fldID.Value%>" title=<%=AttrQs(fldName.Value & TXT_COLON & TXT_AUTHORIZED)%> <%If fldAuthorized Then%> checked<%End If%>></td>
	<td align="center"><input type="checkbox" name="UT_ACTIVE_<%=fldID.Value%>" title=<%=AttrQs(fldName.Value & TXT_COLON & TXT_ACTIVE)%> <%If fldActive Then%> checked<%End If%>></td>
	<td><%= makeSysLanguageList(fldLangID.Value, "UT_LANGID_" & fldID.Value, False, vbNullString)%></td>
</tr>
<%
				.MoveNext
			Wend
		End If
	End With
	Dim i
	For i = 1 to 3
%>
<tr>
	<td><input type="text" name="UT_TERM_NEW_<%=i%>" title=<%=AttrQs(TXT_NEW_TERM & TXT_COLON & i)%> size="<%=TEXT_SIZE-20%>" maxlength="255" class="form-control"></td>
	<td align="center"><input type="checkbox" name="UT_AUTH_NEW_<%=i%>" title=<%=AttrQs(TXT_NEW_TERM & " " & i & TXT_COLON & TXT_AUTHORIZED)%>></td>
	<td align="center"><input type="checkbox" name="UT_ACTIVE_NEW_<%=i%>" title=<%=AttrQs(TXT_NEW_TERM & " " & i & TXT_COLON & TXT_ACTIVE)%>></td>
	<td><%= makeSysLanguageList(vbNullString, "UT_LANGID_NEW_" & i, False, vbNullString)%></td>
</tr>
<% 
Next 
%>
	</table></td>
</tr>
<%
Call closeUnusedTermsRst()
Call closeSysLanguageListRst()

'Fetch the list of "See Also" Terms (Related Terms) associated with this Term
Call openSeeAlsoTermsRst(strCode)
%>
<tr>
	<td class="field-label-cell"><%=TXT_SEE_ALSO%></td>
	<td class="field-data-cell">
<%
	With rsSeeAlsoTerms
		If Not .EOF Then
			Set fldCode = .Fields("Code")
			Set fldName = .Fields("Term")
			Set fldAuthorized = .Fields("Authorized")
			Set fldActive = .Fields("Active")
%>
<span class="SmallNote"><%=TXT_BRACKETS_ONLY_IN & IIf(g_objCurrentLang.LangID=2,TXT_ENGLISH,TXT_FRENCH)%></span>
<table class="BasicBorder cell-padding-2">
<tr>
	<th colspan="2"><%=TXT_TERM_NAME%></th>
	<th><%=TXT_AUTHORIZED%></th>
</tr>
<%
			While Not .EOF
				strIndTerm = fldName.Value & " (" & fldCode.Value & ")"
				If Not fldActive.Value Or Nl(fldActive.Value) Then
					strIndTerm = "<span class=""Alert"">" & strIndTerm & "</span>"
				End If
%>
<tr>
	<td><input type="checkbox" name="SA_Code" value="<%=fldCode.Value%>" checked></td>
	<td><a href="<%=makeLink(ps_strThisPage,"TC=" & fldCode.Value,vbNullString)%>"><%=strIndTerm%></a></td>
	<td align="center"><input type="checkbox" name="SA_AUTH" value="<%=fldCode.Value%>"<%If fldAuthorized Then%> checked<%End If%>></td>
<%
				.MoveNext
			Wend
%>
</table>
<br>
<%
		End If
	End With
%>
<span class="SmallNote"><%=TXT_ENTER_VALUES_NAME_CODE%></span>
	<input type="text" name="SeeAlsoTerms" maxlength="1000" class="form-control">
	[ <a href="javascript:openWinL('<%=makeLink("tax.asp","MD=2",vbNullString)%>','tFind')"><%=TXT_TAXONOMY_FINDER%></a> ]
	</td>
</tr>
<%
Call closeSeeAlsoTermsRst()
%>
<%
'Fetch the list of Related Concepts associated with this Term
Call openRelatedConceptTermRst(strCode)
%>
<tr>
	<td class="field-label-cell"><%=TXT_RELATED_CONCEPTS%></td>
	<td>
<%
	With rsRelatedConceptTerm
		If Not .EOF Then
			Set fldID = .FieldS("RC_ID")
			Set fldCode = .Fields("Code")
			Set fldName = .Fields("ConceptName")
			Set fldAuthorized = .Fields("Authorized")
%>
<% 'XXX This should be "NOT Available in current lang? %>
<span class="SmallNote"><%=TXT_BRACKETS_ONLY_IN & IIf(g_objCurrentLang.LangID = 2,TXT_ENGLISH,TXT_FRENCH)%></span>
<table class="BasicBorder cell-padding-2">
<tr>
	<th colspan="2"><%=TXT_CONCEPT_NAME%></th>
	<th><%=TXT_AUTHORIZED%></th>
</tr>
<%
			While Not .EOF
				strIndTerm = fldName.Value & " (" & fldCode.Value & ")"
%>
<tr>
	<td><input type="checkbox" name="TM_RC_ID" value="<%=fldID.Value%>" checked></td>
	<td><a href="<%=makeLink("tax_rc_edit.asp","RCID=" & fldID.Value,vbNullString)%>"><%=strIndTerm%></a></td>
	<td align="center"><input type="checkbox" name="RC_AUTH" value="<%=fldID.Value%>"<%If fldAuthorized Then%> checked<%End If%>></td>
<%
				.MoveNext
			Wend
%>
</table>
<br>
<%
		End If
	End With
%>
		<span class="SmallNote"><%=TXT_ENTER_VALUES_NAME_CODE%></span>
		<input type="text" name="RelatedConcepts" size="<%=TEXT_SIZE%>" maxlength="1000" class="form-control">
		[ <a href="javascript:openWinL('<%=makeLink("tax.asp","MD=2&ST=3",vbNullString)%>','tFind')"><%=TXT_TAXONOMY_FINDER%></a> ]
	</td>
</tr>
<%
Call closeRelatedConceptTermRst()
%>
<%
For Each strCulture In active_cultures()
	strValue = vbNullString
	If Not bNew Then
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("Comments")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
	End If
If Nl(strValue) Then
	intFieldLen = 0
Else
	intFieldLen = Len(strValue)
	strValue = Server.HTMLEncode(strValue)
End If
%>
<tr>
	<td class="field-label-cell"><label for="Comments_<%= strCulture %>"><%=TXT_COMMENTS%> (<%=Application("Culture_" & strCulture & "_LanguageName")%>)</label></td>
	<td><span class="SmallNote"><%=TXT_INST_MAX_4000%>&nbsp;<%=TXT_HTML_ALLOWED%></span>
		<br><textarea name="Comments_<%= strCulture %>" id="Comments_<%= strCulture %>" wrap="soft" rows="<%=getTextAreaRows(intFieldLen,TEXTAREA_ROWS_SHORT)%>" class="form-control"><%=strValue%></textarea></td>
</tr>
<%
Next
For Each strCulture In active_cultures()
	strValue = vbNullString
	If Not bNew Then
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("AltTerm")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
	End If
%>
<tr>
	<td class="field-label-cell"><label for="AltTerm_<%= strCulture %>"><%=TXT_ALTERNATE_NAME%> (<%=Application("Culture_" & strCulture & "_LanguageName")%>)</label></td>
	<td><input name="AltTerm_<%= strCulture %>" id="AltTerm_<%= strCulture %>" type="text" value=<%=AttrQs(strValue)%> maxlength="255" class="form-control"></td>
</tr>
<%
Next
For Each strCulture In active_cultures()
	strValue = vbNullString
	If Not bNew Then
		If dicDescriptions.Exists(strCulture) Then
			Set xmlNode = dicDescriptions(strCulture)
			Set xmlNode = xmlNode.selectSingleNode("AltDefinition")
			If Not xmlNode Is Nothing Then
				strValue = xmlNode.text
			End If
		End If
	End If
If Nl(strValue) Then
	intFieldLen = 0
Else
	intFieldLen = Len(strValue)
	strValue = Server.HTMLEncode(strValue)
End If
%>
<tr>
	<td class="field-label-cell"><label for="AltDefinition_<%= strCulture %>"><%=TXT_ALTERNATE_DEFINITION%> (<%=Application("Culture_" & strCulture & "_LanguageName")%>)</label></td>
	<td><span class="SmallNote"><%=TXT_INST_MAX_4000%>&nbsp;<%=TXT_HTML_ALLOWED%></span>
		<br><textarea name="AltDefinition_<%= strCulture %>" id="AltDefinition_<%= strCulture %>" wrap="soft" rows="<%=getTextAreaRows(intFieldLen,TEXTAREA_ROWS_SHORT)%>"  class="form-control"><%=strValue%></textarea></td>
</tr>
<%
Next
%>
<tr>
	<td class="field-label-cell"><label for="IconURL"><%=TXT_ICON_URL%></label></td>
	<td><input name="IconURL" id="IconURL" type="text" value=<%=AttrQs(strIconURL)%> maxlength="150" class="form-control"></td>
</tr>
<% If bCanActivate or bCanDeactivate or bCanRollUp Then %>
<tr>
	<td class="field-label-cell"><%=TXT_ACTIVE%></td>
	<td>
<%If g_bOtherMembers Then%>
<strong><%=TXT_MANAGE_GLOBAL_ACTIVATION%></strong>
<br>
<%End If%>
<%If bCanActivate Then%>
<label for="Active_True"><input type="radio" name="Active" id="Active_True" value="<%=SQL_TRUE%>" <%=IIf(bActive," checked",vbNullString)%>>&nbsp;<%=TXT_ACTIVE%></label>
<%End If%>
<%If bCanDeactivate Then%>
<br><label for="Active_False"><input type="radio" name="Active" id="Active_False" value="<%=SQL_FALSE%>" <%=IIf(Not bActive," checked",vbNullString)%>>&nbsp;<%=TXT_INACTIVE%></label>
<%End If%>
<%If bCanRollUp Then%>
<br><label for="Active"><input type="radio" name="Active" id="Active" value="" <%=IIf(Nl(bActive)," checked",vbNullString)%>>&nbsp;<%=TXT_ROLL_UP%></label>
<%End If%>
	<br><br><%=TXT_INST_ACTIVE%>
	</td>
</tr>
<% End If %>
</table>
	<input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>" class="btn btn-default">
	<%If bOkDelete Then%><input type="submit" name="Submit" value="<%=TXT_DELETE%>" class="btn btn-default"><%End If%>
	<input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default">
</form>
<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
