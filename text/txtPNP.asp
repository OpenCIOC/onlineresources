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
Dim TXT_NONPUBLIC_STATUS_SET_IN, _
	TXT_NOTE_PREVIOUS_SEARCH, _
	TXT_PUBLIC_STATUS_SET_IN, _
	TXT_RECORDS, _
	TXT_SET_ALREADY, _
	TXT_SET_NONPUBLIC, _
	TXT_SET_PUBLIC

Sub setTxtPNP()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_NONPUBLIC_STATUS_SET_IN = "Non-public status has been set in "
			TXT_NOTE_PREVIOUS_SEARCH = "Note: This is an exact list of your previous search results, and does not use your search criteria." & _
				"<br>If you want to create a new list of records meeting your criteria, begin a new search."
			TXT_PUBLIC_STATUS_SET_IN = "Public status has been set in "
			TXT_RECORDS = "records."
			TXT_SET_ALREADY = "If this is not the same as the number of records you selected, the status may have already been set in some records."
			TXT_SET_NONPUBLIC = "Set Records Non-Public"
			TXT_SET_PUBLIC = "Set Records Public"
		Case CULTURE_FRENCH_CANADIAN
			'CHECK BELOW
			TXT_NONPUBLIC_STATUS_SET_IN = "Le statut interne a été attribué dans "
			TXT_NOTE_PREVIOUS_SEARCH = "Note : ceci est une liste exhaustive des résultats de votre précédente recherche, sans tenir compte de vos critères de recherche." & _
				"<br>Si vous désirez établir une nouvelle liste de dossiers basée sur vos critères, effectuez une nouvelle recherche."
			'CHECK BELOW
			TXT_PUBLIC_STATUS_SET_IN = "Le statut public a été attribué dans "
			TXT_RECORDS = "dossiers."
			'CHECK BELOW
			TXT_SET_ALREADY = "Si vous n'avez pas le même nombre de dossiers que ce que vous avez sélectionnés, il se peut que le statut de certains dossiers soit déjà établi."
			'CHECK BELOW
			TXT_SET_NONPUBLIC = "Fixer les dossiers pour usage interne."
			'CHECK BELOW
			TXT_SET_PUBLIC = "Fixer les dossiers pour qu'ils soient accessibles au grand public."
	End Select
End Sub

Call setTxtPNP()

%>
