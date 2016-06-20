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
Public Function IsSmallDate(dVal)
	Dim bReturn
	bReturn = False

	If Not Nl(dVal) Then
		If IsDate(dVal) Then
			dVal = CDate(dVal)
			If (dVal >= CDate(MIN_SMALL_DATE)) And (dVal <= CDate(MAX_SMALL_DATE)) Then
				bReturn = True
			End If
		End If
	End If
	IsSmallDate = bReturn
End Function

Public Function IsIDType(intVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(intVal) Then
		If reEquals(intVal,"[1-9][0-9]{0,8}",False,True,True,False) Then
			intVal = 0 + intVal
			If intVal > 0 And intVal <= MAX_INT Then
				bReturn = True
			End If
		End If
	End If
	IsIDType = bReturn
End Function

Public Function IsCulture(strVal)
	Dim bReturn
	bReturn = False
	If Not Nl(Application("Culture_" + strVal)) Then
		bReturn = True
	End If
	IsCulture = bReturn
End Function

Public Function IsLangID(intVal)
	Dim bReturn
	bReturn = False
	If IsNumeric(intVal) Then
		intVal = CInt(intVal)
		bReturn = Not Nl(Application("LangID_" & intVal))
	End If
	IsLangID = bReturn
End Function

Public Function IsPosSmallInt(intVal)
	Dim bReturn
	bReturn = False
	If Not Nl(intVal) Then
		If IsNumeric(intVal) Then
			intVal = 0 + intVal
			If reEquals(intVal,"[0-9]+",False,False,True,False) And intVal >= 0 And intVal < MAX_SMALL_INT Then
				bReturn = True
			End If
		End If
	End If
	IsPosSmallInt = bReturn
End Function

Public Function IsLatLongType(decVal)
	Dim bReturn
	bReturn = False
	If Not Nl(decVal) Then
		If IsNumeric(decVal) Then
			decVal = 0.0 + decVal
			If decVal >= -180 And decVal <= 180 Then
				bReturn = True
			End If
		End If
	End If
End Function

Public Function IsPosTinyInt(intVal)
	Dim bReturn
	bReturn = False
	If Not Nl(intVal) Then
		If IsNumeric(intVal) Then
			intVal = 0 + intVal
			If reEquals(intVal,"[0-9]+",False,False,True,False) And intVal >= 0 And intVal < MAX_TINY_INT Then
				bReturn = True
			End If
		End If
	End If
	IsPosTinyInt = bReturn
End Function

Public Function IsNAICSType(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If IsNumeric(strVal) Then
			strVal = 0 + strVal
			If strVal >= MIN_NAICS_CODE And strVal <= MAX_NAICS_CODE Then
				bReturn = True
			End If
		End If
	End If

	IsNAICSType = bReturn
End Function

Public Function IsNUMType(intVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(intVal) Then
		If reEquals(intVal,"([A-Z]){3}([0-9]){4,5}",False,False,True,False) Then
			bReturn = True
		End If
	End If
	IsNUMType = bReturn
End Function

Public Function IsVNUMType(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"V-([A-Z]){3}([0-9]){4,5}",False,False,True,False) Then
			bReturn = True
		End If
	End If
	IsVNUMType = bReturn
End Function

'***************************************
' Begin Function IsTaxonomyCodeType
'	Confirm that the given string conforms to the structure of
'	a Taxonomy Code, e.g. AA-1111.1111-111-11-L
'		strVal - the string to evaluate
'***************************************
Public Function IsTaxonomyCodeType(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"[A-Z]([A-Z](\-[0-9]{4}(\.[0-9]{4}(\-[0-9]{3}(\.[0-9]{2})?)?)?)?)?(\-L)?",True,False,True,False) Then
			bReturn = True
		End If
	End If

	IsTaxonomyCodeType = bReturn
End Function
'***************************************
' End Function IsTaxonomyCodeType
'***************************************

Public Function IsIDList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"([0-9]{1,9}\s*,\s*)*[0-9]{1,9}",False,True,True,False) Then
			bReturn = True
		End If
	End If
	IsIDList = bReturn
End Function

Public Function IsCodeList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"([0-9A-Z\-]{1,20}\s*,\s*)*[0-9A-Z\-]{1,20}",False,True,True,False) Then
			bReturn = True
		End If
	End If
	IsCodeList = bReturn
End Function

Public Function IsChecklistNameList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"([0-9A-Z\-]{1,20}\s*,\s*)*[0-9A-Z\-]{1,25}",False,True,True,False) Then
			bReturn = True
		End If
	End If
	IsChecklistNameList = bReturn
