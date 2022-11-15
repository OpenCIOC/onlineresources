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
Dim cmdListVOLCommunityGroup, rsListVOLCommunityGroup

Sub openVOLCommunityGroupListRst(bFull, intCommunitySetID)
	Set cmdListVOLCommunityGroup = Server.CreateObject("ADODB.Command")
	With cmdListVOLCommunityGroup
		.ActiveConnection = getCurrentAdminCnn()
		If bFull Then	
			.CommandText = "dbo.sp_VOL_CommunityGroup_lf"
		Else
			.CommandText = "dbo.sp_VOL_CommunityGroup_l"
		End If
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@CommunitySetID", adInteger, adParamInput, 4, intCommunitySetID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListVOLCommunityGroup = Server.CreateObject("ADODB.Recordset")
	With rsListVOLCommunityGroup
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListVOLCommunityGroup
	End With
End Sub

Sub closeVOLCommunityGroupListRst()
	If rsListVOLCommunityGroup.State <> adStateClosed Then
		rsListVOLCommunityGroup.Close
	End If
	Set cmdListVOLCommunityGroup = Nothing
	Set rsListVOLCommunityGroup = Nothing
End Sub

Function makeVOLCommunityGroupList(intSelected, strSelectName, strSelectTitle, bIncludeBlank)
	Dim strReturn
	With rsListVOLCommunityGroup
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select title=" & AttrQs(strSelectTitle) & " name=" & AttrQs(strSelectName) & " class=""form-control"">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			Dim strVolCommunityGroupName
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("CommunityGroupID") & """"
				If intSelected = .Fields("CommunityGroupID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("CommunityGroupName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeVOLCommunityGroupList = strReturn
End Function
%>
