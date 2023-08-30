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
' Purpose: 		Add/Remove Code or Classification Translations.
'
'
%>
<%
Dim TXT_ADD_REMOVE, _
	TXT_ADD_REMOVE_AREA_OF_INTEREST, _
	TXT_ADD_REMOVE_DISTRIBUTION, _
	TXT_ADD_REMOVE_HEADING, _
	TXT_ADD_REMOVE_NAICS, _
	TXT_ADD_REMOVE_PUBLICATION, _
	TXT_ADD_REMOVE_SUBJECT, _
	TXT_ADD_REMOVE_TAX_TERM, _
	TXT_CODE_ADDED_TO, _
	TXT_CODE_ALREADY_IN, _
	TXT_CODE_NOT_IN, _
	TXT_CODE_REMOVED_FROM, _
	TXT_CONFIRM_DELETE_ALL, _
	TXT_DELETE_ALL, _
	TXT_GENERAL_AREAS_OF_INTEREST, _
	TXT_INACTIVE_CODE, _
	TXT_INST_ADD_AREA_OF_INTEREST, _
	TXT_INST_ADD_HEADING_1, _
	TXT_INST_ADD_HEADING_2, _
	TXT_INST_ADD_NAICS, _
	TXT_INST_ADD_PUB, _
	TXT_INST_ADD_SUBJECT, _
	TXT_INST_ADD_TAX_TERM, _
	TXT_ITEMS, _
	TXT_NO_CODE_CHOSEN, _
	TXT_NO_DELETE_CONFIRMATION, _
	TXT_NOTE_PREVIOUS_SEARCH, _
	TXT_PUBLICATION, _
	TXT_REMOVE_TERM_OPTIONS, _
	TXT_REMOVE_TERM_OPTIONS_IGNORE, _
	TXT_REMOVE_TERM_OPTIONS_INST, _
	TXT_REMOVE_TERM_OPTIONS_REMOVE_LINK, _
	TXT_REMOVE_TERM_OPTIONS_REMOVE_TERM, _
	TXT_RECORDS, _
	TXT_SEPARATE_TILDE, _
	TXT_SYNCHRONIZE_WITH_PUB, _
	TXT_VALUE

