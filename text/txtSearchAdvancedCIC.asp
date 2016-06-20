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
Dim TXT_ABOUT_NAICS, _
	TXT_AGE_INSTRUCTIONS, _
	TXT_ALL_IN_RANGE, _
	TXT_ANY_IN_RANGE, _
	TXT_AT_LEAST, _
	TXT_AREAS_SERVED_EXACT, _
	TXT_BEGINS_WITH, _
	TXT_DISTRIBUTIONS, _
	TXT_EXCLUDE_DISTRIBUTIONS, _
	TXT_EXCLUDE_HEADINGS, _
	TXT_EXCLUDE_PUBLICATIONS, _
	TXT_FULL_TIME, _
	TXT_HAS_ANY_OPPS, _
	TXT_HAS_CURRENT_OPPS, _
	TXT_HAS_NO_OPPS, _
	TXT_HAS_ONLY_EXPIRED_OPPS, _
	TXT_HAS_PUBLIC_OPPS, _
	TXT_HIDE_SUBJECT_SIDEBAR, _
	TXT_IN_THIS_VIEW, _
	TXT_INCLUDE_DISTRIBUTIONS, _
	TXT_INCLUDE_HEADINGS, _
	TXT_INCLUDE_PUBLICATIONS, _
	TXT_LOCATED_IN_EXACT, _
	TXT_MEMBERSHIPS, _
	TXT_MAX_AGE, _
	TXT_MIN_AGE, _
	TXT_NAICS_SHORT, _
	TXT_NO_SEARCH_OPPS, _
	TXT_NUMBER_EMPLOYEES, _
	TXT_NUMBER_EMPLOYEES_RANGE, _
	TXT_ONLY_CHILD_CARE_RESOURCES, _
	TXT_ORG_ADVANCED_SEARCH, _
	TXT_PART_TIME_SEASONAL, _
	TXT_POSTAL_CODE, _
	TXT_POSTAL_CODE_EXAMPLE, _
	TXT_SERVING_AGE, _
	TXT_STREET_ADDRESS, _
	TXT_STREET_DIR, _
	TXT_STREET_NAME, _
	TXT_STREET_TYPE, _
	TXT_SUBJECT_SIDEBAR, _
	TXT_TOTAL_EMPLOYEES, _
	TXT_WARNING_EMPLOYEES, _
	TXT_WARNING_EMPLOYEES_CRITERIA

