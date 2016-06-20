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
Call setPageInfo(True, DM_CIC, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeneralSearch1.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSearchResults.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtSubjects.asp" -->
<!--#include file="../text/txtThesaurus.asp" -->
<!--#include file="../includes/search/incCustFieldResults.asp" -->
<!--#include file="../includes/search/incDatesPredef.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/search/incNormalizeSearchTerms.asp" -->
<!--#include file="../includes/thesaurus/incSubjSearchUtils.asp" -->
<!--#include file="../includes/thesaurus/incUseInsteadList.asp" -->
<%
If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Const UNKNOWN_NOVALUE = "_X_"

Call makePageHeader(TXT_MANAGE_THESAURUS, TXT_MANAGE_THESAURUS, True, False, True, True)
%>
<p>[ <a href="<%=makeLinkB("thesaurus.asp")%>"><%=TXT_RETURN_MANAGE_THESAURUS%></a> ]</p>
<%

Dim strSQL, _
	strWhere, _
	strCon, _
	strSortBy, _
	bShowFull, _
	bFSearch
	
strCon = " WHERE "
bFSearch = False

If Request("PrevResults") = "True" Then
	strSortBy = getSessionValue("SubjectSearch_SortBy")
	bShowFull = getSessionValue("SubjectSearch_ShowFull")
Else
	strSortBy = Request("SortBy")
	bShowFull = Request("ShowFull") = "on"
End If

'--------------------------------------------------
' 1. Keyword Search
'--------------------------------------------------

Dim intSCon1, _
	intSCon2, _
	strSCon, _
	strSTerms1, _
	strSTerms2, _
	strSType1, _
	strSType2, _
	strJoinedSTerms1, _
	strJoinedQSTerms1, _
	strJoinedSTerms2, _
	strJoinedQSTerms2, _
	singleSTerms1(), _
	singleSTerms2(), _
	quotedSTerms1(), _
	quotedSTerms2(), _
	exactSTerms1(), _
	exactSTerms2(), _
	displaySTerms1(), _
	displaySTerms2()

Select Case Request("SCon")
	Case "O"
		strSCon = OR_CON
	Case "AN"
		strSCon = ") AND NOT ("
	Case "ON"
		strSCon = ") OR NOT ("
	Case Else
		strSCon = AND_CON
End Select
Select Case Request("SCon1")
	Case "O"
		intSCon1 = JTYPE_OR
	Case "B"
		intSCon1 = JTYPE_BOOLEAN
	Case Else
		intSCon1 = JTYPE_AND
End Select
Select Case Request("SCon2")
	Case "O"
		intSCon2 = JTYPE_OR
	Case "B"
		intSCon2 = JTYPE_BOOLEAN
	Case Else
		intSCon2 = JTYPE_AND
End Select
strSTerms1 = Trim(Request("STerms1"))
strSTerms2 = Trim(Request("STerms2"))
strSType1 = Request("SType1")
strSType2 = Request("SType2")

If Not Nl(strSTerms1) Then
	Call makeSearchString( _
		strSTerms1, _
		singleSTerms1, _
		quotedSTerms1, _
		exactSTerms1, _
		displaySTerms1, _
		intSCon1 = JTYPE_BOOLEAN _
	)

	Select Case intSCon1
		Case JTYPE_BOOLEAN
			strJoinedSTerms1 = vbNullString
			strJoinedQSTerms1 = Join(exactSTerms1," ")
		Case JTYPE_OR
			strJoinedSTerms1 = Join(singleSTerms1,OR_CON)
			strJoinedQSTerms1 = Join(quotedSTerms1,OR_CON)
		Case JTYPE_AND
			strJoinedSTerms1 = Join(singleSTerms1,AND_CON)
			strJoinedQSTerms1 = Join(quotedSTerms1,AND_CON)
	End Select
Else
	ReDim singleSTerms1(-1)
	ReDim quotedSTerms1(-1)
	ReDim exactSTerms1(-1)
End If

If Not Nl(strSTerms2) Then
	Call makeSearchString( _
		strSTerms2, _
		singleSTerms2, _
		quotedSTerms2, _
		exactSTerms2, _
		displaySTerms2, _
		intSCon1 = JTYPE_BOOLEAN _
	)

	Select Case intSCon2
		Case JTYPE_BOOLEAN
			strJoinedSTerms2 = vbNullString
			strJoinedQSTerms2 = Join(exactSTerms2," ")
		Case JTYPE_OR
			strJoinedSTerms2 = Join(singleSTerms2,OR_CON)
			strJoinedQSTerms2 = Join(quotedSTerms2,OR_CON)
		Case JTYPE_AND
			strJoinedSTerms2 = Join(singleSTerms2,AND_CON)
			strJoinedQSTerms2 = Join(quotedSTerms2,AND_CON)
	End Select
Else
	ReDim singleSTerms2(-1)
	ReDim quotedSTerms2(-1)
	ReDim exactSTerms2(-1)
End If

'--------------------------------------------------
' 2. Date Search
'--------------------------------------------------

Dim strSDateType, _
	strSDateRange, _
	strSFirstDate, _
	strSLastDate, _
	strSFirstDateName, _
	strSLastDateName

Select Case Request("SDateType")
	Case "C"
		strSDateType="CREATED_DATE"
	Case "M"
		strSDateType="MODIFIED_DATE"
End Select

If Not Nl(strSDateType) Then
	Call setDateFieldVars("S", "BYPASS", strSFirstDate, strSLastDate, vbNullString, vbNullString, strSDateRange)
End If

'--------------------------------------------------
' 3. Source Search
'--------------------------------------------------

Dim strSRCIDList, _
	bSRCNull

bSRCNull = False
strSRCIDList = Trim(Request("SRCID"))
If strSRCIDList = UNKNOWN_NOVALUE Then
	bSRCNull = True
	strSRCIDList = Null
ElseIf reEquals(strSRCIDList,"(^|,)" & UNKNOWN_NOVALUE & "(,|$)", False, True, False, False) Then
	bSRCNull = True
	strSRCIDList = Replace(strSRCIDList,UNKNOWN_NOVALUE,0)
End If

If Not IsIDList(strSRCIDList) Then
	strSRCIDList = Null
End If

'--------------------------------------------------
' 4. Category Search
'--------------------------------------------------

Dim strSubjCatIDList, _
	bSubjCatNull

bSubjCatNull = False
strSubjCatIDList = Trim(Request("SubjCatID"))
If strSubjCatIDList = UNKNOWN_NOVALUE Then
	bSubjCatNull = True
	strSubjCatIDList = Null
ElseIf reEquals(strSubjCatIDList,"(^|,)" & UNKNOWN_NOVALUE & "(,|$)", False, True, False, False) Then
	bSubjCatNull = True
	strSubjCatIDList = Replace(strSubjCatIDList,UNKNOWN_NOVALUE,0)
End If

If Not IsIDList(strSubjCatIDList) Then
	strSubjCatIDList = Null
End If

'--------------------------------------------------
' 5. Authorization Search
'--------------------------------------------------

Dim strAuthorization
strAuthorization = Request("Auth")

'--------------------------------------------------
' 6. Active Status Search
'--------------------------------------------------

Dim strActiveStatus
strActiveStatus = Request("Active")

'--------------------------------------------------
' 7. Term Usage Search
'--------------------------------------------------

Dim strTUsage
strTUsage = Request("TUsage")

'--------------------------------------------------
' 8. Use by Records Search
'--------------------------------------------------

Dim intRUseLess, _
	intRUseMore

intRUseLess = Request("RUseLess")
intRUseMore = Request("RUseMore")

If Not Nl(intRUseLess) Then
	If Not IsNumeric(intRUseLess) Then
		Call handleError(TXT_WARNING & "&quot;" & intRUseLess & "&quot;" & TXT_IS_NOT_A_NUMBER, _
			vbNullString, vbNullString)
		intRUseLess = Null
	End If
End If
If Not Nl(intRUseMore) Then
	If Not IsNumeric(intRUseMore) Then
		Call handleError(TXT_WARNING & "&quot;" & intRUseMore & "&quot;" & TXT_IS_NOT_A_NUMBER, _
			vbNullString, vbNullString)
		intRUseMore = Null
	End If
End If

'--------------------------------------------------
' 9. Other Local Terms
'--------------------------------------------------

Dim bOtherLocal
bOtherLocal = Request("OtherLocal")="on"

'--------------------------------------------------
' 10. Previous Search
'--------------------------------------------------
Dim strPrevResults, bPrevError
If Request("PrevResults") = "True" Then
	If Not Nl(getSessionValue("SubjectSearch_List")) Then
		strPrevResults = getSessionValue("SubjectSearch_List")
		If Nl(strPrevResults) Then
			bPrevError = True
		End If
	Else
		bPrevError = True
	End If
End If

'--------------------------------------------------
' 1. Keyword Search
'--------------------------------------------------

Dim strKeywordSearch, strKCon

If Not (Nl(strJoinedSTerms1) And Nl(strJoinedQSTerms1)) Then
	Select Case Request("SType1")
		Case "TF"
			strKeywordSearch = "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_FRENCH
			If Not Nl(strJoinedSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedSTerms1 & "', LANGUAGE '" & SQLALIAS_FRENCH & "'))"
			End If
			If Not Nl(strJoinedQSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedQSTerms1 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
			bFSearch = True
		Case "NE"
			strKeywordSearch = "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_ENGLISH
			If Not Nl(strJoinedSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedSTerms1 & "', LANGUAGE '" & SQLALIAS_ENGLISH & "'))"
			End If
			If Not Nl(strJoinedQSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedQSTerms1 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
		Case "NF"
			strKeywordSearch = "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_FRENCH
			If Not Nl(strJoinedSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedSTerms1 & "', LANGUAGE '" & SQLALIAS_FRENCH & "'))"
			End If
			If Not Nl(strJoinedQSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedQSTerms1 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
			bFSearch = True
		Case Else
			strKeywordSearch = "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_ENGLISH
			If Not Nl(strJoinedSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedSTerms1 & "', LANGUAGE '" & SQLALIAS_ENGLISH & "'))"
			End If
			If Not Nl(strJoinedQSTerms1) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedQSTerms1 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
	End Select
	strKCon = strSCon
End If

If Not (Nl(strJoinedSTerms2) And Nl(strJoinedQSTerms2)) Then
	Select Case Request("SType2")
		Case "TF"
			strKeywordSearch = strKeywordSearch & strKCon & "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_FRENCH
			If Not Nl(strJoinedSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedSTerms2 & "', LANGUAGE '" & SQLALIAS_FRENCH & "'))"
			End If
			If Not Nl(strJoinedQSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedQSTerms2 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
			bFSearch = True
		Case "NE"
			strKeywordSearch = strKeywordSearch & strKCon & "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_ENGLISH
			If Not Nl(strJoinedSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedSTerms2 & "', LANGUAGE '" & SQLALIAS_ENGLISH & "'))"
			End If
			If Not Nl(strJoinedQSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedQSTerms2 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
		Case "NF"
			strKeywordSearch = strKeywordSearch & strKCon & "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_FRENCH
			If Not Nl(strJoinedSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedSTerms2 & "', LANGUAGE '" & SQLALIAS_FRENCH & "'))"
			End If
			If Not Nl(strJoinedQSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Notes,'" & strJoinedQSTerms2 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
			bFSearch = True
		Case Else
			strKeywordSearch = strKeywordSearch & strKCon & "EXISTS(SELECT * FROM THS_Subject_Name WHERE Subj_ID=sj.Subj_ID" & _
				" AND LangID=" & LANG_ENGLISH
			If Not Nl(strJoinedSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedSTerms2 & "', LANGUAGE " & SQLALIAS_ENGLISH & "))"
			End If
			If Not Nl(strJoinedQSTerms2) Then
				strKeywordSearch = strKeywordSearch & " AND (CONTAINS(Name,'" & strJoinedQSTerms2 & "'))"
			End If
			strKeywordSearch = strKeywordSearch & ")"
	End Select
End If

If Not Nl(strKeywordSearch) Then
	strWhere = strWhere & strCon & "(" & strKeywordSearch & ")"
	strCon = AND_CON
End If


'--------------------------------------------------
' 2. Date Search
'--------------------------------------------------

Dim strTmpDateSearch
If Not Nl(strSDateType) Then
	strTmpDateSearch = getDateSearchStringS(strSDateType, strSFirstDate, strSLastDate, strSDateRange)
	If Not Nl(strTmpDateSearch) Then
		strWhere = strWhere & strCon & strTmpDateSearch
		strCon = AND_CON
	End If
End If

'--------------------------------------------------
' 3. Source Search
'--------------------------------------------------

Dim strSrcSearch, strSrCon

If bSRCNULL Then
	strSrcSearch = "sj.SRC_ID IS NULL"
	strSrCon = OR_CON
End If
If Not Nl(strSRCIDList) Then
	strSrcSearch = strSrcSearch & strSrCon & "sj.SRC_ID IN (" & strSRCIDList & ")"
End If

If Not Nl(strSrcSearch) Then
	strWhere = strWhere & strCon & "(" & strSrcSearch & ")"
	strCon = AND_CON
End If

'--------------------------------------------------
' 4. Category Search
'--------------------------------------------------

Dim strCatSearch, strCCon

If bSubjCatNULL Then
	strCatSearch = "sj.SubjCat_ID IS NULL"
	strCCon = OR_CON
End If
If Not Nl(strSubjCatIDList) Then
	strCatSearch = strCatSearch & strCCon & "sj.SubjCat_ID IN (" & strSubjCatIDList & ")"
End If

If Not Nl(strCatSearch) Then
	strWhere = strWhere & strCon & "(" & strCatSearch & ")"
	strCon = AND_CON
End If

'--------------------------------------------------
' 5. Authorization Search
'--------------------------------------------------

Select Case strAuthorization
	Case "Y"
		strWhere = strWhere & strCon & "sj.Authorized=" & SQL_TRUE
		strCon = AND_CON
	Case "N"
		strWhere = strWhere & strCon & "sj.Authorized=" & SQL_FALSE
		strCon = AND_CON
End Select

'--------------------------------------------------
' 6. Active Status Search
'--------------------------------------------------

Select Case strActiveStatus
	Case "A"
		strWhere = strWhere & strCon & "NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID)"
		strCon = AND_CON
	Case "I"
		strWhere = strWhere & strCon & "EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID)"
		strCon = AND_CON
End Select

'--------------------------------------------------
' 7. Term Usage Search
'--------------------------------------------------

Select Case strTUsage
	Case "U"
		strWhere = strWhere & strCon & "sj.Used=" & SQL_TRUE
		strCon = AND_CON
	Case "S"
		strWhere = strWhere & strCon & "sj.Used=" & SQL_FALSE
		strCon = AND_CON
	Case "O"
		strWhere = strWhere & strCon & "EXISTS(SELECT * FROM THS_SBJ_UseInstead ui WHERE ui.UsedSubj_ID=sj.Subj_ID)"
		strCon = AND_CON
End Select

'--------------------------------------------------
' 8. Use by Records Search
'--------------------------------------------------

If Not Nl(intRUseLess) Then
	strWhere = strWhere & strCon & getAdminUsageLocalSQL() & "<=" & intRUseLess
	strCon = AND_CON
End If

If Not Nl(intRUseMore) Then
	strWhere = strWhere & strCon & getAdminUsageLocalSQL() & ">=" & intRUseMore
	strCon = AND_CON
End If

'--------------------------------------------------
' 9. Other Local Terms
'--------------------------------------------------

If Not bOtherLocal And Nl(strPrevResults) Then
	strWhere = strWhere & strCon & "(sj.Authorized=1 OR sj.MemberID IS NULL OR sj.MemberID=" & g_intMemberID & ")"
	strCon = AND_CON
End If

'--------------------------------------------------
' 10. Previous Search Results
'--------------------------------------------------

If Not Nl(strPrevResults) Then
	strWhere = strWhere & strCon & "(sj.Subj_ID IN (" & strPrevResults & "))"
	strCon = AND_CON
End If

'--------------------------------------------------

strSQL = "SELECT sj.Subj_ID,sj.Used,sj.UseAll," & vbCrLf & _
	"CASE WHEN sjn.LangID=@@LANGID THEN sjn.Name ELSE '[' + sjn.Name + ']' END AS SubjectTerm," & vbCrLf & _
	"CAST(CASE WHEN EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID) THEN 1 ELSE 0 END AS bit) AS Inactive," & vbCrLf & _
	getAdminUsageLocalSQL() & " AS UsageCountLocal," & getAdminUsageOtherSQL() & " AS UsageCountOther" & vbCrLf & _
	StringIf(bShowFull,",(SELECT TOP 1 SourceName FROM THS_Source_Name WHERE SRC_ID=sj.SRC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS Source," & vbCrLf & _
		"(SELECT TOP 1 ISNULL(MemberNameCIC,MemberName) FROM STP_Member_Description WHERE MemberID=sj.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS ManagedBy," & vbCrLf & _
		"(SELECT TOP 1 Category FROM THS_Category_Name WHERE SubjCat_ID=sj.SubjCat_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS Category," & vbCrLf & _
		"sj.Authorized,sj.MODIFIED_DATE,sj.MODIFIED_BY,sj.CREATED_DATE,sj.CREATED_BY,sjn.Notes" & vbCrLf) & _
	"FROM THS_Subject sj" & vbCrLf & _
	"INNER JOIN THS_Subject_Name sjn ON sj.Subj_ID=sjn.Subj_ID" & vbCrLf & _
	"	AND sjn.LangID=(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjn.Subj_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & _
	strWhere
		
Select Case strSortBy
	Case "M"
		strSQL = strSQL & vbCrLf & "ORDER BY MODIFIED_DATE DESC,sjn.Name"
	Case Else
		strSQL = strSQL & vbCrLf & "ORDER BY sjn.Name"
End Select

'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
'Response.Flush()


Dim cmdSearchSubjectTerm, rsSearchSubjectTerm

Set cmdSearchSubjectTerm = Server.CreateObject("ADODB.Command")
With cmdSearchSubjectTerm
	.ActiveConnection = getCurrentAdminCnn()
	.CommandType = adCmdText
	.CommandText = strSQL
	.CommandTimeout = 0
End With

Dim fldSubjID, _
	fldCreatedDate, _
	fldCreatedBy, _
	fldModifiedDate, _
	fldModifiedBy, _
	fldManagedBy, _
	fldSubjectTerm, _
	fldUsed, _
	fldUseAll, _
	fldInactive, _
	fldAuthorized, _
	fldNotes, _
	fldCategory, _
	fldSource, _
	fldUsageCountLocal, _
	fldUsageCountOther

Dim aIDList, i

Set rsSearchSubjectTerm = Server.CreateObject("ADODB.Recordset")
With rsSearchSubjectTerm
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdSearchSubjectTerm
	
	ReDim aIDList(.RecordCount-1)
	i = 0

	Set fldSubjID = .Fields("Subj_ID")
	Set fldSubjectTerm = .Fields("SubjectTerm")
	Set fldUsed = .Fields("Used")
	Set fldUseAll = .Fields("UseAll")
	Set fldInactive = .Fields("Inactive")
	Set fldUsageCountLocal = .Fields("UsageCountLocal")
	Set fldUsageCountOther = .Fields("UsageCountOther")

	If bShowFull Then
		Set fldCreatedDate = .Fields("CREATED_DATE")
		Set fldCreatedBy = .Fields("CREATED_BY")
		Set fldModifiedDate = .Fields("MODIFIED_DATE")
		Set fldModifiedBy = .Fields("MODIFIED_BY")
		Set fldAuthorized = .Fields("Authorized")
		Set fldNotes = .Fields("Notes")
		Set fldCategory = .Fields("Category")
		Set fldSource = .Fields("Source")
		Set fldManagedBy = .Fields("ManagedBy")
	End If

	If g_bOtherMembers Then
%>
<p class="Info"><%=IIf(user_bSuperUserGlobalCIC,TXT_INST_TERM_COUNT_GLOBAL,TXT_INST_TERM_COUNT)%></p>
<%
	End If
%>
<p><%=TXT_FOUND%><strong><%=.RecordCount%></strong><%=TXT_MATCHES%>.</p>
<%
	While Not .EOF
		aIDList(i) = fldSubjID.Value
		i = i+1
		If bShowFull Then
			Call printFullSubjectInfo(fldSubjID.Value, _
				DateString(fldCreatedDate.Value,True), _
				fldCreatedBy.Value, _
				DateString(fldModifiedDate.Value,True), _
				fldModifiedBy.Value, _
				fldManagedBy.Value, _
				fldSubjectTerm.Value, _
				True, _
				fldInactive.Value, _
				fldAuthorized.Value, _
				fldUsed.Value, _
				fldUseAll.Value, _
				fldNotes.Value, _
				fldCategory.Value, _
				fldSource.Value, _
				fldUsageCountLocal.Value, _
				fldUsageCountOther.Value, _
				True, _
				"admin/thesaurus/edit", _
				False, _
				vbNullString _
				)
		Else
%>
<%=getShortSubjectInfoAdmin(fldSubjID.Value, fldSubjectTerm.Value, fldInactive.Value, fldUsed.Value, fldUseAll.Value, fldUsageCountLocal.Value, fldUsageCountOther.Value, True, "admin/thesaurus/edit", False, vbNullString)%>
<br>
<%
		End If
		.MoveNext
	Wend
	
	If .RecordCount > 0 Then
		Call setSessionValue("SubjectSearch_List", Join(aIDList,","))
		Call setSessionValue("SubjectSearch_ShowFull", bShowFull)
		Call setSessionValue("SubjectSearch_SortBy", strSortBy)
	End If
End With

Call makePageFooter(True)
%>
<!--#include file="../includes/core/incClose.asp" -->
