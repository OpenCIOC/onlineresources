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
Dim TXT_BROADER_CLASSIFICATIONS, _
	TXT_CLASSIFICATION_NAME_ONLY, _
	TXT_ESTABLISHMENTS, _
	TXT_EXACT_MATCH, _
	TXT_EXAMPLES, _
	TXT_EXCLUSIONS, _
	TXT_INDUSTRY, _
	TXT_INDUSTRY_GROUP, _
	TXT_INDUSTRY_SEARCH, _
	TXT_INST_INDUSTRY_SEARCH, _
	TXT_INVALID_NAICS_CODES, _
	TXT_KEYWORD_SEARCH, _
	TXT_KEYWORD_HINT, _
	TXT_KEYWORDS, _
	TXT_NAICS, _
	TXT_NAICS_USE_FOOTER, _
	TXT_NAME_DESC_EXAMPLES, _
	TXT_NARROWER_CLASSIFICATIONS, _
	TXT_NATIONAL_INDUSTRY, _
	TXT_NO_SECTORS, _
	TXT_PARTIAL_MATCH, _
	TXT_RETURN_TO_TOP_LEVEL, _
	TXT_SECTOR, _
	TXT_SECTOR_SEARCH, _
	TXT_SPECIFIC_CODE, _
	TXT_SUBSECTOR, _
	TXT_SUB_CATEGORIES, _
	TXT_UP_ONE_LEVEL, _
	TXT_UNKNOWN_ERROR_NAICS

