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
Dim	TXT_BROWSER_FRAMES, _
	TXT_COMMUNITY_FINDER, _
	TXT_COMMUNITY_SEARCH_RESULTS, _
	TXT_HAS_FOUND, _
	TXT_NAICS_FINDER, _
	TXT_NOT_SURE_ENTER, _
	TXT_NOTHING_TO_SEARCH, _
	TXT_OPP_FINDER, _
	TXT_OPP_SEARCH_RESULTS, _
	TXT_ORG_FINDER, _
	TXT_ORG_SEARCH_RESULTS, _
	TXT_RESULTS, _
	TXT_SEARCH_IN_NAME, _
	TXT_AREA_OF_INTEREST_FINDER, _
	TXT_AREA_OF_INTEREST_SEARCH_RESULTS, _
	TXT_SUBJECT_FINDER, _
	TXT_SUBJECT_SEARCH_RESULTS, _
	TXT_TAXONOMY_FINDER, _
	TXT_YOUR_SEARCH

Sub setTxtFinder()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_BROWSER_FRAMES = "Votre navigateur Web doit supporter les cadres pour consulter cette page."
			TXT_COMMUNITY_FINDER = "Localisateur de communautés"
			TXT_COMMUNITY_SEARCH_RESULTS = "Résultats de la recherche sur les communautés"
			TXT_HAS_FOUND = " a produit "
			TXT_NAICS_FINDER = "Localisateur de codes SCIAN"
			TXT_NOT_SURE_ENTER = "Vous ne savez pas ce qu'il faut inscrire ici? Utilisez le "
			TXT_NOTHING_TO_SEARCH = "Aucun résultat (rien à rechercher)."
			TXT_OPP_FINDER = "Localisateur d'identifiant de dossier d'occasion"
			TXT_OPP_SEARCH_RESULTS = "Résultats de la recherche sur les occasions..."
			TXT_ORG_FINDER = "Localisateur de l'identificateur de l'organismes"
			TXT_ORG_SEARCH_RESULTS = "Résultats de la recherche sur les organismes"
			TXT_RESULTS = " résultat(s)"
			TXT_SEARCH_IN_NAME = "Nom de la recherche" & TXT_COLON
			TXT_AREA_OF_INTEREST_FINDER = "Chercher un &quot;Centre d'intérêt&quot;"
			TXT_AREA_OF_INTEREST_SEARCH_RESULTS = "Résultats de la recherche sur les catégories de bénévolat"
			TXT_SUBJECT_FINDER = "Chercher un sujet"
			TXT_SUBJECT_SEARCH_RESULTS = "Résultats de la recherche sur les sujets"
			TXT_TAXONOMY_FINDER = "Chercher une catégorie de service"
			TXT_YOUR_SEARCH = "Votre recherche pour trouver" & TXT_COLON
		Case Else
			TXT_BROWSER_FRAMES = "Your browser must support frames to view this page."
			TXT_COMMUNITY_FINDER = "Community Finder"
			TXT_COMMUNITY_SEARCH_RESULTS = "Community Search Results..."
			TXT_HAS_FOUND = " found "
			TXT_NAICS_FINDER = "NAICS Code Finder"
			TXT_NOT_SURE_ENTER = "Not sure what to enter here? Use the "
			TXT_NOTHING_TO_SEARCH = "No results (nothing to search for)."
			TXT_OPP_FINDER = "Opportunity Record ID Finder"
			TXT_OPP_SEARCH_RESULTS = "Opportunity Search Results..."
			TXT_ORG_FINDER = "Organization Record # Finder"
			TXT_ORG_SEARCH_RESULTS = "Organization Search Results..."
			TXT_RESULTS = " result(s)"
			TXT_SEARCH_IN_NAME = "Search Name" & TXT_COLON
			TXT_AREA_OF_INTEREST_FINDER = "&quot;Area of Interest&quot; Finder"
			TXT_AREA_OF_INTEREST_SEARCH_RESULTS = "&quot;Areas of Interest&quot; Search Results..."
			TXT_SUBJECT_FINDER = "Subject Finder"
			TXT_SUBJECT_SEARCH_RESULTS = "Subject Search Results..."
			TXT_TAXONOMY_FINDER = "Service Category Finder"
			TXT_YOUR_SEARCH = "Your search for" & TXT_COLON
	End Select
End Sub

Call setTxtFinder()
Call addTextFile("setTxtFinder")
%>
