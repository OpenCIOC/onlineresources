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
' Purpose: 		Taxonomy search translations
'
'
%>
<%
Dim TXT_ADMIN_MODE, _
	TXT_ADVANCED_TAXONOMY_SEARCH, _
	TXT_ANYWHERE, _
	TXT_ARE_YOU_SURE_SUBMIT, _
	TXT_BROADER_TERM, _
	TXT_BUILD_TERM_LIST, _
	TXT_CODE_SEARCH, _
	TXT_CODE_SECTION, _
	TXT_COLLAPSE, _
	TXT_DRILL_DOWN_SEARCH, _
	TXT_EDIT_TAXONOMY_TERM, _
	TXT_HIDE_INACTIVE, _
	TXT_KEYWORD, _
	TXT_MANAGE_TAXONOMY, _
	TXT_MATCH_ANY, _
	TXT_MUST_MATCH, _
	TXT_NO_TERMS, _
	TXT_NO_TERMS_SELECTED, _
	TXT_NORMAL_MODE, _
	TXT_ONLY_WITH_RECORDS, _
	TXT_RECORD_SEARCH, _
	TXT_RELATED_CONCEPT_SEARCH, _
	TXT_RELATED_CONCEPTS, _
	TXT_SELECT, _
	TXT_SERVICE_CATEGORY_SEARCH, _
	TXT_SHOW_ALL_TERMS, _
	TXT_SHOW_INACTIVE, _
	TXT_SORTED_BY_RELEVANCE, _
	TXT_SUGGEST_LINK, _
	TXT_SUGGEST_LINKS_FOR, _
	TXT_SUGGEST_TERM, _
	TXT_SUGGEST_TERMS_FOR_1, _
	TXT_SUGGEST_TERMS_FOR_2, _
	TXT_USE, _
	TXT_USE_REFERENCES

Sub setTxtTaxSearch()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADMIN_MODE = "Admin Mode"
			TXT_ADVANCED_TAXONOMY_SEARCH = "Advanced Taxonomy Record Search"
			TXT_ANYWHERE = "Anywhere"
			TXT_ARE_YOU_SURE_SUBMIT = "Are you sure you want to submit your changes?"
			TXT_BROADER_TERM = "Broader Term"
			TXT_BUILD_TERM_LIST = "Build Term List"
			TXT_CODE_SEARCH = "Code"
			TXT_CODE_SECTION = "Code Section"
			TXT_COLLAPSE = "Collapse"
			TXT_DRILL_DOWN_SEARCH = "Drill Down"
			TXT_EDIT_TAXONOMY_TERM = "Edit Taxonomy Term"
			TXT_HIDE_INACTIVE = "Hide Inactive"
			TXT_KEYWORD = "Keyword"
			TXT_MANAGE_TAXONOMY = "Manage Taxonomy"
			TXT_MATCH_ANY = "Match Any"
			TXT_MUST_MATCH = "Must Match"
			TXT_NO_TERMS = "[ No Terms ]"
			TXT_NO_TERMS_SELECTED = "You have not selected any Terms."
			TXT_NORMAL_MODE = "Normal Mode"
			TXT_ONLY_WITH_RECORDS = "Terms with Records"
			TXT_RECORD_SEARCH = "By Record"
			TXT_RELATED_CONCEPT_SEARCH = "Related Concept"
			TXT_RELATED_CONCEPTS = "Related Concepts"
			TXT_SELECT = "Select"
			TXT_SERVICE_CATEGORY_SEARCH = "Service Category Search"
			TXT_SHOW_ALL_TERMS = "Show All Terms"
			TXT_SHOW_INACTIVE = "Show Inactive"
			TXT_SORTED_BY_RELEVANCE = "Results are sorted by relevance."
			TXT_SUGGEST_LINK = "Suggest Link"
			TXT_SUGGEST_LINKS_FOR = "Suggest Possible Links For" & TXT_COLON
			TXT_SUGGEST_TERM = "Suggest Term"
			TXT_SUGGEST_TERMS_FOR_1 = "Records using the Term(s) "
			TXT_SUGGEST_TERMS_FOR_2 = " also use the Terms..."
			TXT_USE = "use"
			TXT_USE_REFERENCES = "Use References"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADMIN_MODE = "Mode de gestion"
			TXT_ADVANCED_TAXONOMY_SEARCH = "Recherche avancée sur la Taxonomie"
			TXT_ANYWHERE = "Partout"
			TXT_ARE_YOU_SURE_SUBMIT = "Êtes-vous sûr de vouloir appliquer ces modifications ?"
			TXT_BROADER_TERM = "Terme générique"
			TXT_BUILD_TERM_LIST = "Créer la liste des termes"
			TXT_CODE_SEARCH = "Code"
			TXT_CODE_SECTION = "TR_FR Code Section"
			TXT_COLLAPSE = "TR_FR -- Collapse"
			TXT_DRILL_DOWN_SEARCH = "Hiérarchie"
			TXT_EDIT_TAXONOMY_TERM = "TR_FR -- Edit Taxonomy Term"			
			TXT_HIDE_INACTIVE = "Cacher les termes inactifs"
			TXT_KEYWORD = "Mot(s)-clé(s)"
			TXT_MANAGE_TAXONOMY = "Gestion de la Taxonomie"
			TXT_MATCH_ANY = "Au moins un des mots"
			TXT_MUST_MATCH = "L'expression exacte"
			TXT_NO_TERMS = "[ vide ]"
			TXT_NO_TERMS_SELECTED = "Aucun terme n'a été sélectionné."
			TXT_NORMAL_MODE = "Mode normale"
			TXT_ONLY_WITH_RECORDS = "Termes avec dossiers associés"
			TXT_RECORD_SEARCH = "Par dossier"
			TXT_RELATED_CONCEPT_SEARCH = "Concept associé"
			TXT_RELATED_CONCEPTS = "Concepts associés"
			TXT_SELECT = "TR_FR -- Select"
			TXT_SERVICE_CATEGORY_SEARCH = "Recherche par catégorie de service"
			TXT_SHOW_ALL_TERMS = "Afficher tous les termes"
			TXT_SHOW_INACTIVE = "Afficher les termes inactifs"
			TXT_SORTED_BY_RELEVANCE = "Les résultats sont triés par pertinence."
			TXT_SUGGEST_LINK = "Suggestion de relation"
			TXT_SUGGEST_LINKS_FOR = "Suggestion de relations possibles pour" & TXT_COLON
			TXT_SUGGEST_TERM = "Suggestion de terme"
			TXT_SUGGEST_TERMS_FOR_1 = "Les dossiers utilisant le(s) terme(s) "
			TXT_SUGGEST_TERMS_FOR_2 = "utilisent aussi le(s) terme(s)..."
			TXT_USE = "employer"
			TXT_USE_REFERENCES = "Synonymes (non-descripteurs)"
	End Select
End Sub

Call setTxtTaxSearch()
%>
