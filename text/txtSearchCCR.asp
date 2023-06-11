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
Dim TXT_CARE_REQUIRED_ON, _
	TXT_CHILD_CARE_SEARCH, _
	TXT_DATE_OF_BIRTH, _
	TXT_ESCORTS_TO, _
	TXT_LIMIT_SPACE_AVAILABLE, _
	TXT_LIMIT_SPACE_WARNING, _
	TXT_LIMIT_SUBSIDY, _
	TXT_MATCH_ALL_CHILDREN, _
	TXT_MATCH_ALL_SELECTED_TOC, _
	TXT_MATCH_ANY_SELECTED_TOC, _
	TXT_MATCH_ONE_CHILD, _
	TXT_MATCH_SPECIFIC_CHILD, _
	TXT_LOCAL_SCHOOLS, _
	TXT_SEARCH_FOR_CHILD_CARE_RESOURCES, _
	TXT_SEARCH_MULTIPLE_CHILDREN, _
	TXT_SPACE_AVAILABLE, _
	TXT_SUBSIDY, _
	TXT_TYPE_OF_CARE, _
	TXT_TYPE_OF_PROGRAM

Sub setTxtSearchCCR()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CARE_REQUIRED_ON = "Care Required on"
			TXT_CHILD_CARE_SEARCH = "Child Care Search"
			TXT_DATE_OF_BIRTH = "Date of Birth"
			TXT_ESCORTS_TO = "Escorts to / from School"
			TXT_LIMIT_SPACE_AVAILABLE = "Only show programs reporting space available"
			TXT_LIMIT_SUBSIDY = "Only show programs offering subsidized spaces"
			TXT_MATCH_ALL_CHILDREN = "Match only programs that can serve <strong>all</strong> the children"
			TXT_MATCH_ALL_SELECTED_TOC = "Match <strong>all</strong> selected types of care"
			TXT_MATCH_ANY_SELECTED_TOC = "Match <strong>any</strong> selected types of care"
			TXT_MATCH_ONE_CHILD = "Match programs that serve <strong>any one</strong> child's age"
			TXT_MATCH_SPECIFIC_CHILD = "Match programs that serve <strong>child #</strong> "
			TXT_LOCAL_SCHOOLS = "Local schools"
			TXT_SEARCH_FOR_CHILD_CARE_RESOURCES = "Search for Child Care Resources"
			TXT_SEARCH_MULTIPLE_CHILDREN = "Are you searching for care for more than one child?"
			TXT_SPACE_AVAILABLE = "Space Available"
			TXT_SUBSIDY = "Subsidy"
			TXT_TYPE_OF_CARE = "Type of Care Needed"
			TXT_TYPE_OF_PROGRAM = "Type of Program"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CARE_REQUIRED_ON = "Garde requise au"
			TXT_CHILD_CARE_SEARCH = "Recherche de garde d'enfants"
			TXT_DATE_OF_BIRTH = "Date de naissance"
			TXT_ESCORTS_TO = "Accompagne à"
			TXT_LIMIT_SPACE_AVAILABLE = "Afficher uniquement les programmes qui ont des places disponibles"
			TXT_LIMIT_SUBSIDY = "Afficher uniquement les programmes qui offrent des places subventionnées"
			TXT_MATCH_ALL_CHILDREN = "Correspond uniquement aux programmes pouvant servir <strong>tous</strong> les enfants"
			TXT_MATCH_ALL_SELECTED_TOC = "Correspond à <strong>tous</strong> les types de garde d'enfants sélectionnés"
			TXT_MATCH_ANY_SELECTED_TOC = "Correspond à <strong>au moins un</strong> des types de garde d'enfants sélectionnés"
			TXT_MATCH_ONE_CHILD = "Correspond aux programmes qui servent <strong>n'importe quel</strong> âge de l'enfant"
			TXT_MATCH_SPECIFIC_CHILD = "Faire concorder les programmes assistant l'<strong>enfant #</strong> "
			TXT_LOCAL_SCHOOLS = "Les écoles locales"
			TXT_SEARCH_FOR_CHILD_CARE_RESOURCES = "Rechercher des ressources en garde d'enfants"
			TXT_SEARCH_MULTIPLE_CHILDREN = "Cherchez-vous une garderie pour plus d'un enfant ?"
			TXT_SPACE_AVAILABLE = "Espace disponible"
			TXT_SUBSIDY = "Subvention"
			TXT_TYPE_OF_CARE = "Type de garde d'enfants requise"
			TXT_TYPE_OF_PROGRAM = "Type de programme"
	End Select
End Sub

Call setTxtSearchCCR()
%>
