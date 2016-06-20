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
Dim TXT_ASSISTANCE_AVAILABLE, _
	TXT_ASSISTANCE_FOR, _
	TXT_ASSISTANCE_FROM, _
	TXT_AUTH_COMMUNITY, _
	TXT_BOARD, _
	TXT_BOX, _
	TXT_CONTACT, _
	TXT_DATE, _
	TXT_DAYS, _
	TXT_DESCRIPTON, _
	TXT_LINK, _
	TXT_FIELD, _
	TXT_FIRST_NAME, _
	TXT_FULL_TIME_EQUIVALENT, _
	TXT_FUNDED_CAPACITY, _
	TXT_HEADING, _
	TXT_HEADINGS, _
	TXT_HONORIFIC, _
	TXT_HOURS, _
	TXT_ITEM, _
	TXT_LAST_NAME, _
	TXT_MUNICIPALITY, _
	TXT_NOTE, _
	TXT_PRIORITY, _
	TXT_PUBLISH, _
	TXT_ROUTE, _
	TXT_SERVICE_TYPE, _
	TXT_TARGET_POPULATION, _
	TXT_TERM, _
	TXT_UNIT, _
	TXT_VACANCY, _
	TXT_VALUE, _
	TXT_WAIT_LIST_DATE, _
	TXT_WEEKS

Sub setTxtImportInfo()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ASSISTANCE_AVAILABLE = "Assistance disponible"
			TXT_ASSISTANCE_FOR = "Aide pour"
			TXT_ASSISTANCE_FROM = "Aide de"
			TXT_AUTH_COMMUNITY = "Communauté autorisé (parent)"
			TXT_BOARD = "Conseil scolaire"
			TXT_BOX = "C.P."
			TXT_CONTACT = "Contact"
			TXT_DATE = "Date"
			TXT_DAYS = "Jours"
			TXT_DESCRIPTON = "Description"
			TXT_FIELD = "Champ"
			TXT_FIRST_NAME = "Prénom"
			TXT_FULL_TIME_EQUIVALENT = "Équivalent temps plein (ETP)"
			TXT_FUNDED_CAPACITY = "Capacité financière"
			TXT_HEADING = "En-tête"
			TXT_HEADINGS = "En-têtes"
			TXT_HONORIFIC = "Honorifique"
			TXT_HOURS = "Heures"
			TXT_ITEM = "Élément"
			TXT_LAST_NAME = "Nom de famille"
			TXT_LINK = "Lien"
			TXT_MUNICIPALITY = "Municipalité"
			TXT_NOTE = "Note"
			TXT_PRIORITY = "Piorité"
			TXT_PUBLISH = "Publier"
			TXT_ROUTE = "Ligne"
			TXT_SERVICE_TYPE = "Détail du service"
			TXT_TARGET_POPULATION = "Public cible"
			TXT_TERM = "Terme"
			TXT_UNIT = "Unité"
			TXT_VACANCY = "Vacance"
			TXT_VALUE = "Valeur"
			TXT_WAIT_LIST_DATE = "Date de la liste d'attente"
			TXT_WEEKS = "Semaines"
		Case Else
			TXT_ASSISTANCE_AVAILABLE = "Assistance Available"
			TXT_ASSISTANCE_FOR = "Assistance For"
			TXT_ASSISTANCE_FROM = "Assistance From"
			TXT_AUTH_COMMUNITY = "Authorized Parent Community"
			TXT_BOARD = "Board"
			TXT_BOX = "Box"
			TXT_CONTACT = "Contact"
			TXT_DATE = "Date"
			TXT_DAYS = "Days"
			TXT_DESCRIPTON = "Description"
			TXT_FIELD = "Field"
			TXT_FIRST_NAME = "First Name"
			TXT_FULL_TIME_EQUIVALENT = "Full-time Equivalent (FTE)"
			TXT_FUNDED_CAPACITY = "Funded Capacity"
			TXT_HEADING = "Heading"
			TXT_HEADINGS = "Headings"
			TXT_HONORIFIC = "Honorific"
			TXT_HOURS = "Hours"
			TXT_ITEM = "Item"
			TXT_LAST_NAME = "Last Name"
			TXT_LINK = "Link"
			TXT_MUNICIPALITY = "Municipality"
			TXT_NOTE = "Note"
			TXT_PRIORITY = "Priority"
			TXT_PUBLISH = "Publish"
			TXT_ROUTE = "Route"
			TXT_SERVICE_TYPE = "Service Detail"
			TXT_TARGET_POPULATION = "Target Population"
			TXT_TERM = "Term"
			TXT_UNIT = "Unit"
			TXT_VACANCY = "Vacancy"
			TXT_VALUE = "Value"
			TXT_WAIT_LIST_DATE = "Wait List Date"
			TXT_WEEKS = "Weeks"
	End Select
End Sub

Call setTxtImportInfo()
%>
