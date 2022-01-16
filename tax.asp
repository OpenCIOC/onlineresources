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
'Purpose:		The interface for all staff-only Taxonomy search areas, including:
'				- Basic Service Category Search
'				- "Service Category Finder" pop-up window
'				- Advanced Service Category Search (within an IFRAME);
'				- Record Indexing with the Taxonomy (within an IFRAME);
'				A Parameter is passed to the page indicating which of the
'				above 4 "Search Modes" this page should operate under.
'
'				The page can operate under a number of different "Search Types".
'				Different types of searches are available depending on the
'				current Search Mode, and the user can switch between available types
'				using a Menu at the top of the page. Search Types available include:
'				'- Keyword Search
'				'- Code Search
'				'- Drill-Down Search
'				'- Related Concept Search
'				'- Suggest Link
'				'- Suggest Term
'				'- Record Search
'
'				The various Search Modes, Types and Settings are defined in the file
'				includes/incTaxPassVars.asp
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
<!--#include file="text/txtGeneralSearch2.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchTax.asp" -->
<!--#include file="text/txtSearchResultsTax.asp" -->
<!--#include file="includes/taxonomy/incTaxPassVars.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="includes/taxonomy/incTaxConceptList.asp" -->
<!--#include file="includes/taxonomy/incTaxIcons.asp" -->
<!--#include file="includes/taxonomy/incTaxRecordTable.asp" -->
<!--#include file="includes/taxonomy/incTaxSearchDrillDown.asp" -->
<!--#include file="includes/taxonomy/incTaxSearchTable.asp" -->
<%
'Initialize the predifined links to Taxonomy Icons (regular HTML mode)
Call setIcons(False)

Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""" & ps_strPathToStart & makeAssetVer("styles/taxonomy.css") &  """/>")

'Ensure the Taxonomy is available in this View
If Not g_bUseTaxonomyView Then
	Call securityFailure()
End If

Dim strSearchTitle, _
	strSearchSQL, _
	intSearchSort, _
	strCritError, _
	bDoSearch, _
	strSearchVars

Dim strTermList, _
	strDisplay, _
	aTerms, _
	indTerm, _
	strLinkSQL, _
	strLinkSQL2, _
	strLinkCon

Dim strJoinedSTerms, _
	strJoinedQSTerms, _
	quotedSTerms(), _
	exactSTerms(), _
	singleSTerms(), _
	displaySTerms(), _
	strSTerms, _
	strSType, _
	strContains, _
	strContainsQ

bDoSearch = False