Sub setTxtAddRemove()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_ADD_REMOVE = "Add/Remove Code"
			TXT_ADD_REMOVE_AREA_OF_INTEREST = "Add/Remove Area of Interest from selected records"
			TXT_ADD_REMOVE_DISTRIBUTION = "Add/Remove Distribution Code from selected records"
			TXT_ADD_REMOVE_HEADING = "Add/Remove General Heading from selected records"
			TXT_ADD_REMOVE_NAICS = "Add/Remove NAICS code from selected records"
			TXT_ADD_REMOVE_PUBLICATION = "Add/Remove Pub Code from selected records"
			TXT_ADD_REMOVE_SUBJECT = "Add/Remove Subject from selected records"
			TXT_ADD_REMOVE_TAX_TERM = "Add/Remove Taxonomy Term from selected records"
			TXT_CODE_ADDED_TO = "The code(s) were added to"
			TXT_CODE_ALREADY_IN = "If this is not the same as the number of records you selected, the code may have already been in some of the records."
			TXT_CODE_NOT_IN = "If this is not the same as the number of records you selected, the code may not have been in some of the records."
			TXT_CODE_REMOVED_FROM = "The code(s) were removed from"
			TXT_CONFIRM_DELETE_ALL = "I am sure that I wish to remove all values in the selected record(s)"
			TXT_DELETE_ALL = "Delete All Values"
			TXT_GENERAL_AREAS_OF_INTEREST = "General Areas of Interest"
			TXT_INACTIVE_CODE = "The following Code is not Active" & TXT_COLON
			TXT_INST_ADD_AREA_OF_INTEREST = "You must first select a General Area of Interest, then a Specific Area of Interest."
			TXT_INST_ADD_HEADING_1 = "You must first select a publication, then a general heading." & _
				"<br>Headings can only be added to records that already use the selected publication." & _
				"<br>Only publications with headings will be available to choose from."
			TXT_INST_ADD_HEADING_2 = "Taxonomy-based Headings are not included, since they are set automatically based on Taxonomy indexing."
			TXT_INST_ADD_NAICS = "Remember to use a single, 6-digit NAICS code per record whenever possible."
			TXT_INST_ADD_PUB = "Warning: If you remove a publication code from a record, any publication description or general headings associated with that code will also be removed from the record. " & _
				"You may only add or remove publications that are available in the current View."
			TXT_INST_ADD_SUBJECT = "You may only add and remove <em>used</em> subject terms (both Authorized and Local). Unused terms will not be available in the list below. Local terms are marked by *."
			TXT_INST_ADD_TAX_TERM = "You must enter a single valid, active Taxonomy Code to add / remove. You cannot add or remove a set of linked Terms."
			TXT_ITEMS = "Item(s)"
			TXT_NO_CODE_CHOSEN = TXT_ERROR & "No code was chosen to add/remove"
			TXT_NO_DELETE_CONFIRMATION = "Please use the back button to confirm that you wish to delete <em>all</em> values in the selected record(s)."
			TXT_NOTE_PREVIOUS_SEARCH = "Note: This is an exact list of your previous search results, and does not use your search criteria." & _
				"<br>If you want to create a new list of records meeting your criteria, begin a new search."
			TXT_PUBLICATION = "Publication"
			TXT_REMOVE_TERM_OPTIONS = "Remove Term Options"
			TXT_REMOVE_TERM_OPTIONS_IGNORE = "Do not remove the Term(s) from the linked set"
			TXT_REMOVE_TERM_OPTIONS_INST = "If the selected Term(s) are linked to other Terms" & TXT_COLON
			TXT_REMOVE_TERM_OPTIONS_REMOVE_LINK = "Remove the entire linked set that contains the Term(s)"
			TXT_REMOVE_TERM_OPTIONS_REMOVE_TERM = "Remove the Term(s) from the link, but leave the rest of the linked set intact"
			TXT_RECORDS = "records."
			TXT_SEPARATE_TILDE = "Separate linked terms with a tilde (~)"
			TXT_SYNCHRONIZE_WITH_PUB = "Synchronize Headings to the classifications found in" & TXT_COLON
			TXT_VALUE = "Value"
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADD_REMOVE = "Ajouter / Supprimer un code"
			TXT_ADD_REMOVE_AREA_OF_INTEREST = "Ajouter/Supprimer un centre d'intérêt des dossiers sélectionnés"
			TXT_ADD_REMOVE_DISTRIBUTION = "Ajouter / Supprimer un code de distribution pour les dossiers sélectionnés"
			TXT_ADD_REMOVE_HEADING = "Ajouter / Supprimer un en-tête général pour les dossiers sélectionnés"
			TXT_ADD_REMOVE_NAICS = "Ajouter / Supprimer un code SCIAN pour les dossiers sélectionnés"
			TXT_ADD_REMOVE_PUBLICATION = "Ajouter / Supprimer un code de publication pour les dossiers sélectionnés"
			TXT_ADD_REMOVE_SUBJECT = "Ajouter / Supprimer un sujet pour les dossiers sélectionnés"
			TXT_ADD_REMOVE_TAX_TERM = "Ajouter / supprimer un terme de la Taxonomie pour les dossiers sélectionnés"
			TXT_CODE_ADDED_TO = "Le(s) code(s) a été ajouté à"
			TXT_CODE_ALREADY_IN = "Si ceci ne correspond pas au nombre de dossiers que vous avez sélectionnés, il se peut que le code soit déjà associé à certains dossiers."
			TXT_CODE_NOT_IN = "Si ceci ne correspond pas au nombre de dossiers que vous avez sélectionnés, il se peut que le code ne soit pas associé à certains dossiers."
			TXT_CODE_REMOVED_FROM = "Le(s) code(s) a été supprimé de"
			TXT_CONFIRM_DELETE_ALL = "Je confirme que je souhaite supprimer toutes les valeurs dans les dossiers sélectionnés"
			TXT_DELETE_ALL = "Supprimer toutes les valeurs"
			TXT_GENERAL_AREAS_OF_INTEREST = "Secteurs d'intérêt général"
			TXT_INACTIVE_CODE = "Le code suivant est inactif" & TXT_COLON
			TXT_INST_ADD_AREA_OF_INTEREST = "Vous devez d'abord sélectionner un centre d'intérêt général, puis un centre d'intérêt spécifique."
			TXT_INST_ADD_HEADING_1 = "Vous devez d'abord sélectionner une publication, puis un en-tête général." & _
				"<br>Les en-têtes ne peuvent être ajoutés qu'aux dossiers qui utilisent déjà la publication sélectionnée." & _
				"<br>Seules les publications avec des en-têtes peuvent être sélectionnées."
			TXT_INST_ADD_HEADING_2 = "Les en-têtes basés sur la Taxonomie ne sont pas inclus, car ils sont déterminés automatiquement selon l'indexation taxonomique."
			TXT_INST_ADD_NAICS = "Pensez à utiliser un code SCIAN unique à 6 chiffres par dossier quand c'est possible."
			TXT_INST_ADD_PUB = "Attention : si vous supprimez un code de publication dans un dossier, toute description de publication ou en-têtes généraux qui lui sont associés seront aussi supprimés. " & _
				"Seules les publications disponibles dans la vue actuelle peuvent être ajoutées ou retirées."
			TXT_INST_ADD_SUBJECT = "Seuls les sujets qui sont <em>utilisés</em> peuvent être ajoutés ou supprimés (qu'ils soient autorisés ou locaux). Les sujets non utilisés ne seront pas disponibles dans la liste ci-dessous. Les sujets locaux sont identifiés par un astérisque ( * )."
			TXT_INST_ADD_TAX_TERM = "Vous devez saisir un code de la Taxonomie unique, valide et actif à ajouter / supprimer. Vous ne pouvez ajouter ou supprimer un ensemble de termes en relation."
			TXT_ITEMS = "Article(s)"
			TXT_NO_CODE_CHOSEN = TXT_ERROR & "Aucun code à ajouter / supprimer n'a été selectionné."
			TXT_NO_DELETE_CONFIRMATION = "Veuillez utiliser le bouton retour pour confirmer que vous souhaitez supprimer <em>toutes</em> les valeurs dans les dossiers sélectionnés."
			TXT_NOTE_PREVIOUS_SEARCH = "Remarque : ceci est une liste exacte des résultats de votre recherche précédente, sans tenir compte de vos critères de recherche." & _
				"<br>Si vous désirez établir une nouvelle liste de dossiers basée sur vos critères, effectuez une nouvelle recherche."
			TXT_PUBLICATION = "Publication"
			TXT_REMOVE_TERM_OPTIONS = "Options pour retirer des termes"
			TXT_REMOVE_TERM_OPTIONS_IGNORE = "Ne pas retirer le terme de l'ensemble de relations"
			TXT_REMOVE_TERM_OPTIONS_INST = "Si les termes sélectionnés sont liés à d'autres termes" & TXT_COLON
			TXT_REMOVE_TERM_OPTIONS_REMOVE_LINK = "Retirer tout l'ensemble de relations contenant le(s) terme(s)"
			TXT_REMOVE_TERM_OPTIONS_REMOVE_TERM = "Retirer le(s) terme(s) de la relation, mais laisser le reste de l'ensemble intact"
			TXT_RECORDS = "dossiers."
			TXT_SEPARATE_TILDE = "Séparer les termes dans un ensemble de termes en relation par un tilde (~)"
			TXT_SYNCHRONIZE_WITH_PUB = "Synchroniser les en-têtes des classifications trouvées dans" & TXT_COLON
			TXT_VALUE = "Valeur"
	End Select
End Sub

Call setTxtAddRemove()

%>
