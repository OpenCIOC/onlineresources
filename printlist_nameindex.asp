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
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtPrintList.asp" -->
<!--#include file="includes/core/incFormat.asp" -->

<%
Const MAX_LEVEL = 7

Dim aNameSequence, aCurNames(8), aPrevNames(7)
aNameSequence = Array("ORG_LEVEL_1","ORG_LEVEL_2","ORG_LEVEL_3","ORG_LEVEL_4","ORG_LEVEL_5","LOCATION_NAME","SERVICE_NAME_LEVEL_1","SERVICE_NAME_LEVEL_2")

Sub setNameArray(ByRef aNames, rsOrg)
	Dim i, j
	j = 0

	For i = 0 to MAX_LEVEL
		If Not Nl(rsOrg.Fields(aNameSequence(i))) Then
			aNames(j) = rsOrg.Fields(aNameSequence(i))
			j = j + 1
		End If
	Next

	For i = j to MAX_LEVEL
		aNames(i) = vbNullString
	Next
End Sub

Sub clearNameArray(ByRef aNames)
	Dim i

	If IsArray(aNames) Then
		For i = 0 to UBound(aNames)
			aNames(i) = vbNullString
		Next
	End If
End Sub 

Function getFieldData()
	Dim strReturn, _
		strFieldCon
		
	If bHasField Then
		
	strReturn = vbNullString
	strFieldCon = vbNullString

	If bIncEmail Then
		If Not Nl(fldEmail.Value) Then
			strReturn = strReturn & strFieldCon & strLblEmail & fldEmail.Value
			strFieldCon = "<br>"
		End If
	End If
	If bIncOffice Then
		If Not Nl(fldOffice.Value) Then
			strReturn = strReturn & strFieldCon & strLblOffice & textToHTML(fldOffice.Value)
			strFieldCon = "<br>"
		End If
	End If
	If bIncFax Then
		If Not Nl(fldFax.Value) Then
			strReturn = strReturn & strFieldCon & strLblFax & textToHTML(fldFax.Value)
			strFieldCon = "<br>"
		End If
	End If
	If bIncTollFree Then
		If Not Nl(fldTollFree.Value) Then
			strReturn = strReturn & strFieldCon & strLblTollFree & textToHTML(fldTollFree.Value)
			strFieldCon = "<br>"
		End If
	End If
	If bIncTDD Then
		If Not Nl(fldTDD.Value) Then
			strReturn = strReturn & strFieldCon & strLblTDD & textToHTML(fldTDD.Value)
			strFieldCon = "<br>"
		End If
	End If
	If bIncAfterHrs Then
		If Not Nl(fldAfterHrs.Value) Then
			strReturn = strReturn & strFieldCon & strLblAfterHrs & textToHTML(fldAfterHrs.Value)
			strFieldCon = "<br>"
		End If
	End If
	If bIncCrisis Then
		If Not Nl(fldCrisis.Value) Then
			strReturn = strReturn & strFieldCon & strLblCrisis & textToHTML(fldCrisis.Value)
			strFieldCon = "<br>"
		End If
	End If

	End If
	
	getFieldData = Nz(strReturn,"&nbsp;")
End Function

Function getNameIndexSQL(intSubjID)

Dim strReturn, _
	strLimit, _
	strWhereClause

strReturn = _
		"SET NOCOUNT ON" & vbCrLf & _
		"DECLARE @Subj_ID int" & vbCrLf & _
		"DECLARE @wNumbers	TABLE (" & vbCrLf & _
			"PNUM	int IDENTITY (1, 1)," & vbCrLf & _
			"FILELETTER varchar(3), " & vbCrLf & _
			"SORT_AS varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"ORG_LEVEL_1 varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"ORG_LEVEL_2 varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"ORG_LEVEL_3 varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"ORG_LEVEL_4 varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"ORG_LEVEL_5 varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"LOCATION_NAME varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"SERVICE_NAME_LEVEL_1 varchar(200) COLLATE Latin1_General_100_CI_AI," & vbCrLf & _
			"SERVICE_NAME_LEVEL_2 varchar(200) COLLATE Latin1_General_100_CI_AI" & vbCrLf

If Request("IncludeDeleted") = "on" Then
	strWhereClause = g_strWhereClauseCIC
