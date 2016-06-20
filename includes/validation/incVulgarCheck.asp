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
Function isVulgar(strFldVal)
	If Not Nl(strFldVal) Then
		If reEquals(strFldVal,"(\b|^)((puss(y|ies))|(cock[s]?(ucker)?)|(fuck(ing|er[s]?)?)|(twat)|((bull)?shit(ty)?)|(ass(hole[s]?)?)|(bdsm)|(hardcore)|(fetish)|(porn(o)?))(\b|$)",True,True,False,False) Then
			isVulgar = True
		Else
			isVulgar = False
		End If
	End If
End Function
%>
