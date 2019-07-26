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
Class FieldData

Public	fName, _
		fSelect, _
		fLabel
		
Public Sub setData(strName,strSelect,strLabel)
	fName = strName
	fSelect = strSelect
	fLabel = strLabel
End Sub

End Class

Class FacetFieldData

Public	fName, _
		fSelect, _
		fLabel, _
		fFieldID

		
Public Sub setData(strName,strSelect,strLabel,intFieldID)
	fName = strName
	fSelect = strSelect
	fLabel = strLabel
	fFieldID = intFieldID
End Sub

End Class
%>
