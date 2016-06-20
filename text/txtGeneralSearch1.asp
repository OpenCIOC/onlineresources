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
Dim TXT_ANY_COMM, _
	TXT_CONTAINS, _
	TXT_EG, _
	TXT_FOUND, _
	TXT_INST_OTHER_COMMUNITY, _
	TXT_LOCATED_IN_COMM, _
	TXT_MATCHES, _
	TXT_NO_MATCHES, _
	TXT_OTHER_COMMUNITY, _
	TXT_SEARCH_RESULTS_NEW_WINDOW, _
	TXT_SERVING_COMM, _
	TXT_SERVICE_CATEGORIES, _
	TXT_SUBJECTS, _
	TXT_WORDS_ANYWHERE

Sub setTxtGeneralSearch1()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ANY_COMM = "Any Community"
			TXT_CONTAINS = "Contains"
			TXT_EG = "e.g. "
			TXT_FOUND = "Found "
			TXT_INST_OTHER_COMMUNITY = "Find Community Name"
			TXT_LOCATED_IN_COMM = "Located in Community"
			TXT_MATCHES = " matches"
			TXT_NO_MATCHES = "No Matches"
			TXT_OTHER_COMMUNITY = "Other Community"
			TXT_SEARCH_RESULTS_NEW_WINDOW = "Open search results in a new window"
			TXT_SERVICE_CATEGORIES = "Service&nbsp;Categories"
			TXT_SERVING_COMM = "Serving Community"
			TXT_SUBJECTS = "Subjects"
			TXT_WORDS_ANYWHERE = "Keywords"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ANY_COMM = "Touts les communautés"
			TXT_CONTAINS = "Contient"
			TXT_EG = "par exemple "
			TXT_FOUND = "Trouvé "
			TXT_INST_OTHER_COMMUNITY = "Rechercher le nom de la communauté"
			TXT_LOCATED_IN_COMM = "Situé dans la communauté"
			TXT_MATCHES = " résultats"
			TXT_NO_MATCHES = "Aucun résultats"
			TXT_OTHER_COMMUNITY = "Autre communauté"
			TXT_SEARCH_RESULTS_NEW_WINDOW = "Afficher les résultats de recherche dans une nouvelle fenêtre"
			TXT_SERVICE_CATEGORIES = "Catégories de services"
			TXT_SERVING_COMM = "Desservant la communauté"
			TXT_SUBJECTS = "Sujets"
			TXT_WORDS_ANYWHERE = "Mots-clés"
	End Select
End Sub

Call setTxtGeneralSearch1()
%>
