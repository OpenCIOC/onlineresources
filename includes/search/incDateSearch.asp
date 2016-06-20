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
Sub printDateSearchTable(strPrefix)
%>
<div class="form-group row form-inline">
	<label for="<%=strPrefix%>DateRange" class="control-label col-sm-4 col-md-3"><%=TXT_DATE_IN%></label>
	<div class="col-sm-8 col-md-9">
		<select name="<%=strPrefix%>DateRange" id="<%=strPrefix%>DateRange" class="form-control">
			<option value=""> -- </option>
			<option value="P"><%=TXT_PAST%></option>
			<option value="F"><%=TXT_FUTURE%></option>
			<option value="T"><%=TXT_TODAY%></option>
			<option value="Y"><%=TXT_YESTERDAY%></option>
			<option value="7"><%=TXT_LAST_7_DAYS%></option>
			<option value="10"><%=TXT_LAST_10_DAYS%></option>
			<option value="TM"><%=TXT_THIS_MONTH%></option>
			<option value="PM"><%=TXT_PREVIOUS_MONTH%></option>
			<option value="NM"><%=TXT_NEXT_MONTH%></option>
			<option value="N"><%=TXT_IS_NULL%></option>
			<option value="NN"><%=TXT_NOT_NULL%></option>
		</select>
		<strong><%=TXT_OR%></strong>
	</div>
</div>
<div class="form-group row form-inline">
	<label for="<%=strPrefix%>FirstDate" class="control-label col-sm-4 col-md-3"><%=TXT_ON_AFTER_DATE%></label>
	<div class="col-sm-8 col-md-9">
		<input type="text" name="<%=strPrefix%>FirstDate" id="<%=strPrefix%>FirstDate" class="DatePicker form-control" size="<%=DATE_TEXT_SIZE%>" maxlength="<%=DATE_TEXT_SIZE%>">
	</div>
</div>
<div class="form-group row form-inline">
	<label for="<%=strPrefix%>LastDate" class="control-label col-sm-4 col-md-3"><%=TXT_BEFORE_DATE%></label>
	<div class="col-sm-8 col-md-9">
		<input type="text" name="<%=strPrefix%>LastDate" id="<%=strPrefix%>LastDate" class="DatePicker form-control" size="<%=DATE_TEXT_SIZE%>" maxlength="<%=DATE_TEXT_SIZE%>">
	</div>
</div>
<%
End Sub
%>
