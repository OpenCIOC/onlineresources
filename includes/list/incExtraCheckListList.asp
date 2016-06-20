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
Dim dicRsListExtraCheckList

Set dicRsListExtraCheckList = Server.CreateObject("Scripting.Dictionary")

Sub openExtraCheckListListRst(strDomain, strFieldName, bShowHidden, bAllLanguages)
	Dim cmdListExtraCheckList
	Set cmdListExtraCheckList = Server.CreateObject("ADODB.Command")
	
	With cmdListExtraCheckList
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & strDomain & "_ExtraCheckList_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@strFieldName", adVarChar, adParamInput, 100, strFieldName)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@AllLanguages", adBoolean, adParamInput, 1, IIf(bAllLanguages,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	
	Set dicRsListExtraCheckList(strFieldName) = Server.CreateObject("ADODB.Recordset")
	With dicRsListExtraCheckList(strFieldName)
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListExtraCheckList
	End With
	
	Set cmdListExtraCheckList = Nothing
End Sub

Sub closeExtraCheckListListRst(strFieldName)
	If dicRsListExtraCheckList.Exists(strFieldName) Then
		If dicRsListExtraCheckList(strFieldName).State <> adStateClosed Then
			dicRsListExtraCheckList(strFieldName).Close
		End If
		Set dicRsListExtraCheckList(strFieldName) = Nothing
		dicRsListExtraCheckList.Remove(strFieldName)
	End If
End Sub

Function makeExtraCheckListList(strFieldName, strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With dicRsListExtraCheckList(strFieldName)
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("EXC_ID") & """"
				If strSelected = .Fields("EXC_ID") Then
					strReturn = strReturn & " SELECTED"
				End If
				strReturn = strReturn & ">" & .Fields("ExtraCheckList") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeExtraCheckListList = strReturn
End Function
%>