Select Case intTaxSearchType
	'PKeyword Search 
	Case SEARCH_KEYWORD
		Dim bAnywhere

		strSTerms = Trim(Request("STerms"))	
		strSType = Request("SType")
		bAnywhere = Request("SType") = "A"

		intSearchSort = SORT_BY_NAME_ASC
		strSearchTitle = TXT_KEYWORD

		If Not Nl(strSTerms) Then	
			Call makeSearchString( _
				strSTerms, _
				singleSTerms, _
				quotedSTerms, _
				exactSTerms, _
				displaySTerms, _
				False _
			)
			If UBound(singleSTerms) > -1 Or UBound(quotedSTerms) > -1 Then
				strJoinedSTerms = Join(singleSTerms,AND_CON) & _
					StringIf(UBound(singleSTerms) > -1 And UBound(quotedSTerms) > -1,AND_CON) & _
					Join(quotedSTerms,AND_CON)
				strSearchVars = "STerms=" & strSTerms & IIf(bAnywhere,"&SType=A",vbNullString)
				bDoSearch = True
			End If
		Else
			ReDim singleSTerms(-1)
			ReDim quotedSTerms(-1)
			ReDim exactSTerms(-1)
		End If

		'The criteria is available to proceed with a search; generate the SQL
		If bDoSearch Then		
			strSearchSQL = 	"SET NOCOUNT ON" & vbCrLf & _
				"DECLARE @MemberID int," & vbCrLf & _
				"@StringToMatch nvarchar(1000)" & vbCrLf & _
				"SET @MemberID=" & g_intMemberID & vbCrLf & _
				"SET @StringToMatch = '" & strJoinedSTerms & "'" & vbCrLf & _
				"DECLARE @MatchTerms TABLE (" & vbCrLf & _
				"	Code varchar(23) COLLATE Latin1_General_100_CI_AI NOT NULL," & vbCrLf & _
				"	CdLvl tinyint NOT NULL," & vbCrLf & _
				"	CdLvl1 char(1) NOT NULL," & vbCrLf & _
				"	Term nvarchar(255) NOT NULL," & vbCrLf & _
				"	BaseMatch bit NOT NULL" & vbCrLf & _
				")" & vbCrLf & _
				vbCrLf & _
				"INSERT INTO @MatchTerms (Code, CdLvl, CdLvl1, Term, BaseMatch)" & vbCrLf & _
				"SELECT tm.Code, tm.CdLvl, tm.CdLvl1," & vbCrLf & _
				"	ISNULL(tmd.AltTerm,tmd.Term) AS Term," & vbCrLf & _
				"	1 AS BaseMatch" & vbCrLf & _
				"FROM TAX_Term tm" & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
				"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
				"WHERE (" & vbCrLf & _
				"		CONTAINS(tmd.Term,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf & _
				"		OR CONTAINS(tmd.AltTerm,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf & _
				StringIf(bAnywhere,"		OR CONTAINS(tmd.Definition,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "') OR CONTAINS(tmd.AltDefinition,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf) & _
				"	)" & vbCrLf & _
				StringIf(Not bTaxAdmin,"	AND tm.Active IS NOT NULL" & vbCrLf) & _
				vbCrLf & _
				"INSERT INTO @MatchTerms (Code, CdLvl, CdLvl1, Term, BaseMatch)" & vbCrLf & _
				"SELECT tm.Code, tm.CdLvl, tm.CdLvl1," & vbCrLf & _
				"	ut.Term + ' (use ' + ISNULL(tmd.AltTerm,tmd.Term) + ')' AS Term," & vbCrLf & _
				"	0 AS BaseMatch" & vbCrLf & _
				"FROM TAX_Unused ut" & vbCrLf & _
				"INNER JOIN TAX_Term tm" & vbCrLf & _
				"	ON ut.Code=tm.Code" & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
				"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
				"WHERE ut.LangID=@@LANGID" & vbCrLf & _
				"	AND CONTAINS(ut.Term,@StringToMatch)" & vbCrLf & _
				StringIf(Not bTaxAdmin,"	AND NOT EXISTS(SELECT * FROM @MatchTerms m WHERE m.Code=ut.Code)" & vbCrLf) & _
				vbCrLf & _
				StringIf(Not bTaxAdmin,"	AND tm.Active IS NOT NULL" & vbCrLf) & _
				vbCrLf & _
				"INSERT INTO @MatchTerms (Code, CdLvl, CdLvl1, Term, BaseMatch)" & vbCrLf & _
				"SELECT tm.Code, tm.CdLvl, tm.CdLvl1," & vbCrLf & _
				"	ut.Term + ' (use ' + ISNULL(tmd.AltTerm,tmd.Term) + ')' AS Term," & vbCrLf & _
				"	0 AS BaseMatch" & vbCrLf & _
				"FROM TAX_Unused ut" & vbCrLf & _
				"INNER JOIN TAX_Term tm" & vbCrLf & _
				"	ON ut.Code=tm.Code" & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
				"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
				"WHERE ut.LangID=@@LANGID" & vbCrLf & _
				"	AND CONTAINS(ut.Term,@StringToMatch)" & vbCrLf & _
				StringIf(Not bTaxAdmin,"	AND NOT EXISTS(SELECT * FROM @MatchTerms m WHERE m.Code=ut.Code)" & vbCrLf) & _
				vbCrLf & _
				StringIf(Not bTaxAdmin,"INSERT INTO @MatchTerms (Code, CdLvl, CdLvl1, Term, BaseMatch)" & vbCrLf & _
				"SELECT tm.Code, tm.CdLvl, tm.CdLvl1," & vbCrLf & _
				"	ISNULL(tmrld.AltTerm,tmrld.Term) + ' (use ' + ISNULL(tmd.AltTerm,tmd.Term) + ')' AS Term," & vbCrLf & _
				"	0 AS BaseMatch" & vbCrLf & _
				"FROM TAX_Term tmrl" & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmrld" & vbCrLf & _
				"	ON tmrl.Code=tmrld.Code AND tmrld.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN TAX_Term tm" & vbCrLf & _
				"	ON tmrl.Code LIKE tm.Code + '%'" & vbCrLf & _
				"		AND tmrl.CdLvl1 = tm.CdLvl1" & vbCrLf & _
				"		AND tmrl.CdLvl2 = tm.CdLvl2" & vbCrLf & _
				"		AND tmrl.CdLvl > tm.CdLvl" & vbCrLf & _
				"		AND NOT EXISTS(SELECT * FROM TAX_Term tm2" & vbCrLf & _
				"			WHERE tmrl.Code LIKE tm2.Code + '%' AND tmrl.CdLvl1 = tm2.CdLvl1 AND tmrl.CdLvl2 = tm2.CdLvl2 AND tm.CdLvl > tm2.CdLvl" & vbCrLf & _
				"				AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm2.Code AND MemberID=@MemberID)" & vbCrLf & _
				"			)" & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
				"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
				"WHERE tmrl.Active IS NULL" & vbCrLf & _
				"	AND NOT EXISTS(SELECT * FROM @MatchTerms m WHERE m.Code=tmrl.Code AND BaseMatch=1)" & vbCrLf & _
				"	AND (" & vbCrLf & _
				"		CONTAINS(tmrld.Term,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf & _
				"		OR CONTAINS(tmrld.AltTerm,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf & _
				StringIf(bAnywhere,"		OR CONTAINS(tmrld.Definition,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "') OR CONTAINS(tmrld.AltDefinition,@StringToMatch,LANGUAGE '" & g_objCurrentLang.LanguageAlias & "')" & vbCrLf) & _
				"	)" & vbCrLf & _
				"	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID)" & vbCrLf & _
				vbCrLf) & _
				"SET NOCOUNT OFF" & vbCrLf & _
				"SELECT m.Code, m.CdLvl, m.Term," & vbCrLf & _
				"		CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=m.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active," & vbCrLf & _
				"		CAST(CASE WHEN COUNT(DISTINCT tl.NUM) > 0 THEN 1 ELSE 0 END AS bit) AS HasRecords," & vbCrLf & _
				"		COUNT(DISTINCT CASE WHEN tmx.Code=m.Code THEN tl.NUM ELSE NULL END) AS CountRecords" & vbCrLf & _
				"	FROM @MatchTerms m" & vbCrLf & _
				"	LEFT JOIN TAX_Term tmx" & vbCrLf & _
				"	ON tmx.CdLvl1=m.CdLvl1" & vbCrLf & _
				"		AND tmx.CdLvl >= m.CdLvl" & vbCrLf & _
				"		AND tmx.Code LIKE m.Code + '%'" & vbCrLf & _
				"	LEFT JOIN CIC_BT_TAX_TM tlt" & vbCrLf & _
				"		ON tlt.Code=tmx.Code" & vbCrLf & _
				"	LEFT JOIN CIC_BT_TAX tl" & vbCrLf & _
				"		ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
				"			AND EXISTS(SELECT *" & vbCrLf & _
				"				FROM GBL_BaseTable bt" & vbCrLf & _
				"				INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
				"					ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"				WHERE bt.NUM=tl.NUM" & vbCrLf & _
				"					AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
				"			)" & vbCrLf & _
				StringIf(Not (bTaxAdmin Or bTaxInactive), "WHERE EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=m.Code AND MemberID=@MemberID)") & vbCrLf & _
				"GROUP BY m.Code, m.CdLvl, m.Term" & vbCrLf & _
				StringIf(bTaxWithRecords,"HAVING (COUNT(DISTINCT CASE WHEN tmx.Code=m.Code THEN tl.NUM ELSE NULL END) > 0)" & vbCrLf) & _
				"ORDER BY Term"
		End If

	Case SEARCH_DRILL_DOWN
		bDoSearch = True
	
		Dim strHasRecordsSQL
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
			")"

		'generate the SQL to display the top-level Taxonomy Terms
		strSearchSQL = "SELECT tm.Code,ISNULL(tmd.AltTerm,tmd.Term) AS Term," & _
			"	CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ") THEN 1 ELSE 0 END AS bit) AS Active," & vbCrLf & _
			"	CAST(CASE WHEN " & strHasRecordsSQL & " THEN 1 ELSE 0 END AS bit) AS HasRecords," & vbCrLf & _
			"	CAST(CASE WHEN " & IIf(bTaxWithRecords,strHasRecordsSQL,"EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code)") & " THEN 1 ELSE 0 END AS bit) AS HasChildren" & vbCrLf & _
			"FROM TAX_Term tm" & vbCrLf & _
			"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
			"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
			"WHERE tm.CdLvl = 1"& vbCrLf & _
			StringIf(Not (bTaxAdmin Or bTaxInactive),"	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code LIKE tm.Code + '%' AND MemberID=" & g_intMemberID & ")" & vbCrLf) & _
			StringIf(bTaxWithRecords,"	AND " & strHasRecordsSQL & vbCrLf) & _
			"ORDER BY tm.Code"

	
		intSearchSort = SORT_BY_CODE_ASC
		strSearchTitle = TXT_DRILL_DOWN_SEARCH

	Case SEARCH_CONCEPT
		Dim intRCID
		intRCID = Request("RCID")
		If Nl(intRCID) Then
			intRCID = Null
		ElseIf Not IsIDType(intRCID) Then
			strCritError = TXT_INVALID_ID & Server.HTMLEncode(intRCID) & "."
			intRCID = Null
		Else
			bDoSearch = True
			strSearchVars = "RCID=" & intRCID
			intRCID = CLng(intRCID)
		End If
		
		intSearchSort = SORT_BY_NAME_ASC
		strSearchTitle = TXT_RELATED_CONCEPT_SEARCH

		'The criteria is available to proceed with a search; generate the SQL
		If bDoSearch Then
			strSearchSQL = "SELECT tm.Code, tm.CdLvl, ISNULL(tmd.AltTerm,tmd.Term) AS Term," & vbCrLf & _
				"	CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ") THEN 1 ELSE 0 END AS bit) AS Active," & vbCrLf & _
				"	CAST(CASE WHEN COUNT(DISTINCT tl.NUM) > 0 THEN 1 ELSE 0 END AS bit) AS HasRecords," & vbCrLf & _
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
				"WHERE EXISTS(SELECT * FROM TAX_TM_RC rc WHERE rc.Code=tm.Code AND rc.RC_ID=" & intRCID & ")" & vbCrLf & _
				StringIf(Not bTaxAdmin,IIf(bTaxInactive,"	AND (tm.Active=0 OR EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & "))","	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ")") & vbCrLf) & _
				"GROUP BY tm.Code, tm.CdLvl, tm.Active, ISNULL(tmd.AltTerm,tmd.Term)" & vbCrLf & _
				StringIf(bTaxWithRecords,"HAVING (COUNT(DISTINCT CASE WHEN tmx.Code=tm.Code THEN tl.NUM ELSE NULL END) > 0)" & vbCrLf) & _
				"ORDER BY ISNULL(tmd.AltTerm,tmd.Term)"
		End If

	Case SEARCH_SUGGEST_LINK	
		strTermList = Request("TC")
		strDisplay = Trim(Request("TCD"))
		
		If Not Nl(strDisplay) And IsTaxCodeList(strTermList) Then
			aTerms = Split(strTermList,",")
			strSearchVars = "TC=" & strTermList & "&TCD=" & Server.URLEncode(strDisplay)
			bDoSearch = True
		Else
			strTermList = Null
			strDisplay = Null
		End If

		intSearchSort = SORT_BY_RELEVANCE
		strSearchTitle = TXT_SUGGEST_LINK
		
		'The criteria is available to proceed with a search; generate the SQL
		If bDoSearch Then
			strLinkCon = vbNullString
		
			For Each indTerm in aTerms
				strLinkSQL = strLinkSQL & strLinkCon & "EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt3 WHERE tlt2.BT_TAX_ID=tlt3.BT_TAX_ID AND tlt3.Code LIKE " & Qs(indTerm + "%",SQUOTE) & ")" & vbCrLf
				strLinkSQL2 = strLinkSQL2 & strLinkCon & "tm.Code NOT LIKE " & Qs(indTerm + "%",SQUOTE) & vbCrLf
				strLinkCon = AND_CON
			Next
		
			strSearchSQL = "SELECT tm.Code, tm.CdLvl," & vbCrLf & _
				"	COUNT(tlx.BT_TAX_ID) AS Occurrences," & vbCrLf & _
				"	ISNULL(tmd.AltTerm,tmd.Term) AS Term," & vbCrLf & _
				"	CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ") THEN 1 ELSE 0 END AS bit) AS Active," & vbCrLf & _
				"	CAST(CASE WHEN COUNT(DISTINCT tl.NUM) > 0 THEN 1 ELSE 0 END AS bit) AS HasRecords," & vbCrLf & _
				"	COUNT(DISTINCT tl.NUM) AS CountRecords" & vbCrLf & _
				"FROM TAX_Term tm" & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
				"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN CIC_BT_TAX_TM tlt" & vbCrLf & _
				"	ON tlt.Code=tm.Code" & vbCrLf & _
				"INNER JOIN CIC_BT_TAX tl" & vbCrLf & _
				"	ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
				"		AND EXISTS(SELECT *" & vbCrLf & _
				"			FROM GBL_BaseTable bt" & vbCrLf & _
				"			INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
				"				ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"			WHERE bt.NUM=tl.NUM" & vbCrLf & _
				"				AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
				"		)" & vbCrLf & _
				"LEFT JOIN CIC_BT_TAX tlx" & vbCrLf & _
				"	ON tlx.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
				"		" & strLinkCon & Replace(strLinkSQL,"tlt2","tlx") & vbCrLf & _
				"WHERE EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt2 WHERE tlt2.Code=tm.Code" & vbCrLf & _
				"		" & strLinkCon & strLinkSQL & vbCrLf & _
				"	)" & vbCrLf & _
				"	" & strLinkCon & strLinkSQL2 & vbCrLf & _
				StringIf(Not bTaxInactive,"	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ")" & vbCrLf) & _
				"GROUP BY tm.Code, tm.CdLvl, tm.Active, ISNULL(tmd.AltTerm,tmd.Term)" & vbCrLf & _
				"ORDER BY COUNT(tlx.BT_TAX_ID) DESC, ISNULL(tmd.AltTerm,tmd.Term)"
		End If

	Case SEARCH_SUGGEST_TERM		
		strTermList = Request("TC")
		strDisplay = Trim(Request("TCD"))
		
		If Not Nl(strDisplay) And IsTaxCodeList(strTermList) Then
			aTerms = Split(strTermList,",")
			strSearchVars = "TC=" & strTermList & "&TCD=" & Server.URLEncode(strDisplay)
			bDoSearch = True
		Else
			strTermList = Null
			strDisplay = Null
		End If

		intSearchSort = SORT_BY_RELEVANCE
		strSearchTitle = TXT_SUGGEST_TERM

		'The criteria is available to proceed with a search; generate the SQL
		If bDoSearch Then
			strLinkCon = vbNullString
		
			For Each indTerm in aTerms
				strLinkSQL = strLinkSQL & strLinkCon & "EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt3 WHERE tl3.BT_TAX_ID=tlt3.BT_TAX_ID AND tlt3.Code LIKE " & Qs(indTerm + "%",SQUOTE) & ")" & vbCrLf
				strLinkCon = AND_CON
			Next
		
			strSearchSQL = "SELECT tm.Code, tm.CdLvl," & vbCrLf & _
				"	COUNT(DISTINCT tlx.BT_TAX_ID) AS Occurrences," & vbCrLf & _
				"	ISNULL(tmd.AltTerm,tmd.Term) AS Term," & vbCrLf & _
				"	CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ") THEN 1 ELSE 0 END AS bit) AS Active," & vbCrLf & _
				"	CAST(CASE WHEN COUNT(DISTINCT tl.NUM) > 0 THEN 1 ELSE 0 END AS bit) AS HasRecords," & vbCrLf & _
				"	COUNT(DISTINCT tl.NUM) AS CountRecords" & vbCrLf & _
				"FROM TAX_Term tm" & vbCrLf & _
				"INNER JOIN TAX_Term_Description tmd" & vbCrLf & _
				"	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN CIC_BT_TAX_TM tlt" & vbCrLf & _
				"	ON tlt.Code=tm.Code" & vbCrLf & _
				"INNER JOIN CIC_BT_TAX tl" & vbCrLf & _
				"	ON tlt.BT_TAX_ID=tl.BT_TAX_ID" & vbCrLf & _
				"		AND EXISTS(SELECT *" & vbCrLf & _
				"			FROM GBL_BaseTable bt" & vbCrLf & _
				"			INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
				"				ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"			WHERE bt.NUM=tl.NUM" & vbCrLf & _
				"				AND (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
				"		)" & vbCrLf & _
				"LEFT JOIN CIC_BT_TAX tlx" & vbCrLf & _
				"	ON tlx.NUM=tl.NUM AND tlx.BT_TAX_ID<>tl.BT_TAX_ID" & vbCrLf & _
				"		" & strLinkCon & Replace(Replace(strLinkSQL,"tlt3","tltx"),"tl3","tlx") & vbCrLf & _
				"WHERE tm.Code NOT IN ('" & Join(aTerms,"','") & "')" & vbCrLf & _
				"	AND EXISTS(SELECT *" & vbCrLf & _
				"		FROM GBL_BaseTable bt" & vbCrLf & _
				"		INNER JOIN GBL_BaseTable_Description btd" & vbCrLf & _
				"			ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"		INNER JOIN CIC_BT_TAX tl2" & vbCrLf & _
				"			ON tl2.NUM=bt.NUM" & vbCrLf & _
				"		INNER JOIN CIC_BT_TAX_TM tlt2" & vbCrLf & _
				"			ON tl2.BT_TAX_ID=tlt2.BT_TAX_ID" & vbCrLf & _
				"				AND tlt2.Code=tm.Code" & vbCrLf & _
				"		WHERE (" & g_strWhereClauseCICNoDel & ")" & vbCrLf & _
				"			AND EXISTS(SELECT * FROM CIC_BT_TAX tl3 WHERE tl3.NUM=tl2.NUM AND tl3.BT_TAX_ID<>tl2.BT_TAX_ID" & vbCrLf & _
				"				" & strLinkCon & strLinkSQL & vbCrLf & _
				"			)" & vbCrLf & _
				"	)" & vbCrLf & _
				StringIf(Not bTaxInactive,"	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ")" & vbCrLf) & _
				"GROUP BY tm.Code, tm.CdLvl, tm.Active, ISNULL(tmd.AltTerm,tmd.Term)" & vbCrLf & _
				"ORDER BY COUNT(DISTINCT tlx.BT_TAX_ID) DESC, ISNULL(tmd.AltTerm,tmd.Term)"
		End If

	Case SEARCH_BY_RECORD
		Dim strWhere
	
		strSTerms = Trim(Request("STerms"))
		strSType = Request("SType")

		If Not Nl(strSTerms) Then
			Call makeSearchString( _
				strSTerms, _
				singleSTerms, _
				quotedSTerms, _
				exactSTerms, _
				displaySTerms, _
				False _
			)
			If UBound(singleSTerms) > -1 Or UBound(quotedSTerms) > -1 Then
				strJoinedSTerms = Join(singleSTerms,AND_CON)
				strJoinedQSTerms = Join(quotedSTerms,AND_CON)
				strSearchVars = "STerms=" & strSTerms & "&SType=" & strSType
				bDoSearch = True
			End If
		Else
			ReDim singleSTerms(-1)
			ReDim quotedSTerms(-1)
			ReDim exactSTerms(-1)
		End If
		
		Select Case strSType
			Case "S"
				strContains = StringIf(Not Nl(strJoinedSTerms),"cbtd.SRCH_Subjects,'" & strJoinedSTerms & "'")
				strContainsQ = StringIf(Not Nl(strJoinedQSTerms),"cbtd.SRCH_Subjects,'" & strJoinedQSTerms & "'")
			Case "T"
				strContains = StringIf(Not Nl(strJoinedSTerms),"cbtd.SRCH_Taxonomy,'" & strJoinedSTerms & "'")
				strContainsQ = StringIf(Not Nl(strJoinedQSTerms),"cbtd.SRCH_Taxonomy,'" & strJoinedQSTerms & "'")
			Case "O"
				strContains = StringIf(Not Nl(strJoinedSTerms),"btd.SRCH_Org,'" & strJoinedSTerms & "'")
				strContainsQ = StringIf(Not Nl(strJoinedQSTerms),"btd.SRCH_Org,'" & strJoinedQSTerms & "'")
			Case Else
				strSType = "A"
				strContains = StringIf(Not Nl(strJoinedSTerms),"btd.SRCH_Anywhere,'" & strJoinedSTerms & "'")
				strContainsQ = StringIf(Not Nl(strJoinedQSTerms),"btd.SRCH_Anywhere,'" & strJoinedQSTerms & "'")
		End Select	
		
		'The criteria is available to proceed with a search; generate the SQL
		If bDoSearch Then
			If Not Nl(strContains) Then
				strWhere = "(CONTAINS(" & strContains & ",LANGUAGE '" & g_objCurrentLang.LanguageAlias & "'))"
			End If
			If Not Nl(strContainsQ) Then
				strWhere = strWhere & StringIf(Not Nl(strWhere),AND_CON) & "(CONTAINS(" & strContainsQ & "))"
			End If
			
			strWhere = strWhere & AND_CON & g_strWhereClauseCICNoDel
			
			strSearchSQL = "SELECT bt.NUM," & _
				"dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL," & vbCrLf & _
				"CASE WHEN EXISTS(SELECT * FROM CIC_BT_TAX tl WHERE tl.NUM=bt.NUM) THEN 1 ELSE 0 END AS HAS_TERMS" & vbCrLf & _
				"FROM GBL_BaseTable bt " & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
				"WHERE " & strWhere & vbCrLf & _
				"ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5," & vbCrLf & _
				"	STUFF(" & vbCrLf & _
				"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
				"			THEN NULL" & vbCrLf & _
				"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
				"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
				"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
				"			 END," & vbCrLf & _
				"		1, 2, ''" & vbCrLf & _
				"	)"
		End If
	Case Else
		intTaxSearchType = SEARCH_CODE
		Dim strCode
		strCode = Trim(Request("TC"))
		If Not Nl(strCode) Then
			If Not IsTaxonomyCodeType(strCode) Then
				strCritError = TXT_INVALID_CODE & strCode
				strCode = Null
			Else
				strSearchVars = "TC=" & strCode
				bDoSearch = True
			End If
		End If
		
		intSearchSort = SORT_BY_CODE_ASC
		strSearchTitle = TXT_CODE_SEARCH

		'The criteria is available to proceed with a search; generate the SQL
		If bDoSearch Then
			strSearchSQL = "SELECT tm.Code, tm.CdLvl, ISNULL(tmd.AltTerm,tmd.Term) AS Term," & vbCrLf & _
				"	CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ") THEN 1 ELSE 0 END AS bit) AS Active," & vbCrLf & _
				"	CAST(CASE WHEN COUNT(DISTINCT tl.NUM) > 0 THEN 1 ELSE 0 END AS bit) AS HasRecords," & vbCrLf & _
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
				"WHERE tm.Code LIKE " & Qs(strCode + "%",SQUOTE) & vbCrLf & _
				StringIf(Not bTaxAdmin,IIf(bTaxInactive,"	AND (tm.Active=0 OR EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & "))","	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=" & g_intMemberID & ")") & vbCrLf) & _
				"GROUP BY tm.Code, tm.CdLvl, tm.Active, ISNULL(tmd.AltTerm,tmd.Term)" & vbCrLf & _
				StringIf(bTaxWithRecords,"HAVING (COUNT(DISTINCT CASE WHEN tmx.Code=tm.Code THEN tl.NUM ELSE NULL END) > 0)" & vbCrLf) & _
				"ORDER BY tm.Code"
		End If
