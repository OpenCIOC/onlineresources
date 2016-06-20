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
Dim TXT_MAIL_FORM, _
	TXT_RECORD_DETAILS, _
	TXT_RECORD_NOT_AVAILABLE_LANGUAGE, _
	TXT_UPDATE_PUBS, _
	TXT_UPDATE_TAXONOMY, _
	TXT_UPDATE_RECORD

Sub setTxtRecordPages()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_MAIL_FORM = "Expédier&nbsp;le&nbsp;formulaire par&nbsp;la&nbsp;poste"
			TXT_RECORD_DETAILS = "Renseignements sur le dossier"
			TXT_RECORD_NOT_AVAILABLE_LANGUAGE = "Ce dossier n'est pas disponible dans la langue sélectionnée."
			TXT_UPDATE_PUBS = "Mettre&nbsp;à&nbsp;jour les&nbsp;publications"
			TXT_UPDATE_RECORD = "Mettre&nbsp;à&nbsp;jour le&nbsp;dossier"
			TXT_UPDATE_TAXONOMY = "Mettre à jour les catégories de services"
		Case Else
			TXT_MAIL_FORM = "Mail&nbsp;Form"
			TXT_RECORD_DETAILS = "Record Details"
			TXT_RECORD_NOT_AVAILABLE_LANGUAGE = "This record is not available in the selected language."
			TXT_UPDATE_PUBS = "Update Publications"
			TXT_UPDATE_RECORD = "Update&nbsp;Record"
			TXT_UPDATE_TAXONOMY = "Update&nbsp;Service&nbsp;Categories"
	End Select
End Sub

Call setTxtRecordPages()
%>
