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
Dim intDisplayOrder

Public Function IsDisplayOrderType(intVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(intVal) Then
		If IsNumeric(intVal) Then
			intVal = 0 + intVal
			If intVal >= 0 And intVal <= MAX_TINY_INT Then
				bReturn = True
			End If
		End If
	End If
	IsDisplayOrderType = bReturn
End Function

Sub getDisplayOrder()
	intDisplayOrder = Trim(Request("DisplayOrder"))
	If Nl(intDisplayOrder) Then
		strError = TXT_DISPLAY_ORDER_NULL
		intDisplayOrder = Null
	ElseIf Not IsDisplayOrderType(intDisplayOrder) Then
		strError = TXT_DISPLAY_ORDER_BETWEEN & MAX_TINY_INT
		intDisplayOrder = Null
	Else
		intDisplayOrder = CInt(intDisplayOrder)
	End If
End Sub
%>
