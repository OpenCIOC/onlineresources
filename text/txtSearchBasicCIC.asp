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
Dim TXT_CHILD_CARE_RESOURCE, _
	TXT_EXCLUDE_CHILD_CARE_RESOURCES, _
	TXT_HAS_CAPACITY_FOR, _
	TXT_HAS_VACANCIES, _
	TXT_HAS_VACANCIES_OR_WAITLIST, _
	TXT_HEADINGS, _
	TXT_INCLUDE_UNMAPPED_RECORDS, _
	TXT_LOCATIONS_FOR_SERVICE, _
	TXT_NO_SEARCH_VACANCY, _
	TXT_NO_SELECTION_SEARCH_ALL, _
	TXT_OCG, _
	TXT_ON_BUS_ROUTE, _
	TXT_VACANCY, _
	TXT_WITH_VOL, _
	TXT_WITH_WEBSITE, _
	TXT_WITHIN

Sub setTxtSearchBasicCIC()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CHILD_CARE_RESOURCE = "Child Care Resource"
			TXT_EXCLUDE_CHILD_CARE_RESOURCES = "Exclude Child Care Resources"
			TXT_HAS_CAPACITY_FOR = "Has capacity / availability for" & TXT_COLON
			TXT_HAS_VACANCIES = "Has availability"
			TXT_HAS_VACANCIES_OR_WAITLIST = "Has availability or a wait list"
			TXT_HEADINGS = "General Headings"
			TXT_INCLUDE_UNMAPPED_RECORDS = "Include unmapped records"
			TXT_LOCATIONS_FOR_SERVICE = "Locations for the Service"
			TXT_NO_SEARCH_VACANCY = "Do not search availability information"
			TXT_NO_SELECTION_SEARCH_ALL = "If you do not select any values, all values will be searched."
			TXT_OCG = "OCG #"
			TXT_ON_BUS_ROUTE = "On / Near Bus Route"
			TXT_VACANCY = "Availability"
			TXT_WITH_VOL = "Organizations&nbsp;with&nbsp;Volunteer&nbsp;Opportunities"
			TXT_WITH_WEBSITE = "Organizations&nbsp;with&nbsp;WWW&nbsp;Address"
			TXT_WITHIN = "Within"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CHILD_CARE_RESOURCE = "Ressource en garde d'enfants"
			TXT_EXCLUDE_CHILD_CARE_RESOURCES = "Exclure les Ressources en garde d'enfants"
			TXT_HAS_CAPACITY_FOR = "A la capacité / disponibilité de" & TXT_COLON
			TXT_HAS_VACANCIES = "A disponibilité"
			TXT_HAS_VACANCIES_OR_WAITLIST = "A la disponibilité ou d'une liste d'attente"
			TXT_HEADINGS = "En-têtes généraux"
			TXT_INCLUDE_UNMAPPED_RECORDS = "Inclure des dossiers non cartographiées"
			TXT_LOCATIONS_FOR_SERVICE = "Sites pour le service"
			TXT_NO_SEARCH_VACANCY = "Ne pas rechercher des informations sur la disponibilité"
			TXT_NO_SELECTION_SEARCH_ALL = "Si aucune valeur n'est sélectionnée, la recherche portera sur toutes les valeurs."
			TXT_OCG = "No. pour BCG"
			TXT_ON_BUS_ROUTE = "Près de la ligne de bus"
			TXT_VACANCY = "Disponibilité"
			TXT_WITH_VOL = "Organismes avec occasions de bénévolat"
			TXT_WITH_WEBSITE = "Organismes avec site web"
			TXT_WITHIN = "&Agrave; moins de"
	End Select
End Sub

Call setTxtSearchBasicCIC()
%>
