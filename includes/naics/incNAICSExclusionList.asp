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
Dim cmdListExclusions, rsListExclusions

Sub openExclusionListRst(strNAICSCode, bFull)
	Set cmdListExclusions = Server.CreateObject("ADODB.Command")
	With cmdListExclusions
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_NAICS_Exclusion_l" & StringIf(bFull,"f")
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 6, strNAICSCode)
	End With
	Set rsListExclusions = Server.CreateObject("ADODB.Recordset")
	With rsListExclusions
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListExclusions
	End With
End Sub

Sub closeExclusionListRst()
	If rsListExclusions.State <> adStateClosed Then
		rsListExclusions.Close
	End If
	Set cmdListExclusions = Nothing
	Set rsListExclusions = Nothing
End Sub
%>
