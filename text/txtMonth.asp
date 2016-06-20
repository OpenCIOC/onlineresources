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

Dim TXT_JANUARY, _
	TXT_FEBRUARY, _
	TXT_MARCH, _
	TXT_APRIL, _
	TXT_MAY, _
	TXT_JUNE, _
	TXT_JULY, _
	TXT_AUGUST, _
	TXT_SEPTEMBER, _
	TXT_OCTOBER, _
	TXT_NOVEMBER, _
	TXT_DECEMBER

Sub setTxtMonth()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			TXT_JANUARY = "janvier"
			TXT_FEBRUARY = "février"
			TXT_MARCH = "mars"
			TXT_APRIL = "avril"
			TXT_MAY = "mai"
			TXT_JUNE = "juin"
			TXT_JULY = "juillet"
			TXT_AUGUST = "août"
			TXT_SEPTEMBER = "septembre"
			TXT_OCTOBER = "octobre"
			TXT_NOVEMBER = "novembre"
			TXT_DECEMBER = "décembre"
		Case Else
			TXT_JANUARY = "January"
			TXT_FEBRUARY = "February"
			TXT_MARCH = "March"
			TXT_APRIL = "April"
			TXT_MAY = "May"
			TXT_JUNE = "June"
			TXT_JULY = "July"
			TXT_AUGUST = "August"
			TXT_SEPTEMBER = "September"
			TXT_OCTOBER = "October"
			TXT_NOVEMBER = "November"
			TXT_DECEMBER = "December"
	End Select
End Sub

Call setTxtMonth()
Call addTextFile("setTxtMonth")
%>
