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
' Purpose:		Generate HTML for displaying "More Term Information" box
'				during a Basic or Advanced Taxonomy Search, or record Indexing.
'				Outputs data in the form of a JavaScript array for use with AJAX.
'
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
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSearchTax.asp" -->
<!--#include file="../text/txtSearchTaxPublic.asp" -->
<!--#include file="../text/txtSearchResultsTax.asp" -->
<!--#include file="../includes/taxonomy/incTaxPassVars.asp" -->
<!--#include file="../includes/taxonomy/incTaxIcons.asp" -->

<%
'Ensure the Taxonomy is available in this View
If Not g_bUseTaxonomyView Then
	Call securityFailure()
End If

'Set response type headers to ensure the content
'can be read properly by the calling JavaScript
Response.ContentType = "application/json"
Response.CacheControl = "Private"
Response.Expires=-1

Call run_response_callbacks()

'Initialize the predifined links to Taxonomy Icons (JavaScript mode)
Call setIcons(True)

Dim cmdMoreInfo, rsMoreInfo
Set cmdMoreInfo = Server.CreateObject("ADODB.Command")

Dim strCode, _
	strMoreInfoSQL

strCode = Trim(Request("TC"))
If Not Nl(strCode) Then
	If Not IsTaxonomyCodeType(strCode) Then
		strCode = Null
	End If
End If

