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
Dim TXT_INVALID_EMAIL, _
	TXT_INVALID_DATE_FORMAT, _
	TXT_INVALID_POSTAL_CODE, _
	TXT_INVALID_WEBSITE, _
	TXT_MUST_BE_A_NUMBER, _
	TXT_NOT_VALID_ID_FOR_FIELD, _
	TXT_TOO_LONG_1, _
	TXT_TOO_LONG_2

Sub setTxtFormDataCheck()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_INVALID_EMAIL = " does not contain a valid Email address (e.g. foo@bar.com or foo@bar.com,joe@smith.com for multiple addresses)."
			TXT_INVALID_DATE_FORMAT = " is not in an acceptable date format (e.g. " & DateString(Date(),True) & ") or is out of range. Dates must be between "
			TXT_INVALID_POSTAL_CODE = " is not a valid postal or zip code. (e.g. X2X 2X2, 12345, 12345-1234)"
			TXT_INVALID_WEBSITE = " does not contain a valid website address (e.g. www.mysite.com)."
			TXT_MUST_BE_A_NUMBER = " must be a positive number."
			TXT_NOT_VALID_ID_FOR_FIELD = " is not a valid ID for the field" & TXT_COLON
			TXT_TOO_LONG_1 = " is longer than the maximum length of "
			TXT_TOO_LONG_2 = " characters."
		Case CULTURE_FRENCH_CANADIAN
			TXT_INVALID_EMAIL = " ne contient pas une adresse de courriel valide (par exemple, foo@bar.com ou foo@bar.com,joe@smith.com pour adresses multiples)."
			TXT_INVALID_DATE_FORMAT = " n'est pas un formatage de date acceptable (par exemple, 21-mars-2004) ou la date est en dehors de la gamme. Les dates doivent être entre "
			TXT_INVALID_POSTAL_CODE = " n'est pas un code postal ou un code zip valide (par exemple, X2X 2X2, 12345, 12345-1234)."
			TXT_INVALID_WEBSITE = " ne contient pas une adresse Web valide (par exemple, www.mysite.com)."
			TXT_MUST_BE_A_NUMBER = " doit être un nombre positif."
			TXT_NOT_VALID_ID_FOR_FIELD = " n'est pas un identificateur valide pour le champ" & TXT_COLON
			TXT_TOO_LONG_1 = " est plus que la longueur maximale de "
			TXT_TOO_LONG_2 = " caractères."
	End Select
End Sub

Call setTxtFormDataCheck()
Call addTextFile("setTxtFormDataCheck")
%>
