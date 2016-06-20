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
Dim cmdComm, rsComm, strCommList, strCommSearchList

Sub getVolSearchComms(strCMID)
	Set cmdComm = Server.CreateObject("ADODB.Command")
	
	With cmdComm
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText =	"DECLARE @CMList varchar(max)" & vbCrLf & _
						"SET @CMList = dbo.fn_GBL_Community_s_Search_Exact('" & strCMID & "')" & vbCrLf & _
						"SELECT @CMList AS CommList, (SELECT dbo.fn_GBL_Community_s_Search('" & strCMID & "')) AS SearchList"
		.CommandType = adCmdText
		.CommandTimeout = 0
	End With
	Set rsComm = cmdComm.Execute
	With rsComm
		If Not .EOF Then
			strCommList = .Fields("CommList")
			strCommSearchList = .Fields("SearchList")
		End If
		.Close
	End With
	
	Set rsComm = Nothing
	Set cmdComm = Nothing
End Sub
%>
