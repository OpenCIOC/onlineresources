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
Function makeGeoCodeTypeList(intSelected, strSelectName, bBulkCode)
	Dim strReturn
	If bBulkCode Then
		strReturn = _
			"<div class=""radio"">" & _
				"<label for=" & AttrQs(strSelectName & "_DONT_CHANGE") & ">" & _
					"<input type=""radio"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_DONT_CHANGE") & Checked(intSelected=GC_DONT_CHANGE) & " value=" & AttrQs(GC_DONT_CHANGE) & ">" & _
					TXT_GC_DONT_CHANGE & _
				"</label>" & _
			"</div>" & _
			"<div class=""radio"">" & _
				"<label for=" & AttrQs(strSelectName & "_CURRENT") & ">" & _
					"<input type=""radio"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_CURRENT") & Checked(intSelected=GC_CURRENT) & ">" & _
					TXT_GC_CURRENT_SETTING & _
				"</label>" & _
			"</div>"
	Else
		strReturn = vbNullString
	End If
	strReturn = strReturn & _
		"<div class=""radio"">" & _
			"<label for=" & AttrQs(strSelectName & "_BLANK") & ">" & _
				"<input type=""radio"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_BLANK") & Checked(intSelected=GC_BLANK) & " value=" & AttrQs(GC_BLANK) & ">" & _
				TXT_GC_BLANK_NO_GEOCODE & _
			"</label>" & _
		"</div>" & _
		"<div class=""radio"">" & _
			"<label for=" & AttrQs(strSelectName & "_SITE") & ">" & _
				"<input type=""radio"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_SITE") & Checked(intSelected=GC_SITE) & " value=" & AttrQs(GC_SITE) & ">" & _
				TXT_GC_SITE_ADDRESS & _
				StringIf(Not bBulkCode," <a class=""NotVisible"" href=""javascript:void(0)"" id="""& strSelectName & "_SITE_REFRESH""><img title=" & AttrQs(TXT_REFRESH_MAP) & "alt=" & AttrQs(TXT_REFRESH_MAP) & " src=""" & ps_strPathToStart & "images/refresh.gif""></a>") & _
			"</label>" & _
		"</div>" & _
		"<div class=""radio"">" & _
			"<label for=" & AttrQs(strSelectName & "_INTERSECTION") & ">" & _
				"<input type=""radio"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_INTERSECTION") & Checked(intSelected=GC_INTERSECTION) & " value=" & AttrQs(GC_INTERSECTION) & ">" & _
				TXT_GC_INTERSECTION & _
				StringIf(Not bBulkCode," <a class=""NotVisible"" href=""javascript:void(0)"" id="""& strSelectName & "_INTERSECTION_REFRESH""><img title=" & AttrQs(TXT_REFRESH_MAP) & "alt=" & AttrQs(TXT_REFRESH_MAP) & " src=""" & ps_strPathToStart & "images/refresh.gif""></a>") & _
			"</label>" & _
		"</div>"
	If Not bBulkCode Then
		strReturn = strReturn & _
		"<div class=""radio"">" & _
			"<label for=" & AttrQs(strSelectName & "_MANUAL") & ">" & _
				"<input type=""radio"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_MANUAL") & Checked(intSelected=GC_MANUAL) & " value=" & AttrQs(GC_MANUAL) & ">" & _
				TXT_GC_MANUAL & _
			"</label>" & _
		"</div>"
	End If
	makeGeoCodeTypeList = strReturn
End Function
%>
