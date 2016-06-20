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
Function printMonthList(strSelectName)
%>
<select id="<%=strSelectName%>" name="<%=strSelectName%>" class="form-control">
	<option value="" selected></option>
	<option value="1"><%=TXT_JANUARY%></option>
	<option value="2"><%=TXT_FEBRUARY%></option>
	<option value="3"><%=TXT_MARCH%></option>
	<option value="4"><%=TXT_APRIL%></option>
	<option value="5"><%=TXT_MAY%></option>
	<option value="6"><%=TXT_JUNE%></option>
	<option value="7"><%=TXT_JULY%></option>
	<option value="8"><%=TXT_AUGUST%></option>
	<option value="9"><%=TXT_SEPTEMBER%></option>
	<option value="10"><%=TXT_OCTOBER%></option>
	<option value="11"><%=TXT_NOVEMBER%></option>
	<option value="12"><%=TXT_DECEMBER%></option>
</select>
<%
End Function
%>
