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
If Not user_bSuperUserDOM Then
	Call securityFailure()
End If

Dim bError
bError = False

Dim strStoredProcName, _
	strDbAreaID, _
	strIDList, _
	strRecordLn

strIDList = Replace(Request("IDList")," ",vbNullString)

Select Case ps_intDbArea
	Case DM_CIC
		strStoredProcName = "dbo.sp_GBL_BaseTable_d"
		strDbAreaID = "NUM"
		If IsIDType(strIDList) Then
			strRecordLn = Nz(Request("RecordLn"),g_objCurrentLang.Culture)
		End If
	Case DM_VOL
		strStoredProcName = "dbo.sp_VOL_Opportunity_d"
		strDbAreaID = "VNUM"
		If IsIDType(strIDList) Then
			strRecordLn = Nz(Request("RecordLn"),g_objCurrentLang.Culture)
		End If
End Select

Dim bConfirmed
bConfirmed = Request("Confirmed") = "on"

If Nl(strIDList) Then
	bError = True
	Call makePageHeader(TXT_MANAGE_DELETED, TXT_MANAGE_DELETED, True, False, True, True)
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	Call makePageFooter(True)
ElseIf Not IsIDList(strIDList) Then
	bError = True
	Call makePageHeader(TXT_MANAGE_DELETED, TXT_MANAGE_DELETED, True, False, True, True)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(strIDList) & ".", vbNullString, vbNullString)
	Call makePageFooter(True)
End If

If Not bError Then

If bConfirmed Then
	Dim objReturn, objErrMsg
	Dim cmdDelete, rsDelete
	Set cmdDelete = Server.CreateObject("ADODB.Command")
	With cmdDelete
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = strStoredProcName
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, IIf(user_bSuperUser,Null,user_strAgency))
		.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
		
	Set rsDelete = cmdDelete.Execute
	Set rsDelete = rsDelete.NextRecordset
	
	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
				"delete_manage.asp", _
				vbNullString, _
				False)
		Case Else
			Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				"delete_manage.asp", _
				vbNullString)
	End Select
Else
%>

<%	
	Call makePageHeader(TXT_CONFIRM_DELETE, TXT_CONFIRM_DELETE, True, False, True, True)

	Dim strOrgName, _
		strLnLink, _
		strLnOverride, _
		fldLinkID, _
		fldDID, _
		fldCulture, _
		fldCanDelete, _
		fldCanSee, _
		bCanDeleteRecord, _
		strNewIDList, _
		strNewIDListCon

	strNewIDList = vbNullString
	strNewIDListCon = vbNullString

	Dim cmdMarkDeleted, rsMarkDeleted

	Set cmdMarkDeleted = Server.CreateObject("ADODB.Command")
	With cmdMarkDeleted
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & ps_strDbArea & "_" & strDbAreaID & "MarkedDeleted_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
		.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, IIf(user_bSuperUser,Null,user_strAgency))
		.Parameters.Append .CreateParameter("@IdList", adVarWChar, adParamInput, -1, strIDList)
	End With

	Set rsMarkDeleted = Server.CreateObject("ADODB.Recordset")

	With rsMarkDeleted
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdMarkDeleted

		If .EOF Then
%>
<p><%=TXT_NO_DELETED%>.</p>
<%
		Else
			If .RecordCount > 10000 Then
				' If we have a lot of records, let the script timout be 10 minutes
				' This is actually driven by end browser render time, not how longYour 
				' it takes to generate the page.
				Server.ScriptTimeout = 600
			End If
	
%>
<p class="Alert"><%=TXT_CANNOT_DELETE_RECORDS_IN_USE%></p>
<ul>
<%
			If g_bOtherMembersActive Then
%>
	<li><span class="Alert">S</span><%=TXT_COLON & TXT_CANNOT_DELETE_SHARED_RECORDS%></li>
<%
			End If
			If ps_intDbArea = DM_VOL Then
%>
	<li><span class="Alert">R</span><%=TXT_COLON & TXT_CANNOT_DELETE_VOL_W_REFERRAL%></li>
