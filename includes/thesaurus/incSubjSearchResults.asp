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

<%
Sub makeSubjectBox(bAdmin, strPart, strPartQ, strExact, strSubjID, bCount, bUnusedPartial, strLinkPage)
	'On Error Resume Next

	Dim bIsEmpty
	Dim cnnSubjMatch, cmdSubjMatch, rsSubjMatch
	Dim strSQL, strCon, strExactSubjIDs
	Dim strCreatedDate, _
		strCreatedBy, _
		strModifiedDate, _
		strModifiedBy, _
		strManagedBy, _
		bInactive, _
		bAuthorized, _
		strCategory, _
		strSource, _
		strNotes, _
		intUsageCount
	
	strExact = Replace(strExact,DQUOTE,vbNullString)

	Call makeNewAdminConnection(cnnSubjMatch)
	Set cmdSubjMatch = Server.CreateObject("ADODB.Command")
	With cmdSubjMatch 	
		.ActiveConnection = cnnSubjMatch
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With

	bIsEmpty = True
	strExactSubjIDs = vbNullString

	If Not Nl(strExact) Or Not Nl(strSubjID) Then
		strSQL = "SELECT sj.Subj_ID,sj.Used,sj.UseAll,sjn.Name AS SubjectTerm"

		If bAdmin Then
			strSQL = strSQL & "," & vbCrLf & _
				"sj.MODIFIED_DATE,sj.MODIFIED_BY,sj.CREATED_DATE,sj.CREATED_BY,sj.Authorized,sjn.Notes," & vbCrLf & _
				"CAST(CASE WHEN EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID) THEN 1 ELSE 0 END AS bit) AS Inactive," & vbCrLf & _
				"(SELECT TOP 1 SourceName FROM THS_Source_Name WHERE SRC_ID=sj.SRC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS Source," & vbCrLf & _
				"(SELECT TOP 1 ISNULL(MemberNameCIC,MemberName) FROM STP_Member_Description WHERE MemberID=sj.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS ManagedBy," & vbCrLf & _
				"(SELECT TOP 1 Category FROM THS_Category_Name WHERE SubjCat_ID=sj.SubjCat_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS Category," & vbCrLf & _
				getAdminUsageLocalSQL() & " AS UsageCountLocal," & getAdminUsageOtherSQL() & " AS UsageCountOther"

		ElseIf bCount Then
			strSQL = strSQL & "," & vbCrLf & getUsageSQL(True) & " AS UsageCount"
		End If
		
		strSQL = strSQL & vbCrLf & _
			"FROM THS_Subject sj" & vbCrLf & _
			"	INNER JOIN THS_Subject_Name sjn" & vbCrLf & _
			"		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=" & _
			IIf(bAdmin, "(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjn.Subj_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)", "@@LANGID")

		strCon = vbCrLf & "WHERE "

		If Not Nl(strExact) Then
			strSQL = strSQL & strCon & "(sjn.Name LIKE '" & strExact & "')"	
			strCon = AND_CON
		End If
		If Not Nl(strSubjID) Then
			strSQL = strSQL & strCon & "(sj.Subj_ID IN (" & strSubjID & "))"
			strCon = AND_CON
		End If
		If Not g_bUseLocalSubjects And Not bAdmin Then
			strSQL = strSQL & strCon & "(Authorized <> 0)"
			strCon = AND_CON
		End If
		If Not bAdmin Then
			strSQL = strSQL & strCon & _
				"(sj.Authorized=1 OR sj.MemberID IS NULL OR sj.MemberID=" & g_intMemberID & ")" & _
				" AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID)"
			strCon = AND_CON
		End If

		strSQL = strSQL & " ORDER BY sjn.Name"
	End If
	
	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush()
	
	If Not Nl(strSQL) Then
		cmdSubjMatch.CommandText = strSQL
		Set rsSubjMatch = cmdSubjMatch.Execute
		If Err.Number = 0 Then
			With rsSubjMatch
				If Not .EOF Then
					bIsEmpty = False
					Response.Write("<h3>" & TXT_EXACT_MATCH & "</h3>")
					strCon = vbNullString
					While Not .EOF
						If bAdmin Then
							intUsageCount = .Fields("UsageCountLocal")
						ElseIf bCount Then
							intUsageCount = .Fields("UsageCount")
						Else
							intUsageCount = Null
						End If
						If bAdmin Then
							strCreatedDate = DateString(.Fields("CREATED_DATE"), False)
							strCreatedBy = .Fields("CREATED_BY")
							strModifiedDate = DateString(.Fields("MODIFIED_DATE"),False)
							strModifiedBy = .Fields("MODIFIED_BY")
							strManagedBy = .Fields("ManagedBy")
							bInactive = .Fields("Inactive")
							bAuthorized = .Fields("Authorized")
							strSource = .Fields("Source")
							strCategory = .Fields("Category")
							strNotes = .Fields("Notes")
						End If
						Call printFullSubjectInfo(.Fields("Subj_ID"), _
							strCreatedDate, _
							strCreatedBy, _
							strModifiedDate, _
							strModifiedBy, _
							strManagedBy, _
							.Fields("SubjectTerm"), _
							bAdmin, _
							bInactive, _
							bAuthorized, _
							.Fields("Used"), _
							.Fields("UseAll"), _
							strNotes, _
							strCategory, _
							strSource, _
							intUsageCount, _
							0, _
							bCount, _
							strLinkPage, _
							False, _
							StringIf(bAdmin,"Admin=on") _
						)
						strExactSubjIDs = strExactSubjIDs & strCon & .Fields("Subj_ID")
						strCon = ","
						.MoveNext
					Wend
				End If
				.Close
			End With
		Else
			Call handleError(TXT_SRCH_ERROR & Err.Description, vbNullString, vbNullString)
			bIsEmpty = False
		End If
	End If
	
	strSQL = vbNullString
	strCon = vbCrLf & "WHERE "
	
	If Not (Nl(strPart) And Nl(strPartQ)) Then
		strSQL = "SELECT sj.Subj_ID,sj.Used,sj.UseAll,sjn.Name AS SubjectTerm"

		If bAdmin Then
			strSQL = strSQL & "," & vbCrLf & _
				"CAST(CASE WHEN EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID) THEN 1 ELSE 0 END AS bit) AS Inactive," & vbCrLf & _
				getAdminUsageLocalSQL() & " AS UsageCountLocal," & getAdminUsageOtherSQL() & " AS UsageCountOther"
		ElseIf bCount Then
			strSQL = strSQL & "," & vbCrLf & getUsageSQL(False) & " AS UsageCount"
		End If
		
		strSQL = strSQL & vbCrLf & _
			"FROM THS_Subject sj" & vbCrLf & _
			"	INNER JOIN THS_Subject_Name sjn" & vbCrLf & _
			"		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=" & _
			IIf(bAdmin, "(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjn.Subj_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)", "@@LANGID")

		If Not Nl(strPart) Then
			strSQL = strSQL & vbCrLf & IIf(Nl(strPartQ),"INNER","LEFT") & " JOIN CONTAINSTABLE(THS_Subject_Name,Name,'" & strPart & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "',50) AS kt ON kt.[KEY]=sjn.TermLangID" & vbCrLf
		End If
		If Not Nl(strPartQ) Then
			strSQL = strSQL & vbCrLf & IIf(Nl(strPart),"INNER","LEFT") & " JOIN CONTAINSTABLE(THS_Subject_Name,Name,'" & strPartQ & "',50) AS ktq ON ktq.[KEY]=sjn.TermLangID" & vbCrLf
		End If

		If Not bUnusedPartial Then
			strSQL = strSQL & strCon & "(Used <> 0)"
			strCon = AND_CON
		End If
		If Not Nl(strExactSubjIDs) Then
			strSQL = strSQL & strCon & "(sj.Subj_ID NOT IN (" & strExactSubjIDs & "))"
			strCon = AND_CON
		End If
		If Not g_bUseLocalSubjects And Not bAdmin Then
			strSQL = strSQL & strCon & "(Authorized <> 0)"
			strCon = AND_CON
		End If
		If Not bAdmin Then
			strSQL = strSQL & strCon & _
				"(sj.Authorized=1 OR sj.MemberID IS NULL OR sj.MemberID=" & g_intMemberID & ")" & _
				" AND NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=" & g_intMemberID & " AND Subj_ID=sj.Subj_ID)"
			strCon = AND_CON
		End If

		strSQL = strSQL & StringIf(Not (Nl(strPart) Or Nl(strPartQ)),strCon & "(kt.RANK > 0 OR ktq.RANK > 0)") & _
			" ORDER BY " & StringIf(Not Nl(strPart),"ISNULL(kt.RANK,0)" & StringIf(Not Nl(strPartQ)," + ")) & StringIf(Not Nl(strPartQ),"ISNULL(ktq.RANK,0)") & " DESC, sjn.Name"
	End If

	'Response.Write("<pre>" & Server.HTMLEncode(strSQL) & "</pre>")
	'Response.Flush()

	If Not Nl(strSQL) Then
		cmdSubjMatch.CommandText = strSQL
		Set rsSubjMatch = cmdSubjMatch.Execute
		If Err.Number = 0 Then
			With rsSubjMatch
				If Not .EOF Then
					bIsEmpty = False
					Response.Write("<h3>" & TXT_PARTIAL_MATCH & "</h3>")
					While Not rsSubjMatch.EOF
						If bAdmin Then
							intUsageCount = .Fields("UsageCountLocal")
						ElseIf bCount Then
							intUsageCount = .Fields("UsageCount")
						Else
							intUsageCount = Null
						End If
						If bAdmin Then
%>
<%=getShortSubjectInfoAdmin(.Fields("Subj_ID"), .Fields("SubjectTerm"), .Fields("Inactive"), .Fields("Used"), .Fields("UseAll"), intUsageCount, .Fields("UsageCountOther"), bCount, strLinkPage, False, "Admin=on")%>
<br>
<%
						ElseIf Not bCount Or g_bUseZeroSubjects Or intUsageCount > 0 Then
%>
<%=getShortSubjectInfo(.Fields("Subj_ID"), .Fields("SubjectTerm"), .Fields("Used"), .Fields("UseAll"), intUsageCount, bCount, strLinkPage, False)%>
<br>
<%
						End If
						.MoveNext
					Wend
				End If
				.Close
			End With
		Else
			Call handleError(TXT_SRCH_ERROR & Err.Description, vbNullString, vbNullString)
			Response.Write("<!--" & strSQL & "-->")
			bIsEmpty = False
		End If
	End If
	
	If bIsEmpty Then
		Response.Write(TXT_NO_MATCHES)
	End If
	
	cnnSubjMatch.Close
	Set cnnSubjMatch = Nothing
	Set cmdSubjMatch = Nothing
	Set rsSubjMatch = Nothing

End Sub
%>

