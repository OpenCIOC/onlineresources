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
Dim strRecordOwner, _
	strPosition, _
	strDuties, _
	strAppQ1, _
	strAppQ2, _
	strAppQ3, _
	strOrgName, _
	strContactName, _
	strContactTitle, _
	strContactOrg, _
	strContactPhone, _
	strContactFax, _
	strContactEmail, _
	bInView, _
	bInDefaultView, _
	bExpired, _
	intSurvey
	
Sub setOpInfo()
	Dim cmdOp, rsOp
	Set cmdOp = Server.CreateObject("ADODB.Command")
	With cmdOp
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_YesVolunteer"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@DefaultViewType", adInteger, adParamInput, 4, user_intViewVOL)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
		Set rsOp = .Execute
	End With

	With rsOp
		If Not .EOF Then
			strRecordOwner = .Fields("RECORD_OWNER")
			strPosition = .Fields("POSITION_TITLE")
			strDuties = .Fields("DUTIES")
			strAppQ1 = .Fields("APPLICATION_QUESTION_1")
			strAppQ2 = .Fields("APPLICATION_QUESTION_2")
			strAppQ3 = .Fields("APPLICATION_QUESTION_3")
			strOrgName = .Fields("ORG_NAME_FULL")
			strContactName = .Fields("CONTACT_NAME")
			strContactOrg = IIf(Nl(.Fields("CONTACT_ORG")), strOrgName, .Fields("CONTACT_ORG"))
			strContactPhone = .Fields("CONTACT_PHONE")
			strContactFax = .Fields("CONTACT_FAX")
			strContactEmail = .Fields("CONTACT_EMAIL")
			bInView = .Fields("IN_VIEW")
			bInDefaultView = .Fields("IN_DEFAULT_VIEW")
			bExpired = .Fields("EXPIRED")
			intSurvey = .Fields("VolunteerApplicationSurvey")
		Else
			strRecordOwner = vbNullString
			strPosition = vbNullString
			strDuties = vbNullString
			strAppQ1 = vbNullString
			strAppQ2 = vbNullString
			strAppQ3 = vbNullString
			strOrgName = vbNullString
			strContactName = vbNullString
			strContactOrg = vbNullString
			strContactPhone = vbNullString
			strContactFax = vbNullString
			strContactEmail = vbNullString
			bInView = False
			bInDefaultView = False
			bExpired = False
			intSurvey = Null
		End If
	End With
	Set rsOp = Nothing
	Set cmdOp = Nothing	
End Sub

Sub printSurveyInfo()
	Dim cmdSurvey, rsSurvey
	Set cmdSurvey = Server.CreateObject("ADODB.Command")
	With cmdSurvey
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_ApplicationSurvey_s"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@APP_ID", adInteger, adParamInput, 4, intSurvey)
		Set rsSurvey = .Execute
	End With

	dim i, j

	With rsSurvey
		If Not .EOF Then
%>
    <div class="panel panel-default max-width-lg clear-line-below">
        <div class="panel-heading">
            <h3><span class="glyphicon glyphicon-user" aria-hidden="true"></span> <%=Nz(rsSurvey.Fields("Title"),TXT_OPTIONAL_SURVEY)%></h3>
        </div>
		<div class="panel-body">
			<div class="AlertBubble">
				<%=TXT_SURVEY_DISCLAIMER_1 %> <%=strContactOrg%> <%=TXT_SURVEY_DISCLAIMER_2 %>
			</div>
			<%=.Fields("Description") %>
<%
			For i = 1 to 3
				If Not Nl(.Fields("TextQuestion" + CStr(i))) Then
%>
				<hr />
				<h3><label for="TextQuestion<%=i%>"><%=.Fields("TextQuestion" + CStr(i))%></label></h3>
				<%=.Fields("TextQuestion"  + CStr(i) + "Help")%>
				<textarea name="TextQuestion<%=i%>)" id="TextQuestion<%=i%>" class="form-control"></textarea>
<%
				End If
			Next
%>
<%
			For i = 1 to 3
				If Not Nl(.Fields("DDQuestion" + CStr(i))) Then
%>
				<hr />
				<h3><label for="DDQuestion<%=i%>"><%=.Fields("DDQuestion" + CStr(i))%></label></h3>
				<%=.Fields("DDQuestion"  + CStr(i) + "Help")%>
				<select name="DDQuestion<%=i%>)" id="DDQuestion<%=i%>" class="form-control">
					<option selected> -- </option>
<%
				For j = 1 to 10
					If Not Nl(.Fields("DDQuestion" + CStr(i) + "Opt" + CStr(j))) Then
%>
					<option value=<%=AttrQs(.Fields("DDQuestion" + CStr(i) + "Opt" + CStr(j)))%>"><%=Server.HTMLEncode(.Fields("DDQuestion" + CStr(i) + "Opt" + CStr(j)))%></option>
<%
					End If
				Next
%>
				</select>
<%
				End If
			Next
%>
        </div>
    </div>
<%
		End If
	End With

	Set rsSurvey = Nothing
	Set cmdSurvey = Nothing	
End Sub


%>
