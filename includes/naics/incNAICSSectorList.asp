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
Dim cmdListSector, rsListSector

Sub openSectorListRst()
	Set cmdListSector = Server.CreateObject("ADODB.Command")
	With cmdListSector
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_NAICS_l_Sectors"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSector = Server.CreateObject("ADODB.Recordset")
	With rsListSector
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSector
	End With
End Sub

Sub closeSectorListRst()
	If rsListSector.State <> adStateClosed Then
		rsListSector.Close
	End If
	Set cmdListSector = Nothing
	Set rsListSector = Nothing
End Sub

Function makeSectorTable(strLinkPage)
	Dim strReturn
	
	Call openSectorListRst()
	
	With rsListSector
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_SECTORS
		Else
			strReturn = strReturn & "<table class=""NoBorder cell-padding-2"">"
			While Not .EOF
				strReturn = strReturn & "<tr VALIGN=""top""><td><strong>" & linkCode(.Fields("Code"),.Fields("Code"),strLinkPage) & "</strong></td>" & _
					"<td>" & .Fields("Classification") & "</td></tr>"
				.MoveNext
			Wend
			strReturn = strReturn & "</table>"
		End If
	End With
	makeSectorTable = strReturn
	
	Call closeSectorListRst()
End Function
%>