End Select

'The header table is only printed if we are in Basic Search Mode.
Call makePageHeader(TXT_SERVICE_CATEGORY_SEARCH & TXT_COLON & strSearchTitle, TXT_SERVICE_CATEGORY_SEARCH & TXT_COLON & strSearchTitle, intTaxSearchMode = MODE_BASIC, False, True, intTaxSearchMode = MODE_BASIC)

If Not Nl(strCritError) Then
	Call handleError(strCritError, _
		vbNullString, vbNullString)
End If

'Create the menu of Search Types available given the current Search Mode.
'If the user is a Super User and we are in Basic search mode, a link to Manage Taxonomy is provided.
'The current Search Type is highlighted, as are any search settings that have been changed from the default.
%>
<p>[
<%If Not intTaxSearchType=SEARCH_KEYWORD Then%><a href="<%=makeTaxLink(ps_strThisPage,"ST=" & SEARCH_KEYWORD,"ST")%>" class="TaxLink"><%=TXT_KEYWORD%></a><%Else%><span class="HighLight"><%=TXT_KEYWORD%></span><%End If%>
| <%If Not intTaxSearchType=SEARCH_CODE Then%><a href="<%=makeTaxLink(ps_strThisPage,"ST=" & SEARCH_CODE,"ST")%>" class="TaxLink"><%=TXT_CODE_SEARCH%></a><%Else%><span class="HighLight"><%=TXT_CODE_SEARCH%></span><%End If%>
| <%If Not intTaxSearchType=SEARCH_DRILL_DOWN Then%><a href="<%=makeTaxLink(ps_strThisPage,"ST=" & SEARCH_DRILL_DOWN,"ST")%>" class="TaxLink"><%=TXT_DRILL_DOWN_SEARCH%></a><%Else%><span class="HighLight"><%=TXT_DRILL_DOWN_SEARCH%></span><%End If%>
| <%If Not intTaxSearchType=SEARCH_CONCEPT Then%><a href="<%=makeTaxLink(ps_strThisPage,"ST=" & SEARCH_CONCEPT,"ST")%>" class="TaxLink"><%=TXT_RELATED_CONCEPT_SEARCH%></a><%Else%><span class="HighLight"><%=TXT_RELATED_CONCEPT_SEARCH%></span><%End If%>
<%If intTaxSearchType=SEARCH_SUGGEST_LINK Then%>| <span class="HighLight"><%=TXT_SUGGEST_LINK%></span><%End If%>
<%If intTaxSearchType=SEARCH_SUGGEST_TERM Then%>| <span class="HighLight"><%=TXT_SUGGEST_TERM%></span><%End If%>
<%If intTaxSearchMode=MODE_INDEX Then%>
| <%If Not intTaxSearchType=SEARCH_BY_RECORD Then%><a href="<%=makeTaxLink(ps_strThisPage,"ST=" & SEARCH_BY_RECORD,"ST")%>" class="TaxLink"><%=TXT_RECORD_SEARCH%></a><%Else%><span class="HighLight"><%=TXT_RECORD_SEARCH%></span><%End If%>
<%End If%>
<%If (intTaxSearchType<>SEARCH_SUGGEST_LINK And intTaxSearchType<>SEARCH_SUGGEST_TERM) Then%>
| <a href="<%=makeTaxLink(ps_strThisPage,"WR=" & IIf(bTaxWithRecords,vbNullString,"on") & "&" & strSearchVars,"WR")%>" class="TaxLink"><%=IIf(bTaxWithRecords,"<span class=""HighLight"">" & TXT_SHOW_ALL_TERMS & "</span>",TXT_ONLY_WITH_RECORDS)%></a>
<%End If%>
<%If (intTaxSearchMode<>MODE_BASIC) Or Not user_bSuperUserCIC Then%>
| <a href="<%=makeTaxLink(ps_strThisPage,"IA=" & IIf(bTaxInactive,vbNullString,"on") & "&" & strSearchVars,"IA")%>" class="TaxLink"><%=IIf(bTaxInactive,"<span class=""HighLight"">" & TXT_HIDE_INACTIVE & "</span>",TXT_SHOW_INACTIVE)%></a>
<%End If%>
<%If intTaxSearchMode=MODE_BASIC And user_bSuperUserCIC Then%>
| <a href="<%=makeTaxLink(ps_strThisPage,"AM=" & IIf(bTaxAdmin,vbNullString,"on") & "&" & strSearchVars,"AM")%>" class="TaxLink"><%=IIf(bTaxAdmin,"<span class=""HighLight"">" & TXT_NORMAL_MODE & "</span>",TXT_ADMIN_MODE)%></a>
<%End If%>
<%If intTaxSearchMode = MODE_FINDER Then%>
| <a href="javascript:parent.close()" class="TaxLink"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLinkB("TaxLink") %>
<%
ElseIf user_bSuperUserCIC And intTaxSearchMode = MODE_BASIC Then
%>
| <a href="<%=makeLinkB("tax_mng.asp")%>" class="TaxLink"><%=TXT_MANAGE_TAXONOMY%></a>
<%
End If
%>
]</p>
<%
'Print the search criteria form or header, according to the current Search Type.
Select Case intTaxSearchType
	Case SEARCH_KEYWORD
