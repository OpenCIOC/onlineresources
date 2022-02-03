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
Dim TXT_AGE, _
	TXT_AREAS_OF_INTEREST, _
	TXT_BROWSE_ALL, _
	TXT_CREATED, _
	TXT_DAYS_AND_TIMES, _
	TXT_FOR_HELP_USE_SEARCH_TIPS, _
	TXT_FOR_INFO_STUDENT_OPPS, _
	TXT_GENERAL_AREA_OF_INTEREST, _
	TXT_GET_MATCHES, _
	TXT_IN_THE_PAST, _
	TXT_INST_OSSD_COMPONENT, _
	TXT_INST_SELECT_COMMUNITIES, _
	TXT_INST_SELECT_GENERAL_INTERESTS, _
	TXT_INST_SELECT_SPECIFIC_INTERESTS_1, _
	TXT_INST_SELECT_SPECIFIC_INTERESTS_2, _
	TXT_INST_SELECT_DAYS_AND_TIMES, _
	TXT_MEMBERS, _
	TXT_MODIFIED, _
	TXT_MUST_SELECT_GENERAL_INTEREST, _
	TXT_NO_INTERESTS_FOUND, _
	TXT_NO_SPECIFIC_INTERESTS_FOUND, _
	TXT_NUMOPTS, _
	TXT_NUMOPTS_LONG, _
	TXT_NUMOPTS_LONG_AREA, _
	TXT_NUMOPTS_NUMNEEDED, _
	TXT_NUMOPTS_NUMNEEDED_LONG, _
	TXT_NUMOPTS_NUMNEEDED_LONG_AREA, _
	TXT_ORGANIZATIONS, _
	TXT_OSSD_COMPONENT_LONG_FORM, _
	TXT_RECORDS, _
	TXT_REFERRALS, _
	TXT_SHOW_OPPS, _
	TXT_SHOW_AT_LEAST, _
	TXT_SEARCH_STUDENT_OPPS, _
	TXT_SELECT_YOUR_AGE, _
	TXT_SPECIFIC_AREA_OF_INTEREST, _
	TXT_STUDENT_VOLUNTEERS, _
	TXT_TO_BEGIN_OPP_SEARCH, _
	TXT_TO_SEE_RECENT_OPPS, _
	TXT_VIEW_YOUR_PROFILE, _
	TXT_VOLUNTEER_OPPS_MENU, _
	TXT_VOLUNTEER_PROFILES, _
	TXT_VOLUNTEER_SEARCH_STEP