End Function

Public Function IsNUMList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"(([A-Z]){3}([0-9]){4,5}\s*,\s*)*([A-Z]){3}([0-9]){4,5}",False,True,True,False) Then
			bReturn = True
		End If
	End If
	IsNUMList = bReturn
End Function

Public Function IsVNUMList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"(V-([A-Z]){3}([0-9]){4,5}\s*,\s*)*V-([A-Z]){3}([0-9]){4,5}",False,True,True,False) Then
			bReturn = True
		End If
	End If
	IsVNUMList = bReturn
End Function

Public Function IsStringList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"([^,]{1,255}\s*,\s*)*[^,]{1,255}",False,True,True,False) Then
			bReturn = True
		End If
	End If
	IsStringList = bReturn
End Function

'***************************************
' Begin Function IsLinkedTaxCodeList
'	Confirm that the given string conforms to the general structure of a list
'	of linked Codes (comma-delimited sets of linked Codes.
'	Codes within the linked set are separated by ~).
'		strVal - the string to evaluate
'***************************************
Public Function IsLinkedTaxCodeList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"([A-Z]([A-Z](\-[0-9]{4}(\.[0-9]{4}(\-[0-9]{3}(\.[0-9]{2})?)?)?)?)?(\-L)?\s*(,|~)\s*)*[A-Z]([A-Z](\-[0-9]{4}(\.[0-9]{4}(\-[0-9]{3}(\.[0-9]{2})?)?)?)?)?(\-L)?",True,True,True,False) Then
			bReturn = True
		End If
	End If
	IsLinkedTaxCodeList = bReturn
End Function
'***************************************
' End Function IsLinkedTaxCodeList
'***************************************

'***************************************
' Begin Function IsTaxCodeList
'	Confirm that the given string conforms to the general structure of a list
'	of Codes (comma-delimited Codes).
'		strVal - the string to evaluate
'***************************************
Public Function IsTaxCodeList(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If reEquals(strVal,"([A-Z]([A-Z](\-[0-9]{4}(\.[0-9]{4}(\-[0-9]{3}(\.[0-9]{2})?)?)?)?)?(\-L)?\s*,\s*)*[A-Z]([A-Z](\-[0-9]{4}(\.[0-9]{4}(\-[0-9]{3}(\.[0-9]{2})?)?)?)?)?(\-L)?",True,True,True,False) Then
			bReturn = True
		End If
	End If
	IsTaxCodeList = bReturn
End Function
'***************************************
' End Function IsTaxCodeList
'***************************************

'***************************************
' Begin Function IsIPAddress
'	Return true if strVal is an IP address
'***************************************
Public Function IsIPAddress(strVal)
	Dim bReturn
	bReturn = False

	If Not Nl(strVal) Then
		If reEquals(strVal, "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b",False,True,True,False) Then
			bReturn = True
		End If
	End If
	IsIPAddress = bReturn

End Function
'***************************************
' End Function IsIPAddress
'***************************************

'***************************************
' Begin Function IsGUIDType
'	Return true if strVal is a GUID 
'***************************************
Public Function IsGUIDType(strVal)
	Dim bReturn
	bReturn = False

	If Not Nl(strVal) Then
		If reEquals(strVal, "\{[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}\}",True,False,True,False) Then
			bReturn = True
		End If
	End If
	IsGUIDType = bReturn

End Function
'***************************************
' End Function IsGUIDType
'***************************************

'***************************************
' Begin Function IsRandomKey
'	Return true if strVal is a Random Key Value
'***************************************
Public Function IsRandomKey(strVal)
	Dim bReturn
	bReturn = False

	If Not Nl(strVal) Then
		If reEquals(strVal, "[A-F0-9]{32}",True,False,True,False) Then
			bReturn = True
		End If
	End If
	IsRandomKey = bReturn

End Function
'***************************************
' End Function IsGUIDType
'***************************************
%>
