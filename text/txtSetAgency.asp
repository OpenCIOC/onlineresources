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
Dim TXT_AGENCY_CHANGED, _
	TXT_AGENCY_NUM, _
	TXT_ARE_YOU_SURE, _
	TXT_CHANGE_RECORD_AGENCY, _
	TXT_MULTIPLE_ORG_LEVEL_1_WARNING, _
	TXT_NOT_AGENCY_WARNING, _
	TXT_NOTE_PREVIOUS_SEARCH_AGENCY, _
	TXT_SET_ALREADY

Sub setTxtAddAgency()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_AGENCY_CHANGED = "Agency has been changed in [COUNT] records."
			TXT_AGENCY_NUM = "Agency NUM"
			TXT_ARE_YOU_SURE = "Are you sure you want to clear the parent Agency field?<br>Use your back button to return to the form if you do not want to clear the field."
			TXT_CHANGE_RECORD_AGENCY = "Change Record Agency"
			TXT_MULTIPLE_ORG_LEVEL_1_WARNING = "Warning: [COUNT] Org Level 1s were detected."
			TXT_NOT_AGENCY_WARNING = "Not an Agency"
			TXT_NOTE_PREVIOUS_SEARCH_AGENCY = "Note: This is an exact list of your previous search results, and does not use your search criteria." & _
				"<br>If you want to create a new list of records meeting your criteria, begin a new search."
			TXT_SET_ALREADY = "If this is not the same as the number of records you selected, the given agency may have already been set."
		Case CULTURE_FRENCH_CANADIAN
			TXT_AGENCY_CHANGED = "L'agence a été modifiée dans [COUNT] dossiers."
			TXT_AGENCY_NUM = "NUM d'agence"
			TXT_ARE_YOU_SURE = "Êtes-vous certain de vouloir vider le champ Agence parent ?<br>Utiliser le bouton Retour pour revenir au formulaire si vous ne voulez pas vider le champ."
			TXT_CHANGE_RECORD_AGENCY = "Changer l'agence du dossier"
			TXT_MULTIPLE_ORG_LEVEL_1_WARNING = "Attention : [COUNT] Niveaux d'org 1 ont été détectés."
			TXT_NOT_AGENCY_WARNING = "Pas une agence"
			TXT_NOTE_PREVIOUS_SEARCH_AGENCY = "Note : ceci est une liste exhaustive des résultats de votre précédente recherche, sans tenir compte de vos critères de recherche." & _
				"<br>Si vous désirez établir une nouvelle liste de dossiers basée sur vos critères, effectuez une nouvelle recherche."
			TXT_SET_ALREADY = "Si ceci ne correspond pas au nombre de dossiers que vous avez sélectionnés, il se peut que l'agence en question ait déjà été établie."
	End Select
End Sub

Call setTxtAddAgency()

%>
