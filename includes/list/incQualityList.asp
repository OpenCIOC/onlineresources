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
Dim cmdListQuality, rsListQuality

Sub openQualityListRst(bShowHidden, intCurrentValue)
	Set cmdListQuality = Server.CreateObject("ADODB.Command")
	With cmdListQuality
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_Quality_l"
		.CommandType = adCmdStoredProc
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@OverrideID", adInteger, adParamInput, 4, Nz(intCurrentValue, Null))
		.CommandTimeout = 0
	End With
	Set rsListQuality = Server.CreateObject("ADODB.Recordset")
	With rsListQuality
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListQuality
	End With
End Sub

Sub closeQualityListRst()
	If rsListQuality.State <> adStateClosed Then
		rsListQuality.Close
	End If
	Set cmdListQuality = Nothing
	Set rsListQuality = Nothing
End Sub

Function makeQualityList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	With rsListQuality
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
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
					"<option value=""" & .Fields("RQ_ID") & """"
				If strSelected = .Fields("RQ_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">(" & .Fields("Quality") & ")" & _
					IIf(Nl(.Fields("QualityName")),vbNullString," " & .Fields("QualityName")) & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeQualityList = strReturn
End Function
%>