Else
	strWhereClause = g_strWhereClauseCICNoDel
End If

strWhereClause = Replace(strWhereClause,"AND shp.Active=1","AND shp.Active=1 AND shp.CanUsePrint=1")
					
strLimit = StringIf(Not Nl(strWhereClause),AND_CON & "(" & strWhereClause & ")")

If bIncEmail Then
	strReturn = strReturn & ", " & vbCrLf & _
			"E_MAIL varchar(100) COLLATE Latin1_General_100_CI_AI"
End If
If bIncOffice Then
	strReturn = strReturn & ", " & vbCrLf & _
			"OFFICE_PHONE varchar(max) COLLATE Latin1_General_100_CI_AI"
End If
If bIncFax Then
	strReturn = strReturn & ", " & vbCrLf & _
			"FAX varchar(255) COLLATE Latin1_General_100_CI_AI"
End If
If bIncTollFree Then
	strReturn = strReturn & ", " & vbCrLf & _
			"TOLL_FREE_PHONE varchar(max) COLLATE Latin1_General_100_CI_AI"
End If
If bIncTDD Then
	strReturn = strReturn & ", " & vbCrLf & _
			"TDD_PHONE varchar(max) COLLATE Latin1_General_100_CI_AI"
End If
If bIncAfterHrs Then
	strReturn = strReturn & ", " & vbCrLf & _
			"AFTER_HRS_PHONE varchar(max) COLLATE Latin1_General_100_CI_AI"
End If
If bIncCrisis Then
	strReturn = strReturn & ", " & vbCrLf & _
			"CRISIS_PHONE varchar(max) COLLATE Latin1_General_100_CI_AI"
End If

