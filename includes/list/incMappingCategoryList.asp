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
Dim cmdListMappingCategory, rsListMappingCategory

Sub openMappingCategoryListRst()
	Set cmdListMappingCategory = Server.CreateObject("ADODB.Command")
	With cmdListMappingCategory
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_GBL_MappingCategory_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListMappingCategory = Server.CreateObject("ADODB.Recordset")
	With rsListMappingCategory
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListMappingCategory
	End With
End Sub

Sub closeMappingCategoryListRst()
	If rsListMappingCategory.State <> adStateClosed Then
		rsListMappingCategory.Close
	End If
	Set cmdListMappingCategory = Nothing
	Set rsListMappingCategory = Nothing
End Sub

Function makeMappingCategoryList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListMappingCategory
		If .RecordCount = 0 And Not bIncludeBlank Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			If .RecordCount <> 0 Then
				.MoveFirst
			End If
			If bIncludeBlank Then
				strReturn = "<input type=""radio"" name=" & AttrQs(strSelectName) & Checked(Nl(intSelected)) & ">&nbsp;" & TXT_GC_CURRENT_SETTING & "<br>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					StringIf((.Fields("MapCatID") - 1) Mod 4 = 0 And .Fields("MapCatID") <> MAP_PIN_MIN,"<br>") & _
					"<input type=""radio"" name=" & AttrQs(strSelectName) & _
					" value=" & AttrQs(.Fields("MapCatID")) & _
					" id=" & AttrQs(strSelectName & "_" & .Fields("MapCatID")) & _
					Checked(intSelected = .Fields("MapCatID")) & _
					">&nbsp;<label for=" & AttrQs(strSelectName & "_" & .Fields("MapCatID")) & "><img src=" & AttrQs(ps_strPathToStart & "images/mapping/" & .Fields("MapImageSm")) & _
					StringIf(Not Nl(.Fields("CategoryName"))," title=" & AttrQs(.Fields("CategoryName"))) & _
					"></label> "
				.MoveNext
			Wend
		End If
	End With
	makeMappingCategoryList = strReturn
End Function
%>

