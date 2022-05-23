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
Sub VOLProfilePersonalForm(bNew, dicBasicInfo)
%>
<form action="save_personal.asp" method="post" id="personal_form" role="form" class="form-horizontal">
<div style="display:none">
<%=g_strCacheFormVals%>
<%If bNew Then%>
<input type="hidden" name="New" value="True">
<input type="hidden" name="page" value=<%=AttrQs(Server.HTMLEncode(Trim(Ns(Request("page")))))%>>
<input type="hidden" name="args" value=<%=AttrQs(Server.HTMLEncode(Trim(Ns(Request("args")))))%>>
<%End If%>
</div>

<table class="BasicBorder cell-padding-4">
	<tr><th colspan="2" class="RevTitleBox"><%=TXT_PERSONAL_INFO%></th></tr>
	<tr>
		<td class="FieldLabelLeft"><label for="Email"><%=TXT_EMAIL_ADDRESS%></label> <span class="Alert">*</span></td>
		<td>
			<div class="form-group">
				<div class="col-sm-12">
					<input type="text" class="form-control" name="EMail" value=<%=AttrQs(Server.HTMLEncode(dicBasicInfo("Email")))%> maxlength="100">
				</div>
			</div>
		</td>
	<tr>
		<td class="FieldLabelLeft"><%=IIf(bNew,TXT_PASSWORD & " <span class=""Alert"">*</span>",TXT_CHANGE_PASSWORD)%></td>
		<td>
			<p><%=TXT_INST_PASSWORD_2 & StringIf(Not bNew, " " & TXT_INST_PASSWORD_3)%></p>

			<%If Not bNew Then%>
			<div class="form-group">
				<label for="CurPW" class="control-label col-sm-3"><%=TXT_OLD_PASSWORD%></label>
				<div class="col-sm-9">
					<input name="CurPW" class="form-control" type="password">
				</div>
			</div>
			<%End If%>
			<div class="form-group">
				<label for="CurPW" class="control-label col-sm-3"><%=IIf(bNew, TXT_PASSWORD, TXT_NEW_PASSWORD)%></label>
				<div class="col-sm-9">
					<input name="NewPW" class="form-control" type="password">
				</div>
			</div>
			<div class="form-group">
				<label for="CurPW" class="control-label col-sm-3"><%=TXT_CONFIRM_PASSWORD%></label>
				<div class="col-sm-9">
					<input name="CNewPW" class="form-control" type="password">
				</div>
			</div>
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_NAME%> <span class="Alert">*</span></td>
		<td>
			<div class="form-group">
				<label for="CurPW" class="control-label col-sm-3"><%=TXT_FIRST_NAME%></label>
				<div class="col-sm-9">
					<input name="FirstName" id="FirstName" class="form-control" maxlength="50" value=<%=AttrQs(Server.HTMLEncode(Ns(dicBasicInfo("FirstName"))))%>>
				</div>
			</div>
			<div class="form-group">
				<label for="CurPW" class="control-label col-sm-3"><%=TXT_LAST_NAME%></label>
				<div class="col-sm-9">
					<input name="LastName" id="LastName" class="form-control" maxlength="50" value=<%=AttrQs(Server.HTMLEncode(Ns(dicBasicInfo("LastName"))))%>>
				</div>
			</div>
		</td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_CONTACT_INFO %></td>
		<td>
			<div class="form-group">
				<label for="Address" class="control-label col-sm-3"><%=TXT_ADDRESS%></label>
				<div class="col-sm-9">
					<input type="text" name="Address" class="form-control" maxlength="150" value=<%=AttrQs(Server.HTMLEncode(Ns(dicBasicInfo("Address"))))%>>
				</div>
			</div>
			<div class="form-group">
				<label for="City" class="control-label col-sm-3"><%=TXT_CITY%></label>
				<div class="col-sm-9">
					<input type="text" name="City" class="form-control" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicBasicInfo("City"))))%>>
				</div>
			</div>
			<div class="form-group">
				<label for="Province" class="control-label col-sm-3"><%=TXT_PROVINCE%></label>
				<div class="col-sm-9 form-inline">
					<input type="text" name="Province" class="form-control" maxlength="2" value=<%=AttrQs(Server.HTMLEncode(Ns(dicBasicInfo("Province"))))%>>
				</div>
			</div>
			<div class="form-group">
				<label for="PostalCode" class="control-label col-sm-3"><%=TXT_POSTAL_CODE%></label>
				<div class="col-sm-9 form-inline">
					<input type="text" name="PostalCode" class="form-control" maxlength="10" value=<%=AttrQs(Server.HTMLEncode(Ns(dicBasicInfo("PostalCode"))))%>>
				</div>
			</div>
			<div class="form-group">
				<label for="Phone" class="control-label col-sm-3"><%=TXT_PHONE%></label>
				<div class="col-sm-9">
					<input type="text" name="Phone" class="form-control" maxlength="100" value=<%=AttrQs(Server.HTMLEncode(Ns(dicBasicInfo("Phone"))))%>>
				</div>
			</div>
		</td>
	</tr>
	<% 
	If Not bNew And g_bMultiLingualActive Then 
		Call openSysLanguageListRst(True)
	%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_LANGUAGE %></td>
		<td>
			<div class="form-group">
				<label for="LangID" class="control-label col-sm-6"><%= TXT_PREFERRED_LANGUAGE %></label>
				<div class="col-sm-6">
					<%=makeSysLanguageList(dicBasicInfo("LangID"),"LangID",False,"form-control")%>
				</div>
			</div>
		</td>
	</tr>
	<%	
	Call closeSysLanguageListRst() 
	End If 
	%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_CONTACT %></td>
		<td>
			<div class="form-group">
				<div class="checkbox col-sm-12">
					<label for="OrgCanContact">
						<input type="checkbox" name="OrgCanContact" id="OrgCanContact"<%=Checked(dicBasicInfo("OrgCanContact"))%>>
						<%=IIf(Not Nl(g_strVolProfilePrivacyPolicyOrgName),g_strVolProfilePrivacyPolicyOrgName,TXT_THE_VOLUNTEER_CENTRE) & " " & TXT_MAY_REVIEW_MY_SEARCHING_PROFILE %>
					</label>
				</div>
			</div>
		</td>
	</tr>
