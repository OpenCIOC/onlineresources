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
Sub printStatsForm(strIDList)

	Dim intThisMonth, intThisYear, dateToday, dateLastMonthFirst, dateThisMonthFirst
	intThisMonth = Month(Date())
	intThisYear = Year(Date())
	dateToday = DateString(Date(),True)
	dateThisMonthFirst = DateString(DateSerial(intThisYear,intThisMonth,1),True)
	dateLastMonthFirst = DateString(DateAdd("m",-1,dateThisMonthFirst),True)

	Dim strViewTypeHidden, intNumViews
	strViewTypeHidden = vbNullString

%>
<form action="stats1.asp" method="post" name="EntryForm" onsubmit="formPrintMode(this);" id="EntryForm">
	<div style="display: none">
		<%=g_strCacheFormVals%>
		<input type="hidden" name="IDList" value="<%=strIDList%>">
	</div>
	<table class="BasicBorder cell-padding-3">
		<tr>
			<th colspan="2" class="RevTitleBox"><%=TXT_CREATE_STATS_REPORT%></th>
		</tr>
		<tr>
			<td class="FieldLabel">
				<label for="IPAddress"><%=TXT_IP_BEGINS_WITH%></label></td>
			<td>
				<input type="text" name="IPAddress" id="IPAddress" size="12" maxlength="40">
				(<%=TXT_EXAMPLE%> 199.235)</td>
		</tr>
		<%
If user_bSuperUserDOM Then
	Call openUserTypeListRst(ps_intDbArea, user_strAgency, user_intUserTypeDOM)
		%>
		<tr>
			<td class="FieldLabel"><%=TXT_USERS_WITH_TYPE%></td>
			<td><%=makeUserTypeList(vbNullString,"SLID",True,False)%></td>
		</tr>
		<%
	Call closeUserTypeListRst()
	Call openViewListRst(ps_intDbArea, user_strAgency, g_intViewTypeDOM)
	intNumViews = 0
Else
	Call openChangeViewsListRst(True)
	intNumViews = rsListChangeViews.RecordCount
End If
If user_bSuperUserDOM Or intNumViews > 1 Then
		%>
		<tr>
			<td class="FieldLabel"><%=TXT_VIEW%></td>
			<td><%If user_bSuperUserDOM Then
			Response.Write(makeViewList(vbNullString,"ViewType",False, True))
		Else
			Response.Write(makeChangeViewsList(ps_intDbAreaViewType, "ViewType", False, True))
		End If%></td>
		</tr>
		<%
Else
	rsListChangeViews.MoveFirst
	strViewTypeHidden = "<div style=""display:none""><input type=""hidden"" name=""ViewType"" value=" & AttrQs(rsListChangeViews("ViewType")) & "></div>"
End If
If user_bSuperUserDOM Then
	Call closeViewListRst()
Else
	Call closeChangeViewsListRst()
End If
		%>
		<tr>
			<td class="FieldLabel">
				<label for="StartDate"><%=TXT_ON_AFTER_DATE%></label></td>
			<td>
				<input type="text" name="StartDate" id="StartDate" size="15" maxlength="40" class="DatePicker">
				<input type="BUTTON" value="<%=TXT_FIRST_OF_LAST_MONTH%>" onclick="document.EntryForm.StartDate.value='<%=dateLastMonthFirst%>'"></td>
		</tr>
		<tr>
			<td class="FieldLabel">
				<label for="EndDate"><%=TXT_BEFORE_DATE%></label></td>
			<td>
				<input type="text" name="EndDate" id="EndDate" size="15" maxlength="40" class="DatePicker">
				<input type="BUTTON" value="<%=TXT_FIRST_OF_THIS_MONTH%>" onclick="document.EntryForm.EndDate.value='<%=dateThisMonthFirst%>'"></td>
		</tr>
		<%
If Nl(strIDList) Then
	Call openAgencyListRst(ps_intDbArea, True, True)
		If Not rsListAgency.EOF Then
		%>
		<tr>
			<td class="FieldLabel"><%=TXT_RECORDS_OWNED_BY%></td>
			<td><%=makeAgencyList(vbNullString,"RecordOwner",True,True)%></td>
		</tr>
		<%
		End If
	Call closeAgencyListRst()
End If
		%>
		<tr>
			<td class="FieldLabel"><%=TXT_RECORD_VIEWS_BY%></td>
			<td>
				<label for="StaffStatus_A">
					<input type="radio" name="StaffStatus" id="StaffStatus_A" value="" checked>
					<%=TXT_ANYONE%></label>
				<br>
				<label for="StaffStatus_L">
					<input type="radio" name="StaffStatus" id="StaffStatus_L" value="L">
					<%=TXT_LOGGED_IN_USERS%></label>
				<br>
				<label for="StaffStatus_P">
					<input type="radio" name="StaffStatus" id="StaffStatus_P" value="P">
					<%=TXT_PUBLIC_USERS%></label></td>
		</tr>
		<%
Call openSysLanguageListRst(True)
		%>
		<tr>
			<td class="FieldLabel"><%=TXT_RECORD_VIEWS_IN%></td>
			<td><%=makeSysLanguageList(vbNullString, "LimitLangID", True, vbNullString)%></td>
		</tr>
		<%
Call closeSysLanguageListRst()

		%>
		<tr>
			<td class="FieldLabel"><%=TXT_PRINT_VERSION_NW%></td>
			<td>
				<label for="PrintMd_Yes">
					<input type="radio" name="PrintMd" id="PrintMd_Yes" value="on">&nbsp;<%=TXT_YES%></label>
				<label for="PrintMd_No">
					<input type="radio" name="PrintMd" id="PrintMd_No" value="" checked>&nbsp;<%=TXT_NO%></label></td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input type="submit" value="<%=TXT_SEARCH%>">
				<input type="reset" value="<%=TXT_CLEAR_FORM%>"></td>
		</tr>
	</table>
	<%=strViewTypeHidden%>
</form>
<%
End Sub
%>
