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
If Not user_bCanDeleteRecordDOM Then
	Call securityFailure()
End If

Call makePageHeader(TXT_MANAGE_DELETED, TXT_MANAGE_DELETED, True, False, True, True)
%>
<%
Dim strDbAreaID, _
	strLnLink, _
	strLnOverride, _
	fldLinkID, _
	fldDID, _
	fldCulture, _
	fldRefCount, _
	fldLastRef, _
	fldOpps, _
	fldCanDelete, _
	fldCanSee, _
	bCanDeleteRecord
	
strDbAreaID = IIf(ps_intDbArea = DM_VOL,"VNUM","NUM")

Dim cmdMarkDeleted, rsMarkDeleted

Set cmdMarkDeleted = Server.CreateObject("ADODB.Command")
With cmdMarkDeleted
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_" & ps_strDbArea & "_" & strDbAreaID & "MarkedDeleted_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
	.Parameters.Append .CreateParameter("@Agency", adVarChar, adParamInput, 3, IIf(user_bSuperUser,Null,user_strAgency))
	.Parameters.Append .CreateParameter("@IdList", adVarWChar, adParamInput, -1, Null)
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
			' If we have a lot of records, let the script timeout be 10 minutes
			' This is actually driven by end browser render time, not how longYour 
			' it takes to generate the page.
			Server.ScriptTimeout = 600
		End If
	
	If user_bSuperUserDOM Then
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
		If ps_intDbArea = DM_CIC Then
			If g_bUseVOL Then
%>
	<li><span class="Alert">V</span><%=TXT_COLON & TXT_CANNOT_DELETE_ORG_W_OPPS%></li>
	<li><span class="Alert">A</span><%=TXT_COLON & TXT_CANNOT_DELETE_AGENCY_ORG%></li>
<%			End If %>
	<li><span class="Alert">P</span><%=TXT_COLON & TXT_CANNOT_DELETE_PARENT_ORG%></li>
	<li><span class="Alert">L</span><%=TXT_COLON & TXT_CANNOT_DELETE_SITE%></li>
	<li><span class="Alert">M</span><%=TXT_COLON & TXT_CANNOT_DELETE_VOL_MEMBER_ORG%></li>
<%
		End If
%>
</ul>
<form name="RecordList" action="delete_perm.asp" method="post">
<%=g_strCacheFormVals%>
<p><input type="BUTTON" onClick="CheckAll();" value="<%=TXT_CHECK_ALL%>"> <input type="BUTTON" onClick="ClearAll();" value="<%=TXT_UNCHECK_ALL%>"> <input type="submit" value="<%=TXT_DELETE_SELECTED%>"></p>
<%
	End If
%>
<table class="BasicBorder cell-padding-3">
<tr>
<%
	If user_bSuperUserDOM Then
%>
	<th class="RevTitleBox">&nbsp;</th>
<%
	End If
%>
	<th class="RevTitleBox"><%=TXT_ID%></th>
	<th class="RevTitleBox"><%=TXT_RECORD_OWNER%></th>
	<th class="RevTitleBox"><%=TXT_LANGUAGE%></th>
<%	
	Set fldCulture = .Fields("Culture")
	Set fldCanDelete = .Fields("CAN_DELETE")
	Set fldCanSee = .Fields("CAN_SEE")
	Select Case ps_intDbArea
		Case DM_CIC
			Set fldLinkID = .Fields("NUM")
			Set fldDID = .Fields("BTD_ID")
			Set fldOpps = .Fields("OPPORTUNITIES")
%>
	<th class="RevTitleBox"><%=TXT_ORG_NAMES%></th>		
<%
			If g_bUseVOL Then
%>
	<th class="RevTitleBox"><%=TXT_VOLUNTEER%></th>
<%
			End If
		Case DM_VOL
			Set fldLinkID = .Fields("VNUM")
			Set fldDID = .Fields("OPD_ID")
			Set fldRefCount = .Fields("REFERRALS")
			Set fldLastRef = .Fields("LAST_REFERRAL")
%>
	<th class="RevTitleBox"><%=TXT_POSITION_TITLE%></th>
	<th class="RevTitleBox"><%=TXT_REFERRALS%></th>
	<th class="RevTitleBox"><%=TXT_LAST_REFERRAL%></th>
<%
	End Select
%>
	<th class="RevTitleBox"><%=TXT_DELETION_DATE%></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<%
	Dim i
	i = 0

	While Not .EOF
		bCanDeleteRecord = user_bSuperUserDOM And Nl(fldCanDelete.Value)
%>
<tr>
<%


		If user_bSuperUserDOM Then
%>
	<td><%If bCanDeleteRecord Then%><input type="checkbox" name="IDList" title=<%=AttrQs(TXT_SELECT_RECORD & TXT_COLON & fldDID.Value)%> value="<%=fldDID.Value%>"><%Else%><span class="Alert"><%=fldCanDelete.Value%></span><%End If%></td>
<%
		End If
%>
	<td class="NoWrap"><%= fldLinkID.Value %></td>
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
	<td><%If fldCanSee.Value Then%><a href="<%=makeDetailsLink(fldLinkID.Value,strLnLink,strLnOverride)%>"><%End If%><%=.Fields("ORG_NAME_FULL")%><%If fldCanSee.Value Then%></a><%End If%></td>
<%
			If g_bUseVOL Then
%>
	<td><%=fldOpps%></td>
<%
			End If
		Case DM_VOL
%>
	<td><%If fldCanSee.Value Then%><a href="<%=makeVOLDetailsLink(fldLinkID.Value,strLnLink,strLnOverride)%>"><%End If%><%=.Fields("POSITION_TITLE") & " (" & .Fields("ORG_NAME_FULL") & ")"%><%If fldCanSee.Value Then%></a><%End If%></td>
	<td><%=fldRefCount%></td>
	<td class="NoWrap text-right"><%=Nz(fldLastRef,"&nbsp;")%></td>
<%
	End Select
%>
	<td class="NoWrap text-right"><%=.Fields("DELETION_DATE")%></td>
	<td><%If bCanDeleteRecord Then%><a href="<%=makeLink("delete_perm.asp","IDList=" & fldDID.Value,vbNullString)%>"><%=TXT_PERMANENT_DELETE%></a><br><%End If%>
		<%If fldCanSee.Value Then%>
		<a href="<%=makeLink("delete_mark.asp","IDList=" & fldDID.Value & "&Unmark=on",vbNullString)%>"><%=TXT_RESTORE%></a>
		<br><a href="<%=makeLink("delete_mark.asp","IDList=" & fldDID.Value & "&DELETION_DATE=" & Server.URLEncode(.Fields("DELETION_DATE")),vbNullString)%>"><%=TXT_CHANGE_DATE%></a>
		<% End If %>
	</td>
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
	If user_bSuperUserDOM Then
%>
</form>
<%
	End If
	
	End If
End With
%>
<%
Call makePageFooter(True)
%>