<%If Not Nl(g_strVolProfilePrivacyPolicy) Then%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_PRIVACY_POLICY %></td>
		<td>
			<div class="form-group">
				<div class="checkbox col-sm-12">
					<label for="AgreedToPrivacyPolicy">
						<input type="checkbox" name="AgreedToPrivacyPolicy" id="AgreedToPrivacyPolicy"<%=Checked(dicBasicInfo("AgreedToPrivacyPolicy"))%>>
						<%= TXT_I_AGREE_TO_PRIVACY_POLICY_1 %><%=StringIf(Not Nl(g_strVolProfilePrivacyPolicyOrgName),TXT_BY & g_strVolProfilePrivacyPolicyOrgName) & " " & TXT_I_AGREE_TO_PRIVACY_POLICY_2 %> <a href="<%=makeLinkB("privacy_policy.asp")%>" onClick=<%=AttrQs(Server.HTMLEncode("openWinL(" & JsQs(makeLinkB("privacy_policy.asp")) & ", 'PrivacyPolicy'); return false"))%> target="_blank"><%= TXT_PRIVACY_POLICY %></a>.
					</label>
				</div>
			</div>
		</td>
	</tr>
<%Else%>
<div style="display:none">
<input type="hidden" name="AgreedToPrivacyPolicy" value="<%If dicBasicInfo("AgreedToPrivacyPolicy") Then%>on<%End If%>">
</div>
<%End If%>
<%If Not bNew Then%>
	<tr>
		<td class="FieldLabelLeft"><%= TXT_DEACTIVATE %></td>
		<td><a style="display: inline-block; padding: 0.25em; text-decoration: none;" class="ui-state-default ui-corner-all" href="<%= makeLinkB("deactivate.asp") %>"><%= TXT_DEACTIVATE %></a>
			<br><%= TXT_DEACTIVATE_PROMPT %></td>
	</tr>
<%End If%>
	<tr>
		<td colspan="2"><input type="submit" name="Submit" value="<%=TXT_SUBMIT%>" class="btn btn-default"> <input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default"></td>
	</tr>
	</table>
<%If Nl(g_strVolProfilePrivacyPolicy) Then%>
<div class="NotVisible"><input type="hidden" name="AgreedToPrivacyPolicy" value="<%=StringIf(dicBasicInfo("AgreedToPrivacyPolicy"), "on")%>"></div>
<%End If%>
	</form>
<%
End Sub
%>
