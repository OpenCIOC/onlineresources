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
Const CSET_FULL = 0
Const CSET_BASIC = 1
Const CSET_RECORD = 2

Dim cmdListVOLCommunitySet, rsListVOLCommunitySet

Sub openVOLCommunitySetListRst(intCSetType, strVNUM)
	Set cmdListVOLCommunitySet = Server.CreateObject("ADODB.Command")
	With cmdListVOLCommunitySet
		.ActiveConnection = getCurrentAdminCnn()
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		Select Case intCSetType
			Case CSET_FULL
				.CommandText = "dbo.sp_VOL_CommunitySet_lf"
			Case CSET_BASIC
				.CommandText = "dbo.sp_VOL_CommunitySet_l"
			Case CSET_RECORD
				.CommandText = "dbo.sp_VOL_CommunitySet_lr"
				.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, IIf(Nl(strVNUM),Null,strVNUM))
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListVOLCommunitySet = Server.CreateObject("ADODB.Recordset")
	With rsListVOLCommunitySet
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListVOLCommunitySet
	End With
End Sub

Sub closeVOLCommunitySetListRst()
	If rsListVOLCommunitySet.State <> adStateClosed Then
		rsListVOLCommunitySet.Close
	End If
	Set cmdListVOLCommunitySet = Nothing
	Set rsListVOLCommunitySet = Nothing
End Sub

Function makeVolCommunitySetList(intSelected, strSelectName, bIncludeBlank)
	Dim strReturn
	With rsListVOLCommunitySet
		If .RecordCount = 0 Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			.MoveFirst
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("CommunitySetID") & """"
				If intSelected = .Fields("CommunitySetID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("SetName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeVolCommunitySetList = strReturn
End Function

Function makeVolCommunitySetCheckList(strSelectName)
	Dim strReturn, _
		bCurrentSet, _
		bNotMine
	With rsListVOLCommunitySet
		While Not .EOF
			bNotMine = .Fields("MemberID")<>g_intMemberID
			bCurrentSet = .Fields("CommunitySetID")=g_intCommunitySetID
			strReturn = strReturn & _
				"<br><label for=" & AttrQs(strSelectName & "_" & .Fields("CommunitySetID")) & "><input type=""checkbox"" name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName & "_" & .Fields("CommunitySetID")) & " value=""" & .Fields("CommunitySetID") & """"
			If .Fields("RecordUses")=1 Or bCurrentSet Then
				strReturn = strReturn & " checked" 
				If bCurrentSet Or bNotMine Then
					strReturn = strReturn & " onclick=""return false;"""
				End If
			End If
			strReturn = strReturn & ">&nbsp;" & .Fields("SetName") & "</label>" &  _
				StringIf(bNotMine, " <em>[" & .Fields("MemberName") & "]</em>") & _
				StringIf(bCurrentSet Or bNotMine," <span class=""Alert"">*</span>")
			.MoveNext
		Wend
	End With
	makeVolCommunitySetCheckList = strReturn
End Function
%>
