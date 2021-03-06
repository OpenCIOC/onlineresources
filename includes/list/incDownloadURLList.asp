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
Dim cmdListDownloadURL, rsListDownloadURL

Sub openDownloadURLListRst(intDomain)
	Set cmdListDownloadURL = Server.CreateObject("ADODB.Command")
	With cmdListDownloadURL
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_DownloadURL_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, intDomain)
	End With
	Set rsListDownloadURL = Server.CreateObject("ADODB.Recordset")
	With rsListDownloadURL
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListDownloadURL
	End With
End Sub

Sub closeDownloadURLListRst()
	If rsListDownloadURL.State <> adStateClosed Then
		rsListDownloadURL.Close
	End If
	Set cmdListDownloadURL = Nothing
	Set rsListDownloadURL = Nothing
End Sub
%>

