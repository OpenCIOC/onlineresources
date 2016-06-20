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
Sub makeNAICSBox(strSearchType,strPart,strPartQ,strExact,strNAICSCode,bCount,bUnusedPartial,strLinkPage)
	Dim bIsEmpty
	Dim cnnNAICSMatch, cmdNAICSMatch, rsNAICSMatch
	Dim strSQL, strCon, strExactNAICSCodes
	Dim intUsageCount

	Call makeNewAdminConnection(cnnNAICSMatch)
	Set cmdNAICSMatch = Server.CreateObject("ADODB.Command")
	With cmdNAICSMatch 	
		.ActiveConnection = cnnNAICSMatch
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With

	bIsEmpty = True
	strExactNAICSCodes = vbNullString

	If strSearchType = "C" Then
		strSearchType = "ncd.Classification"
	Else
		strSearchType = "ncd.SRCH_Anywhere"
	End If

	If Not Nl(strExact) Or Not Nl(strNAICSCode) Then
		strSQL = "SELECT nc.Code, ncd.Classification, ncd.Description " & _
			StringIf(bCount,",dbo.fn_CIC_NAICSCount(vw.MemberID, vw.ViewType, vw.CanSeeNonPublic, vw.CanSeeDeleted, vw.PB_ID, vw.HidePastDueBy, nc.Code, GETDATE()) AS UsageCount") & _
			" FROM " & StringIf(bCount,"CIC_View vw,") & " NAICS nc" & _
			" INNER JOIN NAICS_Description ncd ON nc.Code=ncd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ncd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)" & _
			" WHERE "
		If bCount Then
			strSQL = strSQL & "vw.ViewType=" & g_intViewTypeCIC & " AND ("
		End If
		If Not Nl(strExact) Then
			strSQL = strSQL & "(NOT EXISTS(SELECT * FROM NAICS x INNER JOIN NAICS_Description xd ON xd.Code=x.Code AND xd.LangID=@@LANGID WHERE ncd.Classification=xd.Classification AND LEN(nc.Code) < LEN(x.Code)) AND (ncd.Classification LIKE '" & strExact & "'))"
			strCon = OR_CON
		End If
		If Not Nl(strNAICSCode) Then
			strSQL = strSQL & strCon & "(nc.Code IN (" & strNAICSCode & "))"
		End If
		If bCount Then
			strSQL = strSQL & ")"
		End If
		strSQL = strSQL & " ORDER BY nc.Code"
	End If
	
	If Not Nl(strSQL) Then
		cmdNAICSMatch.CommandText = strSQL
		Set rsNAICSMatch = cmdNAICSMatch.Execute
		If Err.Number = 0 Then
			With rsNAICSMatch
				If Not .EOF Then
					bIsEmpty = False
					Response.Write("<h2>" & TXT_EXACT_MATCH & "</h2>")
					strCon = vbNullString
					While Not .EOF
						If bCount Then
							intUsageCount = .Fields("UsageCount")
						Else
							intUsageCount = Null
						End If
						Call printFullNAICSInfo(.Fields("Code"), _
							.Fields("Classification"), _
							.Fields("Description"), _
							intUsageCount, _
							bCount, _
							strLinkPage _
						)
						strExactNAICSCodes = strExactNAICSCodes & strCon & .Fields("Code")
						strCon = ","
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

	strSQL = vbNullString
	
	If Not (Nl(strPart) And Nl(strPartQ)) Then
		strSQL = "SELECT nc.Code, ncd.Classification " & _
			StringIf(bCount,",dbo.fn_CIC_NAICSCount(vw.MemberID, vw.ViewType, vw.CanSeeNonPublic, vw.CanSeeDeleted, vw.PB_ID, vw.HidePastDueBy, nc.Code, GETDATE()) AS UsageCount") & _
			" FROM " & StringIf(bCount,"CIC_View vw,") & " NAICS nc" & _
			" INNER JOIN NAICS_Description ncd ON nc.Code=ncd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ncd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)" & _
			" WHERE "
		If bCount Then
			strSQL = strSQL & "vw.ViewType=" & g_intViewTypeCIC & " AND ("
		End If	
		strSQL = strSQL & "(NOT EXISTS(SELECT * FROM NAICS x INNER JOIN NAICS_Description xd ON x.Code=xd.Code AND LangID=@@LANGID WHERE ncd.Classification=xd.Classification AND LEN(nc.Code) < LEN(x.Code)))"
		If Not Nl(strPart) Then
			strSQL = strSQL & " AND (CONTAINS(" & strSearchType & ",'" & strPart & "',LANGUAGE '" & g_objCurrentLang.LanguageAlias & "'))"
		End If
		If Not Nl(strPartQ) Then
			strSQL = strSQL & " AND (CONTAINS(" & strSearchType & ",'" & strPartQ & "'))"
		End If
		If Not Nl(strExactNAICSCodes) Then
			strSQL = strSQL & " AND (nc.Code NOT IN (" & strExactNAICSCodes & "))"
		End If
		If bCount Then
			strSQL = strSQL & ")"
		End If
		strSQL = strSQL & " ORDER BY nc.Code"
	End If
	
	If Not Nl(strSQL) Then
		cmdNAICSMatch.CommandText = strSQL
		Set rsNAICSMatch = cmdNAICSMatch.Execute
		If Err.Number = 0 Then
			With rsNAICSMatch
				If Not .EOF Then
					bIsEmpty = False
					Response.Write("<h2>" & TXT_PARTIAL_MATCH & "</h2>")
					If Not rsNAICSMatch.EOF Then
%>
<table class="NoBorder cell-padding-2">
<%
						While Not rsNAICSMatch.EOF
							If bCount Then
								intUsageCount = .Fields("UsageCount")
							Else
								intUsageCount = Null
							End If
							Response.Write(getShortNAICSInfo(.Fields("Code"), _
									.Fields("Classification"), _
									intUsageCount, _
									bCount, _
									strLinkPage _
								))
							.MoveNext
						Wend
%>
</table>
<%
					End If
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
	
	cnnNAICSMatch.Close
	Set cnnNAICSMatch = Nothing
	Set cmdNAICSMatch = Nothing
	Set rsNAICSMatch = Nothing

End Sub
%>

