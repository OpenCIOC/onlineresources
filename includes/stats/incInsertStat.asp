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
Sub insertStat(intRecID,bRSN,strRecID)
	Dim cnnStat, cmdInsertStat
	
	Call makeNewAdminConnection(cnnStat)

	On Error Resume Next
	Set cmdInsertStat = Server.CreateObject("ADODB.Command")
	With cmdInsertStat
		.ActiveConnection = cnnStat
		.CommandText = "dbo.sp_" & ps_strDbArea & "_Stats_i"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@AccessDate", 135, adParamInput, 8, Now())
		.Parameters.Append .CreateParameter("@IPAddress", adVarChar, adParamInput, 20, getRemoteIP())
		If bRSN Then
			.Parameters.Append .CreateParameter("@RSN", adInteger, adParamInput, 4, intRecID)
		Else
			.Parameters.Append .CreateParameter("@OP_ID", adInteger, adParamInput, 4, intRecID)
		End If
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, IIf(Nl(user_intID),Null,user_intID))
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, IIf(Nl(ps_intDbAreaViewType),Null,ps_intDbAreaViewType))
		.Parameters.Append .CreateParameter("@API", adBoolean, adParamInput, 1, False)
		If bRSN Then
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strRecID)
		Else
			.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strRecID)
		End If
		.Execute()
	End With

	Err.Clear
End Sub
%>
