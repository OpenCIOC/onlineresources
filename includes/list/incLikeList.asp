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
Function makeLikeList(strSelectName)
	Dim strReturn
	strReturn = "<select name=""" & strSelectName & """ class=""form-control"">" & _
			"<option value=""L"" SELECTED>" & TXT_CONTAINS & "</option>" & _
			"<option value=""NL"">" & TXT_NOT_CONTAINS & "</option>" & _
			"<option value=""N"">" & TXT_IS_NULL & "</option>" & _
			"<option value=""NN"">" & TXT_NOT_NULL & "</option>" & _
			"</select>"
	makeLikeList = strReturn
End Function
%>
