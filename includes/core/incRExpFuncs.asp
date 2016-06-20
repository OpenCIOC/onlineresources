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
Function reFormatStr(ByVal str1)
	Dim badChars, badChar
	If Not Nl(str1) Then
		badChars = Array("\","/","[","]",".","*","(",")","?","+","^")
		For Each badChar in badChars
			str1 = Replace(str1, badChar, "\" & badChar)
		Next
	End If
	str1 = Replace(str1,vbCrLf,"(\n)|(\r\n)")
	str1 = Replace(str1,vbCr,"\r")
	str1 = Replace(str1,vbLf,"\f")
	reFormatStr = str1
End Function

Function reFormatIgnoreSpace(str1)
	Dim rExp
	Set rExp = New RegExp

	If Not Nl(str1) Then	
		rExp.Global = True
		rExp.Pattern = "\s+"
		reFormatIgnoreSpace = "\s*" & rExp.Replace(str1, "\s+") & "\s*"
	Else
		reFormatIgnoreSpace = vbNullString
	End If
End Function

Function reEquals(ByVal str1, ByVal str2, ByVal bIgnoreCase, ByVal bIgnoreSpace, ByVal bWholeField, ByVal reFormat)
	Dim rExp, strPattern
	Set rExp = New RegExp

	If reFormat Then
		strPattern = strPattern & reFormatStr(str2)
	Else
		strPattern = strPattern & str2
	End If
	If bIgnoreSpace Then
		strPattern = reFormatIgnoreSpace(strPattern)
	End If
	If bWholeField Then
		strPattern = "^(" & strPattern & ")$"
	End If

	rExp.IgnoreCase = bIgnoreCase
	rExp.Global = False
	rExp.Pattern = strPattern

	If Not Nl(str1) Then
		reEquals = rExp.Test(str1)
	Else
		reEquals = False
	End If
End Function

Function reReplace(ByVal str1, ByVal str2, ByVal str3, ByVal bIgnoreCase, ByVal bIgnoreSpace, ByVal bGlobal, ByVal reFormat)
	Dim rExp, strPattern
	Set rExp = New RegExp

	If Not Nl(str1) And Not Nl(str2) Then	
		If reFormat Then
			strPattern = reFormatStr(str2)
		Else
			strPattern = str2
		End If
	
		If bIgnoreSpace Then
			strPattern = reFormatIgnoreSpace(strPattern)
		End If

		rExp.IgnoreCase = bIgnoreCase
		rExp.Global = bGlobal		
		rExp.Pattern = strPattern
		
		reReplace = rExp.Replace(str1, str3)
	Else
		reReplace = vbNullString
	End If
End Function
%>
