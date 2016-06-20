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
Function checkDate(strFldName,ByRef strFldVal)
	Dim bRetval
	bRetval = True
	If Not Nl(strFldVal) Then
		If Not IsSmallDate(strFldVal) Then
			strErrorList = strErrorList & "<li>" & _
				strFldName & TXT_INVALID_DATE_FORMAT & DateString(MIN_SMALL_DATE,True) & TXT_AND_LC & DateString(MAX_SMALL_DATE,True) & ".</li>"
			bRetval = False
		Else
			strFldVal = DateString(strFldVal,False)
		End If
	End If
	checkDate = bRetval
End Function

Sub checkDouble(strFldName,strFldVal)
	If Not Nl(strFldVal) Then
		If Not IsNumeric(strFldVal) Then
			strErrorList = strErrorList & "<li>" & strFldName & TXT_MUST_BE_A_NUMBER & "</li>"
		Else
			strFldVal = CDbl(strFldVal)
			If strFldVal < 0 Then
				strErrorList = strErrorList & "<li>" & strFldName & TXT_MUST_BE_A_NUMBER & "</li>"	
			End If
		End If
	End If
End Sub

Sub checkInteger(strFldName,strFldVal)
	If Not Nl(strFldVal) Then
		If Not IsNumeric(strFldVal) Then
			strErrorList = strErrorList & "<li>" & strFldName & TXT_MUST_BE_A_NUMBER & "</li>"
		Else
			strFldVal = CInt(strFldVal)
			If strFldVal < 0 Then
				strErrorList = strErrorList & "<li>" & strFldName & TXT_MUST_BE_A_NUMBER & "</li>"		
			End If
		End If
	End If
End Sub

Sub checkNUM(strFldName,strFldVal)
	If Not Nl(strFldVal) Then
		If Not IsNUMType(strFldVal) Then
			strErrorList = strErrorList & "<li>" & strFldVal & TXT_NOT_VALID_ID_FOR_FIELD & strFldName & "</li>"
		End If
	End If
End Sub

Sub checkID(strFldName,strFldVal)
	If Not Nl(strFldVal) Then
		If Not IsIDType(strFldVal) Then
			strErrorList = strErrorList & "<li>" & strFldVal & TXT_NOT_VALID_ID_FOR_FIELD & strFldName & "</li>"
		End If
	End If
End Sub

Sub checkPostalCode(strFldName, ByRef strFldVal)
	If Not Nl(strFldVal) Then
		If reEquals(strFldVal, "[A-Z]\d[A-Z]\d[A-Z]\d", True, False, True, False) Then
			strFldVal = reReplace(strFldVal, "([A-Z]\d[A-Z])(\d[A-Z]\d)", "$1 $2", True, False, False, False)
		End If
		If Not reEquals(strFldVal,"([A-Z]\d[A-Z] \d[A-Z]\d)|(\d{5}(( |-)\d{4})?)",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & strFldName & TXT_INVALID_POSTAL_CODE & "</li>"
		End If
	End If
End Sub

'Const strOneEmailAddressRegex = "([A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*@[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*)"
Const strOneEmailAddressRegex = "[^@\s,]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}"
Sub checkOneEmail(strFldName,strFldVal)
	If Not Nl(strFldVal) Then
		If Not reEquals(strFldVal,strOneEmailAddressRegex,True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & strFldName & TXT_INVALID_EMAIL & "</li>"	
		End If
	End If
End Sub

Sub checkEmail(strFldName, strFldVal)
	If Not Nl(strFldVal) Then
		If Not reEquals(strFldVal,"(" & strOneEmailAddressRegex & "(\s*,*\s*))*",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & strFldName & TXT_INVALID_EMAIL & "</li>"	
		End If
	End If
End Sub

Sub checkWeb(strFldName,strFldVal)
	If Not Nl(strFldVal) Then
		If Not reEquals(strFldVal,"^(\d{1,3}(\.\d{1,3}){3})|([\w_-]+(\.[\w\._-]+)*)(:[0-9]+)?((\/|\?)[^\s]*)?$",True,False,True,False) Then
			strErrorList = strErrorList & "<li>" & strFldName & TXT_INVALID_WEBSITE & "</li>"	
		End If
	End If
End Sub

Sub checkWebWithProtocol(strFldName, ByRef strFldVal, ByRef strFldProtocol)
	strFldProtocol = vbNullString
	If Not Nl(strFldVal) Then
		strFldProtocol = "http://"
		If LCase(Left(strFldVal, 7)) = "http://" Then
			strFldVal = Mid(strFldVal, 8) 
		ElseIf LCase(Left(strFldVal, 8)) = "https://" Then
			strFldProtocol = "https://"
			strFldVal = Mid(strFldVal, 9) 
		End If
		Call checkWeb(strFldName, strFldVal)
	End If
End Sub

Sub checkLength(strFldName,strFldVal,intMaxLength)
	If Not Nl(strFldVal) And Not Nl(intMaxLength) Then
		If Len(strFldVal) > intMaxLength Then
			strErrorList = strErrorList & "<li>" & _
				strFldName & _
				TXT_TOO_LONG_1 & _
				intMaxLength & _
				TXT_TOO_LONG_2 & "</li>"
		End If
	End If
End Sub

Sub checkAddValidationError(strErrMsg)
	strErrorList = strErrorList & "<li>" & strErrMsg & "</li>"
End Sub

%>
