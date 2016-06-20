<%@LANGUAGE="VBSCRIPT"%><%Option Explicit%><?xml version="1.0" encoding="iso-8859-1"?>

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
g_bAllowAPILogin = True
Call setPageInfo(False, DM_CIC, DM_CIC, "../", "special/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>

<%
'Set response type headers
Response.ContentType = "application/xml"
Response.CacheControl = "Private"
Response.Expires=-1
Response.CodePage = 28591
Response.CharSet = "ISO-8859-1"

Call run_response_callbacks()

If Not user_bLoggedIn Then
	Call HTTPBasicUnauth("CIOC O211 Records")
End If
If Not has_api_permission(DM_CIC, "211ontario.ca") Then
	Call HTTPBasicUnauth("CIOC O211 Records")
End If

Sub GiveError(strReason) 
    %><error><%=XMLEncode(strReason)%></error><%
    Response.Status = "400 Bad Request"
End Sub

Sub DoPage()
    Dim strWhich, strSQL
	strWhich = Trim(Request("Table"))


	SELECT Case strWhich
		Case "CIC_BT_TAX"
			strSQL = "SELECT (SELECT pr.*, bt.RSN FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
						"FROM CIC_BT_TAX pr INNER JOIN GBL_BaseTable bt ON pr.NUM=bt.NUM" & _
						StringIf(Not Nl(g_strWhereClauseCIC), vbCrLf & "WHERE " & g_strWhereClauseCIC)

		Case "CIC_BT_TAX_TM"
			strSQL = "SELECT (SELECT BT_TM_ID, pr.BT_TAX_ID, Code as CODE FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
						"FROM CIC_BT_TAX_TM pr INNER JOIN CIC_BT_TAX bttx ON bttx.BT_TAX_ID=pr.BT_TAX_ID" & vbCrLf & _
						"INNER JOIN GBL_BaseTable bt ON bttx.NUM=bt.NUM" & _
						StringIf(Not Nl(g_strWhereClauseCIC), vbCrLf & "WHERE " & g_strWhereClauseCIC)
						
		Case "GBL_COMMUNITY"
			strSQL = "SELECT (SELECT cm.CM_ID," & vbCrLf & _
						"		CM_GUID AS CM_GUID" & vbCrLf & _
						"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
						"FROM GBL_Community cm"
		Case "GBL_LANGUAGE"
			strSQL = "SELECT (SELECT ln.LN_ID," & vbCrLf & _
						"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE, CREATED_BY AS CREATED_BY," & vbCrLf & _
						"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE, MODIFIED_BY AS MODIFIED_BY," & vbCrLf & _
						"		ISNULL(lnne.Name,lnnf.Name) AS LANGUAGENAME, ISNULL(lnnf.Name,lnne.Name) AS LANGUAGENAMEEQ," & vbCrLf & _
						"		ShowOnForm AS SHOWONFORM," & vbCrLf & _
						"		DisplayOrder AS DISPLAYORDER" & vbCrLf & _
						"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
						"FROM GBL_Language ln" & vbCrLf & _
						"INNER JOIN GBL_Language_Name lnne" & vbCrLf & _
						"	ON ln.LN_ID=lnne.LN_ID AND lnne.LangID=0" & vbCrLf & _
						"INNER JOIN GBL_Language_Name lnnf" & vbCrLf & _
						"	ON ln.LN_ID=lnnf.LN_ID AND lnnf.LangID=2"
		Case "TAX_RELATEDCONCEPT"
			strSQL = "SELECT (SELECT rc.RC_ID," & vbCrLf & _
						"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE, CREATED_BY," & vbCrLf & _
						"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE, MODIFIED_BY," & vbCrLf & _
						"		Code AS CODE," & vbCrLf & _
						"		rcne.ConceptName AS CONCEPTNAME, rcnf.ConceptName AS CONCEPTNAMEEQ," & vbCrLf & _
						"		Authorized AS AUTHORIZED," & vbCrLf & _
						"		Source AS SOURCE" & vbCrLf & _
						"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
						"FROM TAX_RelatedConcept rc" & vbCrLf & _
						"LEFT JOIN TAX_RelatedConcept_Name rcne" & vbCrLf & _
						"	ON rc.RC_ID=rcne.RC_ID AND rcne.LangID=0" & vbCrLf & _
						"LEFT JOIN TAX_RelatedConcept_Name rcnf" & vbCrLf & _
						"	ON rc.RC_ID=rcnf.RC_ID AND rcnf.LangID=2"
		Case "TAX_SEEALSO"
			strSQL = "SELECT (SELECT SA_ID," & vbCrLf & _
						"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE, CREATED_BY," & vbCrLf & _
						"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE, MODIFIED_BY," & vbCrLf & _
						"		Code AS CODE, SA_Code AS SA_CODE, Authorized AS AUTHORIZED" & vbCrLf & _
						"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
						"FROM TAX_SeeAlso sa"
		Case "TAX_TERM"
			strSQL = "SELECT (SELECT TM_ID,	tm.Code AS CODE," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE, CREATED_BY AS CREATED_BY," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE, MODIFIED_BY AS MODIFIED_BY," & vbCrLf & _
					"		CdLvl1 AS CDLVL1, CdLvl2 AS CDLVL2, CdLvl3 AS CDLVL3, CdLvl4 AS CDLVL4, CdLvl5 AS CDLVL5, CdLvl6 AS CDLVL6, CdLocal AS CDLOCAL," & vbCrLf & _
					"		ParentCode AS PARENTCODE, CdLvl AS CDLVL," & vbCrLf & _
					"		tmde.Term AS TERM, tmdf.Term AS TERMEQ," & vbCrLf & _
					"		Authorized AS AUTHORIZED, Active AS ACTIVE, Source AS SOURCE," & vbCrLf & _
					"		tmde.Definition AS DEFINITION, tmdf.Definition AS DEFINITIONEQ," & vbCrLf & _
					"		Facet AS FACET," & vbCrLf & _
					"		tmde.Comments AS COMMENTS, tmdf.Comments AS COMMENTSEQ," & vbCrLf & _
					"		tmde.AltTerm AS ALTTERM, tmdf.AltTerm AS ALTTERMEQ," & vbCrLf & _
					"		tmde.AltDefinition AS ALTDEFINITION, tmdf.AltDefinition AS ALTDEFINITIONEQ," & vbCrLf & _
					"		tmde.BiblioRef AS BIBLIOREF, tmdf.BiblioRef AS BIBLIOREFEQ," & vbCrLf & _
					"		IconURL AS ICONURL" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM TAX_Term tm" & vbCrLf & _
					"LEFT JOIN TAX_Term_Description tmde" & vbCrLf & _
					"	ON tmde.Code=tm.Code AND tmde.LangID=0" & vbCrLf & _
					"LEFT JOIN TAX_Term_Description tmdf" & vbCrLf & _
					"	ON tmdf.Code=tm.Code AND tmdf.LangID=2" 
		Case "TAX_TM_RC"
			strSQL = "SELECT (SELECT TM_RC_ID," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE, CREATED_BY," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE, MODIFIED_BY," & vbCrLf & _
					"		Code AS CODE, RC_ID, Authorized AS AUTHORIZED" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM TAX_TM_RC tmr"
		Case "TAX_UNUSED"
			strSQL = "SELECT (SELECT UT_ID," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE, CREATED_BY AS CREATED_BY," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE, MODIFIED_BY AS MODIFIED_BY," & vbCrLf & _
					"		Code AS CODE, CASE WHEN LangID=0 THEN Term ELSE NULL END AS TERM, CASE WHEN LangID=2 THEN Term ELSE NULL END AS TERMEQ," & vbCrLf & _
					"		Authorized AS AUTHORIZED, Active AS ACTIVE, Source AS SOURCE" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM TAX_Unused ut"
		Case "THS_EQUIVALENT"
			strSQL = "SELECT (SELECT sj.Subj_ID AS EQUIV_ID," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE," & vbCrLf & _
					"		CREATED_BY AS CREATED_BY, dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE," & vbCrLf & _
					"		MODIFIED_BY AS MODIFIED_BY, sj.Subj_ID AS SUBJ_ID," & vbCrLf & _
					"		sjnf.Name AS EQUIVALENT, sjnf.Notes AS NOTESEQ" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM THS_Subject sj" & vbCrLf & _
					"INNER JOIN THS_Subject_Name sjnf" & vbCrLf & _
					"	ON sj.Subj_ID=sjnf.Subj_ID AND sjnf.LangID=2"
		Case "THS_SUBJECT"
			strSQL = "SELECT (SELECT sj.Subj_ID AS SUBJ_ID," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(CREATED_DATE) AS CREATED_DATE, CREATED_BY AS CREATED_BY," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MODIFIED_DATE, MODIFIED_BY AS MODIFIED_BY," & vbCrLf & _
					"		SubjGUID AS SUBJGUID, sjne.Name AS SUBJECTTERM," & vbCrLf & _
					"		CAST(CASE WHEN inact.Subj_ID IS NULL THEN 0 ELSE 1 END AS bit) AS INACTIVE, Authorized AS AUTHORIZED," & vbCrLf & _
					"		Used AS USED, UseAll AS USEALL," & vbCrLf & _
					"		SRC_ID AS SRC_ID, SubjCat_ID AS SUBJCAT_ID, sjne.Notes AS NOTES" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM THS_Subject sj" & vbCrLf & _
					"INNER JOIN THS_Subject_Name sjne" & vbCrLf & _
					"	ON sj.Subj_ID=sjne.Subj_ID AND sjne.LangID=0" & vbCrLf & _
					"LEFT JOIN THS_Subject_InactiveByMember inact" & vbCrLf & _
					"	ON inact.Subj_ID=sj.Subj_ID AND inact.MemberID=" & g_intMemberID
        Case "THS_SBJ_BROADERTERM"
            strSQL = "SELECT (SELECT BDTerm_ID AS BDTERM_ID, Subj_ID AS SUBJ_ID, BroaderSubj_ID AS BROADERSUBJ_ID" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM THS_SBJ_BroaderTerm sjb"
        Case "THS_SBJ_RELATEDTERM"
            strSQL = "SELECT (SELECT RLTerm_ID AS RLTERM_ID, Subj_ID AS SUBJ_ID, RelatedSubj_ID AS RELATEDSUBJ_ID" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM THS_SBJ_RelatedTerm sjr"
        Case "THS_SBJ_USEINSTEAD"
            strSQL = "SELECT (SELECT UITerm_ID AS UITERM_ID, Subj_ID AS SUBJ_ID, UsedSubj_ID AS USEDSUBJ_ID" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM THS_SBJ_UseInstead sju"
		Case "ORGINFOS"
			strSQL = "SELECT (SELECT ex.* FOR XML PATH('ROW'), TYPE) AS ROW FROM O211_XML_EXPORT_RECORDS ex" & vbCrLf & _
					"INNER JOIN GBL_BaseTable bt ON ex.ORGID=bt.NUM" & vbCrLf & _
					StringIf(Not Nl(g_strWhereClauseCIC), vbCrLf & "WHERE " & g_strWhereClauseCIC)
		CASE "GEO"
			strSQL = "SELECT (SELECT NUM AS ORGID," & vbCrLf & _
					"		LATITUDE, LONGITUDE," & vbCrLf & _
					"		dbo.fn_O211_XML_DateFormat(MODIFIED_DATE) AS MDATE," & vbCrLf & _
					"		0 AS STATUS" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM GBL_BaseTable bt" & vbCrLf & _
					"WHERE GEOCODE_TYPE <> 0" & vbCrLf & _
					"	AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=bt.NUM AND (DELETION_DATE IS NULL OR DELETION_DATE > GETDATE()))" & _
					StringIf(Not Nl(g_strWhereClauseCIC), vbCrLf & " AND " & g_strWhereClauseCIC)

		CASE "ORGNAMES"
			strSQL = "SELECT (SELECT btd.NUM AS ORGID, CASE WHEN LangID=2 THEN 'fr' ELSE 'en' END AS LNG," & vbCrLf & _
					"dbo.fn_GBL_DisplayFullOrgName_O211(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2) AS ORG_LEVEL_1," & vbCrLf & _
					"NULL AS ORG_LEVEL_2, NULL AS ORG_LEVEL_3, NULL AS ORG_LEVEL_4, NULL AS ORG_LEVEL_5" & vbCrLf & _
					"FOR XML PATH('ROW'), TYPE) AS ROW" & vbCrLf & _
					"FROM GBL_BaseTable_Description btd INNER JOIN GBL_BaseTable bt ON btd.NUM=bt.NUM" & vbCrLf & _
					StringIf(Not Nl(g_strWhereClauseCIC), vbCrLf & "WHERE " & g_strWhereClauseCIC)
		Case Else
			GiveError("Invalid table name.")
			Exit Sub
	End Select

	Server.ScriptTimeout = 3600 * 10
    Dim cmdOrg, rsOrg
    Set cmdOrg = Server.CreateObject("ADODB.Command")
    With cmdOrg
        .ActiveConnection = getCurrentBasicCnn()
        .CommandType = adCmdText
        .CommandText = strSQL 
        .CommandTimeout = 0

        Set rsOrg = .Execute
    End With

	If rsOrg.EOF Then
		GiveError("NO Records")
	Else
		Dim fldRow, i
		i = 0
		%><ROWSET><%
		With rsOrg
			.CacheSize = 100
			Set fldRow = .Fields("ROW")
			While Not .EOF
				Response.Write(fldRow.Value)

				.MoveNext

				If i Mod 100 = 0 Then
					Response.Flush
				End If

				i = i + 1
			Wend
		End With
		%></ROWSET><%
	End If

    rsOrg.Close
    Set rsOrg = Nothing
    Set cmdOrg = Nothing

End Sub

Call DoPage()

%>

<!--#include file="../includes/core/incClose.asp" -->


