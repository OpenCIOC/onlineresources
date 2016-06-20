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
' Purpose: 
'
%>
<%
'***************************************
' Begin Function getTermListSQL
'	Generate the WHERE clause for searching the given lists of Taxonomy Terms
'		strNUMTable - The Name/Alias of the table containing the record
'			of the records to be searched
'		strAllTermList - Optional. Comma-separated list of linked Term IDs.
'			Term IDs within the linked Term lists are tilde-separated (~).
'		strAnyTermList - Optional. Comma-separated list of linked Term IDs.
'			Term IDs within the linked Term lists are tilde-separated (~).
'	Assumes the lists have already been validated by IsLinkedTaxCodeList.
'***************************************
Function getTermListSQL(strNUMTable, strAllTermList, strAnyTermList, bRestricted)
	Dim strReturn, _
		strTLSQL, _
		strFullTLSQL, _
		aLinks, _
		aTerms, _
		indLink, _
		indTerm, _
		strLinkCon, _
		strTermCon
	
	strReturn = vbNullString
	strFullTLSQL = vbNullString
	strLinkCon = vbNullString
	strTermCon = vbNullString
	
	'SQL for "All" Terms
	If Not Nl(strAllTermList) Then
		aLinks = Split(strAllTermList,",")
		'For each set of linked Terms
		For Each indLink in aLinks
			strTermCon = vbNullString
			aTerms = Split(indLink,"~")

			'Create the SQL
			strTLSQL = "EXISTS(SELECT * FROM CIC_BT_TAX tl WHERE tl.NUM=" & strNUMTable & ".NUM AND "
			'We do not need to worry about extra Terms in the link,
			'only that we have at least the Term(s) that are given.
			'For each Term ID in the link (may be only 1)
			For Each indTerm in aTerms
				strTLSQL = strTLSQL & strTermCon & "EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE " & _
					"tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code" & IIf(bRestricted,"=" & Qs(indTerm,SQUOTE)," LIKE " & Qs(indTerm & "%",SQUOTE)) & ")"
				strTermCon = AND_CON
			Next
			strTLSQL = strTLSQL & ")"
			
			strReturn = strReturn & strLinkCon & strTLSQL
			strLinkCon = AND_CON
		Next
	End If
	
	strLinkCon = vbNullString
	
	'SQL for "Any" Terms
	If Not Nl(strAnyTermList) Then
		aLinks = Split(strAnyTermList,",")
		'For each set of linked Terms
		For Each indLink in aLinks
			strTermCon = vbNullString
			aTerms = Split(indLink,"~")

			'Create the SQL	
			strTLSQL = "EXISTS(SELECT * FROM CIC_BT_TAX tl WHERE tl.NUM=" & strNUMTable & ".NUM AND "
			'We do not need to worry about extra Terms in the link,
			'only that we have at least the Term(s) that are given.
			'For each Term ID in the link (may be only 1)
			For Each indTerm in aTerms
				strTLSQL = strTLSQL & strTermCon & "EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE " & _
					"tlt.BT_TAX_ID=tl.BT_TAX_ID AND tlt.Code" & IIf(bRestricted,"=" & Qs(indTerm,SQUOTE)," LIKE " & Qs(indTerm & "%",SQUOTE)) & ")"
				strTermCon = AND_CON
			Next
			strTLSQL = strTLSQL & ")"
			
			strFullTLSQL = strFullTLSQL & strLinkCon & strTLSQL
			strLinkCon = OR_CON
		Next
		strFullTLSQL = "(" & strFullTLSQL & ")"
	End If

	getTermListSQL = strReturn & IIf(Nl(strFullTLSQL) Or Nl(strReturn),vbNullString,AND_CON) & strFullTLSQL
End Function
'***************************************
' End Function getTermListSQL
'***************************************