Sub setTxtNAICS
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_BROADER_CLASSIFICATIONS = "Broader Classifications"
			TXT_CLASSIFICATION_NAME_ONLY = "Classification&nbsp;Name Only"
			TXT_ESTABLISHMENTS = "Establishments primarily engaged in"
			TXT_EXACT_MATCH = "Exact&nbsp;Match"
			TXT_EXAMPLES = "Examples"
			TXT_EXCLUSIONS = "Exclusions"
			TXT_INDUSTRY = "Industry"
			TXT_INDUSTRY_GROUP = "Industry&nbsp;Group"
			TXT_INDUSTRY_SEARCH = "Industry Search"
			TXT_INST_INDUSTRY_SEARCH = "The number of businesses listed under each classification (including any sub-categories of that classification) are listed in brackets. You can browse sub-categories or do a search to list all businesses in the chosen Classification. Only Classifications with related records in the database are shown here. You can explore the full NAICS classification system through our "
			TXT_INVALID_NAICS_CODES = "The following are invalid NAICS codes: "
			TXT_KEYWORD_SEARCH = "Keyword Search"
			TXT_KEYWORD_HINT = "Hint: If you have difficulty locating a keyword, try searching the plural form or the long form of the word."
			TXT_KEYWORDS = "Keywords"
			TXT_NAICS = "North American Industry Classification System (NAICS)"
			TXT_NAICS_USE_FOOTER = "This classification system is adapted from <em>North American Industry Classification System  NAICS, Catalogue 12-501, 2002</em>, and used with the permission of Statistics Canada. Users are forbidden to copy the data and disseminate them, in an original or modified form, for commercial purposes, without the expressed permission of Statistics Canada. Information on the availability of the wide range of data from Statistics Canada can be obtained from Statistics Canada's Regional Offices, its World Wide Web site at <a href=""http://www.statcan.gc.ca"">http://www.statcan.gc.ca</a>, and its toll-free access number 1-800-263-1136."
			TXT_NAME_DESC_EXAMPLES = "Name,&nbsp;Description, and Examples"
			TXT_NARROWER_CLASSIFICATIONS = "Narrower Classifications"
			TXT_NATIONAL_INDUSTRY = "National&nbsp;Industry"
			TXT_NO_SECTORS = "There are no Sectors available"
			TXT_PARTIAL_MATCH = "Partial&nbsp;Match"
			TXT_RETURN_TO_TOP_LEVEL = "Return&nbsp;to&nbsp;Top&nbsp;Level"
			TXT_SECTOR = "Sector"
			TXT_SECTOR_SEARCH = "Sector Search"
			TXT_SPECIFIC_CODE = "Specific Code"
			TXT_SUBSECTOR = "Subsector"
			TXT_SUB_CATEGORIES = "Sub-Categories"
			TXT_UP_ONE_LEVEL = "Up&nbsp;1&nbsp;Level"
			TXT_UNKNOWN_ERROR_NAICS = "An unknown error occurred processing new NAICS codes"
		Case CULTURE_FRENCH_CANADIAN
			TXT_BROADER_CLASSIFICATIONS = "Niveaux supérieurs"
			TXT_CLASSIFICATION_NAME_ONLY = "Nom de classe uniquement"
			TXT_ESTABLISHMENTS = "Établissements dont l'activité principale est"
			TXT_EXACT_MATCH = "Concordance&nbsp;exacte"
			TXT_EXAMPLES = "Exemples"
			TXT_EXCLUSIONS = "Exclusions"
			TXT_INDUSTRY = "Classe&nbsp;d'industrie"
			TXT_INDUSTRY_GROUP = "Groupe&nbsp;d'industrie"
			TXT_INDUSTRY_SEARCH = "Recherche par industrie"
			TXT_INST_INDUSTRY_SEARCH = "Le nombre d'entreprises inscrites pour chaque classification (y compris les sous-catégories de cette classification) est affiché entre crochets. Vous pouvez balayer les sous-catégories ou effectuer une recherche pour afficher toutes les entreprises dans la classification choisie. Seules les classifications avec des dossiers associés dans la base de données seront affichées ici. Vous pouvez découvrir le systéme complet de classification SCIAN par notre "
			TXT_INVALID_NAICS_CODES = "Les codes SCIAN suivants ne sont pas valides :"
			TXT_KEYWORD_SEARCH = "Recherche par mot clé"
			TXT_KEYWORD_HINT = "Conseil : si vous avez des difficultés à trouver un mot-clé, essayez en chercher la forme pluriel ou complète du mot."
			TXT_KEYWORDS = "Mots-clés"
			TXT_NAICS = "Système de Classification des Industries de l'Amérique du Nord (SCIAN)"
			TXT_NAICS_USE_FOOTER = "Ce sytème de classification est une adaptation du <em>Système de classification des industries de l'Amérique du Nord (SCIAN), Catalogue 12-501, 2002</em>, qui est utilisé avec l'autorisation de Statistiques Canada. Il est interdit aux utilisateurs(trices) de reproduire et de diffuser les données, à des fins commerciales, sous forme originale ou modifiée, sans l'autorisation explicite de Statistiques Canada. L'information sur la grande variété de données disponibles à Statistiques Canada peut être obtenue, soit en s'adressant à l'un des bureaux régionaux de Statistiques Canada, soit en consultant son site web à <a href=""http://www.statcan.gc.ca"">http://www.statcan.gc.ca</a>, ou encore en composant le numéro sans frais 1-800-263-1136."
			TXT_NAME_DESC_EXAMPLES = "Nom,&nbsp;description, et exemples"
			TXT_NARROWER_CLASSIFICATIONS = "Niveaux inférieurs"
			TXT_NATIONAL_INDUSTRY = "Industrie&nbsp;nationale"
			TXT_NO_SECTORS = "Il n'y a pas de secteur disponible"
			TXT_PARTIAL_MATCH = "Concordance&nbsp;partielle"
			TXT_RETURN_TO_TOP_LEVEL = "Retourner au niveau supérieur"
			TXT_SECTOR = "Secteur"
			TXT_SECTOR_SEARCH = "Recherche par secteur"
			TXT_SPECIFIC_CODE = "Code spécifique"
			TXT_SUBSECTOR = "Sous-secteur"
			TXT_SUB_CATEGORIES = "Sous-catégories"
			TXT_UP_ONE_LEVEL = "1 niveau supérieur"
			TXT_UNKNOWN_ERROR_NAICS = "Une erreur inconnue est survenue lors du traitement des nouveaux codes SCIAN"
	End Select
End Sub

Call setTxtNAICS()
%>
