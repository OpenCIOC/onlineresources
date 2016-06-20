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
Dim cmdUseInstead, rsUseInstead

Sub openUseInsteadRst(intSubjID,bAdmin)
	set cmdUseInstead = Server.CreateObject("ADODB.Command")
	With cmdUseInstead
		If bAdmin Then
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_THS_SBJ_UseInstead_s_Admin"
		Else
			.ActiveConnection = getCurrentCICBasicCnn()
			.CommandText = "dbo.sp_THS_SBJ_UseInstead_s"
		End If
		.Parameters.Append .CreateParameter("@SubjID", adInteger, adParamInput, 4,intSubjID)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsUseInstead = Server.CreateObject("ADODB.Recordset")
	With rsUseInstead
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdUseInstead
	End With
End Sub

Sub closeUseInsteadRst()
	If rsUseInstead.State <> adStateClosed Then
		rsUseInstead.Close
	End If
	Set cmdUseInstead = Nothing
	Set rsUseInstead = Nothing
End Sub
%>
