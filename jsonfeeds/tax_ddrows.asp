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
' Purpose:		Returns the display HTML for child terms when
'				expanding a branch of the tree in a Drill-Down search.
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
<!--#include file="../includes/taxonomy/incTaxPassVars.asp" -->
<!--#include file="../includes/taxonomy/incTaxIcons.asp" -->
<!--#include file="../text/txtSearchTax.asp" -->
<!--#include file="../text/txtSearchResultsTax.asp" -->
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

Dim cmdDrill, rsDrill
Set cmdDrill = Server.CreateObject("ADODB.Command")

Dim strCode, _
	strSep, _
	intLevel, _
	strDrillSQL, _
	strQCode

strSep = vbNullString
strCode = Trim(Request("TC"))
If Not Nl(strCode) Then
	If Not IsTaxonomyCodeType(strCode) Then
		strCode = Null
	End If
End If

intLevel = Request("LV")

'If no Code is given, return an empty array to the calling script
If Nl(strCode) Then
%>
[]
<%
'If we have a valid Code, fetch the child Terms for the given Code
Else
	Dim strHasRecordsSQL, _
		strHasChildrenSQL

	strHasRecordsSQL = "EXISTS(SELECT *" & vbCrLf & _
		"	FROM TAX_Term tmx" & vbCrLf & _
		"	INNER JOIN CIC_BT_TAX_TM tlt" & vbCrLf & _
		"		ON tlt.Code=tmx.Code" & vbCrLf & _
		"	INNER JOIN CIC_BT_TAX tl" & vbCrLf & _
		"		ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
		"			AND EXISTS(SELECT *" & vbCrLf & _
		"				FROM GBL_BaseTable bt" & vbCrLf & _
		"				INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
		"					ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"				WHERE bt.NUM=tl.NUM" & vbCrLf & _
		"					AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
		"				)" & vbCrLf & _
		"	WHERE tmx.CdLvl1=tm.CdLvl1" & vbCrLf & _
		"		AND tmx.CdLvl >= tm.CdLvl" & vbCrLf & _
		"		AND tmx.Code LIKE tm.Code + '%'" & vbCrLf & _
		StringIf(Not (bTaxAdmin Or bTaxInactive),"		AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code LIKE tmx.Code + '%' AND MemberID=" & g_intMemberID & ")" & vbCrLf) & _
		")"

	strHasChildrenSQL = "EXISTS(SELECT * FROM TAX_Term tmx WHERE tmx.ParentCode=tm.Code" & _
		StringIf(Not (bTaxAdmin Or bTaxInactive)," AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code LIKE tmx.Code + '%' AND MemberID=" & g_intMemberID & ")") & _
		")"

	strQCode = Qs(strCode,SQUOTE)
	strDrillSQL = "SELECT tm.Code, ISNULL(tmd.AltTerm,tmd.Term) AS Term," & _
		"	CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ") THEN 1 ELSE 0 END AS bit) AS Active," & vbCrLf & _
		"	CAST(CASE WHEN " & strHasRecordsSQL & " THEN 1 ELSE 0 END AS bit) AS HasRecords," & vbCrLf & _
		"	CAST(CASE WHEN " & IIf(bTaxWithRecords,Replace(strHasRecordsSQL,"tmx.CdLvl >= tm.CdLvl","tmx.CdLvl > tm.CdLvl"),strHasChildrenSQL) & " THEN 1 ELSE 0 END AS bit) AS HasChildren," & vbCrLf & _
		"	COUNT(DISTINCT CASE WHEN tmx.Code=tm.Code THEN tl.NUM ELSE NULL END) AS CountRecords" & vbCrLf & _
		"FROM TAX_Term tm" & vbCrLf & _
		"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
		"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
		"LEFT JOIN TAX_Term tmx" & vbCrLf & _
		"	ON tmx.CdLvl1=tm.CdLvl1" & vbCrLf & _
		"		AND tmx.CdLvl >= tm.CdLvl" & vbCrLf & _
		"		AND tmx.Code LIKE tm.Code + '%'" & vbCrLf & _
		"LEFT JOIN CIC_BT_TAX_TM tlt" & vbCrLf & _
		"	ON tlt.Code=tmx.Code" & vbCrLf & _
		"LEFT JOIN CIC_BT_TAX tl" & vbCrLf & _
		"	ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
		"		AND EXISTS(SELECT *" & vbCrLf & _
		"			FROM GBL_BaseTable bt" & vbCrLf & _
		"			INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
		"				ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"			WHERE bt.NUM=tl.NUM" & vbCrLf & _
		"				AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
		"			)" & vbCrLf & _
		"WHERE tm.ParentCode=" & strQCode & vbCrLf & _
		StringIf(Not (bTaxAdmin Or bTaxInactive),"	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code LIKE tm.Code + '%' AND MemberID=" & g_intMemberID & ")" & vbCrLf) & _
		"GROUP BY tm.Code, tm.CdLvl, tm.CdLvl1, ISNULL(tmd.AltTerm,tmd.Term)" & vbCrLf & _
		StringIf(bTaxWithRecords,"HAVING (COUNT(tl.NUM) > 0)" & vbCrLf) & _
		"ORDER BY tm.Code"
	
	'Response.Write("<pre>" & strDrillSQL & "</pre>")
	'Response.Flush()

	With cmdDrill
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strDrillSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
		Set rsDrill = .Execute

	End With