<%
			End If
			If ps_intDbArea = DM_CIC And g_bUseVOL Then
%>
	<li><span class="Alert">V</span><%=TXT_COLON & TXT_CANNOT_DELETE_ORG_W_OPPS%></li>
	<li><span class="Alert">A</span><%=TXT_COLON & TXT_CANNOT_DELETE_AGENCY_ORG%></li>
	<li><span class="Alert">M</span><%=TXT_COLON & TXT_CANNOT_DELETE_VOL_MEMBER_ORG%></li>
<%
			End If
%>
</ul>
<p class="Info"><%=TXT_ONLY_MARKED & " " & TXT_VIEW_BEFORE_DELETE%></p>
<hr>
<table class="BasicBorder cell-padding-3">
<tr>
	<th></th>
	<th><%=TXT_RECORD_OWNER%></th>
	<th><%=TXT_LANGUAGE%></th>
<%	
	Set fldCulture = .Fields("Culture")
	Set fldCanDelete = .Fields("CAN_DELETE")
	Set fldCanSee = .Fields("CAN_SEE")
	Select Case ps_intDbArea
		Case DM_CIC
			Set fldLinkID = .Fields("NUM")
			Set fldDID = .Fields("BTD_ID")
%>
	<th><%=TXT_ORG_NAMES%></th>		
<%
		Case DM_VOL
			Set fldLinkID = .Fields("VNUM")
			Set fldDID = .Fields("OPD_ID")
%>
	<th><%=TXT_POSITION_TITLE%></th>
<%
	End Select
%>
	<th><%=TXT_DELETION_DATE%></th>
</tr>
<%
	Dim i
	i = 0

	While Not .EOF
		strOrgName = .Fields("ORG_NAME_FULL")
		bCanDeleteRecord = user_bSuperUserDOM And Nl(fldCanDelete.Value)
		If bCanDeleteRecord Then
			strNewIDList = strNewIDList & strNewIDListCon & fldDID
			strNewIDListCon = ","
		End If
%>
<tr>
<%

%>
	<td><%If bCanDeleteRecord Then%><img src="<%=ps_strPathToStart%>images/greencheck.gif" alt=<%=AttrQs(TXT_DELETE)%>><%Else%><span class="Alert"><%=fldCanDelete.Value%></span><%End If%></td>
	<td><%=.Fields("RECORD_OWNER")%></td>
	<td><%=.Fields("LanguageName")%></td>
<%	
		strLnLink = vbNullString
		strLnOverride = vbNullString
		If fldCulture.Value<>g_objCurrentLang.Culture Then
			strLnOverride = StringIf(.Fields("LangActive"), "Ln")
			strLnLink = IIf(Nl(strLnOverride), "TmpLn=", "Ln=") & fldCulture.Value
		End If
		Select Case ps_intDbArea
			Case DM_CIC
%>
	<td><%If fldCanSee.Value Then%><a href="<%=makeDetailsLink(fldLinkID.Value,strLnLink,strLnOverride)%>"><%End If%><%=strOrgName%><%If fldCanSee.Value Then%></a><%End If%></td>
<%
			Case DM_VOL
%>
	<td><%If fldCanSee.Value Then%><a href="<%=makeVOLDetailsLink(fldLinkID.Value,strLnLink,strLnOverride)%>"><%End If%><%=.Fields("POSITION_TITLE") & " (" & strOrgName & ")"%><%If fldCanSee.Value Then%></a><%End If%></td>
<%
	End Select
%>
	<td class="NoWrap text-right"><%=.Fields("DELETION_DATE")%></td>
</tr>
<%
		.MoveNext
		i = i + 1
		If i Mod 500 = 0 Then
			Response.Flush
		End If
	Wend
%>
</table>
<%
	If Not Nl(strNewIDList) Then
%>
<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE%></span></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="IDList" value="<%=strNewIDList%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" value="<%=TXT_DELETE%>">
</form>
<%
	End If

		End If
	End With

	Call makePageFooter(True)
End If

End If
%>
