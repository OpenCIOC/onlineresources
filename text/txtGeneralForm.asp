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
Dim TXT_CLEAR_FORM, _
	TXT_FULL_UPDATE, _
	TXT_HOLD_CTRL, _
	TXT_HTML_ALLOWED, _
	TXT_INST_FRENCH, _
	TXT_INST_MAX_500, _
	TXT_INST_MAX_2000, _
	TXT_INST_MAX_4000, _
	TXT_INST_MAX_8000, _
	TXT_INST_MAX_30000, _
	TXT_INST_NUM_FINDER, _
	TXT_RESET, _
	TXT_RESET_FORM, _
	TXT_SEPARATE_SEMICOLON, _
	TXT_SET_AUTOMATICALLY, _
	TXT_SUBMIT, _
	TXT_SUBMIT_UPDATES

Sub setTxtGeneralForm()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_CLEAR_FORM = "Effacer"
			TXT_FULL_UPDATE = "Mise à jour complète"
			TXT_HOLD_CTRL  = "Maintenir la touche CTRL enfoncée pour sélectionner ou dessélectionner plusieurs articles à la fois."
			TXT_HTML_ALLOWED = "HTML est permis."
			TXT_INST_FRENCH = "Comme ci-dessus, à utiliser pour visualiser la base de données en français."
			TXT_INST_MAX_500 = "Maximum de 500 caractères."
			TXT_INST_MAX_2000 = "Maximum de 2 000 caractères."
			TXT_INST_MAX_4000 = "Maximum de 4 000 caractères."
			TXT_INST_MAX_8000 = "Maximum de 8 000 caractères."
			TXT_INST_MAX_30000 = "Maximum de 30 000 caractères."
			TXT_INST_NUM_FINDER = "Vous ne connaissez pas le no. de dossier ? Utilisez le <a href=""javascript:openWinL('" & makeLinkB(ps_strPathToStart & "orgfind.asp") & "','oFind')"">Localisateur de no de dossier des agences</a>."
			TXT_RESET = "Effacer"
			TXT_RESET_FORM = "Effacer"
			TXT_SEPARATE_SEMICOLON = "Séparer par un point-virgule (;)"
			TXT_SET_AUTOMATICALLY = "Inscrit automatiquement"
			TXT_SUBMIT = "Soumettre"
			TXT_SUBMIT_UPDATES = "Soumettre"
		Case Else
			TXT_CLEAR_FORM = "Clear&nbsp;Form"
			TXT_FULL_UPDATE = "Full&nbsp;Update"
			TXT_HOLD_CTRL  = "Hold CTRL to select/deselect multiple items"
			TXT_HTML_ALLOWED = "HTML is allowed."
			TXT_INST_FRENCH = "As above, to be used when viewing the database in French."
			TXT_INST_MAX_500 = "Maximum 500 characters."
			TXT_INST_MAX_2000 = "Maximum 2000 characters."
			TXT_INST_MAX_4000 = "Maximum 4000 characters."
			TXT_INST_MAX_8000 = "Maximum 8000 characters."
			TXT_INST_MAX_30000 = "Maximum 30000 characters."
			TXT_INST_NUM_FINDER = "Don't know the Record #? Use the <a href=""javascript:openWinL('" & makeLinkB(ps_strPathToStart & "orgfind.asp") & "','oFind')"">Organization Record # Finder</a>."
			TXT_RESET = "Reset"
			TXT_RESET_FORM = "Reset Form"
			TXT_SEPARATE_SEMICOLON = "Separate with semi-colon (;)"
			TXT_SET_AUTOMATICALLY = "set automatically"
			TXT_SUBMIT = "Submit"
			TXT_SUBMIT_UPDATES = "Submit Updates"
	End Select
End Sub

Call setTxtGeneralForm()
Call addTextFile("setTxtGeneralForm")
%>
