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
Class CommunityGroup
	Public GroupID
	Public SearchList
	Public CurrentSearchItem
	Public GroupName
	Public IconURL
	Public NumPos
	Public NumNeeded
	Public SubItems
	
	Sub Initialize_Class()
		SubItems = vbNullString
	End Sub
	
	Sub setValues(intGroupID, strCommunityGroupName, strImageURL, strBallFileName, intNumPos, intNumNeeded)
		GroupID = intGroupID
		GroupName = strCommunityGroupName
		IconURL = Nz(strImageURL,ps_strPathToStart & "images/" & strBallFileName)
		NumPos = intNumPos
		NumNeeded = intNumNeeded
		CurrentSearchItem = -1
		ReDim SearchList(CurrentSearchItem)
	End Sub
	
	Sub addSubItem(intCMID, strCommunityName, intNumPos, intNumNeeded)
		CurrentSearchItem = CurrentSearchItem + 1
		ReDim Preserve SearchList(CurrentSearchItem)
		SearchList(CurrentSearchItem) = intCMID	
		
		SubItems = SubItems & "<li style=""list-style-type:none"">" & _
			"<input type=""checkbox"" name=""CMID"" id=" & AttrQs("CMID_" & intCMID) & " value=" & AttrQs(intCMID) & ">&nbsp;" & _
			"<label for=" & AttrQs("CMID_" & intCMID) & ">" & strCommunityName & "</label>" & _
			"&nbsp;(" & Replace(Replace(IIf(g_bUseIndividualCount,TXT_NUMOPTS_NUMNEEDED,TXT_NUMOPTS), "[NUMPOS]", intNumPos), "[NUMNEEDED]", intNumNeeded) & ")</li>"
	End Sub
	
	Function makeEntry()
		Dim strReturn
	
		strReturn = "<p><input type=""checkbox"" name=""CMID"" id=" & AttrQs("CMList_CGID_" & GroupID) & " value=""" & Join(SearchList,",") & """>&nbsp;<img src=""" & _
			IconURL & """ border=""0"">&nbsp;&nbsp;<strong>" & _
			"<label for=" & AttrQs("CMList_CGID_" & GroupID) & ">" & GroupName & "</label>" & _
			"</strong>&nbsp;(" & Replace(Replace(IIf(g_bUseIndividualCount,TXT_NUMOPTS_NUMNEEDED,TXT_NUMOPTS), "[NUMPOS]", NumPos), "[NUMNEEDED]", NumNeeded) & ")</p>" & vbCrLf & _
			StringIf(UBound(SearchList) > 0,"<ul>" & SubItems & "</ul>")
		
		makeEntry = strReturn
	End Function
	
End Class

Function makeCommSrchTable(ByRef bIsEmpty, bCountPosition)
	Dim strReturn, intWrapAt
	Dim cmdSrchComm, rsSrchComm
	Set cmdSrchComm = Server.CreateObject("ADODB.Command")
	With cmdSrchComm
		If bCountPosition Then
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandText = "dbo.sp_VOL_CommunityGroup_CM_lc"
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
		Else
			.ActiveConnection = getCurrentVOLBasicCnn()
			.CommandText = "dbo.sp_VOL_CommunityGroup_CM_l"
			.Parameters.Append .CreateParameter("@CommunitySetID", adInteger, adParamInput, 4, g_intCommunitySetID)
		End If
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With

	Set rsSrchComm = cmdSrchComm.Execute

	Dim intWrapNum
	intWrapAt = g_intCommSrchWrapAtVOL

	If Not bCountPosition Then
		With rsSrchComm
			If .EOF Then
				bIsEmpty = True
			Else
				intWrapAt = intWrapAt - 1
				intWrapNum = intWrapAt
				bIsEmpty = False
				strReturn = strReturn & "<table class=""NoBorder cell-padding-1"">"
				While Not .EOF
					If intWrapNum = intWrapAt Then
						strReturn = strReturn & "<tr valign=""top""><td>"
					Else
						strReturn = strReturn & "<td style=""padding-left:8px;"">"
					End If
					strReturn = strReturn & vbCrLf & "<label for=" & AttrQs("CMID_" & .Fields("CM_ID")) & "><input type=""checkbox"" name=""CMID"" id=" & AttrQs("CMID_" & .Fields("CM_ID")) & " value=""" & _
						.Fields("CM_ID") & """>&nbsp;" & .Fields("Community") & "</label></td>"
					If intWrapNum > 0 Then
						intWrapNum = intWrapNum - 1
					Else
						strReturn = strReturn & "</tr>"
						intWrapNum = intWrapAt
					End If
					.MoveNext
				Wend
				If intWrapNum <> intWrapAt Then
					strReturn = strReturn & "</tr>"
				End If
				strReturn = strReturn & vbCrLf & "</table>"
			End If
		End With
	Else
		Dim dicCommunityGroup
		Set dicCommunityGroup = Server.CreateObject("Scripting.Dictionary")
	
		Dim intCGID, _
			indCG

		With rsSrchComm
			If .EOF Then
				bIsEmpty = True
			Else
				If g_bUseIndividualCount And Not Nl(g_strAreaServed) Then
					strReturn = Replace( _
						Replace( _
							Replace(TXT_NUMOPTS_NUMNEEDED_LONG_AREA, "[NUMPOS]", Nz(.Fields("TOTAL_NUM_POS"),0)), _
							"[NUMNEEDED]", Nz(.Fields("TOTAL_NUM_NEEDED"),0) _
							), _
						"[AREA]", g_strAreaServed _
						)
				ElseIf g_bUseIndividualCount Then
					strReturn = Replace( _
						Replace(TXT_NUMOPTS_NUMNEEDED_LONG, "[NUMPOS]", Nz(.Fields("TOTAL_NUM_POS"),0)), _
						"[NUMNEEDED]", Nz(.Fields("TOTAL_NUM_NEEDED"),0) _
						)
				ElseIf Not Nl(g_strAreaServed) Then
					strReturn = Replace( _
						Replace(TXT_NUMOPTS_LONG_AREA, "[NUMPOS]", Nz(.Fields("TOTAL_NUM_POS"),0)), _
						"[AREA]", g_strAreaServed _
						)
				Else
					strReturn = Replace(TXT_NUMOPTS_LONG, "[NUMPOS]", Nz(.Fields("TOTAL_NUM_POS"),0))
				End If

				strReturn = "<p class=""Info"">" & strReturn & "</p>"
				If Not Nl(g_strAreaServed) Then
					strReturn = Replace(strReturn, "[AREA]", g_strAreaServed)
				End If
			End If
		End With
	
		Set rsSrchComm = rsSrchComm.NextRecordSet
	
		With rsSrchComm
			If .EOF Then
				bIsEmpty = True
			Else
				While Not .EOF
					intCGID = .Fields("CommunityGroupID").Value
					Set dicCommunityGroup(intCGID) = New CommunityGroup
					Call dicCommunityGroup(intCGID).setValues( _
						intCGID, _
						.Fields("CommunityGroupName"), _
						.Fields("ImageURL"), _
						.Fields("BallFileName"), _
						.Fields("TOTAL_NUM_POS"), _
						.Fields("TOTAL_NUM_NEEDED") _
					)
					.MoveNext
				Wend
			End If
		End With
	
		Set rsSrchComm = rsSrchComm.NextRecordSet
	
		With rsSrchComm
			If .EOF Then
				bIsEmpty = True
			Else
				While Not .EOF
					intCGID = .Fields("CommunityGroupID").Value
					Call dicCommunityGroup(intCGID).addSubItem(.Fields("CM_ID"),.Fields("Community"),.Fields("NUM_POS"),.Fields("NUM_NEEDED"))
					.MoveNext
				Wend
			
				For Each indCG in dicCommunityGroup
					strReturn = strReturn & vbCrLf & dicCommunityGroup(indCG).makeEntry()
				Next
			End If
		End With
	End If
	
	makeCommSrchTable = strReturn
End Function
%>
