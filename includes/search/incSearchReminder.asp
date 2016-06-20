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
'
' Purpose: 		Fetch parameters and generate SQL for record searches
'				Common to multiple modules of the software.
'
%>

<%
'--------------------------------------------------
' Reminder Search
'--------------------------------------------------

Dim intReminderID, _
	strReminderName

intReminderID = Request("ReminderID")

If Not Nl(intReminderID) Then
	If Not IsIDType(intReminderID) Then
		Call handleError(TXT_WARNING & TXT_WARNING_REMINDER_ID & intReminderID & "." & _
			vbNullString, vbNullString)
		intReminderID = Null
	End If
End If

'--------------------------------------------------

Sub setReminderData()

'--------------------------------------------------
' Reminder Search
'--------------------------------------------------

	If Not Nl(intReminderID) Then
		Dim cmdReminder, rsReminder
		Set cmdReminder = Server.CreateObject("ADODB.Command")
		With cmdReminder
			.ActiveConnection = getCurrentAdminCnn()
			.Prepared = False
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.CommandText = "dbo.sp_GBL_Reminder_sr"
			.Parameters.Append .CreateParameter("@ReminderID", adInteger, adParamInput, 4, intReminderID)
			.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
			Set rsReminder = .Execute
		End With

		With rsReminder
			If .EOF Then
				Call handleError(TXT_WARNING & TXT_WARNING_REMINDER_INVALID, _
					vbNullString, vbNullString)
			Else
				strReminderName = .Fields("ReminderName")
				Select Case ps_intDbArea
					CASE DM_CIC
						strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM GBL_BT_Reminder rm WHERE rm.NUM=bt.NUM AND rm.ReminderID=" & intReminderID & "))"
					CASE DM_VOL
						strWhere = strWhere & strCon & "(EXISTS(SELECT * FROM VOL_OP_Reminder rm WHERE rm.VNUM=vo.VNUM AND rm.ReminderID=" & intReminderID & "))"
				End Select
				strCon = AND_CON
			End If
		End With
	End If

End Sub
%>
