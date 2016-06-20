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
Dim TXT_ANY_OF_THE_DATES_TIMES, _
	TXT_DATES_TIMES, _
	TXT_DISPLAY_UNTIL_DATE, _
	TXT_FOR_VOLUNTEER_AGED, _
	TXT_HAS_OPPORTUNITIES_IN_COMMUNITIES, _
	TXT_ONLY_CURRENT, _
	TXT_ONLY_EXPIRED, _
	TXT_OSSD_COMPONENT, _
	TXT_OSSD_SUITABLE, _
	TXT_SEARCH_OPPORTUNITY, _
	TXT_SEARCH_ORG_NAME, _
	TXT_TEST_VALUE, _
	TXT_VOL_ADVANCED_SEARCH

Sub setTxtSearchAdvancedVOL()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ANY_OF_THE_DATES_TIMES = "Limiter aux dossiers ayant <em>l'une ou plusieurs</em> des dates/heures suivantes" & TXT_COLON
			TXT_DATES_TIMES = "Dates et heures"
			TXT_DISPLAY_UNTIL_DATE = "Date pour afficher jusqu'à"
			TXT_FOR_VOLUNTEER_AGED = "Disponible pour un bénévole âgé de" & TXT_COLON
			TXT_HAS_OPPORTUNITIES_IN_COMMUNITIES = "A des occasions dans l'une ou plusieurs des communautés suivantes" & TXT_COLON
			TXT_ONLY_CURRENT = "Seulement les dossiers courants"
			TXT_ONLY_EXPIRED = "Seulement les dossiers expirés"
			TXT_OSSD_COMPONENT = "Volet DESO"
			TXT_OSSD_SUITABLE = "Adapté au volet bénévolat du DESO"
			TXT_SEARCH_OPPORTUNITY = "Rechercher des occasions"
			TXT_SEARCH_ORG_NAME = "Rechercher des noms d'organismes"
			TXT_VOL_ADVANCED_SEARCH = "Recherche avancée sur les occasions de bénévolat"
		Case Else
			TXT_ANY_OF_THE_DATES_TIMES = "Confine to records having <em>any</em> of the following dates/times" & TXT_COLON
			TXT_DATES_TIMES = "Dates and Times"
			TXT_DISPLAY_UNTIL_DATE = "Display Until Date"
			TXT_FOR_VOLUNTEER_AGED = "Available for a volunteer aged" & TXT_COLON
			TXT_HAS_OPPORTUNITIES_IN_COMMUNITIES = "Has opportunities in any of the following communities" & TXT_COLON
			TXT_ONLY_CURRENT = "Only current records"
			TXT_ONLY_EXPIRED = "Only expired records"
			TXT_OSSD_COMPONENT = "OSSD Component"
			TXT_OSSD_SUITABLE = "Suitable for the OSSD Volunteer Component"
			TXT_SEARCH_OPPORTUNITY = "Search Opportunity"
			TXT_SEARCH_ORG_NAME = "Search Org Name"
			TXT_VOL_ADVANCED_SEARCH = "Volunteer Opportunity Advanced Search"
	End Select
End Sub

Call setTxtSearchAdvancedVOL()
%>
