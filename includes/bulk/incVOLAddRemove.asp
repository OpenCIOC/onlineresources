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
Select Case strActionType

	'###################
	' AREA OF INTEREST
	'###################
	Case "AI"
%><h2><%= TXT_ADD_REMOVE_AREA_OF_INTEREST %></h2><%
		If Nl(intIGID) And Not g_bOnlySpecificInterests Then
%><p class="Info"><%= TXT_INST_ADD_AREA_OF_INTEREST %></p><%
			Call openInterestGroupListRst()
			strDropDownContents = makeInterestGroupTableList("IGID")
			Call closeInterestGroupListRst()
		Else
			Call openInterestListRst(intIGID, True)
			strDropDownContents = makeInterestTableList("ActionID")
			Call closeInterestListRst()
		End If

	'###################
	' UNKNOWN TYPE
	'###################
	Case Else
			bError = True
			Call handleError(TXT_ERROR & TXT_NO_ACTION, _
					vbNullString, _
					vbNullString)
End Select
%>
