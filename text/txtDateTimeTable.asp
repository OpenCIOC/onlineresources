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
Dim TXT_DAY_FRIDAY, _
	TXT_DAY_MONDAY, _
	TXT_DAY_SATURDAY, _
	TXT_DAY_SUNDAY, _
	TXT_DAY_THURSDAY, _
	TXT_DAY_TUESDAY, _
	TXT_DAY_WEDNESDAY, _
	TXT_TIME_12_6, _
	TXT_TIME_AFTER_6, _
	TXT_TIME_BEFORE_12, _
	TXT_TIME_AFTERNOON, _
	TXT_TIME_EVENING, _
	TXT_TIME_MORNING, _
	TXT_TIME_SPECIFIC, _
	TXT_TITLE_SPECIFIC

Sub setTxtDateTimeTable()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_DAY_FRIDAY = "vendredi"
			TXT_DAY_MONDAY = "lundi"
			TXT_DAY_SATURDAY = "samedi"
			TXT_DAY_SUNDAY = "dimanche"
			TXT_DAY_THURSDAY = "jeudi"
			TXT_DAY_TUESDAY = "mardi"
			TXT_DAY_WEDNESDAY = "mercredi"
			TXT_TIME_12_6 = "12 h-18 h"
			TXT_TIME_AFTER_6 = "Après 18 h"
			TXT_TIME_BEFORE_12 = "Avant 12 h"
			TXT_TIME_AFTERNOON = "Après-midi"
			TXT_TIME_EVENING = "Soir"
			TXT_TIME_MORNING = "Matin"
			TXT_TIME_SPECIFIC = "Horaires spécifiques (facultatif)"
			TXT_TITLE_SPECIFIC = "Horaires spécifiques"
		Case Else
			TXT_DAY_FRIDAY = "Friday"
			TXT_DAY_MONDAY = "Monday"
			TXT_DAY_SATURDAY = "Saturday"
			TXT_DAY_SUNDAY = "Sunday"
			TXT_DAY_THURSDAY = "Thursday"
			TXT_DAY_TUESDAY = "Tuesday"
			TXT_DAY_WEDNESDAY = "Wednesday"
			TXT_TIME_12_6 = "12pm-6pm"
			TXT_TIME_AFTER_6 = "After 6pm"
			TXT_TIME_BEFORE_12 = "Before 12pm"
			TXT_TIME_AFTERNOON = "Afternoon"
			TXT_TIME_EVENING = "Evening"
			TXT_TIME_MORNING = "Morning"
			TXT_TIME_SPECIFIC = "Specific Times (Optional)"
			TXT_TITLE_SPECIFIC = "Specific Times"
	End Select
End Sub

Call setTxtDateTimeTable()
Call addTextFile("setTxtDateTimeTable")
%>
