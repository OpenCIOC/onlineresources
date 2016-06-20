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
Class BasicFormatter
	Dim strNameField
	
	Sub setNameField(strInNameField)
		strNameField = strInNameField
	End Sub
	
	Function format_name(rs)
		With rs
			format_name = .Fields(strNameField)
		End With
	End Function
End Class

Class CodeAndNameFormatter
	Dim strCodeField, strNameField, bQuoteCode
	
	Sub setFields(strInCodeField, strInNameField, bInQuoteCode)
		strCodeField = strInCodeField
		strNameField = strInNameField
		bQuoteCode = bInQuoteCode
	End Sub
	
	Function format_name(rs)
		With rs
			If bQuoteCode Then
				format_name = "(" & .Fields(strCodeField) & ")" & _
					IIf(Nl(.Fields(strNameField)),vbNullString," " & .Fields(strNameField))
			Else
				format_name = .Fields(strCodeField) & _
					IIf(Nl(.Fields(strNameField)),vbNullString," (" & .Fields(strNameField) & ")")
			End If
		End With
	End Function
End Class


Function makeChecklistUI(strTypeField, strIncField, strExclField, bAllFrom, rsOptions, strOptionsID, objNameFormatter, bJsonResponse)
	Dim strRetVal, strOptions
	
	strOptions = vbNullString
	With rsOptions
		While Not .EOF
			strOptions = strOptions & vbCrLf & _
				"<option value=" & AttrQs(.Fields(strOptionsID)) & ">" & _
				Server.HTMLEncode(Ns(objNameFormatter.format_name(rsOptions))) & "</option>"
			.MoveNext
		Wend
	End With
	strRetVal = vbNullString
	If strOptionsID = "EXC_ID" Or strOptionsID = "EXD_ID" Then
		strRetVal = "<input type=""hidden"" name=" & AttrQs(Replace(strOptionsID, "_ID", "")) & _
				" value=" & AttrQs(Mid(strIncField,4,Len(strIncField)-5)) & ">"
	End If

	strRetVal = strRetVal &  _
		"<span class=""SmallNote"">" & TXT_HOLD_CTRL & "</span>" & _
		"<div class=""row"">" & _
			"<div class=""col-sm-6"">" & _
				"<div class=""panel"">" & _
					"<div class=""panel-body""><h4>" & TXT_INCLUDE_VALUES & "</h4>" & _
						"<div class=""radio""><label for=" & AttrQs(strTypeField & "N") & "><input type=""radio"" name=""" & strTypeField & """ id=""" & strTypeField & "N"" value=""N""> " & TXT_HAS_NONE & "</label></div>" & _
						"<div class=""radio""><label for=" & AttrQs(strTypeField & "A") & "><input type=""radio"" name=""" & strTypeField & """ id=""" & strTypeField & "A"" value=""A""> " & TXT_HAS_ANY & "</label></div>" & _
						StringIf(bAllFrom,"<div class=""radio""><label for=" & AttrQs(strTypeField & "AF") & "><input type=""radio"" name=""" & strTypeField & """ id=""" & strTypeField & "AF"" value=""AF""> " & TXT_HAS_ALL_FROM & "</label></div>") & _
						"<div class=""radio""><label for=" & AttrQs(strTypeField & "F") & "><input type=""radio"" name=""" & strTypeField & """ id=""" & strTypeField & "F"" value=""F"" checked> " & TXT_HAS_ANY_FROM & "</label></div>" & _
						"<select name=""" & strIncField & """ id=""" & strIncField & """ class=""form-control""  multiple>" & _
							strOptions & _
						"</select>" & _
					"</div>" & _
				"</div>" & _
			"</div>" & _
			"<div class=""col-sm-6"">" & _
				"<div class=""panel"">" & _
					"<div class=""panel-body""><h4>" & TXT_EXCLUDE_VALUES & "</h4>" & _
						"<select name=""" & strExclField & """ id=""" & strExclField & """ class=""form-control"" multiple>" & _
							strOptions & _
						"</select>" & _
					"</div>" & _
				"</div>" & _
			"</div>" & _
		"</div>"

	If bJsonResponse Then
		strRetVal = "{""fail"": false, ""innerHTML"": " & JSONQs(strRetVal, True) & "}"
	End If

	makeChecklistUI = strRetVal
End Function

%>
