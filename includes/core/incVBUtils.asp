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
'
' Purpose:		General utility file, including:
'					- System-wide constants
'					- General evaluation functions (Nl, Nz, IIf)
'					- Specialized quotation functions (Qs,QsNl,AttrQs,JsQs,...)
'					- Type-testing functions
'
'
%>

<%
Const SQUOTE = "'"
Const DQUOTE = """"
Const SQL_TRUE = 1
Const SQL_FALSE = 0
Const AND_CON = " AND "
Const OR_CON = " OR "
Const MAX_INT = 2147483647
Const MAX_SMALL_INT = 32767
Const MAX_TINY_INT = 255
Const MIN_NAICS_CODE = 11
Const MAX_NAICS_CODE = 999999

Dim MIN_SMALL_DATE, _
	MAX_SMALL_DATE

MIN_SMALL_DATE = DateSerial(1900, 1, 1)
MAX_SMALL_DATE = DateSerial(2079, 6, 6)

Public Function IIf(expr,truepart,falsepart)
	IIf = falsepart
	If expr Then IIf = truepart
End Function

Public Function Nl(strTest)
	On Error Resume Next
	Nl = False
	If IsNull(strTest) Then
		Nl = True
	ElseIf IsEmpty(strTest) Then
		Nl = True
	ElseIf CStr(strTest) = vbNullString Then
		Nl = True
	End If
	Err.Clear
End Function

Public Function NlNl(strTest)
	If Nl(strTest) Then
		NlNl = Null
	Else
		NlNl = strTest
	End If
End Function

Public Function Nz(strTest,strIfNull)
	If Nl(strTest) Then
		Nz = strIfNull
	Else
		Nz = strTest
	End If
End Function

Public Function Ns(strTest)
	If Nl(strTest) Then
		Ns = vbNullString
	Else
		Ns = strTest
	End If
End Function

Public Function Qs(strVal, ByVal strDelimiter)
	If IsNull(strVal) Then
		Qs = vbNullString
	Else
		Qs = strDelimiter & _
			Replace(strVal, strDelimiter, strDelimiter & strDelimiter) & _
			strDelimiter
	End If
End Function

Function QsN(strVal)
	QsN = "N" & Qs(strVal, SQUOTE)
End Function

Function QsNNl(strVal)
	If Not Nl(strVal) Then
		QsNNl = "N" & Qs(strVal,SQUOTE)
	Else
		QsNNl = vbNullString
	End If
End Function

Function QsNl(strVal)
	If Not Nl(strVal) Then
		QsNl = "N" & Qs(strVal,SQUOTE)
	Else
		QsNl = "NULL"
	End If
End Function

Function QsStrList(strVal)
	If Not Nl(strVal) Then
		strVal = Replace(strVal," ",vbNullString)
		If Not Nl(strVal) Then
			QsStrList = SQUOTE & Replace(Replace(strVal, "'", "''"),",","','") & SQUOTE
		Else
			QsStrList = vbNullString
		End If
	Else
		QsStrList = vbNullString
	End If
End Function

Public Function AttrQs(strVal)
	If IsNull(strVal) Then
		AttrQs = DQUOTE & DQUOTE
	Else
		AttrQs = DQUOTE & Replace(strVal, DQUOTE, "&quot;") & DQUOTE
	End If
End Function

Public Function JsQs(strVal)
	If IsNull(strVal) Then
		JsQs = SQUOTE & SQUOTE
	Else
		JsQs = SQUOTE & _
			Replace(Replace(Replace(Replace(Replace(strVal,"\","\\"),vbCr,"\r"), vbLf, "\n"), SQUOTE, "\'"), DQUOTE, "\""") & _
			SQUOTE
	End If
End Function

'***************************************
' Begin Function JSONQs
'	Specialized quotation/escape function for use with JSON/AJAX files.
'		strVal - the string to quote / escape
'		bQ - True -> quote the string
'***************************************
Function JSONQs(strVal, bQ)
	Dim strQ

	If bQ Then
		strQ = DQUOTE
	Else
		strQ = vbNullString
	End If

	If IsNull(strVal) Then
		JSONQs = strQ & strQ
	Else
		JSONQs = strQ & Replace(Replace(Replace(Replace(Replace(Nz(strVal,vbNullString),"\","\\"),vbCr,"\r"), vbLf, "\n"), DQUOTE, "\"""), "	", "\t") & strQ
	End If
End Function
'***************************************
' End Function JSONQs
'***************************************

Public Function XMLEncode(strVal)
	XMLEncode = Replace(Replace(Replace(Replace(Replace(Nz(strVal,vbNullString), "&", "&amp;"), "<", "&lt;"), ">", "&gt;"), SQUOTE, "&apos;"), DQUOTE, "&quot;")
End Function

Public Function XMLQs(strVal)
	If IsNull(strVal) Then
		XMLQs = DQUOTE & DQUOTE
	Else
		XMLQs = DQUOTE & _
			XMLEncode(strVal) & _
			DQUOTE
	End If
End Function

'***************************************
' Begin Function StartsWith
'	Return true if strTarget string begins with the strBegin string
'		strTarget - the string that might start with strBegin 
'		strBegin - what the string needs to start with.
'***************************************
Public Function StartsWith(strTarget, strBegin)
	StartsWith = (strBegin = Left(strTarget, Len(strBegin)))
End Function
'***************************************
' End Function StartsWith
'***************************************

'***************************************
' Begin Function StringIf
'	Return strVal if bCondition is True else return vbNullString
'***************************************
Public Function StringIf(bCondition, strVal)
	If bCondition Then
		StringIf = strVal
	Else
		StringIf = vbNullString
	End If

End Function
'***************************************
' End Function StringIF
'***************************************

'***************************************
' Begin Function Checked
'	Return "checked" if bCondition is True
'***************************************
Public Function Checked(bCondition)
	Checked = StringIf(bCondition, " checked")
End Function
'***************************************
' End Function Checked
'***************************************

'***************************************
' Begin Function Selected
'	Return "selected" if bCondition is True
'***************************************
Public Function Selected(bCondition)
	Selected = StringIf(bCondition, " selected")
End Function
'***************************************
' End Function Selected
'***************************************

'***************************************
' Begin Function CbToSQLBool
'	Return SQL True if the value of in the Request object is equal to "on"
'***************************************
Public Function CbToSQLBool(strParamName)
	CbToSQLBool = IIf(Request(strParamName)="on",SQL_TRUE,SQL_FALSE)
End Function
'***************************************
' End Function Selected
'***************************************


'***************************************
' Begin Function TrimAll
'	Return string trimmed of all trailing whitespace
'***************************************
Public Function TrimAll(strVal)
	TrimAll = reReplace(strVal, "^\s+|\s+$", vbNullString, True, False, True, False)
End Function

Public Function Trim(strVal)
	Trim = TrimAll(strVal)
End Function
'***************************************
' End Function TrimAll
'***************************************

'***************************************
' Begin Function ConvertFloatSQL
'	Return string trimmed of all trailing whitespace
'***************************************
Public Function ConvertFloatSQL(decNumber)
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			ConvertFloatSQL = Replace(decNumber,",",".")
		Case Else
			ConvertFloatSQL = decNumber
	End Select
End Function
'***************************************
' End Function ConvertFloatSQL
'***************************************

Public Function Min(intA, intB)
	If intA < intB Then
		Min = intA
	Else 
		Min = intB
	End If
End Function
%>
