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
Dim cmdListExamples, rsListExamples

Sub openExampleListRst(strNAICSCode, bFull)
	Set cmdListExamples = Server.CreateObject("ADODB.Command")
	With cmdListExamples
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_NAICS_Example_l" & StringIf(bFull,"f")
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@Code", adVarChar, adParamInput, 6, strNAICSCode)
	End With
	Set rsListExamples = Server.CreateObject("ADODB.Recordset")
	With rsListExamples
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListExamples
	End With
End Sub

Sub closeExampleListRst()
	If rsListExamples.State <> adStateClosed Then
		rsListExamples.Close
	End If
	Set cmdListExamples = Nothing
	Set rsListExamples = Nothing
End Sub
%>
