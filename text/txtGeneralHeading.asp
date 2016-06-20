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
Dim	TXT_CHOOSE_PUB, _
	TXT_COPY_HEADINGS_FROM, _
	TXT_INST_COPY_HEADINGS, _
	TXT_RETURN_PUBLICATION, _
	TXT_RETURN_PUBS, _
	TXT_UPDATE_HEADING_FAILED

Sub setTxtGeneralHeading()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_CHOOSE_PUB = "Choose a Publication from the list below or add a new Publication."
			TXT_COPY_HEADINGS_FROM = "Copy General Headings from" & TXT_COLON
			TXT_INST_COPY_HEADINGS = "Use this tool topy <em>Used</em> General Headings from one Publication to another. " & _
				"This tool will copy the English and French names, but not Related Term informaton. " & _
				"You may not re-add or update a heading that already has a matching name in the target Publication, even if it is not a &quot;Used&quot; Heading. " & _
				"<span class=""Alert"">Please be aware that any future changes you make to these Headings will not be reflected in the copies</span>."
			TXT_RETURN_PUBS = "Return to Publications"
			TXT_RETURN_PUBLICATION = "Return to Publication" & TXT_COLON
			TXT_UPDATE_HEADING_FAILED = "Update General Heading Failed"
		Case CULTURE_FRENCH_CANADIAN
			TXT_CHOOSE_PUB = "Sélectionner une publication dans la liste ci-dessous ou ajouter une nouvelle publication."
			TXT_COPY_HEADINGS_FROM = "Copier l'en-tête général depuis" & TXT_COLON
			TXT_INST_COPY_HEADINGS = "Utilisez cet outil pour copier des en-têtes généraux <em>utilisés</em> dans une publication vers une autre. " & _
				"Cet outil copiera les noms français et anglais, mais pas les renseignements sur les termes associés. " & _
				"Les en-têtes sont mis en correspondance en fonction du nom anglais uniquement ; vous ne pouvez ni créer, ni mettre à jour un en-tête qui possède déjà un nom anglais correspondant dans la publication cible, même si l'en-tête n'est pas &quot;utilisé&quot;. " & _
				"<span class=""Alert"">Soyez conscient que tout changement effectué à ces en-têtes dans le futur ne sera pas appliqué aux copies</span>."
			TXT_RETURN_PUBLICATION = "Retourner à la publication" & TXT_COLON
			TXT_RETURN_PUBS = "Retourner aux publications"
			TXT_UPDATE_HEADING_FAILED = "La mise à jour de l'en-tête général a échoué."
	End Select
End Sub

Call setTxtGeneralHeading()
%>
