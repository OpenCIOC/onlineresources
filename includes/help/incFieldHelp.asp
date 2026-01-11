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
Call makePageHeader(TXT_FIELD_HELP, TXT_FIELD_HELP, False, True, True, False)
%>
<%
Dim	strFieldName
strFieldName = Trim(Request("field"))
If Len(strFieldName) > 100 Then
	strFieldName = Null
End If
If Not Nl(strFieldName) Then

	Dim	strFieldHelp, strFieldDisplay
	Dim cmdFieldHelp, rsFieldHelp
	Set cmdFieldHelp = Server.CreateObject("ADODB.Command")
	With cmdFieldHelp
		.ActiveConnection = getCurrentBasicCnn()
		Select Case ps_intDbArea
			Case DM_CIC
				.CommandText = "dbo.sp_GBL_FieldOption_s_Help"
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_FieldOption_s_Help"
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@FieldName", adVarChar, adParamInput, 100, strFieldName)
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	End With
	Set rsFieldHelp = cmdFieldHelp.Execute

	With rsFieldHelp
		If Not .EOF Then
			strFieldDisplay = .Fields("FieldDisplay")
			strFieldHelp = .Fields("HelpText")
		Else
			strFieldDisplay = strFieldName
		End If
	End With
%>
<h1 align="center"><%=strFieldDisplay%></h1>
<%
	If Not Nl(strFieldHelp) Then
		Response.Write(strFieldHelp)
	Else
		Call handleError(TXT_CANNOT_PRINT_FIELD_HELP & TXT_COLON & TXT_NO_HELP_FOR_FIELD, vbNullString, vbNullString)
	End If

	rsFieldHelp.Close
	Set rsFieldHelp = Nothing
	Set cmdFieldHelp = Nothing

Else
	Call handleError(TXT_CANNOT_PRINT_FIELD_HELP & TXT_COLON & TXT_NO_FIELD_SELECTED, vbNullString, vbNullString)
End If
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>
<%
Call makePageFooter(False)
%>
