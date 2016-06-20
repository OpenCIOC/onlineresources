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
Dim cmdIndexFieldList, rsIndexFieldList

Sub openIndexFieldRst(strNUM)
	Dim intViewType

	Set cmdIndexFieldList = Server.CreateObject("ADODB.Command")
	With cmdIndexFieldList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_View_IndexField_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarchar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End With
	Set rsIndexFieldList = Server.CreateObject("ADODB.Recordset")
	With rsIndexFieldList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdIndexFieldList
	End With
End Sub

Sub closeIndexFieldRst()
	If rsIndexFieldList.State <> adStateClosed Then
		rsIndexFieldList.Close
	End If
	Set cmdIndexFieldList = Nothing
	Set rsIndexFieldList = Nothing
End Sub

Function makeIndexFieldList(strSelectName, strNUM)
	Dim strReturn, _
		strSQL, _
		strCon
	
	strSQL = vbNullString
	strCon = vbNullString
	
	With rsIndexFieldList
		If Not .EOF Then
			strReturn = "<select name=" & AttrQs(strSelectName) & " onChange=""displayField(this.options[this.selectedIndex].value);"" class=""form-control"">" & _
				"<option value=""""> -- </option>"
		
			strSQL = "SELECT "
			While Not .EOF
				strSQL = strSQL & strCon & .Fields("FieldSelect")
				strCon = ","
				.MoveNext
			Wend
			strSQL = strSQL & vbCrLf & _
				"FROM GBL_BaseTable bt " & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
				"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID" & vbCrLf & _
				"WHERE bt.NUM=" & QsNl(strNUM)
			
			Dim cmdOrg, rsOrg
			Set cmdOrg = Server.CreateObject("ADODB.Command")
			With cmdOrg
				.ActiveConnection = getCurrentAdminCnn()
				.CommandType = adCmdText
				.CommandText = strSQL
				.CommandTimeout = 0
				.Prepared = True
			End With
			Set rsOrg = cmdOrg.Execute

			.MoveFirst
			
			Dim fldName, _
				strFieldContents

			Set fldName = .Fields("FieldName")
			
			While Not .EOF
				strFieldContents = rsOrg.Fields(fldName.Value)
				If Not Nl(strFieldContents) Then
					If .Fields("CheckMultiline") Then
						strFieldContents = textToHTML(strFieldContents)
					End If
					strReturn = strReturn & "<option value=" & AttrQs(strFieldContents) & ">" & _
						.Fields("FieldDisplay") & "</option>"
				End If
				.MoveNext
			Wend
			
			strReturn = strReturn & "</select>"
		Else
			strReturn = TXT_NO_VALUES_AVAILABLE
		End If
	End With
	
	makeIndexFieldList = strReturn
End Function
%>
