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
Dim TXT_BROWSE_BY_SERVICE_CATEGORY, _
	TXT_FIND_BY_SERVICE, _
	TXT_PROGRAMS_SERVICES_FOR_TOPIC, _
	TXT_RELATED_TOPICS, _
	TXT_SUB_TOPICS, _
	TXT_SUB_TOPICS_OF, _
	TXT_TAXONOMY_DISCLAIMER, _
	TXT_TOPICS_RELATED_TO

Sub setTxtTaxPublicSearch()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_BROWSE_BY_SERVICE_CATEGORY = "Browse by Service Category"
			TXT_FIND_BY_SERVICE = "Find an Organization or Program by type of service" & TXT_COLON
			TXT_PROGRAMS_SERVICES_FOR_TOPIC = "View Programs and Services"
			TXT_RELATED_TOPICS = "Related Topics"
			TXT_SUB_TOPICS = "Sub-Topics"
			TXT_SUB_TOPICS_OF = "Sub-Topics of "
			TXT_TAXONOMY_DISCLAIMER = "The above terms and definitions are part of the <a href=""https://211taxonomy.org/"">Taxonomy of Human Services</a>, used here by permission of INFO LINE of Los Angeles."
			TXT_TOPICS_RELATED_TO = "Topics Related to "
		Case CULTURE_FRENCH_CANADIAN
			TXT_BROWSE_BY_SERVICE_CATEGORY = "Parcourir par catégorie de service"
			TXT_FIND_BY_SERVICE = "Chercher un organisme ou un programme par type de service" & TXT_COLON
			TXT_PROGRAMS_SERVICES_FOR_TOPIC = "Consulter les programmes et services"
			TXT_RELATED_TOPICS = "Sujets associés"
			TXT_SUB_TOPICS = "Sous-sujets"
			TXT_SUB_TOPICS_OF = "Sous-sujets de "
			TXT_TAXONOMY_DISCLAIMER = "Les termes et définitions ci-dessus font partie de la <a href=""https://211taxonomy.org/"">Taxonomie des services humains</a>, utilisée présentement avec la permission d'INFO LINE de Los Angeles"
			TXT_TOPICS_RELATED_TO = "Sujets associés à "
	End Select
End Sub

Call setTxtTaxPublicSearch()
%>
