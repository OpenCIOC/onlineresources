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
Dim cmdListSuitability, rsListSuitability

Sub openSuitabilityListRst(bShowHidden)
	Set cmdListSuitability = Server.CreateObject("ADODB.Command")
	With cmdListSuitability
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_Suitability_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListSuitability = Server.CreateObject("ADODB.Recordset")
	With rsListSuitability
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListSuitability
	End With
End Sub

Sub closeSuitabilityListRst()
	If rsListSuitability.State <> adStateClosed Then
		rsListSuitability.Close
	End If
	Set cmdListSuitability = Nothing
	Set rsListSuitability = Nothing
End Sub
%>
