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
Dim cmdListTraining, rsListTraining

Sub openTrainingListRst(bShowHidden)
	Set cmdListTraining = Server.CreateObject("ADODB.Command")
	With cmdListTraining
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_Training_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListTraining = Server.CreateObject("ADODB.Recordset")
	With rsListTraining
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListTraining
	End With
End Sub

Sub closeTrainingListRst()
	If rsListTraining.State <> adStateClosed Then
		rsListTraining.Close
	End If
	Set cmdListTraining = Nothing
	Set rsListTraining = Nothing
End Sub
%>