%>
<form action="<%=ps_strThisPage%>" name="Search" class="form-inline">
<%=strTaxCacheFormVals%>
<div class="clearfix">
<div id="tax-keyword-search" style="float:left;">
	<div style="margin-bottom:0.5em;"><input type="text" maxlength="255" size="60" class="form-control" name="STerms" title=<%=AttrQs(TXT_SERVICE_CATEGORY_SEARCH & TXT_COLON & TXT_KEYWORD)%> id="STerms" <%If Not Nl(strJoinedSTerms) Then%> value=<%=AttrQs(strSTerms)%><%End If%>></div>
	<div style="float:left"><label for="SType_Name"><input type="radio" name="SType" id="SType_Name" value="T"<%If Not bAnywhere Then%> checked<%End If%>>&nbsp;<%=TXT_NAME%></label> <label for="SType_Any"><input type="radio" name="SType" id="SType_Any" value="A"<%If bAnywhere Then%> checked<%End If%>>&nbsp;<%=TXT_ANYWHERE%></label></div>
	<div style="float:right"><a href="#javascript" class="ButtonLink" style="float:none"  onClick="document.Search.submit(); return true"><%=TXT_SEARCH%></a>
		<a href="#javascript" class="ButtonLink" style="float:none"  onClick="Search.STerms.value=''; Search.SType[0].checked=true; return true"><%=TXT_CLEAR_FORM%></a></div>
