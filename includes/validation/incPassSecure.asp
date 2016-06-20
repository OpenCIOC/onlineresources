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
' Purpose:		Utility for confirming that a given string
'				is an adequately secure password
'
'
%>

<%
'***************************************
' Begin Function IsSecurePassword
'	Confirm that the given string is adequately secure and contains 
'	at least 8 characters, with at least one lowercase and uppercase letter
'		strVal - the string to evaluate
'***************************************
Public Function IsSecurePassword(strVal)
	Dim bReturn
	bReturn = False
	
	If Not Nl(strVal) Then
		If Len(strVal) >= 8 _
			And reEquals(strVal,"[A-Z]",False,False,False,False) _
			And reEquals(strVal,"[a-z]",False,False,False,False) _
			And reEquals(strVal,"[0-9]",False,False,False,False) Then
				bReturn = True
		End If
	End If
	IsSecurePassword = bReturn
End Function
'***************************************
' End Function IsSecurePassword
'***************************************
%>
