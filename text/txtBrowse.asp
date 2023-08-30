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
Dim TXT_BROWSE_BY_ORG, _
	TXT_BROWSE_BY_ORG_TITLE, _
	TXT_BROWSE_BY_SUBJECT_TITLE, _
	TXT_BROWSE_BY_AREA_OF_INTEREST, _
	TXT_BROWSE_BUSINESS_USING, _
	TXT_BROWSE_ORG_W_OPS, _
	TXT_SELECT_LETTER, _
	TXT_SHOW_ALL, _
	TXT_ZERO_COUNT

Sub setTxtBrowse()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_BROWSE_BY_ORG = "Browse by Organization"
			TXT_BROWSE_BY_ORG_TITLE = "Browse by Organization"
			TXT_BROWSE_BY_SUBJECT_TITLE = "Browse by Subject"
			TXT_BROWSE_BY_AREA_OF_INTEREST = "Browse by Area of Interest"
			TXT_BROWSE_BUSINESS_USING = "Browse for a Business / Organization using the "
			TXT_BROWSE_ORG_W_OPS = "Browse Organizations with Opportunities"
			TXT_SELECT_LETTER = "Select a Letter" & TXT_COLON
			TXT_SHOW_ALL = "Show All"
			TXT_ZERO_COUNT = "<strong>Note</strong>: Some subjects may have a zero (0) count. By clicking on them you may be led to related subjects to which records are attached."
		Case CULTURE_FRENCH_CANADIAN
			TXT_BROWSE_BY_ORG = "Explorer par organisme"
			TXT_BROWSE_BY_ORG_TITLE = "Exploration par organisme"
			TXT_BROWSE_BY_SUBJECT_TITLE = "Exploration par sujet"
			TXT_BROWSE_BY_AREA_OF_INTEREST = "Explorer par centre d'intérêt"
			TXT_BROWSE_BUSINESS_USING = "Chercher une entreprise ou un organisme en utilisant "
			TXT_BROWSE_ORG_W_OPS = "Explorer les organismes offrant des possibilités de bénévolat"
			TXT_SELECT_LETTER = "Choisir une lettre" & TXT_COLON
			TXT_SHOW_ALL = "Afficher tout"
			TXT_ZERO_COUNT = "<strong>Avis</strong> : Certains sujets peuvent n'afficher aucun résultat. En les sélectionnant, vous pourriez toutefois être dirigé vers des sujets connexes possédant des dossiers."
	End Select
End Sub

Call setTxtBrowse()
%>