Sub setTxtSearchAdvancedCIC()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ABOUT_NAICS = "NAICS Information"
			TXT_AGE_INSTRUCTIONS = "Fill in either side of the range to match one specific age." & _
				"<br>If the second number is lower than the first, it will be ignored." & _
				"<br>You may use decimal numbers. Negative numbers will be ignored."
			TXT_ALL_IN_RANGE = "All in given range"
			TXT_ANY_IN_RANGE = "Any in given range"
			TXT_AREAS_SERVED_EXACT = "Areas Served Community - Exact Match"
			TXT_AT_LEAST = "At least"
			TXT_BEGINS_WITH = "Begins with"
			TXT_DISTRIBUTIONS = "Distributions"
			TXT_EXCLUDE_DISTRIBUTIONS = "Exclude Distribution(s)"
			TXT_EXCLUDE_HEADINGS = "Exclude Heading(s)"
			TXT_EXCLUDE_PUBLICATIONS = "Exclude Publication(s)"
			TXT_FULL_TIME = "Full-Time"
			TXT_HAS_ANY_OPPS = "Has <strong>any</strong> opportunities"
			TXT_HAS_CURRENT_OPPS = "Has <strong>current</strong> opportunities"
			TXT_HAS_NO_OPPS = "Has <strong>no</strong> opportunities"
			TXT_HAS_ONLY_EXPIRED_OPPS = "Has <strong>only expired or deleted</strong> opportunities"
			TXT_HAS_PUBLIC_OPPS = "Has <strong>current, public, non-deleted</strong> opportunities"
			TXT_HIDE_SUBJECT_SIDEBAR = "Hide&nbsp;Subject&nbsp;Sidebar"
			TXT_IN_THIS_VIEW = "in this View"
			TXT_INCLUDE_DISTRIBUTIONS = "Include Distribution(s)"
			TXT_INCLUDE_HEADINGS = "Include Heading(s)"
			TXT_INCLUDE_PUBLICATIONS = "Include Publication(s)"
			TXT_LOCATED_IN_EXACT = "Located In Community - Exact Match"
			TXT_MEMBERSHIPS = "Memberships"
			TXT_MAX_AGE = "Maximum Age"
			TXT_MIN_AGE = "Minimum Age"
			TXT_NAICS_SHORT = "NAICS"
			TXT_NO_SEARCH_OPPS = "Do not search for opportunities"
			TXT_NUMBER_EMPLOYEES = "# Employees"
			TXT_NUMBER_EMPLOYEES_RANGE = "Number of Employees (Range)" & TXT_COLON
			TXT_ONLY_CHILD_CARE_RESOURCES = "Only Child Care Resources"
			TXT_ORG_ADVANCED_SEARCH = "Organization / Program Advanced Search"
			TXT_PART_TIME_SEASONAL = "Part-Time/Seasonal"
			TXT_POSTAL_CODE = "Postal Code"
			TXT_POSTAL_CODE_EXAMPLE = "e.g. A1B 2C3"
			TXT_SERVING_AGE = "Serving&nbsp;a&nbsp;person&nbsp;aged"
			TXT_STREET_ADDRESS = "Street Address"
			TXT_STREET_DIR = "Street Direction"
			TXT_STREET_NAME = "Street Name"
			TXT_STREET_TYPE = "Street Type"
			TXT_SUBJECT_SIDEBAR = "Subject Sidebar"
			TXT_TOTAL_EMPLOYEES = "Total Employees"
			TXT_WARNING_EMPLOYEES = "Warning: Employee information is not available for all records." & _
				"<br>Records without employee information will be excluded from a # Employees search."
			TXT_WARNING_EMPLOYEES_CRITERIA = "Warning: Some # Employees criteria was ignored; &quot;[CRITERIA]&quot; is not a number greater than 0."
		Case CULTURE_FRENCH_CANADIAN
			TXT_ABOUT_NAICS = "Renseignements sur le SCIAN"
			TXT_AGE_INSTRUCTIONS = "Remplir uniquement l'une ou l'autre des cases de la classe d'âge pour choisir un âge spécifique." & _
				"<br>Si le deuxième nombre est inférieur au premier, il sera ignoré." & _
				"<br>Vous pouvez utiliser des nombres décimaux. Les nombres négatifs seront ignorés."
			TXT_ALL_IN_RANGE = "Doit correspondre à la classe d'âge exactement"
			TXT_ANY_IN_RANGE = "Doit correspondre à une partie de la classe d'âge"
			TXT_AREAS_SERVED_EXACT = "Communautés desservies - Correspondance exacte"
			TXT_AT_LEAST = "Au moins"
			TXT_BEGINS_WITH = "Commence par"
			TXT_DISTRIBUTIONS = "Distributions"
			TXT_EXCLUDE_DISTRIBUTIONS = "Exclure les distributions"
			TXT_EXCLUDE_HEADINGS = "Exclure les en-têtes"
			TXT_EXCLUDE_PUBLICATIONS = "Exclure les publications"
			TXT_FULL_TIME = "Temps plein"
			TXT_HAS_ANY_OPPS = "Offre <strong>des</strong> occasions de bénévolat"
			TXT_HAS_CURRENT_OPPS = "Offre des occasions de bénévolat <strong>en ce moment</strong>"
			TXT_HAS_NO_OPPS = "N'offre <strong>aucune</strong> occasion de bénévolat"
			TXT_HAS_ONLY_EXPIRED_OPPS = "A <strong>seulement</strong> des opportunités qui sont <strong>expirés</strong> ou qui <strong>supprimés</strong>"
			TXT_HAS_PUBLIC_OPPS = "Offre des occasions de bénévolat <strong>courantes, publiques et non supprimées</strong>"
			TXT_HIDE_SUBJECT_SIDEBAR = "Cacher le menu des sujets"
			TXT_IN_THIS_VIEW = "dans cette Vue"
			TXT_INCLUDE_DISTRIBUTIONS = "Inclure les distributions"
			TXT_INCLUDE_HEADINGS = "Inclure les en-têtes"
			TXT_INCLUDE_PUBLICATIONS = "Inclure les publications"
			TXT_LOCATED_IN_EXACT = "Situé dans la communauté - Correspondance exacte"
			TXT_MEMBERSHIPS = "Membriété"
			TXT_MAX_AGE = "TR_FR -- Maximum Age"
			TXT_MIN_AGE = "TR_FR -- Minimum Age"
			TXT_NAICS_SHORT = "SCIAN"
			TXT_NO_SEARCH_OPPS = "Ne pas rechercher d'occasions"
			TXT_NUMBER_EMPLOYEES = "No. d'employés"
			TXT_NUMBER_EMPLOYEES_RANGE = "TR_FR -- Number of Employees (Range)" & TXT_COLON
			TXT_ONLY_CHILD_CARE_RESOURCES = "Uniquement les Ressources en garde d'enfants"
			TXT_ORG_ADVANCED_SEARCH = "Recherche avancée par organisme ou programme"
			TXT_PART_TIME_SEASONAL = "Temps partiel / Saisonnier"
			TXT_POSTAL_CODE = "Code postal"
			TXT_POSTAL_CODE_EXAMPLE = "par ex. A1B 2C3"
			TXT_SERVING_AGE = "Sert&nbsp;les&nbsp;personnes&nbsp;âgées&nbsp;de"
			TXT_STREET_ADDRESS = "Adresse municipale"
			TXT_STREET_DIR = "Orientation"
			TXT_STREET_NAME = "Nom de la rue"
			TXT_STREET_TYPE = "Type de rue"
			TXT_SUBJECT_SIDEBAR = "Menu des sujets"
			TXT_TOTAL_EMPLOYEES = "Total employés"
			TXT_VACANCY = "Disponibilité"
			TXT_WARNING_EMPLOYEES = "Attention : les renseignements sur les employés ne sont pas disponibles pour tous les dossiers." & _
				"<br>Les dossiers sans renseignement sur les employés seront exclus d'une recherche par nombre d'employés."
			TXT_WARNING_EMPLOYEES_CRITERIA = "Attention : Quelques critères pour «Nombre d'employés» a été ignorée; «[CRITERIA]» n'est pas un nombre supérieur à 0."
	End Select
End Sub

Call setTxtSearchAdvancedCIC()
%>
