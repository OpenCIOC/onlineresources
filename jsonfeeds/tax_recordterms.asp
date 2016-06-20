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
' Purpose:		Generate HTML for displaying a box with the list of Terms
'				indexed to the selected record (by NUM) during record Indexing.
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
<!--#include file="../text/txtSearchTax.asp" -->
<!--#include file="../text/txtSearchResultsTax.asp" -->
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

Dim cmdRecordTerms, rsRecordTerms
Set cmdRecordTerms = Server.CreateObject("ADODB.Command")

Dim strNUM
strNUM = Trim(Request("NUM"))
If Not Nl(strNUM) Then
	If Not IsNUMType(strNUM) Then
		strNUM = Null
	End If
End If

'If no NUM is given, return an empty array to the calling script
If Nl(strNUM) Then
%>
[]
<%
'If we have a valid NUM, fetch a list of the record's Terms
Else
	With cmdRecordTerms
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_NUMTaxonomy_sb"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		Set rsRecordTerms = .Execute
	End With
%>[<%
	With rsRecordTerms
		If Not .EOF	Then
			Dim strReturn

			Dim strIconSelect
		
			Dim strLinkCon, _
				strTermCon, _
				intPrevLink

			Dim fldCode, _
				fldTerm
				
			Set fldCode = .Fields("Code")
			Set fldTerm = .Fields("Term")
			
			strReturn = vbNullString
			strLinkCon = vbNullString
			strTermCon = vbNullString

			'Output the list of Terms associated with the record.
			'Each Term is linked with a JavaScript call to add the Term to the Build List.
			While Not .EOF
				strIconSelect = "&nbsp;<a href=\""#javascript\"" onClick=\""parent.addBuildTerm(" & JSONQs(JsQs(fldCode.Value),False) & "," & JSONQs(JsQs(fldTerm.Value),False) & "); return false\"">" & ICON_SELECT & "</a>"
				If .Fields("BT_TAX_ID") <> intPrevLink Then
					strReturn = strReturn & strLinkCon & "<LI CLASS=\""TermItem\"">"
					strLinkCon = "</li>"
					strTermCon = vbNullString
				End If
				strReturn = strReturn & strTermCon & fldTerm.Value & strIconSelect
				strTermCon = " ~ "
				intPrevLink = .Fields("BT_TAX_ID")
				.MoveNext
			Wend 
%>"<ul><%=strReturn%></ul>"<%
		End If
	End With
%>]<%
End If
%>

<!--#include file="../includes/core/incClose.asp" -->
