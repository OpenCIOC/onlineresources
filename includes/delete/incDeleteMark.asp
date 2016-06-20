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

Call makePageHeader(TXT_MARK_DELETED, TXT_MARK_DELETED, True, False, True, True)
%>
<%
Dim bError

bError = False

Dim strIDList, _
	bConfirmed, _
	dDeleteDate, _
	bMakeNP, _
	strMarkTxt

Dim cmdMarkDeleted, _
	rsMarkDeleted, _
	strDbAreaID, _
	bUseNUM, _
	bUseVNUM

bUseNUM = False
bUseVNUM = False

strIDList = Replace(Trim(Request("IDList"))," ",vbNullString)

If ps_intDbArea = DM_CIC And IsNUMList(strIDList) Then
	bUseNUM = True
End If
If ps_intDbArea = DM_VOL And IsVNUMList(strIDList) Then
	bUseVNUM = True
End If


If Nl(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
ElseIf Not bUseNUM And Not bUseVNUM Then
	If Not IsIDList(strIDList) Then
		bError = True
		Call handleError(TXT_NO_RECORD_CHOSEN, vbNullString, vbNullString)
	End If
End If

If ps_intDbArea = DM_VOL Then
	strDbAreaID = "VNUM"
Else
	strDbAreaID = "NUM"
End If

If Not bError Then

If Request("Unmark") = "on" Then
	bConfirmed = True
	dDeleteDate = Null
	bMakeNP = False
	strMarkTxt = TXT_RESTORED
Else
	bConfirmed = Request("Confirmed") = "on"
	dDeleteDate = Request("DELETION_DATE")
	bMakeNP = Request("MakeNP") = "on"
	If Nl(dDeleteDate) Then
		dDeleteDate = Now()
	End If
	If bConfirmed Then
		If Not IsSmallDate(dDeleteDate) Then
			Call handleError(TXT_WARNING & TXT_WARNING_INVALID_DATE, _
				vbNullString, vbNullString)
			dDeleteDate = Now()
		Else
			dDeleteDate = DateValue(dDeleteDate)
		End If
	Else
		If g_bUseVOL And ps_intDbArea = DM_CIC Then
			Dim strHasOpsList, strOrgName
			Set cmdMarkDeleted = Server.CreateObject("ADODB.Command")
			With cmdMarkDeleted
				.ActiveConnection = getCurrentAdminCnn()
				.CommandText = "dbo.sp_VOL_NUMHasOpportunities_l"
				.CommandType = adCmdStoredProc
				.CommandTimeout = 0
				.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
				.Parameters.Append .CreateParameter("@UseNUM", adBoolean, adParamInput, 1, IIf(bUseNUM, SQL_TRUE, SQL_FALSE))
			End With
			Set rsMarkDeleted = Server.CreateObject("ADODB.Recordset")
			With rsMarkDeleted
				.CursorType = adOpenForwardOnly
				.Open cmdMarkDeleted
				While Not .EOF
					strHasOpsList = strHasOpsList & "<tr><td>" & .Fields("RECORD_OWNER") & "</td><td>" & _
						"<a href=""" & makeDetailsLink(.Fields("NUM"),vbNullString,vbNullString) & """>" & _
						.Fields("NUM") & "</td><td>" & _
						.Fields("ORG_NAME_FULL") & "</td><td>" & _
						.Fields("CURRENT_PUBLIC") & "</td><td>" & _
						.Fields("TOTAL_COUNT") & "</td></tr>"
					.MoveNext
				Wend
				.Close
			End With
		End If
%>

<form name="EntryForm" action="<%=ps_strThisPage%>" method="post" id="EntryForm">
<%=g_strCacheFormVals%>
<input type="hidden" name="Confirmed" value="on">
<%If ps_intDbArea=DM_VOL And Request("UseVNUM")="on" Then%>
<input type="hidden" name="UseVNUM" value="on">
<%End If%>
<input type="hidden" name="IDList" value="<%=strIDList%>">
<h2><%=TXT_MARK_DELETED%></h2>
<p><%=TXT_DELETE_INSTRUCTIONS%></p>
<%
If g_bUseVOL And ps_intDbArea = DM_CIC Then
	If Not Nl(strHasOpsList) Then%>
<p><span class="AlertBubble"><%=TXT_RECORDS_HAVE_VOL%></span></p>
<table class="BasicBorder cell-padding-2">
<tr><th><%=TXT_RECORD_OWNER%></th><th><%=TXT_RECORD_NUM%></th><th><%=TXT_ORG_NAMES%></th><th><%=TXT_CURRENT_PUBLIC%></th><th><%=TXT_TOTAL%></th></tr>
<%=strHasOpsList%>
</table>
<br>
<%
	End If
End If
%>
<table class="BasicBorder cell-padding-2">
<%=makeRow("DELETION_DATE", TXT_DELETION_DATE, makeDateFieldVal("DELETION_DATE",dDeleteDate,True,True,True,True,True,False), False,False,False,False,False,False,True)%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_MAKE_NON_PUBLIC%></td>
	<td><label for="MakeNP"><input type="checkbox" name="MakeNP" id="MakeNP" checked> <%=TXT_INST_MAKE_NP%></label></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" value="<%=TXT_SUBMIT%>"></td>
</tr>
</table>
</form>
<form class="NotVisible" name="stateForm" id="stateForm">
<textarea id="cache_form_values"></textarea>
</form>
<%= makeJQueryScriptTags() %>
<%= JSVerScriptTag("scripts/datepicker.js") %>
<script type="text/javascript">
jQuery(function() {
		init_cached_state();
		restore_cached_state();
		});
</script>
<%
		g_bListScriptLoaded = True
	End If
	strMarkTxt = TXT_MARKED_DELETED
End If

If bConfirmed Then
	Dim objReturn, objErrMsg
	Set cmdMarkDeleted = Server.CreateObject("ADODB.Command")
	With cmdMarkDeleted
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & ps_strDbArea & "_" & strDbAreaID & "MarkDeleted_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
		.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strIDList)
		.Parameters.Append .CreateParameter("@DeletionDate", adDBDate, adParamInput, 1, dDeleteDate)
		.Parameters.Append .CreateParameter("@MakeNP", adBoolean, adParamInput, 1, IIf(bMakeNP,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
		If ps_intDbArea = DM_CIC Then
			.Parameters.Append .CreateParameter("@UseNUM", adBoolean, adParamInput, 1, IIf(bUseNUM, SQL_TRUE, SQL_FALSE))
			.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamOutput, 8)
		Else
			.Parameters.Append .CreateParameter("@UseVNUM", adBoolean, adParamInput, 1, IIf(bUseVNUM, SQL_TRUE, SQL_FALSE))
			.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamOutput, 10)
		End If
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsMarkDeleted = cmdMarkDeleted.Execute
	Set rsMarkDeleted = rsMarkDeleted.NextRecordset
	
	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & strMarkTxt & ".", _
				vbNullString, _
				vbNullString, _
				False)
		Case Else
			Call handleError(TXT_RECORDS_WERE_NOT & strMarkTxt & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				vbNullString, _
				vbNullString)
	End Select
%>
<p>[
<%
	If ps_intDbArea=DM_CIC Then
		If Not Nl(cmdMarkDeleted.Parameters("@NUM").Value) Then
%>
<a href="<%=makeDetailsLink(cmdMarkDeleted.Parameters("@NUM").Value,vbNullString,vbNullString)%>"><%=TXT_RECORD_DETAILS%></a> |
<%
		End If
	ElseIf ps_intDbArea=DM_VOL Then
		If Not Nl(cmdMarkDeleted.Parameters("@VNUM").Value) Then
%>
<a href="<%=makeVOLDetailsLink(cmdMarkDeleted.Parameters("@VNUM").Value,vbNullString,vbNullString)%>"><%=TXT_RECORD_DETAILS%></a> |
<%
		End If
	End If
%>
<a href="<%=makeLinkB("delete_manage.asp")%>"><%=TXT_DELETED_RECORDS%></a>
]</p>
<%
End If

End If
%>
<%
Call makePageFooter(True)
%>
