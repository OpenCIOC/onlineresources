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
Call setPageInfo(False, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtSearchTaxPublic.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<%
If Not g_bUseTaxonomyView Then
	Call securityFailure()
End If

Dim bInlineMode
bInlineMode = Not Nl(Trim(Request("InlineMode")))


If Not bInlineMode Then
Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""" & ps_strPathToStart & makeAssetVer("styles/taxonomy.css") & """/>")
Else
%>
<link href="<%=ps_strPathToStart & makeAssetVer("styles/taxonomy.css")%>" rel="stylesheet" type="text/css">
<%
End If

If Not bInlineMode Then
Call makePageHeader(TXT_BROWSE_BY_SERVICE_CATEGORY, TXT_BROWSE_BY_SERVICE_CATEGORY, True, False, True, True)
End If

Dim strCode, _
	bRelated

'"Browse By Service Category" Search, performs the following functions,
'depending on the criteria provided:
'	1.	No criteria – produces a list Level 1 Taxonomy Terms
'	2.	TC – a Taxonomy Code – produces a list of narrower Terms (Sub-Topics) for the given Term
'	3.	RC – a Taxonomy Code – produces a list of “See Also” (Related) Terms for the given Term
strCode = Trim(Request("TC"))
If Nl(strCode) Then
	strCode = Trim(Request("RC"))
	If Not Nl(strCode) Then
		bRelated = True
	End If
End If

Dim strServCatSQL, _
	strQCode

'If there are no Criteria, retrieve a list of Level 1 Terms
If Nl(strCode) Then
	strServCatSQL = "SELECT tm.Code,ISNULL(tmd.AltTerm,tmd.Term) AS Term," & _
			"CASE WHEN " & g_intTaxDefnLevel & " >= tm.CdLvl THEN ISNULL(AltDefinition,Definition) ELSE NULL END AS Definition," & _
			"tm.IconURL, tm.IconFA, CAST(1 AS bit) AS HasChildren, 0 AS CountRecords,CAST(0 AS bit) AS HasRelated" & vbCrLf & _
		"FROM TAX_Term tm" & vbCrLf & _
		"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
		"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
		"WHERE tm.CdLvl=1" & vbCrLf & _
		"ORDER BY Code"
'There is some criteria (Search for Sub-Topics or Related Topics)
Else
	strQCode = Qs(strCode,SQUOTE)
	
	'Fetch information about the Code that was passed as a parameter
	strServCatSQL = "SELECT ISNULL(tmd.AltTerm,tmd.Term) AS Term," & _
			"CASE WHEN tm.ParentCode IS NOT NULL THEN COUNT(DISTINCT btd.NUM) ELSE 0 END AS CountRecords," & _
			"tm.ParentCode," & _
			"(SELECT ISNULL(ptmd.AltTerm,ptmd.Term)" & _
				" FROM TAX_Term ptm INNER JOIN TAX_Term_Description ptmd ON ptmd.Code=ptm.Code AND ptmd.LangID=@@LANGID WHERE ptm.Code=tm.ParentCode) AS ParentTerm" & vbCrLf & _
		"FROM TAX_Term tm" & vbCrLf & _
		"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
		"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
		"INNER JOIN TAX_Term tmx" & vbCrLf & _
		"	ON tmx.CdLvl1=tm.CdLvl1 AND tmx.CdLvl >= tm.CdLvl AND tmx.Code LIKE tm.Code + '%'" & vbCrLf & _
		"INNER JOIN CIC_BT_TAX_TM tlt" & vbCrLf & _
		"	ON tlt.Code=tmx.Code" & vbCrLf & _
		"INNER JOIN CIC_BT_TAX tl" & vbCrLf & _
		"	ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
		"INNER JOIN GBL_BaseTable bt" & vbCrLf & _
		"	ON tl.NUM=bt.NUM" & vbCrLf & _
		"INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
		"	ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"WHERE tm.Code=" & strQCode & vbCrLf & _
		"	AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
		"GROUP BY ISNULL(tmd.AltTerm,tmd.Term), tm.ParentCode"

	strServCatSQL = strServCatSQL & vbCrLf & vbCrLf & _
		"SELECT tm.Code," & vbCrLf & _
		"		ISNULL(tmd.AltTerm,tmd.Term) AS Term," & vbCrLf & _
		"		CASE WHEN " & g_intTaxDefnLevel & " >= tm.CdLvl THEN ISNULL(AltDefinition,Definition) ELSE NULL END AS Definition," & vbCrLf & _
		"		tm.IconURL, tm.IconFA," & vbCrLf & _
		"		CAST(CASE WHEN EXISTS(SELECT *" & vbCrLf & _
		"				FROM TAX_Term tmx2" & vbCrLf & _
		"				INNER JOIN CIC_BT_TAX_TM tlt2" & vbCrLf & _
		"					ON tlt2.Code=tmx2.Code" & vbCrLf & _
		"				INNER JOIN CIC_BT_TAX tl2" & vbCrLf & _
		"					ON tlt2.BT_TAX_ID=tl2.BT_TAX_ID" & vbCrLf & _
		"				INNER JOIN GBL_BaseTable bt2" & vbCrLf & _
		"					ON tl2.NUM=bt2.NUM" & vbCrLf & _
		"				INNER JOIN GBL_BaseTable_Description btd2" & vbCrLf & _
		"					ON bt2.NUM=btd2.NUM AND btd2.LangID=@@LANGID" & vbCrLf & _
		"				WHERE tmx2.CdLvl1=tm.CdLvl1 AND tmx2.CdLvl > tm.CdLvl AND tmx2.Code LIKE tm.Code + '%'" & vbCrLf & _
		"					AND (" & Replace(Replace(g_strWhereClauseCICNoDel,"bt.","bt2."),"btd.","btd2.") & ")" & vbCrLf & _
		"			) THEN 1 ELSE 0 END AS bit) AS HasChildren," & vbCrLf & _
		"		COUNT(DISTINCT btd.NUM) AS CountRecords," & vbCrLf & _
		"		CAST(CASE WHEN EXISTS(SELECT *" & vbCrLf & _
		"				FROM TAX_SeeAlso sa" & vbCrLf & _
		"				INNER JOIN TAX_Term tm2" & vbCrLf & _
		"					ON sa.SA_Code=tm2.Code" & vbCrLf & _
		"				INNER JOIN TAX_Term tmx2" & vbCrLf & _
		"					ON tmx2.CdLvl1=tm2.CdLvl1 AND tmx2.CdLvl >= tm2.CdLvl AND tmx2.Code LIKE tm2.Code + '%'" & vbCrLf & _
		"				INNER JOIN CIC_BT_TAX_TM tlt2" & vbCrLf & _
		"					ON tlt2.Code=tmx2.Code" & vbCrLf & _
		"				INNER JOIN CIC_BT_TAX tl2" & vbCrLf & _
		"					ON tlt2.BT_TAX_ID=tl2.BT_TAX_ID" & vbCrLf & _
		"				INNER JOIN GBL_BaseTable bt2" & vbCrLf & _
		"					ON tl2.NUM=bt2.NUM" & vbCrLf & _
		"				INNER JOIN GBL_BaseTable_Description btd2" & vbCrLf & _
		"					ON bt2.NUM=btd2.NUM AND btd2.LangID=@@LANGID" & vbCrLf & _
		"				WHERE sa.Code=tm.Code" & vbCrLf & _
		"					AND (" & Replace(Replace(g_strWhereClauseCICNoDel,"bt.","bt2."),"btd.","btd2.") & ")" & vbCrLf & _
		"			) THEN 1 ELSE 0 END AS bit) AS HasRelated" & vbCrLf & _
		"	FROM TAX_Term tm" & vbCrLf & _
		"	INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
		"		ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
		"	INNER JOIN TAX_Term tmx" & vbCrLf & _
		"		ON tmx.CdLvl1=tm.CdLvl1 AND tmx.CdLvl >= tm.CdLvl AND tmx.Code LIKE tm.Code + '%'" & vbCrLf & _
		"	INNER JOIN CIC_BT_TAX_TM tlt" & vbCrLf & _
		"		ON tlt.Code=tmx.Code" & vbCrLf & _
		"	INNER JOIN CIC_BT_TAX tl" & vbCrLf & _
		"		ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
		"	INNER JOIN GBL_BaseTable bt" & vbCrLf & _
		"		ON tl.NUM=bt.NUM" & vbCrLf & _
		"	INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
		"		ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
		"	WHERE " & IIf(bRelated,"EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.SA_Code=tm.Code AND sa.Code=" & strQCode & ")","tm.ParentCode=" & strQCode) & vbCrLf & _
		"			AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
		"	GROUP BY tm.Code, tm.CdLvl, tm.CdLvl1, tm.ParentCode, ISNULL(tmd.AltTerm,tmd.Term), ISNULL(AltDefinition,Definition), tm.IconURL, tm.IconFA"
End If

'Response.Write("<pre>" & Server.HTMLEncode(strServCatSQL) & "</pre>")
'Response.Flush()

Dim cmdServCat, rsServCat
Set cmdServCat = Server.CreateObject("ADODB.Command")
With cmdServCat
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandText = strServCatSQL
	.CommandType = adCmdText
	.CommandTimeout = 0
	Set rsServCat = .Execute
End With

Dim strTermName

Dim strLinkCon, _
	strSubTopicLink, _
	strSearchLink, _
	strNameLink

Dim fldCode, _
	fldTerm, _
	fldDefinition, _
	fldIconURL, _
	fldIconFA, _
	fldCountRecords, _
	fldHasChildren, _
	fldHasRelated

'If this was not a Level 1 search, print information about the current search and Code
If Not Nl(strCode) Then
	Dim strTerm

%>
<p>[ <a href="<%=makeLinkB(ps_strThisPage)%>" class="TaxLink"><%=TXT_BROWSE_BY_SERVICE_CATEGORY%></a>
<%
	With rsServCat
		If Not .EOF Then
			strTerm = "<span class=""TaxTerm"">" & .Fields("Term") & "</span>"
		
			If bRelated Then
				If .Fields("CountRecords") > 0 Then
%>
: <%=TXT_TOPICS_RELATED_TO%><a href="<%=makeLink(ps_strPathToStart & "tresults.asp","TC=" & strCode,vbNullString)%>" class="TaxLink"><%=strTerm%> (<%=.Fields("CountRecords")%>)</a>
<%
				Else
%>
: <%=TXT_TOPICS_RELATED_TO%><%=strTerm%></p>
<%
				End If
			Else
				If Not Nl(.Fields("ParentCode")) Then
%>
: <a href="<%=makeLink(ps_strThisPage,"TC=" & .Fields("ParentCode"),vbNullString)%>"><%=.Fields("ParentTerm")%></a>
<%
				End If
				If .Fields("CountRecords") > 0 Then
%>
: <%=TXT_SUB_TOPICS_OF%><a href="<%=makeLink(ps_strPathToStart & "tresults.asp","TC=" & strCode,vbNullString)%>" class="TaxLink"><%=strTerm%> (<%=.Fields("CountRecords")%>)</a>
<%
				Else
%>
: <%=TXT_SUB_TOPICS_OF%><%=strTerm%>
<%
				End If
			End If
			Set rsServCat = .NextRecordset
		End If
	End With
%>
]</p>
<%
End If

'Display the list of Terms
With rsServCat
	If .EOF Then
%>
<p><%=TXT_FOUND%><strong>0</strong><%=TXT_MATCHES%>.</p>
<%
	Else
		Set fldCode = .Fields("Code")
		Set fldTerm = .Fields("Term")
		Set fldDefinition = .Fields("Definition")
		Set fldIconURL = .Fields("IconURL")
		Set fldIconFA = .Fields("IconFA")
		Set fldCountRecords = .Fields("CountRecords")
		Set fldHasChildren = .Fields("HasChildren")
		Set fldHasRelated = .Fields("HasRelated")

		While NOT .EOF
			strLinkCon = vbNullString
			If fldCountRecords > 0 Then
				strSearchLink = makeLink(ps_strPathToStart & "tresults.asp","TC=" & fldCode,vbNullString)
				strNameLink = strSearchLink
			End If
			If fldHasChildren Then
				strSubTopicLink = makeLink(ps_strThisPage,"TC=" & fldCode,vbNullString)
				strNameLink = strSubTopicLink
			End If
%>
<h2 class="RevBoxHeader"><%If Not Nl(fldIconURL.Value) Then%><img src="<%=fldIconURL.Value%>"><%Else%><i class="fa fa-<%=fldIconFA.Value%>"></i><%End If%>
	<a href="<%=strNameLink%>"><%=fldTerm.Value%></a></h2>
	<div class="SubBoxHeader">
	<%If Not Nl(fldDefinition.Value) Then%><p class="TermDefinition"><%=textToHTML(fldDefinition.Value)%></p><%End If%>
	<p class="MoreTermInfo">[
<%
		'There are Sub-Topics with records associated with this Term
		If fldHasChildren Then
%>
<%=strLinkCon%><a href="<%=strSubTopicLink%>" class="MoreTermInfo"><%=TXT_SUB_TOPICS%></a>
<%
			strLinkCon = " | "
		End If
		'There are records associated with this Term or its Sub-Topics
		If fldCountRecords > 0 Then
%>
<%=strLinkCon%><a href="<%=strSearchLink%>" class="MoreTermInfo"><%=Nz(get_view_data_cic("ViewProgramsAndServices"), TXT_PROGRAMS_SERVICES_FOR_TOPIC)%>&nbsp;(<strong><%=fldCountRecords%></strong>)</a>
<%
			strLinkCon = " | "
		End If
		'There are Terms related to this Term
		If fldHasRelated Then
%>
<%=strLinkCon%><a href="<%=makeLink(ps_strThisPage,"RC=" & fldCode,vbNullString)%>" class="MoreTermInfo"><%=TXT_RELATED_TOPICS%></a>
<%
			strLinkCon = " | "
		End If
%>
	]</p>
	</div>
<%
			.MoveNext
		Wend
	End If
End With

'Print a link to the Taxonomy Disclaimer if the user is not logged in
If Not user_bLoggedIn Then
%>
<p class="SmallNote"><%=TXT_TAXONOMY_DISCLAIMER%></p>
<%
End If

If Not bInlineMode Then
Call makePageFooter(True)
End If
%>

<!--#include file="includes/core/incClose.asp" -->