'If no Code is given, return an empty array to the calling script
If Nl(strCode) Then
%>
[]
<%
'If we have a valid Code, fetch the information about the current code
Else
	With cmdMoreInfo
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_TAX_Term_Srch_More_Info"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 21, strCode)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@Inactive", adBoolean, adParamInput, 1, IIf(bTaxAdmin Or bTaxInactive,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@NoDeleted", adBoolean, adParamInput, 1, SQL_TRUE)
		Set rsMoreInfo = .Execute
	End With
	
	Dim strDefinition, _
		strParentCode, _
		strParentTerm, _
		bParentActive, _
		strParentCountRecords, _
		strCreatedDate, _
		strLastModified, _
		bError

	bError = False
%>
[
<%
'Retrieve and print basic information information about the Term (data from TAX_Term)
With rsMoreInfo
	If Not .EOF	Then
		strDefinition = JSONQs(.Fields("Definition"),False)
		strParentCode = .Fields("ParentCode")
		strParentTerm = JSONQs(.Fields("ParentTerm"),False)
		bParentActive = .Fields("ParentActive")
		strParentCountRecords = .Fields("ParentCountRecords")
		strCreatedDate = .Fields("CREATED_DATE")
		strLastModified = .Fields("MODIFIED_DATE")
	Else
		bError = True
	End If
End With

If Not bError Then
%>"<%=strDefinition%><dl><%
If Not Nl(strParentCode) Then
%><dt><%=TXT_BROADER_TERM%></dt><dd><a href=\"<%=makeTaxLink(ps_strPathToStart & "tax.asp","ST=" & SEARCH_CODE & "&TC=" & strParentCode,"ST")%>\" class=\"TaxLink<%=IIf(bParentActive,vbNullString,"Inactive")%>\"><%=strParentTerm%></a><%
If strParentCountRecords > 0 Then
%>&nbsp;<strong>[<%=strParentCountRecords%>]</strong><%
End If
%></dd><%
End If

'Retrieve and print any Sub-Topics (child Terms)
Set rsMoreInfo = rsMoreInfo.NextRecordset
With rsMoreInfo
	If Not .EOF Then
		Dim strSubTopicCon
		strSubTopicCon = vbNullString
%><dt><%=TXT_SUB_TOPICS%></dt><dd><%
		While Not rsMoreInfo.EOF
		%><%=strSubTopicCon%><a href=\"<%=makeTaxLink(ps_strPathToStart & "tax.asp","ST=" & SEARCH_CODE & "&TC=" & .Fields("Code"),"ST")%>\" class=\"TaxLink<%=IIf(.Fields("Active"),vbNullString,"Inactive")%>\"><%=JSONQs(.Fields("Term"),False)%></a><%
			If .Fields("CountRecords") > 0 Then
				%>&nbsp;<strong>[<%=.Fields("CountRecords")%>]</strong><%
			End If
			strSubTopicCon = " ; "
			.MoveNext
		Wend
%></dd><%
	End If
End With

'Retrieve and print any Related Topics (See Also References)
Set rsMoreInfo = rsMoreInfo.NextRecordset
With rsMoreInfo
	If Not .EOF Then
		Dim strRelTopicCon
		strRelTopicCon = vbNullString
%><dt><%=TXT_RELATED_TOPICS%></dt><dd><%
		While Not rsMoreInfo.EOF
		%><%=strRelTopicCon%><a href=\"<%=makeTaxLink(ps_strPathToStart & "tax.asp","ST=" & SEARCH_CODE & "&TC=" & .Fields("Code"),"ST")%>\" class=\"TaxLink<%=IIf(.Fields("Active"),vbNullString,"Inactive")%>\"><%=JSONQs(.Fields("Term"),False)%></a><%
			If .Fields("CountRecords") > 0 Then
				%>&nbsp;<strong>[<%=.Fields("CountRecords")%>]</strong><%
			End If
			strRelTopicCon = " ; "
			.MoveNext
		Wend
%></dd><%
	End If
End With

'Retrieve and print any Use References (synonyms)
Set rsMoreInfo = rsMoreInfo.NextRecordset
With rsMoreInfo
	If Not .EOF Then
		Dim strUseRefCon
		strUseRefCon = vbNullString
%><dt><%=TXT_USE_REFERENCES%></dt><dd><%
		While Not rsMoreInfo.EOF
			If bTaxAdmin And Not Nl(.Fields("Code")) Then
		%><%=strUseRefCon%><a href=\"<%=makeTaxLink(ps_strPathToStart & "tax.asp","ST=" & SEARCH_CODE & "&TC=" & .Fields("Code"),"ST")%>\" class=\"TaxLinkInactive\"><%=JSONQs(.Fields("Term"),False)%></a><%			
			ElseIf .Fields("Active") Or Not Nl(.Fields("Code")) Then
		%><%=strUseRefCon%><%=JSONQs(.Fields("Term"),False)%><%
			Else
		%><%=strUseRefCon%><span class=\"TaxInactive\"><%=JSONQs(.Fields("Term"),False)%></span><%
			End If
			strUseRefCon = " ; "
			.MoveNext
		Wend
%></dd><%
	End If
End With

'Retrieve and print any Related Concepts
Set rsMoreInfo = rsMoreInfo.NextRecordset
With rsMoreInfo
	If Not .EOF Then
		Dim strRelConceptCon
		strRelConceptCon = vbNullString
%><dt><%=TXT_RELATED_CONCEPTS%></dt><dd><%
		While Not rsMoreInfo.EOF
		%><%=strRelConceptCon%><a href=\"<%=makeTaxLink(ps_strPathToStart & "tax.asp","ST=" & SEARCH_CONCEPT & "&RCID=" & .Fields("RC_ID"),"ST")%>\" class=\"TaxLink\"><%=JSONQs(.Fields("ConceptName"),False)%></a><%
			strRelConceptCon = " ; "
			.MoveNext
		Wend
%></dd><%
	End If
End With

'If the user is a Super User, print extra data management information
If user_bSuperUserCIC Then
%><dt><%=TXT_DATE_CREATED%></dt><dd><%=strCreatedDate%></dd><dt><%=TXT_LAST_MODIFIED%></dt><dd><%=strLastModified%></dd><%
End If
%></dl>"<%

End If
%>
]
<%
End If
%>

<!--#include file="../includes/core/incClose.asp" -->
