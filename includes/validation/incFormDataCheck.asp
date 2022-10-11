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
<script language="python" runat="server">
import re
from datetime import time

from cioc.core.i18n import gettext

_ = lambda x: gettext(x, pyrequest)
time_re = re.compile(r'''(?P<hour>\d?\d):(?P<minute>\d\d)(:(?P<second>\d\d))?(\s*(?P<ampm>(pm|p\.m\.|am|a\.m\.)))?''')

def check_time(label, value, checkAddValidationError=None):
	label = label + _(': ')
	if value is None:
		return
	if not value.strip():
		return

	time_match = time_re.search(value.lower())
	if time_match is None:
		checkAddValidationError(label + _('Invalid Time'))
		return None

	hour = time_match.group('hour')
	minute = time_match.group('minute')
	second = time_match.group('second')
	ampm = time_match.group('ampm')
	# log.debug('AMPM: %s', ampm)
	if ampm is None:
		ampm = ''

	hour = int(hour, 10)
	minute = int(minute, 10)
	if second is None:
		second = '0'
	second = int(second, 10)

	if hour < 0:
		checkAddValidationError(label + _('Hour is not valid'))
		return None

	# includes a time
	if hour < 12 and ampm.replace('.', '').lower() == 'pm':
		# log.debug("PM bump up 12 hours")
		hour += 12

	elif hour == 12 and ampm.replace('.', '').lower() == 'am':
		# log.debug("AM and 12, make 0")
		hour = 0

	if hour > 23:
		checkAddValidationError(label + _('Hour is not valid'))
		return None

	if 0 > minute or minute > 59:
		checkAddValidationError(label + _('Minute is not valid'))
		return None

	if 0 > second or second > 59:
		checkAddValidationError(label + _('Second is not valid'))
		return None

	value = time(hour, minute, second)
	return value
</script>

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
Const strOneEmailAddressRegex = "[^@\s,]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,63}"
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