'***************************************
' Begin Function getTermListDisplay
'	Generate a human-readable display of the lists of Taxonomy Terms being searched
'		strTermList - Comma-separated list of linked Term IDs.
'			Term IDs within the linked Term lists are tilde-separated (~).
'		strParam - The name of the parameter for search links
'		strLinkPage - Page to link to a new search
'	Assumes the list has already been validated by IsLinkedTaxCodeList.
'	Invalid Terms are discarded.
'***************************************
Function getTermListDisplay(strTermList, strParam, strLinkPage)
	Dim strReturn, _
		strTLSQL, _
		intLinkCount, _
		aLinks, _
		indLink, _
		strLink, _
		strLinkCon, _
		strCode, _
		strCodeCon, _
		intLastLink, _
		bLinkEnd
		
	Dim cmdListDisplay, _
		rsListDisplay
	
	strReturn = vbNullString
	strLinkCon = vbNullString
	
	If Not Nl(strTermList) Then
		intLinkCount = 0
		aLinks = Split(strTermList,",")

		'For each set of linked Terms
		For Each indLink in aLinks
			intLinkCount = intLinkCount + 1
			strLink = reReplace(indLink,"\s*~\s*",",",False,False,True,False)
			If IsTaxCodeList(strLink) Then
				strTLSQL = strTLSQL & strLinkCon & "SELECT DISTINCT " & intLinkCount & " AS LNK_ID, tm.Code, " & _
					"CASE WHEN tmd.LangID=@@LANGID THEN ISNULL(tmd.AltTerm,tmd.Term) " & _
					"ELSE '[' + ISNULL(tmd.AltTerm,tmd.Term) + ']' END AS Term"
						
				If Not Nl(strLinkPage) Then
					strTLSQL = strTLSQL & _
						", CASE WHEN tmd.LangID=@@LANGID THEN ISNULL(tmd.AltDefinition,tmd.Definition) " & _
						"ELSE '[' + ISNULL(tmd.AltDefinition,tmd.Definition) + ']' END AS Definition"
				End If
				
				strTLSQL = strTLSQL & _
					" FROM TAX_Term tm " & _
					" INNER JOIN TAX_Term_Description tmd " & _
					"	ON tm.Code=tmd.Code AND LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE tmd.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & _
					" WHERE tm.Code IN ('" & Replace(strLink,",","','") & "')"
				strLinkCon = vbCrLf & "UNION "
			End If
		Next
		If Not Nl(strTLSQL) Then
			strTLSQL = "SET NOCOUNT ON" & vbCrLf & strTLSQL & vbCrLf & "ORDER BY LNK_ID, Term SET NOCOUNT OFF"
			strLinkCon = vbNullString
			intLinkCount = 0
			intLastLink = 0
			strCode = vbNullString
			strCodeCon = vbNullString

			Set cmdListDisplay = Server.CreateObject("ADODB.Command")
			With cmdListDisplay
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdText
				.CommandText = strTLSQL
				.CommandTimeout = 0
				Set rsListDisplay = .Execute
			End With
			With rsListDisplay
				While Not .EOF
					If Not Nl(strLinkPage) Then
						strReturn = strReturn & strLinkCon & _
							"<a href=""" & makeLink(strLinkPage,strParam & "=" & .Fields("Code"),vbNullString) & """ title=""" & .Fields("Term") & TXT_COLON & .Fields("Definition") & """>" & .Fields("Term") & "</a>"
					Else
						strReturn = strReturn & strLinkCon & .Fields("Term")
					End If
					strLinkCon = " ~ "
					intLastLink = .Fields("LNK_ID")
					intLinkCount = intLinkCount + 1
					strCode = strCode & strCodeCon & .Fields("Code")
					strCodeCon = "~"
					.MoveNext
					If Not .EOF Then
						If intLastLink <> .Fields("LNK_ID") Then
							bLinkEnd = True
						Else
							bLinkEnd = False
						End If
					Else
						bLinkEnd = True
					End If
					If bLinkEnd Then
						If intLinkCount > 1 And Not Nl(strLinkPage) Then
							strReturn = strReturn & " <a href=""" & makeLink(strLinkPage,strParam & "=" & strCode,vbNullString) & """>[+]</a>"
						End If
						strLink = vbNullString
						strLinkCon = " ; "
						strCode = vbNullString
						strCodeCon = vbNullString
						intLinkCount = 0
					End If
				Wend
			End With
		End If

	End If

	getTermListDisplay = strReturn	
End Function
'***************************************
' End Function getTermListDisplay
'***************************************


'***************************************
' Begin Function getTermCodeSQL
'	Generate the WHERE clause for searching based on a Taxonomy Code 
'		strNUMTable - The Name/Alias of the table containing the record
'			of the records to be searched
'		strCode - The Taxonomy Code being searched
'		bRestricted - If False, include lower-level Terms in the search
'	Assumes the Code has already been validated by IsTaxonomyCodeType.
'***************************************
Function getTermCodeSQL(strNUMTable, strCode, bRestricted)
	Dim strReturn
	
	If Not Nl(strCode) Then
		strReturn = "EXISTS(SELECT * FROM CIC_BT_TAX tl INNER JOIN CIC_BT_TAX_TM tlt ON tl.BT_TAX_ID=tlt.BT_TAX_ID " & _
			"WHERE tl.NUM=" & strNUMTable & ".NUM AND tlt.Code" & _
			IIf(bRestricted,"=" & Qs(strCode,SQUOTE)," LIKE " & Qs(strCode & "%",SQUOTE)) & ")"
	End If

	getTermCodeSQL = strReturn	
End Function
'***************************************
' End Function getTermCodeSQL
'***************************************


'***************************************
' Begin Function getTermCodeDisplay
'	Generate a display for the Code being searched, 
'	including a menu of options to execute related searches.
'		strCode - The Taxonomy Code being searched
'		bRestricted - For logged in users: if False, include link to Restrict the search
'			if True, include link to Expand the search.
'		strWarning - Identify any issues with the Code
'	Assumes the Code has already been validated by IsTaxonomyCodeType.
'***************************************
Function getTermCodeDisplay(ByRef strCode, bRestricted, ByRef strTermName, ByRef strWarning)
	Dim strReturn, _
		strSearchedFor
	
	Dim strParentCode
	
	Dim cmdCodeDisplay, _
		rsCodeDisplay

	Set cmdCodeDisplay = Server.CreateObject("ADODB.Command")
	With cmdCodeDisplay
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_TAX_Term_Srch_Basic_Info"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 21, strCode)		
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@NoDeleted", adBoolean, adParamInput, 1, SQL_TRUE)
		Set rsCodeDisplay = .Execute
	End With
	With rsCodeDisplay
		If Not .EOF Then
			strParentCode = .Fields("ParentCode")
			If .Fields("HasChildren") And g_bUseTaxonomyView Then
				strReturn = strReturn & _
					"<li><a href=""" & makeLink(ps_strPathToStart & "servcat.asp","TC=" & strCode,vbNullString) & """>" & _
						TXT_VIEW_SUBTOPICS_OF & "<em>" & .Fields("Term") & "</em></a></li>"
			End If	
			If .Fields("HasRelated") And g_bUseTaxonomyView Then
				strReturn = strReturn & _
					"<li><a href=""" & makeLink(ps_strPathToStart & "servcat.asp","RC=" & strCode,vbNullString) & """>" & _
						TXT_VIEW_TOPICS_RELATED_TO & "<em>" & .Fields("Term") & "</em></a></li>"
			End If	
			If Not Nl(strParentCode) Then
				If .Fields("CdLvl") > 2 Then
					strReturn = strReturn & _
						"<li>" & TXT_EXPAND_SEARCH_TO_TOPIC & "<a href=""" & makeLink(ps_strPathToStart & "tresults.asp","TC=" & strParentCode,vbNullString) & """>" & _
							"<em>" & .Fields("ParentTerm") & "</em></a></li>"
				End If
				If g_bUseTaxonomyView Then
					strReturn = strReturn & _
						"<li><a href=""" & makeLink(ps_strPathToStart & "servcat.asp","TC=" & strParentCode,vbNullString) & """>" & _
							TXT_VIEW_ALL_SUBTOPICS_OF & "<em>" & .Fields("ParentTerm") & "</em></a></li>"
				End If
			End If	
			If Not Nl(strReturn) Then
				strReturn = "<p>" & TXT_YOU_MAY_ALSO & "</p><ul>" & strReturn & "</ul>"
			End If

			strTermName = .Fields("Term")
			strSearchedFor = "<p>" & TXT_YOU_SEARCHED_FOR & "<em><strong><span title=""" & .Fields("Term") & TXT_COLON & .Fields("Definition") & """>" & strTermName & "</span></strong></em>"
			
			If user_bLoggedIn Then
				strSearchedFor = strSearchedFor & " [ <a href=""" & IIf(bRestricted, _
					makeLink(ps_strPathToStart & "tresults.asp","TC=" & strCode,vbNullString) & """>" & TXT_EXPAND, _
					makeLink(ps_strPathToStart & "tresults.asp","TCR=" & strCode,vbNullString) & """>" & TXT_RESTRICT) & _
					"</a> ]</p>"
			Else
				strSearchedFor = strSearchedFor & "</p>"
			End If
			
			strReturn = strSearchedFor & strReturn
				
		Else
			strWarning = TXT_NO_ACTIVE_SERVICE_CATEGORIES & strCode
			strCode = Null
		End If
	End With

	getTermCodeDisplay = strReturn	
End Function
'***************************************
' End Function getTermCodeDisplay
'***************************************
%>
