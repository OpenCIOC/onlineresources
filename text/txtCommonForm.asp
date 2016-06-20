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
Dim TXT_ADDRESS, _
	TXT_EXT, _
	TXT_FAX, _
	TXT_NUMBER, _
	TXT_OPTION, _
	TXT_OPTIONAL, _
	TXT_PHONE, _
	TXT_PLEASE_CALL_FIRST, _
	TXT_TITLE, _
	TXT_TYPE

Sub setTxtCommonForm()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_ADDRESS = "Adresse"
			TXT_EXT = "Poste"
			TXT_FAX = "Télécopieur"
			TXT_NUMBER = "Numéro"
			TXT_OPTIONAL = "(facultatif)"
			TXT_OPTION = "Option"
			TXT_PHONE = "Téléphone"
			TXT_PLEASE_CALL_FIRST = "Veuillez appeler avant"
			TXT_TITLE = "Titre"
			TXT_TYPE = "Type"
		Case Else
			TXT_ADDRESS = "Address"
			TXT_EXT = "Ext"
			TXT_FAX = "Fax"
			TXT_NUMBER = "Number"
			TXT_OPTION = "Option"
			TXT_OPTIONAL = "(optional)"
			TXT_PHONE = "Phone"
			TXT_PLEASE_CALL_FIRST = "Please call first"
			TXT_TITLE = "Title"
			TXT_TYPE = "Type"
	End Select
End Sub

Call setTxtCommonForm()
Call addTextFile("setTxtCommonForm")
%>
