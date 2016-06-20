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
' Purpose:		Form to edit values for a Taxonomy Related Concept.
'				Values are stored in table: TAX_RelatedConcept.
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
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtMgmtFields.asp" -->
<!--#include file="text/txtTaxonomy.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/taxonomy/incTaxSourceList.asp" -->
<%
'Ensure user has super user privileges
If Not user_bSuperUserGlobalCIC Or Not g_bUseTaxonomy Then
	Call securityFailure()
End If

Dim bNew
bNew = False

'Concept fields
Dim	intRCID, _
	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strCode, _
	strConceptName, _
	intSource, _
	bAuthorized, _
	intUsageCount, _
	intFieldLen, _
	strRelatedConceptStatus, _
	strCulture, _
	xmlDoc, _
	xmlNode, _
	strValue

'Check if we are editing an existing Concept
intRCID = Request("RCID")
If Nl(intRCID) Then
	'This is a new Concept
	intRCID = Null
	bNew = True
ElseIf Not IsIDType(intRCID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intRCID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_CONCEPT, _
		"tax_mng.asp", vbNullString)
Else
	intRCID = CLng(intRCID)
End If

'If this is not a new record, retrieve the current info
If Not bNew Then
	Dim cmdTaxRelatedConcept, rsTaxRelatedConcept
	Set cmdTaxRelatedConcept = Server.CreateObject("ADODB.Command")
	With cmdTaxRelatedConcept
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_RelatedConcept_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@RC_ID", adInteger, adParamInput, 4, intRCID)
		Set rsTaxRelatedConcept = .Execute
	End With

	With rsTaxRelatedConcept
		If Not .EOF Then
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCode = .Fields("Code")
			intSource = .Fields("Source")
			bAuthorized = .Fields("Authorized")
			intUsageCount = .Fields("UsageCount")
			strConceptName = .Fields("ConceptName")

			Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
			With xmlDoc
				.async = False
				.setProperty "SelectionLanguage", "XPath"
			End With
			xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"

		Else
			Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intRCID), _
				"tax_mng.asp", _
				vbNullString)	
		End If
	End With

	'If this Concept being used by an Terms?
	If intUsageCount > 0 Then
		strRelatedConceptStatus = strRelatedConceptStatus & "<strong>" & intUsageCount & "</strong>" & TXT_STATUS_USE_TERMS
	Else
		strRelatedConceptStatus = strRelatedConceptStatus & TXT_STATUS_NO_USE_TERMS
	End If

	Set rsTaxRelatedConcept = Nothing
	Set cmdTaxRelatedConcept = Nothing
End If

If bNew Then
	Call makePageHeader(TXT_CREATE_NEW_CONCEPT_TITLE, TXT_CREATE_NEW_CONCEPT_TITLE, True, False, True, True)
Else
	Call makePageHeader(TXT_EDIT_CONCEPT & strConceptName , TXT_EDIT_CONCEPT &  strConceptName, True, False, True, True)
End If

%>
<p>[ <a href="<%=makeLinkB("tax_mng.asp")%>"><%=TXT_RETURN_MANAGE_TAXONOMY%></a> ]</p>
<form action="tax_rc_edit2.asp" method="post" class="form">
<%=g_strCacheFormVals%>
<%If Not bNew Then%>
<input type="hidden" name="RCID" value="<%=intRCID%>">
<%End If%>
<table class="BasicBorder cell-padding-4 form-table responsive-table max-width-lg clear-line-below">
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_USE_FORM_FOR_CONCEPT%> <%=IIf(bNew,TXT_NEW_CONCEPT, strConceptName )%></th>
</tr>
<%If Not bNew Then%>
<tr>
	<td class="field-label-cell"><%=TXT_STATUS%></td>
	<td class="field-data-cell"><%=strRelatedConceptStatus%></td>
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
	<td class="field-label-cell"><label for="Code"><%=TXT_CODE%></label></td>
	<td class="field-data-cell"><input name="Code" id="Code" type="text" value=<%=AttrQs(strCode)%> size="6" maxlength="6" class="form-control"></td>
</tr>
<%
	For Each strCulture In active_cultures()
	If Not bNew Then
		Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture, SQUOTE) & "]")
		If xmlNode IS Nothing Then
			strConceptName = vbNullString
		Else 
			strConceptName = xmlNode.getAttribute("ConceptName")
		End If
	Else
		strConceptName = vbNullString
	End If
%>
<tr>
	<td class="field-label-cell"><label for=<%=AttrQs("ConceptName_" & strCulture)%>><%=TXT_CONCEPT_NAME%> (<%= Application("Culture_" & strCulture & "_LanguageName")%>)</label></td>
	<td class="field-data-cell"><input name="ConceptName_<%= strCulture %>" id=<%=AttrQs("ConceptName_" & strCulture)%> type="text" value=<%=AttrQs(strConceptName)%> maxlength="200" class="form-control"></td>
</tr>
<%
Next
%>
<tr>
	<td class="field-label-cell"><%=TXT_AUTHORIZED%></td>
	<td class="field-data-cell"><label for="Authorized_Yes"><input type="radio" name="Authorized" id="Authorized_Yes" value="on"<%=IIf(bAuthorized," checked",vbNullString)%>><%=TXT_YES%></label> <label for="Authorized_No"><input type="radio" name="Authorized" id="Authorized_No" value=""<%=IIf(Not bAuthorized," checked",vbNullString)%>><%=TXT_NO%></label></td>
</tr>
<%
Call openTaxonomySourceListRst()
%>
<tr>
	<td class="field-label-cell"><label for="Source"><%=TXT_TAX_SOURCE%></label></td>
	<td class="field-data-cell"><%=makeTaxonomySourceList(intSource,"Source","Source",True,False,False)%></td>
</tr>
<%
Call closeTaxonomySourceListRst()
%>
</table>

<input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>" class="btn btn-default">
<%If Not bNew Then%><input type="submit" name="Submit" value="<%=TXT_DELETE%>" class="btn btn-default"><%End If%>
<input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default">

</form>
<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->
