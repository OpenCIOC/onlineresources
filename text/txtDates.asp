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
Dim TXT_1_YEAR, _
	TXT_3_MONTHS, _
	TXT_6_MONTHS, _
	TXT_18_MONTHS, _
	TXT_BEFORE_DATE, _
	TXT_DATE_IN, _
	TXT_DAYS, _
	TXT_FIRST_OF_LAST_MONTH, _
	TXT_FIRST_OF_THIS_MONTH, _
	TXT_FUTURE, _
	TXT_LAST_7_DAYS, _
	TXT_LAST_10_DAYS, _
	TXT_NEXT_MONTH, _
	TXT_ON_AFTER_DATE, _
	TXT_ON_BEFORE_DATE, _
	TXT_PAST, _
	TXT_PREVIOUS_MONTH, _
	TXT_THIS_MONTH, _
	TXT_TODAY, _
	TXT_YESTERDAY

Sub setTxtDates()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_1_YEAR = "1 an"
			TXT_3_MONTHS = "3 mois"
			TXT_6_MONTHS = "6 mois"
			TXT_18_MONTHS = "18 mois"
			TXT_BEFORE_DATE = "avant le"
			TXT_DATE_IN = "La date est"
			TXT_DAYS = "jours"
			TXT_FIRST_OF_LAST_MONTH = "Premier du dernier mois"
			TXT_FIRST_OF_THIS_MONTH = "Premier de ce mois"
			TXT_FUTURE = "dans le futur"
			TXT_LAST_7_DAYS = "dans les 7 derniers jours"
			TXT_LAST_10_DAYS = "dans les 10 derniers jours"
			TXT_NEXT_MONTH = "dans le prochain mois"
			TXT_ON_AFTER_DATE = "le ou après le"
			TXT_ON_BEFORE_DATE = "le ou avant le"
			TXT_PAST = "dans le passé"
			TXT_PREVIOUS_MONTH = "dans le dernier mois"
			TXT_THIS_MONTH = "dans le présent mois"
			TXT_TODAY = "aujourd'hui"
			TXT_YESTERDAY = "hier"
		Case Else
			TXT_1_YEAR = "1 Year"
			TXT_3_MONTHS = "3 Months"
			TXT_6_MONTHS = "6 Months"
			TXT_18_MONTHS = "18 Months"
			TXT_BEFORE_DATE = "before the date"
			TXT_DATE_IN = "Date is in"
			TXT_DAYS = "days"
			TXT_FIRST_OF_LAST_MONTH = "First of last month"
			TXT_FIRST_OF_THIS_MONTH = "First of this month"
			TXT_FUTURE = "Future"
			TXT_LAST_7_DAYS = "Last 7 Days"
			TXT_LAST_10_DAYS = "Last 10 Days"
			TXT_NEXT_MONTH = "Next Month"
			TXT_ON_AFTER_DATE = "on or after the date"
			TXT_ON_BEFORE_DATE = "on or before the date"
			TXT_PAST = "Past"
			TXT_PREVIOUS_MONTH = "Previous Month"
			TXT_THIS_MONTH = "This Month"
			TXT_TODAY = "Today"
			TXT_YESTERDAY = "Yesterday"
	End Select
End Sub

Call setTxtDates()
Call addTextFile("setTxtDates")
%>
