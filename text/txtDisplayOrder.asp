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
Dim TXT_DISPLAY_ORDER_BETWEEN, _
	TXT_DISPLAY_ORDER_NULL

Sub setTxtDisplayOrder()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_ENGLISH_CANADIAN
			TXT_DISPLAY_ORDER_BETWEEN = "Display Order must be a number between 0 and "
			TXT_DISPLAY_ORDER_NULL = "Display Order cannot be NULL"
		Case CULTURE_FRENCH_CANADIAN
			TXT_DISPLAY_ORDER_BETWEEN = "L'ordre d'affichage doit être un nombre entre 0 et "
			TXT_DISPLAY_ORDER_NULL = "L'ordre d'affichage ne peut pas être NUL."
	End Select
End Sub

Call setTxtDisplayOrder()
%>