strReturn = strReturn & ", " & vbCrLf & _
			"NUM varchar(8) COLLATE Latin1_General_100_CI_AI" & vbCrLf & _
		")" & vbCrLf & _
		"SET @Subj_ID=" & intSubjID & vbCrLf & _
		"INSERT INTO @wNumbers (NUM, FILELETTER, SORT_AS, ORG_LEVEL_1, ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5, LOCATION_NAME, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2" & _
				IIf(bIncEmail,", E_MAIL",vbNullString) & _
				IIf(bIncOffice,", OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", FAX", vbNullString) & _
				IIf(bIncTollFree,", TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", CRISIS_PHONE",vbNullString) & _
				")" & vbCrLf & _
		"SELECT bt.NUM, ISNULL(idx.LetterIndex,'0-9'), btd.SORT_AS, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, " & _
				"CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM) OR btd.LOCATION_NAME=btd.ORG_LEVEL_1 THEN '' ELSE btd.LOCATION_NAME END AS LOCATION_NAME, " & _
				"CASE WHEN btd.SERVICE_NAME_LEVEL_1=btd.ORG_LEVEL_1 OR btd.LOCATION_NAME=btd.SERVICE_NAME_LEVEL_1 THEN '' ELSE btd.SERVICE_NAME_LEVEL_1 END AS SERVICE_NAME_LEVEL_1, " & _
				"CASE WHEN btd.SERVICE_NAME_LEVEL_2=btd.ORG_LEVEL_1 OR btd.LOCATION_NAME=btd.SERVICE_NAME_LEVEL_2 THEN '' ELSE btd.SERVICE_NAME_LEVEL_2 END AS SERVICE_NAME_LEVEL_2" & _
				IIf(bIncEmail,", btd.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", btd.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", btd.FAX", vbNullString) & _
				IIf(bIncTollFree,", btd.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", cbtd.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", cbtd.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", cbtd.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			StringIf(bIncTDD Or bIncAfterHrs Or bIncCrisis, _
				"INNER JOIN CIC_BaseTable cbt on bt.NUM=cbt.NUM" & vbCrLf & _
				"INNER JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf) & _
			"INNER JOIN dbo.CIC_BT_PB sj" & vbCrLf & _
				"ON bt.NUM = sj.NUM" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx" & vbCrLf & _
				"ON (((btd.SORT_AS_USELETTER IS NULL OR btd.SORT_AS_USELETTER=0) AND btd.ORG_LEVEL_1 LIKE idx.LetterIndex + '%') OR (btd.SORT_AS_USELETTER=1 AND btd.SORT_AS LIKE idx.LetterIndex + '%'))" & vbCrLf & _
			"WHERE sj.PB_ID = @Subj_ID" & vbCrLf & _
				strLimit & vbCrLf & _
				"ORDER BY idx.LetterIndex, ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5," & vbCrLf & _
				"	STUFF(" & vbCrLf & _
				"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
				"			THEN NULL" & vbCrLf & _
				"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
				"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
				"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
				"			 END," & vbCrLf & _
				"		1, 2, ''" & vbCrLf & _
				"	)"

If bLimitField And bHasField Then
	Dim strLimitCon
	
	strLimitCon = vbNullString
	
	strReturn = strReturn & "DELETE FROM @wNumbers WHERE ("
	If bIncEmail Then
		strReturn = strReturn & strLimitCon & "E_MAIL IS NULL"
		strLimitCon = AND_CON
	End If
	If bIncOffice Then
		strReturn = strReturn & strLimitCon & "OFFICE_PHONE IS NULL"
		strLimitCon = AND_CON
	End If
	If bIncFax Then
		strReturn = strReturn & strLimitCon & "FAX IS NULL"
		strLimitCon = AND_CON
	End If
	If bIncTollFree Then
		strReturn = strReturn & strLimitCon & "TOLL_FREE_PHONE IS NULL"
		strLimitCon = AND_CON
	End If
	If bIncTDD Then
		strReturn = strReturn & strLimitCon & "TDD_PHONE IS NULL"
		strLimitCon = AND_CON
	End If
	If bIncAfterHrs Then
		strReturn = strReturn & strLimitCon & "AFTER_HRS_PHONE IS NULL"
		strLimitCon = AND_CON
	End If
	If bIncCrisis Then
		strReturn = strReturn & strLimitCon & "CRISIS_PHONE IS NULL"
		strLimitCon = AND_CON
	End If
	strReturn = strReturn & ")" & vbCrLf
End If

strReturn = strReturn & vbCrLf & _
		"SELECT tm.PNUM, tm.FILELETTER, ISNULL(tm.SORT_AS,tm.ORG_LEVEL_1) AS SORT_NAME, tm.ORG_LEVEL_1, tm.ORG_LEVEL_2, tm.ORG_LEVEL_3, tm.ORG_LEVEL_4, tm.ORG_LEVEL_5, LOCATION_NAME, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _				
				vbCrLf & _
			"FROM @wNumbers tm" & vbCrLf

If bCrossRef Then
	strReturn = strReturn & _
		"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, btd.ORG_LEVEL_2 AS SORT_NAME, btd.ORG_LEVEL_2 + ' (' + btd.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON btd.ORG_LEVEL_2 LIKE idx.LetterIndex + '%'" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON bt.NUM=tm.NUM" & vbCrLf & _
			"WHERE btd.O2_PUBLISH=1 AND btd.ORG_LEVEL_2 IS NOT NULL" & vbCrLf & _
		"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, btd.ORG_LEVEL_3 AS SORT_NAME, btd.ORG_LEVEL_3 + ' (' + btd.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON btd.ORG_LEVEL_3 LIKE idx.LetterIndex + '%'" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON bt.NUM=tm.NUM" & vbCrLf & _
			"WHERE btd.O3_PUBLISH=1 AND btd.ORG_LEVEL_3 IS NOT NULL" & vbCrLf & _
		"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, btd.ORG_LEVEL_4 AS SORT_NAME, btd.ORG_LEVEL_4 + ' (' + btd.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON btd.ORG_LEVEL_4 LIKE idx.LetterIndex + '%'" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON bt.NUM=tm.NUM" & vbCrLf & _
			"WHERE btd.O4_PUBLISH=1 AND btd.ORG_LEVEL_4 IS NOT NULL" & vbCrLf & _
		"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, btd.ORG_LEVEL_5 AS SORT_NAME, btd.ORG_LEVEL_5 + ' (' + btd.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON btd.ORG_LEVEL_5 LIKE idx.LetterIndex + '%'" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON bt.NUM=tm.NUM" & vbCrLf & _
			"WHERE btd.O5_PUBLISH=1 AND btd.ORG_LEVEL_5 IS NOT NULL" & vbCrLf & _
		"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, btd.LEGAL_ORG AS SORT_NAME, btd.LEGAL_ORG + ' (' + btd.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON btd.LEGAL_ORG LIKE idx.LetterIndex + '%'" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON bt.NUM=tm.NUM" & vbCrLf & _
			"WHERE btd.LO_PUBLISH=1 AND btd.LEGAL_ORG IS NOT NULL" & vbCrLf & _
			"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, btd.SERVICE_NAME_LEVEL_1 AS SORT_NAME, btd.SERVICE_NAME_LEVEL_1 + ' (' + btd.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON btd.SERVICE_NAME_LEVEL_1 LIKE idx.LetterIndex + '%'" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON bt.NUM=tm.NUM" & vbCrLf & _
			"WHERE btd.S1_PUBLISH=1 AND btd.SERVICE_NAME_LEVEL_1 IS NOT NULL" & vbCrLf & _
			"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, btd.SERVICE_NAME_LEVEL_2 AS SORT_NAME, btd.SERVICE_NAME_LEVEL_2 + ' (' + btd.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM GBL_BaseTable bt" & vbCrLf & _
			"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON btd.SERVICE_NAME_LEVEL_2 LIKE idx.LetterIndex + '%'" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON bt.NUM=tm.NUM" & vbCrLf & _
			"WHERE btd.S2_PUBLISH=1 AND btd.SERVICE_NAME_LEVEL_2 IS NOT NULL" & vbCrLf & _
		"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, ao.ALT_ORG COLLATE Latin1_General_100_CI_AI AS SORT_NAME, ao.ALT_ORG COLLATE Latin1_General_100_CI_AI + ' (' + tm.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM dbo.GBL_BT_ALTORG ao" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON ao.ALT_ORG LIKE idx.LetterIndex + '%' COLLATE Latin1_General_100_CI_AI" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON ao.NUM=tm.NUM" & vbCrLf & _
			"WHERE ao.PUBLISH=1" & vbCrLf & _
			"AND ao.LangID=" & g_objCurrentLang.LangID & vbCrLf & _
		"UNION ALL SELECT tm.PNUM, ISNULL(idx.LetterIndex,'0-9') AS FILELETTER, fo.FORMER_ORG COLLATE Latin1_General_100_CI_AI AS SORT_NAME, fo.FORMER_ORG COLLATE Latin1_General_100_CI_AI + ' (' + tm.ORG_LEVEL_1 + ')', NULL, NULL, NULL, NULL, NULL, NULL, NULL" & _
				IIf(bIncEmail,", tm.E_MAIL",vbNullString) & _
				IIf(bIncOffice,", tm.OFFICE_PHONE",vbNullString) & _
				IIf(bIncFax,", tm.FAX", vbNullString) & _
				IIf(bIncTollFree,", tm.TOLL_FREE_PHONE",vbNullString) & _
				IIf(bIncTDD,", tm.TDD_PHONE",vbNullString) & _
				IIf(bIncAfterHrs,", tm.AFTER_HRS_PHONE",vbNullString) & _
				IIf(bIncCrisis,", tm.CRISIS_PHONE",vbNullString) & _
				vbCrLf & _
			"FROM dbo.GBL_BT_FORMERORG fo" & vbCrLf & _
			"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON fo.FORMER_ORG LIKE idx.LetterIndex + '%' COLLATE Latin1_General_100_CI_AI" & vbCrLf & _
			"INNER JOIN @wNumbers tm" & vbCrLf & _
				"ON fo.NUM=tm.NUM" & vbCrLf & _
			"WHERE fo.PUBLISH=1" & vbCrLf & _
			"AND fo.LangID=" & g_objCurrentLang.LangID & vbCrLf
End If
strReturn = strReturn & _
		"ORDER BY FILELETTER, SORT_NAME" & vbCrLf & _
		"SET NOCOUNT OFF"

	'Response.Write("<pre>" & strReturn & "</pre>")
	'Response.Flush()

	getNameIndexSQL = strReturn

End Function

Server.ScriptTimeOut = 900

Dim bError
bError = False

Dim intSubjID
intSubjID = Request("SubjID")
If Nl(intSubjID) Then
	Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
	Call handleError(TXT_NO_RECORD_CHOSEN & " <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
	bError = True
ElseIf Not IsIDType(intSubjID) Then
	Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSubjID) & ". <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
	bError = True
Else
	intSubjID = CLng(intSubjID)
End If

If Not bError Then

	Dim	bIncEmail, _
		bIncOffice, _
		bIncFax, _
		bIncTollFree, _
		bIncTDD, _
		bIncAfterHrs, _
		bIncCrisis, _
		strLblEmail, _
		strLblOffice, _
		strLblFax, _
		strLblTollFree, _
		strLblTDD, _
		strLblAfterHrs, _
		strLblCrisis, _
		bLimitField, _
		bFormatBold, _
		bCrossRef, _
		bHasField, _
		intFieldWidth, _
		bDotLeader, _
		bWord
	
	bIncEmail = Request("IncEmail") = "on"
	bIncOffice = Request("IncOffice") = "on"
	bIncFax = Request("IncFax") = "on"
	bIncTollFree = Request("IncTollFree") = "on"
	bIncTDD = Request("IncTDD") = "on" 
	bIncAfterHrs = Request("IncAfterHrs") = "on" 
	bIncCrisis = Request("IncCrisis") = "on" 
	bHasField = bIncEmail Or bIncOffice Or bIncFax Or bIncTollFree Or bIncTDD Or bIncAfterHrs Or bIncCrisis
	
	strLblEmail = Request("LblEmail")
	strLblOffice = Request("LblOffice")
	strLblFax = Request("LblFax")
	strLblTollFree = Request("LblTollFree")
	strLblTDD = Request("LblTDD")
	strLblAfterHrs = Request("LblAfterHrs")
	strLblCrisis = Request("LblCrisis")
	
	bLimitField = Request("LimitField") = "on"
	bFormatBold = Request("FormatBold") = "on"
	bCrossRef = Request("CrossRef") = "on"
	bDotLeader = Request("DotLeader") = "on"
	bWord = Request("ForWord") = "on"

	intFieldWidth = IIf(bHasField,Nz(Request("FieldWidth"),250),0)

	Dim strWordDots, _
		intFontSize, _
		strFontFamily
	
	If bWord And bDotLeader Then
		strWordDots = "<span STYLE='mso-tab-count:1 dotted'></span>"
	Else
		strWordDots = vbNullString
	End If
	
	intFontSize = Nz(Request("FontSize"),10)
	If Not IsNumeric(intFontSize) Then
		intFontSize = 10
	ElseIf Not intFontSize >= 8 and intFontSize <= 14 Then
		intFontSize = 10
	End If
	
	strFontFamily = Nz(Request("FontFamily"),SANS_SERIF_FONT)
%>
<html>
<head>
<title><%=TXT_NAME_INDEX%></title>
<style type="text/css">
<!--
td {
	font-size: <%=intFontSize%>pt;
	font-family: <%=strFontFamily%>;
	padding-top: 3px;
	padding-bottom: 3px;
}
<%
	Dim iDots
	For iDots = 1 to MAX_LEVEL+1
%>
td.dots<%=iDots%> {
<%
		If bWord Then
			If bDotLeader Then
%>
	tab-stops:dotted <%=IIf(bHasField,"4","5.5")%>in;
<%
			End If
%>
	margin-left: <%=2*iDots-2%>em;
<%
		ElseIf bDotLeader Then
%>
	background: url("/images/dots.gif") repeat-x left <%=intFontSize-3%>px;
<%
		End If
%>
	text-align: left;
}
<%
	Next
	For iDots = 1 to MAX_LEVEL+1
%>
td.nodots<%=iDots%> {
<%
		If bWord Then
%>
	margin-left: <%=2*iDots-2%>em;
<%
		End If
%>
	text-align: left;
}
<%
	Next
%>
<%
	Dim iOrg
	For iOrg = 1 to MAX_LEVEL+1
%>
span.org<%=iOrg%> {
<%
		If Not bWord Then
%>
	background-color: white;
	padding-left: <%=2*iOrg-2%>em;
<%
		End If
%>
	padding-right: 0.5em;
}
<%
	Next
%>
td.field {
	text-align: right;
	padding-left: 0.5em;
	padding-right: 1em;
	width: <%=intFieldWidth%>px;
<%
	If bFormatBold Then
%>
	font-weight:bold;
<%
	End If
%>
}
td.rnum {
	font-weight: bold;
	text-align: right;
	padding-left: .5em;
	width: 4em;
}
H1.letter {
	font-size: <%=intFontSize+6%>pt;
	font-family: <%=strFontFamily%>;
	font-weight:bold;
	padding-top: 1px;
	padding-bottom: 1px;
}
-->
</style>
</head>
<%
Dim cmdNameIndex, rsNameIndex
Set cmdNameIndex = Server.CreateObject("ADODB.Command")
With cmdNameIndex
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = getNameIndexSQL(intSubjID)
	.CommandType = adCmdText
	.CommandTimeout = 0
End With

Set rsNameIndex = Server.CreateObject("ADODB.Recordset")
With rsNameIndex
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdNameIndex

	If .EOF Then
		Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
		Call handleError(TXT_NO_RECORDS_TO_PRINT & " <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
			vbNullString, _
			vbNullString)
		Call makePageFooter(False)
		bError = True
	End If
End With

End If

If Not bError Then

Dim fldSortName, _
	fldLetterIndex, _
	fldEmail, _
	fldFax, _
	fldOffice, _
	fldTDD, _
	fldTollFree, _
	fldAfterHrs, _
	fldCrisis, _
	fldPNUM

Dim intCurLvl, _
	strPrevLet

With rsNameIndex
	strPrevLet = vbNullString

	Set fldSortName = .Fields("SORT_NAME")
	Set fldLetterIndex = .Fields("FILELETTER")
	Set fldPNUM = .Fields("PNUM")
	If bIncEmail Then
		Set fldEmail = .Fields("E_MAIL")
	End If
	If bIncFax Then
		Set fldFax = .Fields("FAX")
	End If
	If bIncOffice Then
		Set fldOffice = .Fields("OFFICE_PHONE")
	End If
	If bIncTDD Then
		Set fldTDD = .Fields("TDD_PHONE")
	End If
	If bIncTollFree Then
		Set fldTollFree = .Fields("TOLL_FREE_PHONE")
	End If
	If bIncAfterHrs Then
		Set fldAfterHrs = .Fields("AFTER_HRS_PHONE")
	End If
	If bIncCrisis Then
		Set fldCrisis = .Fields("CRISIS_PHONE")
	End If


%>
<body bgcolor="#FFFFFF" text="#000000">
<%
	While Not .EOF
		intCurLvl = 0
		Call setNameArray(aCurNames, rsNameIndex)

		If fldLetterIndex.Value > strPrevLet Then
			strPrevLet = fldLetterIndex.Value
			If aPrevNames(0) <> vbNullString Then
%>
</table>
<%
			End If
			Call clearNameArray(aPrevNames)
%>
<h1 class="letter"><%=strPrevLet%> ...</h1>
<table width="100%" class="NoBorder" cellpadding="0" cellspacing="0">
<%
		End If

		For intCurLvl = 0 to MAX_LEVEL
			If Not Nl(aCurNames(intCurLvl)) Then
				If Nl(aCurNames(intCurLvl+1)) Then
%>
<tr valign="TOP">
	<td class="dots<%=intCurLvl+1%>" style="padding-top: 5px;"><span class="org<%=intCurLvl+1%>"><%=aCurNames(intCurLvl)%></span><%=strWordDots%></td>
	<td class="field"><%=getFieldData()%></td>
	<td class="rnum" <%If intCurLvl=0 Then%> style="padding-top: 5px;"<%End If%>><%=fldPNUM.Value%></td>
</tr>
<%
				ElseIf Not (aCurNames(intCurLvl) = aPrevNames(intCurLvl)) Then
%>
<tr valign="TOP">
	<td class="nodots<%=intCurLvl+1%>" colspan="2"><span class="org<%=intCurLvl+1%>"><%=aCurNames(intCurLvl)%></span></td>
	<td class="rnum">&nbsp;</td>
</tr>
<%
				End If
			End If
			aPrevNames(intCurLvl) = aCurNames(intCurLvl)
		Next

		.MoveNext
	Wend
	.Close
End With


Set rsNameIndex = Nothing
Set cmdNameIndex = Nothing

%>
</table>
</body>
</html>
<%
End If

%>

<!--#include file="includes/core/incClose.asp" -->
