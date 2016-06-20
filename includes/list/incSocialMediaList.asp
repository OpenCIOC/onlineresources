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
Dim cmdListSocialMedia, rsListSocialMedia

Sub openSocialMediaListRst(bInactive)
	Set cmdListSocialMedia = Server.CreateObject("ADODB.Command")
	With cmdListSocialMedia
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_SocialMedia_l"
		.Parameters.Append .CreateParameter("@Inactive", adBoolean, adParamInput, 1, IIf(bInactive,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSocialMedia = Server.CreateObject("ADODB.Recordset")
	With rsListSocialMedia
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSocialMedia
	End With
End Sub

Sub closeSocialMediaListRst()
	If rsListSocialMedia.State <> adStateClosed Then
		rsListSocialMedia.Close
	End If
	Set cmdListSocialMedia = Nothing
	Set rsListSocialMedia = Nothing
End Sub

Function makeSocialMediaList(intSelected, strSelectName, bIncludeBlank, bIncludeNew, strOnChange)
	Dim strReturn
	With rsListSocialMedia
		If .RecordCount = 0 And Not bIncludeNew Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			If .RecordCount <> 0 Then
				.MoveFirst
			End If
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeNew Then
				strReturn = strReturn & "<option value="""">" & TXT_CREATE_NEW & "</option>"
			ElseIf bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("SM_ID") & """"
				If intSelected = .Fields("SM_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("SocialMediaName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeSocialMediaList = strReturn
End Function
%>