Sub setTxtSearchBasicVOL()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_AGE = "Âge"
			TXT_AREAS_OF_INTEREST = "Centres d'intérêt"
			TXT_BROWSE_ALL = "Explorer tout "
			TXT_CREATED = "créé"
			TXT_DAYS_AND_TIMES = "Dates et heures"
			TXT_FOR_HELP_USE_SEARCH_TIPS = "Pour de l'aide sur la recherche, consulter les <a href=""""" & makeLinkB("search_help.asp") & """"" style=""""font-weight:bold;"""">Conseils de recherche</a>."
			TXT_FOR_INFO_STUDENT_OPPS = "Pour des informations sur le bénévolat étudiant" & TXT_COLON
			TXT_GENERAL_AREA_OF_INTEREST = "Centre d'intérêt général"
			TXT_GET_MATCHES = "Obtenir des correspondances"
			TXT_IN_THE_PAST = "dans le passé"
			TXT_INST_OSSD_COMPONENT = "Afficher uniquement les occasions désignées comme adaptées au volat bénévolat du DESO"
			TXT_INST_SELECT_COMMUNITIES = "Sélectionner toutes les communautés où vous souhaitez faire du bénévolat. Si vous n'en sélectionnez aucune, la recherche portera sur toutes les communautés."
			TXT_INST_SELECT_GENERAL_INTERESTS = "Sélectionner au moins un centre d'intérêt général dans lequel vous souhaitez faire du bénévolat."
			TXT_INST_SELECT_SPECIFIC_INTERESTS_1 = "Sélectionner les centres d'intérêts spécifiques dans lesquels vous souhaitez faire du bénévolat. Si vous ne sélectionnez rien, la recherche portera sur tous."
			TXT_INST_SELECT_SPECIFIC_INTERESTS_2 = "Sélectionner au moins un centre d'intérêt dans lesquel vous souhaitez faire du bénévolat."
			TXT_INST_SELECT_DAYS_AND_TIMES = "Sélectionner les jours et heures spécifiques auxquels vous souhaitez faire du bénévolat. Si vous ne sélectionnez rien, la recherche portera sur tous."
			TXT_MEMBERS = "Membres"
			TXT_MODIFIED = "modifié"
			TXT_MUST_SELECT_GENERAL_INTEREST = "Vous devez sélectionner au moins un centre d'intérêt général."
			TXT_NO_INTERESTS_FOUND = "Il n'y a pas de centre d'intérêt général pour les critères de recherche sélectionnés. Veuillez revenir et modifier votre recherche pour qu'elle soit moins restrictive."
			TXT_NO_SPECIFIC_INTERESTS_FOUND = "Il n'y a pas de centre d'intérêt spécifique dans les communautés et centres d'intérêt général sélectionnés. Veuillez revenir et modifier votre recherche pour qu'elle soit moins restrictive."
			TXT_NUMOPTS = "[NUMPOS] occasions"
			TXT_NUMOPTS_LONG = "Il y a [NUMPOS] occasions disponibles"
			TXT_NUMOPTS_LONG_AREA = "Il y a [NUMPOS] occasions disponibles dans l'ensemble de [AREA]"
			TXT_NUMOPTS_NUMNEEDED = "[NUMPOS] occasions, [NUMNEEDED] personnes nécessaires"
			TXT_NUMOPTS_NUMNEEDED_LONG = "Il y a [NUMPOS] occasions disponibles, et [NUMNEEDED] personnes nécessaires"
			TXT_NUMOPTS_NUMNEEDED_LONG_AREA = "Il y a [NUMPOS] occasions disponibles, et [NUMNEEDED] personnes nécessaires dans l'ensemble de [AREA]"
			TXT_ORGANIZATIONS = "les organismes"
			TXT_OSSD_COMPONENT_LONG_FORM = "Volet Diplôme d'études secondaires de l'Ontario"
			TXT_RECORDS = "dossiers."
			TXT_REFERRALS = "Renvois"
			TXT_SHOW_OPPS = "Afficher les occasions"
			TXT_SHOW_AT_LEAST = "Afficher au moins"
			TXT_SEARCH_STUDENT_OPPS = "Rechercher les occasions pour étudiants"
			TXT_SELECT_YOUR_AGE = "Sélectionner votre âge"
			TXT_SPECIFIC_AREA_OF_INTEREST = "Centre d'intérêt spécifique"
			TXT_STUDENT_VOLUNTEERS = "Bénévoles étudiants"
			TXT_TO_BEGIN_OPP_SEARCH = "Pour commencer une recherche sur toutes les occasions de bénévolat disponibles" & TXT_COLON
			TXT_TO_SEE_RECENT_OPPS = "Pour voir les ajouts récents à la base de données Bénévolat" & TXT_COLON
			TXT_VIEW_YOUR_PROFILE = "Voir votre profil"
			TXT_VOLUNTEER_OPPS_MENU = "Menu principal des occasions de bénévolat"
			TXT_VOLUNTEER_PROFILES = "Profils de bénévoles"
			TXT_VOLUNTEER_SEARCH_STEP = "Recherche de bénévoles : Étape "
		Case Else
			TXT_AGE = "Age"
			TXT_AREAS_OF_INTEREST = "Areas of Interest"
			TXT_BROWSE_ALL = "Browse all "
			TXT_CREATED = "created"
			TXT_DAYS_AND_TIMES = "Days and Times"
			TXT_FOR_HELP_USE_SEARCH_TIPS = "For help with your search, review the <a href=""" & makeLinkB("search_help.asp") & """ style=""font-weight:bold;"">Search Tips</a>."
			TXT_FOR_INFO_STUDENT_OPPS = "For information on student volunteering" & TXT_COLON
			TXT_GENERAL_AREA_OF_INTEREST = "General Area of Interest"
			TXT_GET_MATCHES = "Get Matches"
			TXT_IN_THE_PAST = "in the past"
			TXT_INST_OSSD_COMPONENT = "Only show opportunities designated as suitable for secondary school diploma requirements."
			TXT_INST_SELECT_COMMUNITIES = "Select all communities in which you would like to volunteer. If you do not select any, all communities will be searched."
			TXT_INST_SELECT_GENERAL_INTERESTS = "Select at least one general area in which you would like to volunteer."
			TXT_INST_SELECT_SPECIFIC_INTERESTS_1 = "Select the specific areas in which you would like to volunteer. If you do not select any, all the areas below will be searched."
			TXT_INST_SELECT_SPECIFIC_INTERESTS_2 = "Select at least one area if interest in which you would like to volunteer."
			TXT_INST_SELECT_DAYS_AND_TIMES = "Select all days and times you would like to volunteer. If you do not select any, all days/times will be searched."
			TXT_MEMBERS = "Members"
			TXT_MODIFIED = "modified"
			TXT_MUST_SELECT_GENERAL_INTEREST = "You must select at least one general area of interest."
			TXT_NO_INTERESTS_FOUND = "There are no general areas of interest within the search criteria you selected. Please go back and modify your search to be less restrictive."
			TXT_NO_SPECIFIC_INTERESTS_FOUND = "There are no specific areas of interest in the communities and general areas you selected. Please go back and modify your search to be less restrictive."
			TXT_NUMOPTS = "[NUMPOS] opportunities"
			TXT_NUMOPTS_LONG = "There are [NUMPOS] opportunities available"
			TXT_NUMOPTS_LONG_AREA = "There are [NUMPOS] opportunities available in all of [AREA]"
			TXT_NUMOPTS_NUMNEEDED = "[NUMPOS] opportunities, [NUMNEEDED] individuals needed"
			TXT_NUMOPTS_NUMNEEDED_LONG = "There are [NUMPOS] opportunities available, and [NUMNEEDED] individuals needed"
			TXT_NUMOPTS_NUMNEEDED_LONG_AREA = "There are [NUMPOS] opportunities available, and [NUMNEEDED] individuals needed in all of [AREA]"
			TXT_ORGANIZATIONS = "Organizations"
			TXT_OSSD_COMPONENT_LONG_FORM  = "Secondary School Diploma Requirements"
			TXT_RECORDS = "records."
			TXT_REFERRALS = "Referrals"
			TXT_SHOW_OPPS = "Show opportunities"
			TXT_SHOW_AT_LEAST = "Show at least"
			TXT_SEARCH_STUDENT_OPPS = "Search Student Opportunities"
			TXT_SELECT_YOUR_AGE = "Select your age:"
			TXT_SPECIFIC_AREA_OF_INTEREST = "Specific Area of Interest"
			TXT_STUDENT_VOLUNTEERS = "Student Volunteers"
			TXT_TO_BEGIN_OPP_SEARCH = "To begin a search on all available volunteer opportunities" & TXT_COLON
			TXT_TO_SEE_RECENT_OPPS = "To see recent additions to the Volunteer Database" & TXT_COLON
			TXT_VIEW_YOUR_PROFILE = "View your Profile"
			TXT_VOLUNTEER_OPPS_MENU = "Volunteer Opportunity Main Menu"
			TXT_VOLUNTEER_PROFILES = "Volunteer Profiles"
			TXT_VOLUNTEER_SEARCH_STEP = "Volunteer Search: Step "
	End Select
End Sub

Call setTxtSearchBasicVOL()
%>
