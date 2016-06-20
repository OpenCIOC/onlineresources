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
Dim TXT_INST_VACANCY_SETUP, _
	TXT_MANAGE_VACANCY_SETUP, _
	TXT_UPDATE_VACANCY_FAILED, _
	TXT_VACANCY_DAYS_PER_WEEK, _
	TXT_VACANCY_FULL_TIME_EQUIVALENT, _
	TXT_VACANCY_FUNDED_CAPACITY, _
	TXT_VACANCY_HOURS_PER_DAY, _
	TXT_VACANCY_WEEKS_PER_YEAR

Sub setTxtVacancySetup()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_INST_VACANCY_SETUP = "Use the settings below to modify which options are available on the entry forms for the Vacancy field."
			TXT_MANAGE_VACANCY_SETUP = "Manage Vacancy Field Setup"
			TXT_UPDATE_VACANCY_FAILED = "Update Vacancy Field Setup Failed"
			TXT_VACANCY_DAYS_PER_WEEK = "Days per week"
			TXT_VACANCY_FULL_TIME_EQUIVALENT = "Full-time Equivalent (FTE)"
			TXT_VACANCY_FUNDED_CAPACITY = "Funded Capacity"
			TXT_VACANCY_HOURS_PER_DAY = "Hours per day"
			TXT_VACANCY_WEEKS_PER_YEAR = "Weeks per year"
		Case CULTURE_FRENCH_CANADIAN
			TXT_INST_VACANCY_SETUP = "Utiliser les réglage ci-dessous pour modifier la disponibilité des options sur les formulaires de saisie pour le champ Places disponibles."
			TXT_MANAGE_VACANCY_SETUP = "Gérer la configuration des places disponibles"
			TXT_UPDATE_VACANCY_FAILED = "La mise à jour de la configuration des places disponibles a échoué"
			TXT_VACANCY_DAYS_PER_WEEK = "Jours par semaine"
			TXT_VACANCY_FULL_TIME_EQUIVALENT = "Équivalent temps plein (ETP)"
			TXT_VACANCY_FUNDED_CAPACITY = "Capacité financée"
			TXT_VACANCY_HOURS_PER_DAY = "Heures par jour"
			TXT_VACANCY_WEEKS_PER_YEAR = "Semaines par an"
	End Select
End Sub

Call setTxtVacancySetup()
%>