%>
[
<%
	Dim strIconPlusMinus, _
		strIconEdit, _
		strIconSelect, _
		strLinkSearch, _
		strIconZoom, _
		strLinkTermInfo
		
	Dim strBaseRowURL
	strBaseRowURL = makeTaxLink(ps_strPathToStart & "jsonfeeds/tax_ddrows.asp", "TC=", vbNullString)

	Dim fldCode, _
		fldTerm, _
		fldActive, _
		fldHasChildren, _
		fldHasRecords, _
		fldCountRecords

	With rsDrill
		Set fldCode = .Fields("Code")
		Set fldTerm = .Fields("Term")
		Set fldActive = .Fields("Active")
		Set fldHasChildren = .Fields("HasChildren")
		Set fldHasRecords = .Fields("HasRecords")
		Set fldCountRecords = .Fields("CountRecords")

		While NOT .EOF
			'If there are child terms (Sub-Topics), create a linked icon to expand the tree
			If fldHasChildren Then
				strIconPlusMinus = "<span class=\""SimulateLink taxPlusMinus\"" data-taxcode=\""" & Replace(fldCode.Value,"-L",vbNullString) & "\"" data-url=\""" & Server.HTMLEncode(strBaseRowURL & fldCode.Value) & "\"" data-level=\""" & intLevel & "\"" data-closed=\""true\"">" & ICON_PLUS & "</span>"
			Else
				strIconPlusMinus = ICON_NOPLUSMINUS
			End If
			
			'If we are in Basic Search Mode and the user is a Super User, include a linked edit icon
			If user_bSuperUserCIC And intTaxSearchMode = MODE_BASIC And bTaxAdmin Then
				strIconEdit = "&nbsp;<a href=\""" & _
					makeLink(ps_strPathToStart & "tax_edit.asp","TC=" & fldCode.Value,vbNullString) & "\"">" & ICON_EDIT & "</a>"
			Else
				strIconEdit = vbNullString
			End If

			'If we are in Basic Search Mode and the Term (or its sub-Topics) have associated records, include a search link
			If fldHasRecords And intTaxSearchMode = MODE_BASIC Then
				strIconZoom = "&nbsp;<a class=\""TaxLink\"" href=\""" & _
					makeLink(ps_strPathToStart & "results.asp","TMC=" & fldCode.Value,vbNullString) & "\"">" & ICON_ZOOM & "</a>"
			Else
				strIconZoom = vbNullString
			End If

			'If we are in Advanced Search or Index Mode and the Term (or its sub-Topics) have associated records, include a select link
			If (intTaxSearchMode = MODE_ADVANCED And fldHasRecords) Or _
					(intTaxSearchMode = MODE_INDEX And fldActive) Then
				strIconSelect = "&nbsp;<a href=\""#javascript\"" onClick=\""parent.addBuildTerm(" & JSONQs(JsQs(fldCode.Value),False) & "," & JSONQs(JsQs(fldTerm.Value), False) & "); return false\"">" & ICON_SELECT & "</a>"
			Else
				strIconSelect = vbNullString
			End If

			'If this Term has associated records, include a record count.
			'In Basic Mode, the record count is linked to a search.
			If fldCountRecords.Value > 0 Then
				If intTaxSearchMode = MODE_BASIC Then
					strLinkSearch = "&nbsp;<a class=\""TaxLink\"" href=\""" & _
						makeLink(ps_strPathToStart & "results.asp","TMCR=on&TMC=" & fldCode.Value,vbNullString) & "\"">[<strong>" & fldCountRecords.Value & "</strong>]</a>"
				Else
					strLinkSearch = "&nbsp;[<strong>" & fldCountRecords.Value & "</strong>]"
				End If
			Else
				strLinkSearch = vbNullString
			End If
			
			'Link the Term Name to display more detailed Term Information.
			'If the Term is inactive, make it Alert-coloured.
			strLinkTermInfo = "&nbsp;<span class=\""taxExpandTerm SimulateLink TaxLink" & IIf(fldActive,vbNullString,"Inactive") & "\"" data-closed=\""true\"" data-taxcode=\""" & fldCode.Value & "\"" data-url=\""" & Server.HTMLEncode(makeTaxLink(ps_strPathToStart & "jsonfeeds/tax_moreinfo.asp", "TC=" & fldCode.Value, vbNullString)) & "\"">" & JSONQs(fldTerm.Value,False) & "</span>"
%>
		<%= strSep %>"<tr class=\"TaxRowLevel<%= intLevel %>\"><td class=\"<%= IIf(intLevel = 2, "TaxLevel2", "TaxBasic") %>\"><%=JSONQs(fldCode.Value,False)%></td><td class=\"<%= IIf(intLevel = 2, "TaxLevel2", "TaxBasic") %>\"><div class=\"CodeLevel<%=intLevel%>\"><%=strIconPlusMinus%><%=strLinkTermInfo%><%=strIconEdit%><%=strIconZoom%><%=strLinkSearch%><%=strIconSelect%></div><div class=\"taxDetail\"></div></td></tr>"
<%
			strSep = ","
			.MoveNext
		Wend
	End With
%>
]
<%
End If
%>

<!--#include file="../includes/core/incClose.asp" -->
