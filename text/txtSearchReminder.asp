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
Dim TXT_REMINDER, _
	TXT_WARNING_REMINDER_ID, _
	TXT_WARNING_REMINDER_INVALID

Sub setTxtSearchSaved()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_REMINDER = "Reminder"
			TXT_WARNING_REMINDER_ID = "The following is an invalid Reminder ID and was ignored" & TXT_COLON
			TXT_WARNING_REMINDER_INVALID = "No such Reminder exists, or you do not have permissions. Reminder search criteria was ignored."
		Case CULTURE_FRENCH_CANADIAN
			TXT_REMINDER = "Rappel"
			TXT_WARNING_REMINDER_ID = "L'identificateur Rappel est invalide et a été ignoré" & TXT_COLON
			TXT_WARNING_REMINDER_INVALID = "Soit le rappel n'existe pas, ou si vous ne disposez pas des autorisations. Critères de rappels a été ignoré."
	End Select
End Sub

Call setTxtSearchSaved()
%>
