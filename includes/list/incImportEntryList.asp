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
Dim cmdListImportEntry, rsListImportEntry

Sub openImportEntryListRst()
	Set cmdListImportEntry = Server.CreateObject("ADODB.Command")
	With cmdListImportEntry
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListImportEntry = Server.CreateObject("ADODB.Recordset")
	With rsListImportEntry
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListImportEntry
	End With
End Sub

Sub closeImportEntryListRst()
	If rsListImportEntry.State <> adStateClosed Then
		rsListImportEntry.Close
	End If
	Set cmdListImportEntry = Nothing
	Set rsListImportEntry = Nothing
End Sub
%>

