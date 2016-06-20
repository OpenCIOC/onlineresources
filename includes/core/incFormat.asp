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
Const SERIF_FONT = "Times, 'Times New Roman', Georgia, serif"
Const SANS_SERIF_FONT = "Geneva, Arial, Helvetica, sans-serif"

Const DATE_TEXT_SIZE = 25
Const TEXT_SIZE = 85
Const TEXTAREA_COLS = 85
Const TEXTAREA_ROWS_SHORT = 2
Const TEXTAREA_ROWS_LONG = 4
Const TEXTAREA_ROWS_XLONG = 10
Const MAX_LENGTH_CHECKLIST_NOTES = 255

Function getTextAreaRows(intLengthOfField,intSuggestedLength)
	If Nl(intLengthOfField) Then
		intLengthOfField = 0
	ElseIf Not IsNumeric(intLengthOfField) Then
		intLengthOfField = 0
	End If
	
	If Nl(intSuggestedLength) Then
		intSuggestedLength = 0
	ElseIf Not IsNumeric(intLengthOfField) Then
		intSuggestedLength = 0
	End If

	If intLengthOfField > 0 Then
		getTextAreaRows = (intLengthOfField\(TEXTAREA_COLS-20)) + TEXTAREA_ROWS_SHORT
	ElseIf intSuggestedLength > 0 Then
		getTextAreaRows = intSuggestedLength
	Else
		getTextAreaRows = TEXTAREA_ROWS_LONG
	End If
End Function

Function textToHTML(strText)
	If Not Nl(strText) Then
		If Not reEquals(strText,"(<br>)|(<p>)|(<a\s+href)|(<b>)|(<strong>)|(<i>)|(<em>)|(<li>)|(<img\s+)|(<table\s+)|(&nbsp;)|(&amp;)|(h[1-6]>)|(<span[\s>])|(<div[\s>])",True,False,False,False) Then
			textToHTML = Replace(Replace(Replace(Server.HTMLEncode(strText),vbCrLf,"&nbsp;<br>"),vbLf,"&nbsp;<br>"),vbCr,"&nbsp;<br>")
		ElseIf Not reEquals(strText,"(<br>)|(<p>)",True,False,False,False) Then
			textToHTML = Replace(Replace(Replace(strText,vbCrLf,"&nbsp;<br>"),vbLf,"&nbsp;<br>"),vbCr,"&nbsp;<br>")
		Else
			textToHTML = strText
		End If
	Else
		textToHTML = vbNullString
	End If
End Function

Function DateString(dDate,bAbbrev)
	Dim strDay, strMonth, strMonthName, strYear, strDate
	If Not Nl(dDate) Then
		If IsDate(dDate) Then
			strDay = Day(dDate)
			strMonth = Month(dDate)
			strMonthName = MonthName(strMonth,bAbbrev)
			strYear = Year(dDate)
			Select Case Application(g_objCurrentLang.Culture & "_DateFormatCode")
				Case 103
					strDate = strDay & "/" & strMonth & "/" & strYear
				Case 104
					strDate = strDay & "." & strMonth & "." & strYear
				Case 105
					strDate = strDay & "-" & strMonth & "-" & strYear
				Case 107
					strDate = strMonthName & " " & strDay & ", " & strYear
				Case 111
					strDate = strYear & "/" & strMonth & "/" & strDay
				Case Else
					strDate = strDay & " " & strMonthName & " " & strYear
			End Select
			DateString = strDate
		Else
			DateString = dDate
		End If
	Else
		DateString = Null
	End If
End Function

Function DateTimeString(dDate,bAbbrev)
	If Not Nl(dDate) Then
		If IsDate(dDate) Then
			DateTimeString = DateString(dDate,bAbbrev) & " " & TimeValue(dDate)
		Else
			DateTimeString = dDate
		End If
	Else
		DateTimeString = Null
	End If
End Function

Function DateStringFromXML(dDateTime, bAbbrev)
	If Not Nl(dDateTime) Then
		Dim dDate
		dDate = Left(dDateTime, 10)
		DateStringFromXML = DateString(dDate, bAbbrev)
	Else
		DateStringFromXML = Null
	End If
End Function

Function DateTimeStringFromXML(dDateTime, bAbbrev)
	If Not Nl(dDateTime) Then
		Dim dDate, dTime
		dDate = Left(dDateTime, 10)
		dTime = Right(dDateTime, 8)
		DateTimeStringFromXML = DateTimeString(dDate & " " & dTime, bAbbrev)
	Else
		DateTimeStringFromXML = Null
	End If
End Function

Function ISODateString(dDate)
	Dim intDay, intMonth, intYear, strDate
	If Not Nl(dDate) Then
		If IsDate(dDate) Then
			intDay = Day(dDate)
			intMonth =Month(dDate)
			intYear = Year(dDate)
			strDate = intYear & "-" & _
						Right(Cstr(intMonth + 100),2) & "-" & _
						Right(Cstr(intDay+100), 2)
			ISODateString = strDate
		Else
			ISODateString = dDate
		End If
	Else
		ISODateString = Null
	End If
End Function

Function ISOTimeString(dDate)
	Dim tTime, intHour, intMinute, intSecond
	If Not Nl(dDate) Then
		If IsDate(dDate) Then
			tTime = TimeValue(dDate)
			intHour = Hour(tTime)
			intMinute = Minute(tTime)
			intSecond = Second(tTime)
			ISOTimeString = Right(Cstr(intHour + 100), 2) & ":" & _
							Right(Cstr(intMinute + 100), 2) & ":" & _
							Right(Cstr(intSecond + 100), 2)
		Else
			ISOTimeString = dDate
		End If
	Else
		ISOTimeString = Null
	End If
End Function

Function ISODateTimeString(dDate)
	Dim intDay, intMonth, intYear, strDate
	If Not Nl(dDate) Then
		If IsDate(dDate) Then
			intDay = Day(dDate)
			intMonth =Month(dDate)
			intYear = Year(dDate)
			strDate = intYear & "-" & _
						Right(Cstr(intMonth + 100),2) & "-" & _
						Right(Cstr(intDay+100), 2)
			ISODateString = strDate
		Else
			ISODateString = dDate
		End If
	Else
		ISODateString = Null
	End If
End Function

Function ISODateTimeString(dDate)
	If Not Nl(dDate) Then
		If IsDate(dDate) Then
			ISODateTimeString = ISODateString(dDate) & " " & ISOTimeString(dDate)
		Else
			ISODateTimeString = dDate
		End If
	Else
		ISODateTimeString = Null
	End If
End Function

Function ISODateTimeStringSQL(dDate)
	If Not Nl(dDate) Then
		If IsDate(dDate) Then
			ISODateTimeStringSQL = ISODateString(dDate) & "T" & ISOTimeString(dDate)
		Else
			ISODateTimeStringSQL = dDate
		End If
	Else
		ISODateTimeStringSQL = Null
	End If
End Function
%>
