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
' Purpose: 		Taxonomy Search Results translations.
'
'
%>
<%
Dim TXT_ADD_CRITERIA, _
	TXT_EDIT_TERM_LIST, _
	TXT_EXPAND, _
	TXT_EXPAND_SEARCH_TO_TOPIC, _
	TXT_MATCH_ANY_TERMS, _
	TXT_MUST_MATCH_TERMS, _
	TXT_NEW_SEARCH_W_TERMS, _
	TXT_NO_ACTIVE_SERVICE_CATEGORIES, _
	TXT_RESTRICT, _
	TXT_TAX_CRITERIA, _
	TXT_VIEW_ALL_SUBTOPICS_OF, _
	TXT_VIEW_SUBTOPICS_OF, _
	TXT_VIEW_TOPICS_RELATED_TO, _
	TXT_YOU_MAY_ALSO, _
	TXT_YOUR_TAX_CRITERIA

Sub setTxtTaxSearchResults()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_CRITERIA = "Add Criteria"
			TXT_EDIT_TERM_LIST = "Add or Remove Terms"
			TXT_EXPAND = "Expand"
			TXT_EXPAND_SEARCH_TO_TOPIC = "<strong>Expand your search</strong> to the Topic "
			TXT_MATCH_ANY_TERMS = "Match at least one from" & TXT_COLON
			TXT_MUST_MATCH_TERMS = "Must match" & TXT_COLON
			TXT_NEW_SEARCH_W_TERMS = "Create a new search with the above Terms" & TXT_COLON
			TXT_NO_ACTIVE_SERVICE_CATEGORIES = "There are no active Service Categories with the Code" & TXT_COLON
			TXT_RESTRICT = "Restrict"
			TXT_TAX_CRITERIA = "Taxonomy Criteria"
			TXT_VIEW_ALL_SUBTOPICS_OF = "View all <strong>Sub-Topics</strong> of "
			TXT_VIEW_SUBTOPICS_OF = "View <strong>Sub-Topics</strong> of "
			TXT_VIEW_TOPICS_RELATED_TO = "View Topics <strong>related to</strong> "
			TXT_YOU_MAY_ALSO = "You may also wish to..."
			TXT_YOUR_TAX_CRITERIA = "You are searching using the following Taxonomy Terms" & TXT_COLON
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_CRITERIA = "Ajouter un critère"
			TXT_EDIT_TERM_LIST = "Ajouter ou retirer des termes"
			TXT_EXPAND_SEARCH_TO_TOPIC = "<strong>élargir la recherche</strong> au sujet "
			TXT_EXPAND = "Élargir"
			TXT_MATCH_ANY_TERMS = "Au moins un des mots de" & TXT_COLON
			TXT_MUST_MATCH_TERMS = "L'expression exacte" & TXT_COLON
			TXT_NEW_SEARCH_W_TERMS = "Effectuer une nouvelle recherche avec les termes ci-dessus" & TXT_COLON
			TXT_NO_ACTIVE_SERVICE_CATEGORIES = "Il n'existe pas de catégorie de service active avec le code" & TXT_COLON
			TXT_RESTRICT = "Restreindre"
			TXT_TAX_CRITERIA = "Critères taxonomiques"
			TXT_VIEW_ALL_SUBTOPICS_OF = "Voir toutes les <strong>sous-catégories</strong> pour "
			TXT_VIEW_SUBTOPICS_OF = "Voir les <strong>sous-catégories</strong> pour "
			TXT_VIEW_TOPICS_RELATED_TO = "Voir les sujets <strong>associés à</strong> "
			TXT_YOU_MAY_ALSO = "Vous voudriez également"
			TXT_YOUR_TAX_CRITERIA = "Votre recherche utilise les termes taxonomiques suivants" & TXT_COLON
	End Select
End Sub

Call setTxtTaxSearchResults()
%>