</div>
</div>
</form>
<%
	Case SEARCH_CONCEPT
		Call openRelatedConceptListRst(False)
%>
<form action="<%=ps_strThisPage%>" name="Search" class="form-inline">
<%=strTaxCacheFormVals%>
<p><%=makeRelatedConceptList(intRCID,"RCID",True,False)%> <a href="#javascript" class="ButtonLink" style="float:none" onClick="document.Search.submit(); return true"><%=TXT_SEARCH%></a></p>
</form>
<%
		Call closeRelatedConceptListRst()
	Case SEARCH_SUGGEST_LINK
%>
<p><%=TXT_SUGGEST_LINKS_FOR%><span class="TaxTerm"><%=IIf(IsTaxonomyCodeType(strTermList),"<a href=""" & makeTaxLink(ps_strThisPage,"ST=" & SEARCH_CODE & "&TC=" & strTermList,"ST") & """>",vbNullString) & Server.HTMLEncode(strDisplay) & IIf(IsTaxonomyCodeType(strTermList),"</a>",vbNullString)%></span></p>
<%
	Case SEARCH_SUGGEST_TERM
%>
<p><%=TXT_SUGGEST_TERMS_FOR_1%><span class="TaxTerm"><%=IIf(IsTaxonomyCodeType(strTermList),"<a href=""" & makeTaxLink(ps_strThisPage,"ST=" & SEARCH_CODE & "&TC=" & strTermList,"ST") & """>",vbNullString) & Server.HTMLEncode(strDisplay) & IIf(IsTaxonomyCodeType(strTermList),"</a>",vbNullString)%></span><%=TXT_SUGGEST_TERMS_FOR_2%></p>
<%
	Case SEARCH_BY_RECORD
%>
<form id="SearchForm" action="<%=ps_strThisPage%>" name="Search" class="form-inline">
<%=strTaxCacheFormVals%>
<table class="NoBorder cell-padding-2">
<tr>
<td class="FieldLabelClr"><%=TXT_FIND%></td>
<td><input type="text" size="60" maxlength="255" id="STerms" name="STerms"<%If Not (Nl(strJoinedSTerms) And Nl(strJoinedQSTerms)) Then%> value=<%=AttrQs(strSTerms)%><%End If%> class="form-control"></td>
</tr>
<tr>
<td class="FieldLabelClr" rowspan="2"><%=TXT_IN%></td>
<td><input type="radio" name="SType" value="A"<%If strSType="A" Then%>checked<%End If%>>&nbsp;<%=TXT_WORDS_ANYWHERE%>
<input type="radio" name="SType" value="O"<%If strSType="O" Then%>checked<%End If%>>&nbsp;<%=TXT_ORG_NAMES%>
<input type="radio" name="SType" value="S"<%If strSType="S" Then%>checked<%End If%>>&nbsp;<%=TXT_SUBJECTS%>
<input type="radio" name="SType" value="T"<%If strSType="T" Then%>checked<%End If%>>&nbsp;<%=TXT_SERVICE_CATEGORIES%></td>
</tr>
<tr>
<td><a href="#javascript" class="ButtonLink" style="float:none"  onClick="document.Search.submit(); return true"><%=TXT_SEARCH%></a>
	<a href="#javascript" class="ButtonLink" style="float:none"  onClick="Search.STerms.value=''; Search.SType[0].checked=true; return true"><%=TXT_CLEAR_FORM%></a></td>
</tr>
</table>
</form>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%
	Case SEARCH_CODE
%>
<form action="<%=ps_strThisPage%>" name="Search" id="SearchForm" class="form-inline">
<%=strTaxCacheFormVals%>
<p><input type="text" maxlength="21" title=<%=AttrQs(TXT_SERVICE_CATEGORY_SEARCH & TXT_COLON & TXT_CODE_SEARCH)%> id="TC" name="TC"<%If Not Nl(strCode) Then%> value=<%=AttrQs(strCode)%><%End If%> class="form-control">
	<a href="#javascript" class="ButtonLink" style="float:none" onClick="document.Search.submit(); return true"><%=TXT_SEARCH%></a>
	<a href="#javascript" class="ButtonLink" style="float:none" onClick="Search.TC.value=''; return true"><%=TXT_CLEAR_FORM%></a></p>
</form>
<%
End Select

'If search criteria were provided, print the resulting Terms or records.
'Drill-Down and Record searches have specialized displays, while the rest use
'the same function to display a list of Term Codes and Names.
If bDoSearch Then
	Dim cmdTaxSearch, rsTaxSearch

	Set cmdTaxSearch = Server.CreateObject("ADODB.Command")
	With cmdTaxSearch
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strSearchSQL
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	
	'Response.Write("<pre>" & Server.HTMLEncode(strSearchSQL) & "</pre>")
	'Response.Flush

	Set rsTaxSearch = Server.CreateObject("ADODB.Recordset")
	With rsTaxSearch
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdTaxSearch
	End With
	
	If Err.Number <> 0 Then
		Call handleError(TXT_ERROR & Err.Description, vbNullString, vbNullString)
	Else
		Select Case intTaxSearchType 
			Case SEARCH_DRILL_DOWN
				Call printTaxDrillDownTable()
			Case SEARCH_BY_RECORD
				Call printTaxRecordTable()
			Case Else
				Call printTaxSearchTable()
		End Select
	End If

	rsTaxSearch.Close
	Set cmdTaxSearch = Nothing
	Set rsTaxSearch = Nothing
End If
%>

<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/tax" & StringIf(intTaxSearchType = SEARCH_BY_RECORD or intTaxSearchType = SEARCH_KEYWORD, "records") & ".js") %>
<%If intTaxSearchType = SEARCH_BY_RECORD or intTaxSearchType = SEARCH_KEYWORD Or intTaxSearchType = SEARCH_CODE Then%>
<script type="text/javascript">
jQuery(function ($) {
	init_cached_state('#SearchForm');
	<% If intTaxSearchType = SEARCH_CODE Then %>
		init_taxcode_autocomplete('<%= makeLinkB(ps_strPathToStart & "jsonfeeds/taxcodes") %>');
	<% Else %>
	init_find_box({
		<% if intTaxSearchType = SEARCH_BY_RECORD  Then %>
			A: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=A", vbNullString) %>", 
			O: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=O", vbNullString) %>", 
			S: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=S", vbNullString) %>", 
		<% Else %>
			A: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=T", vbNullString) %>", 
		<% End If %>
			T: "<%= makeLink(ps_strPathToStart & "jsonfeeds/cic_keyword_generator.asp", "SearchType=T", vbNullString) %>"
			});
	<% End If %>
	restore_cached_state();
});
</script>
<%
End If
g_bListScriptLoaded = True

'The footer table is only printed if we are in Basic Search Mode.
Call makePageFooter(intTaxSearchMode = MODE_BASIC)
%>

<!--#include file="includes/core/incClose.asp" -->

