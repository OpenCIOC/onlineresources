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
Dim cmdListVOLCGCommunity, rsListVOLCGCommunity

Sub openVOLCGCommunityListRst(intCommunitySetID)
	Set cmdListVOLCGCommunity = Server.CreateObject("ADODB.Command")
	With cmdListVOLCGCommunity
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_VOL_CommunityGroup_CM_lf"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@CommunitySetID", adInteger, adParamInput, 4, intCommunitySetID)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListVOLCGCommunity = Server.CreateObject("ADODB.Recordset")
	With rsListVOLCGCommunity
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListVOLCGCommunity
	End With
End Sub

Sub closeVOLCGCommunityListRst()
	If rsListVOLCGCommunity.State <> adStateClosed Then
		rsListVOLCGCommunity.Close
	End If
	Set cmdListVOLCGCommunity = Nothing
	Set rsListVOLCGCommunity = Nothing
End Sub
%>
