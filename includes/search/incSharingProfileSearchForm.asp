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

Sub makeSharingProfileAdvSearchForm()
	Dim objFormatter
	If g_bOtherMembersActive and user_bSuperUserDOM and ps_intDomain=DM_CIC Then

		Call openSharingProfileListRst(ps_intDbArea)
%>
<tr>
	<td class="field-label-cell-widelabel"><%= TXT_SHARED_RECORDS %></td>
	<td class="field-data-cell">
		<strong><%= TXT_MY_SHARING_PROFILES & TXT_COLON %></strong>
		<%
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("Name")
			Response.Write(makeChecklistUI("ShareType", "ShareID", "ShareIDx", False, rsListSharingProfile, "ProfileID", objFormatter, False))
		%>
		<strong><%= TXT_INCLUDE & TXT_COLON %></strong>
		<div class="radio">
			<label for="Shared"><input type="radio" name="Shared" id="Shared" value="" checked><%=TXT_ALL_RECORDS%></label>
		</div>
		<div class="radio">
			<label for="Shared_N"><input type="radio" name="Shared" id="Shared_N" value="N"><%=TXT_ONLY_MINE%> <em><%= g_strMemberNameDOM %></em></label>
		</div>
		<div class="radio">
			<label for="Shared_Y"><input type="radio" name="Shared" id="Shared_Y" value="Y"><%=TXT_ONLY_NOT_MINE%> <em><%= g_strMemberNameDOM %></em></label>
		</div>
	</td>
<%
		Call closeSharingProfileListRst()
	End If
End Sub
%>

