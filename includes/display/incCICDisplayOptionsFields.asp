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
Dim opt_fld_bNUM, _
	opt_fld_bRecordOwnerCIC, _
	opt_fld_bAlertCIC, _
	opt_fld_bOrgCIC, _
	opt_fld_bLocated, _
	opt_fld_bUpdateScheduleCIC, _
	opt_bUpdateCIC, _
	opt_bEmailCIC, _
	opt_bSelectCIC, _
	opt_bWebCIC, _
	opt_bListAddRecordCIC, _
	opt_intOrderByCIC, _
	opt_fld_intCustOrderCIC, _
	opt_bOrderByDescCIC, _
	opt_bTableSortCIC, _
	opt_bDispTableCIC, _
	opt_bMail, _
	opt_bPub, _
	opt_fld_aCustCIC	

opt_fld_bNUM = False
opt_fld_bRecordOwnerCIC = False
opt_fld_bAlertCIC = False
opt_fld_bOrgCIC = True
opt_fld_bLocated = True
opt_fld_bUpdateScheduleCIC = False
opt_bUpdateCIC = False
opt_bEmailCIC = False
opt_bSelectCIC = False
opt_bWebCIC = False
opt_bListAddRecordCIC = False
opt_intOrderByCIC = OB_NAME
opt_fld_intCustOrderCIC = Null
opt_bOrderByDescCIC = False
opt_bTableSortCIC = False
opt_bDispTableCIC = True
opt_bMail = False
opt_bPub = False
opt_fld_aCustCIC = Null

Sub getDisplayOptionsCIC(intViewType, bForView)
Dim bAlreadyLoaded
bAlreadyLoaded = getSessionValue("opt_bSessionSettingsCIC") 

If Nl(bAlreadyLoaded) Then
	bAlreadyLoaded = False
End If

If Not bAlreadyLoaded Or bForView Then
	Dim cmdDisplay, rsDisplay
	Set cmdDisplay = Server.CreateObject("ADODB.Command")
	
	With cmdDisplay
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		If Not bForView Then
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_Display_s_User"
			.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		Else
			.ActiveConnection = getCurrentBasicCnn()
			.CommandText = "dbo.sp_GBL_Display_s_View"
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
		End If
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, DM_CIC)
	End With
	Set rsDisplay = Server.CreateObject("ADODB.Recordset")
	With rsDisplay
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdDisplay
	End With

	If Not bForView And rsDisplay.EOF Then
		Call getDisplayOptionsCIC(intViewType, True)
		Exit Sub
	End If
	
	With rsDisplay
		If Not .EOF Then
			opt_fld_bNUM = .Fields("ShowID")
			opt_fld_bRecordOwnerCIC = .Fields("ShowOwner")
			opt_fld_bAlertCIC = .Fields("ShowAlert")
			opt_fld_bOrgCIC = .Fields("ShowOrg")
			opt_fld_bLocated = .Fields("ShowCommunity")
			opt_fld_bUpdateScheduleCIC = .Fields("ShowUpdateSchedule")
			opt_bUpdateCIC = .Fields("LinkUpdate")
			opt_bEmailCIC = .Fields("LinkEmail")
			opt_bSelectCIC = .Fields("LinkSelect")
			opt_bWebCIC = .Fields("LinkWeb") And Not g_bPrintMode
			opt_bListAddRecordCIC = .Fields("LinkListAdd")
			opt_intOrderByCIC = Nz(.Fields("OrderBy"),OB_NAME)
			opt_fld_intCustOrderCIC = .Fields("OrderByCustom")
			opt_bOrderByDescCIC = .Fields("OrderByDesc")
			opt_bTableSortCIC = .Fields("TableSort")
			opt_bDispTableCIC = .Fields("ShowTable")
			opt_bMail = .Fields("GLinkMail")
			opt_bPub = .Fields("GLinkPub")
			opt_fld_aCustCIC = Null
		End If
	End With
	
	Set rsDisplay = rsDisplay.NextRecordset
	With rsDisplay
		Dim aTmpFieldList, i
		
		If Not .EOF Then
			ReDim aTmpFieldList(.RecordCount - 1)
			i = 0
			While Not .EOF
				aTmpFieldList(i) = .Fields("FieldID")
				i = i + 1
				.MoveNext
			Wend
			opt_fld_aCustCIC = aTmpFieldList
		End If
	End With
	
	If Not bForView And user_bLoggedIn Then
		Call setSessionValue("opt_bSessionSettingsCIC", True)
		Call setSessionValue("opt_fld_bNUM", opt_fld_bNUM)
		Call setSessionValue("opt_fld_bRecordOwnerCIC", opt_fld_bRecordOwnerCIC)
		Call setSessionValue("opt_fld_bAlertCIC", opt_fld_bAlertCIC And g_bAlertColumnCIC)
		Call setSessionValue("opt_fld_bOrgCIC", opt_fld_bOrgCIC)
		Call setSessionValue("opt_fld_bLocated", opt_fld_bLocated)
		Call setSessionValue("opt_fld_bUpdateScheduleCIC", opt_fld_bUpdateScheduleCIC)
		Call setSessionValue("opt_bUpdateCIC", opt_bUpdateCIC)
		Call setSessionValue("opt_bEmailCIC", opt_bEmailCIC)
		Call setSessionValue("opt_bSelectCIC", opt_bSelectCIC)
		Call setSessionValue("opt_bWebCIC", opt_bWebCIC)
		Call setSessionValue("opt_bListAddRecordCIC", opt_bListAddRecordCIC)
		Call setSessionValue("opt_intOrderByCIC", opt_intOrderByCIC)
		Call setSessionValue("opt_fld_intCustOrderCIC", opt_fld_intCustOrderCIC)
		Call setSessionValue("opt_bOrderByDescCIC", opt_bOrderByDescCIC)
		Call setSessionValue("opt_bTableSortCIC", opt_bTableSortCIC)
		Call setSessionValue("opt_bDispTableCIC", opt_bDispTableCIC)
		Call setSessionValue("opt_bMail", opt_bMail)
		Call setSessionValue("opt_bPub", opt_bPub)
		If IsArray(opt_fld_aCustCIC) Then
			Call setSessionValue("opt_fld_aCustCIC", Join(opt_fld_aCustCIC, ","))
		Else
			Call setSessionValue("opt_fld_aCustCIC", vbNullString)
		End If
	End If
Else
	opt_fld_bNUM = Nz(getSessionValue("opt_fld_bNUM"),opt_fld_bNUM)
	opt_fld_bRecordOwnerCIC = Nz(getSessionValue("opt_fld_bRecordOwnerCIC"),opt_fld_bRecordOwnerCIC)
	opt_fld_bAlertCIC = Nz(getSessionValue("opt_fld_bAlertCIC"),opt_fld_bAlertCIC) And g_bAlertColumnCIC
	opt_fld_bOrgCIC = Nz(getSessionValue("opt_fld_bOrgCIC"),opt_fld_bOrgCIC)
	opt_fld_bLocated = Nz(getSessionValue("opt_fld_bLocated"),opt_fld_bLocated)
	opt_fld_bUpdateScheduleCIC = Nz(getSessionValue("opt_fld_bUpdateScheduleCIC"),opt_fld_bUpdateScheduleCIC)
	opt_bUpdateCIC = Nz(getSessionValue("opt_bUpdateCIC"),opt_bUpdateCIC) And user_bLoggedIn
	opt_bEmailCIC = Nz(getSessionValue("opt_bEmailCIC"),opt_bEmailCIC) And user_bLoggedIn
	opt_bSelectCIC = Nz(getSessionValue("opt_bSelectCIC"),opt_bSelectCIC) And user_bLoggedIn
	opt_bWebCIC = Nz(getSessionValue("opt_bWebCIC"),opt_bWebCIC)
	opt_bListAddRecordCIC = Nz(getSessionValue("opt_bListAddRecordCIC"),opt_bListAddRecordCIC)
	If Not Nl(getSessionValue("opt_intOrderByCIC")) Then
		If IsPosSmallInt(getSessionValue("opt_intOrderByCIC")) Then
			opt_intOrderByCIC = CInt(getSessionValue("opt_intOrderByCIC"))
		End If
	End If
	opt_fld_intCustOrderCIC = Nz(getSessionValue("opt_fld_intCustOrderCIC"),opt_fld_intCustOrderCIC)
	opt_bOrderByDescCIC = Nz(getSessionValue("opt_bOrderByDescCIC"),opt_bOrderByDescCIC)
	opt_bTableSortCIC = Nz(getSessionValue("opt_bTableSortCIC"),opt_bTableSortCIC)
	opt_bDispTableCIC = Nz(getSessionValue("opt_bDispTableCIC"),opt_bDispTableCIC)
	opt_bMail = Nz(getSessionValue("opt_bMail"),opt_bMail) And user_bLoggedIn
	opt_bPub = Nz(getSessionValue("opt_bPub"),opt_bPub) And user_bLoggedIn
	If Not Nl(getSessionValue("opt_fld_aCustCIC")) Then
		'Response.Write("opt_fld_aCustCIC")
		opt_fld_aCustCIC = getSessionValue("opt_fld_aCustCIC")
		If Not Nl(opt_fld_aCustCIC) Then
			opt_fld_aCustCIC = Split(opt_fld_aCustCIC, ",")
		End If
	End If
End If

End Sub


Sub printDisplayOptionsFormCIC(intViewType, bForView)

Call getDisplayOptionsCIC(intViewType, bForView)

If Not bForView Then
	'Response.Write("Setting Session")
	Call setSessionValue("session_test", "ok")
%>
<form method="post" action="display_options2.asp" name="EntryForm">
<%=g_strCacheFormVals%>
<%
End If
%>
<table class="BasicBorder cell-padding-3"<%If Not bForView Then%> align="center"<%End If%>>
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_CHANGE_RESULTS_DISPLAY%></th>
</tr>
<tr>
	<th><%=TXT_SHOW_FIELDS%></th>
</tr>
<tr>
	<td>
	<table class="NoBorder cell-padding-2" width="100%">
		<tr>
		<td><label for="opt_fld_bNUM"><input name="opt_fld_bNUM" id="opt_fld_bNUM" type="checkbox"<%=Checked(opt_fld_bNUM)%> />&nbsp;<%=TXT_RECORD_NUM%></label></td>
		<td><label for="opt_fld_bRecordOwnerCIC"><input name="opt_fld_bRecordOwnerCIC" id="opt_fld_bRecordOwnerCIC" type="checkbox"<%=Checked(opt_fld_bRecordOwnerCIC)%> />&nbsp;<%=TXT_RECORD_OWNER%></label></td>
		<td><label for="opt_fld_bOrgCIC"><input name="opt_fld_bOrgCIC" id="opt_fld_bOrgCIC" type="checkbox"<%=Checked(opt_fld_bOrgCIC)%> />&nbsp;<%=TXT_ORG_NAMES_SHORT%></label></td>
		</tr>
		<tr>
		<td><label for="opt_fld_bLocated"><input name="opt_fld_bLocated" id="opt_fld_bLocated" type="checkbox"<%=Checked(opt_fld_bLocated)%> />&nbsp;<%=TXT_LOCATED_IN%></label></td>
		<td><label for="opt_fld_bUpdateScheduleCIC"><input name="opt_fld_bUpdateScheduleCIC" id="opt_fld_bUpdateScheduleCIC" type="checkbox"<%=Checked(opt_fld_bUpdateScheduleCIC)%> />&nbsp;<%=TXT_UPDATE_SCHEDULE%></label></td>
<%If g_bAlertColumnCIC And Not bForView Then%>
		<td><label for="opt_fld_bAlertCIC"><input name="opt_fld_bAlertCIC" id="opt_fld_bAlertCIC" type="checkbox"<%=Checked(opt_fld_bAlertCIC)%> />&nbsp;<%=TXT_ALERT_BOX%></label></td>
<%Else%>
		<td><input type="hidden" name="opt_fld_bAlertCIC" value="<%=IIf(opt_fld_bAlertCIC And Not bForView,"on",vbNullString)%>">&nbsp;</td>
<%End If%>
		</tr>
	</table>
	</td>
</tr>
<tr>
	<td>
<%
	Call openCustFieldRst(DM_CIC, intViewType, False, False)
%>
	<table class="NoBorder cell-padding-2" width="100%">
	<tr>
		<td style="vertical-align: top;"><%=TXT_CUSTOM_FIELDS & TXT_COLON%>
		<br><span class="SmallNote">(<%=TXT_HOLD_CTRL%>)</span>
		<br><input type="BUTTON" value="<%=TXT_CLEAR_SELECTIONS%>" onClick="for(var i=0;i<document.EntryForm.opt_fld_aCustCIC.length;i++){document.EntryForm.opt_fld_aCustCIC.options[i].selected = false;};"></td>
		<td><%=makeCustFieldList(opt_fld_aCustCIC,"opt_fld_aCustCIC",False,True,5)%></td>
	</tr>
	</table>
	</td>
</tr>
<tr>
	<th><%=TXT_SHOW_OPTIONS%></th>
</tr>
<tr>
	<td><table class="NoBorder cell-padding-2" width="100%">
<%If Not bForView Then%>
	<tr>
		<td><label for="opt_bUpdateCIC"><input<%If opt_bUpdateCIC Then%> checked<%End If%> name="opt_bUpdateCIC" id="opt_bUpdateCIC" type="checkbox">&nbsp;<%=TXT_UPDATE_RECORD%></label></td>
		<td><label for="opt_bSelectCIC"><input<%If opt_bSelectCIC Then%> checked<%End If%> name="opt_bSelectCIC" id="opt_bSelectCIC" type="checkbox">&nbsp;<%=TXT_SELECT_CHECKBOX%></label></td>
	</tr>
<%End If%>
<%If user_bCanRequestUpdateCIC And Not bForView Then%>
	<tr>
		<td><label for="opt_bMail"><input<%If opt_bMail Then%> checked<%End If%> name="opt_bMail" id="opt_bMail" type="checkbox">&nbsp;<%=TXT_MAIL_FORM%></label></td>
	<%If g_bNoEmail Then%>
		<td><input type="hidden" name="opt_bEmailCIC" value="">&nbsp;</td>
	<%Else%>
		<td><label for="opt_bEmailCIC"><input<%If opt_bEmailCIC Then%> checked<%End If%> name="opt_bEmailCIC" id="opt_bEmailCIC" type="checkbox">&nbsp;<%=TXT_EMAIL_UPDATE_REQUEST%></label></td>
	<%End If%>
	</tr>
<%Else%>
<input type="hidden" name="opt_bMail" value="">
<input type="hidden" name="opt_bEmailCIC" value="">
<%End If%>
	<tr>
		<td><label for="opt_bDispTableCIC"><input name="opt_bDispTableCIC" id="opt_bDispTableCIC" type="checkbox"<%=Checked(opt_bDispTableCIC)%>>&nbsp;<%=TXT_USE_TABLE_FORMAT%></label></td>
<% 
Dim intColCount 
intColCount = 1
If user_intCanUpdatePubs <> UPDATE_NONE And Not user_bLimitedViewCIC And Not bForView Then
	intColCount = intColCount + 1
%>
		<td><label for="opt_bPub"><input<%If opt_bPub Then%> checked<%End If%> name="opt_bPub" id="opt_bPub" type="checkbox">&nbsp;<%=TXT_UPDATE_PUBS%></label></td>
<%
End If
If intColCount Mod 2 = 0 Then
%></tr><tr><%
End If
%>

		<td><label for="opt_bWebCIC"><input<%If opt_bWebCIC Then%> checked<%End If%> name="opt_bWebCIC" id="opt_bWebCIC" type="checkbox">&nbsp;<%=TXT_WEB_ENABLE%></label></td>
<%
intColCount = intColCount + 1
If intColCount Mod 2 = 0 And (g_bMyListCIC Or Not Nl(g_strClientTrackerIP)) Then
%></tr><tr><%
End If
%>
<%If (g_bMyListCIC Or Not Nl(g_strClientTrackerIP)) Then
intColCount = intColCount + 1
%>
		<td<%If intColCount Mod 2 = 1 Then%> colspan="2"<%End If%>><label for="opt_bListAddRecordCIC"><input<%If opt_bListAddRecordCIC Then%> checked<%End If%> name="opt_bListAddRecordCIC" id="opt_bListAddRecordCIC" type="checkbox">&nbsp;<%=TXT_LIST_CLIENT_TRACKER%></label></td>
<%ElseIf intColCount Mod 2 = 1 Then%>
		<td>&nbsp;</td>
<%End If%>
	</tr>
	</table></td>
</tr>
<tr>
	<th><%=TXT_ORDER_RESULTS_BY%></th>
</tr>
<tr>
	<td align="center"><label for="opt_intOrderByCIC_O"><input<%If opt_intOrderByCIC = OB_NAME Then%> checked<%End If%> type="radio" name="opt_intOrderByCIC" id="opt_intOrderByCIC_O" value="<%=OB_NAME%>">&nbsp;<%=TXT_ORG_NAMES_SHORT%></label>
	<label class="NoWrap" for="opt_intOrderByCIC_R"><input<%If opt_intOrderByCIC = OB_NUM Then%> checked<%End If%> type="radio" name="opt_intOrderByCIC" id="opt_intOrderByCIC_R" value="<%=OB_NUM%>">&nbsp;<%=TXT_RECORD_NUM%></label>
	<label class="NoWrap" for="opt_intOrderByCIC_U"><input<%If opt_intOrderByCIC = OB_UPDATE Then%> checked<%End If%> type="radio" name="opt_intOrderByCIC" id="opt_intOrderByCIC_U" value="<%=OB_UPDATE%>">&nbsp;<%=TXT_UPDATE_SCHEDULE%></label>
	<label class="NoWrap" for="opt_intOrderByCIC_L"><input<%If opt_intOrderByCIC = OB_LOCATION Then%> checked<%End If%> type="radio" name="opt_intOrderByCIC" id="opt_intOrderByCIC_L" value="<%=OB_LOCATION%>">&nbsp;<%=TXT_LOCATED_IN%></label>
	<br><label class="NoWrap" for="opt_intOrderByCIC_RE"><input<%If opt_intOrderByCIC = OB_RELEVANCY Then%> checked<%End If%> type="radio" name="opt_intOrderByCIC" id="opt_intOrderByCIC_RE" value="<%=OB_RELEVANCY%>">&nbsp;<%=TXT_RELEVANCY%></label>
	<label class="NoWrap" for="opt_intOrderByCIC_C"><input<%If opt_intOrderByCIC = OB_CUSTOM Then%> checked<%End If%> type="radio" name="opt_intOrderByCIC" id="opt_intOrderByCIC_C" value="<%=OB_CUSTOM%>">&nbsp;<%=TXT_CUSTOM_SPECIFY%></label>&nbsp;<%=makeCustFieldList(opt_fld_intCustOrderCIC,"opt_fld_intCustOrderCIC",True,False,0)%>
	<br><%=TXT_SORT & TXT_COLON%><label for="opt_bOrderByDescCIC_A"><input <%=Checked(Not opt_bOrderByDescCIC)%> type="radio" name="opt_bOrderByDescCIC" id="opt_bOrderByDescCIC_A" value="">&nbsp;<%=TXT_ASCENDING%></label>
	<label for="opt_bOrderByDescCIC_D"><input <%=Checked(opt_bOrderByDescCIC)%> type="radio" name="opt_bOrderByDescCIC" id="opt_bOrderByDescCIC_D" value="on">&nbsp;<%=TXT_DESCENDING%></label></td>
	<br><label for="opt_bTableSortCIC"><input <%=Checked(opt_bTableSortCIC)%> type="checkbox" name="opt_bTableSortCIC" id="opt_bTableSortCIC" value="on">&nbsp;<%=TXT_DESCENDING%></label></td>
</tr>
<%
	Call closeCustFieldRst()
%>
<%If Not bForView Then%>
<tr>
	<td align="center" class="RevTitleBox"><input type="submit" value="<%=TXT_UPDATE_DISPLAY%>"></td>
</tr>
<%End If%>
</table>
<%If Not bForView Then%>
</form>
<%End If%>
<%
End Sub

Sub setViewDisplayOptionsFormCIC()

Dim aTmpFldList, i

opt_fld_bNUM = Request.Form("opt_fld_bNUM") = "on"
opt_fld_bRecordOwnerCIC = Request.Form("opt_fld_bRecordOwnerCIC") = "on"
opt_fld_bOrgCIC = Request.Form("opt_fld_bOrgCIC") = "on"
opt_fld_bLocated = Request.Form("opt_fld_bLocated") = "on"
opt_fld_bUpdateScheduleCIC = Request.Form("opt_fld_bUpdateScheduleCIC") = "on"
opt_bWebCIC = Request.Form("opt_bWebCIC") = "on"
opt_bListAddRecordCIC = Request.Form("opt_bListAddRecordCIC") = "on"
If Not Nl(Request.Form("opt_intOrderByCIC")) And IsPosSmallInt(Request.Form("opt_intOrderByCIC")) Then
	opt_intOrderByCIC = Request.Form("opt_intOrderByCIC")
Else
	opt_intOrderByCIC = OB_NAME
End If
If Not Nl(Request.Form("opt_fld_intCustOrderCIC")) And IsIDType(Request.Form("opt_fld_intCustOrderCIC")) Then
	opt_fld_intCustOrderCIC = CInt(Request.Form("opt_fld_intCustOrderCIC"))
Else
	opt_fld_intCustOrderCIC = Null
End If
opt_bOrderByDescCIC = Request.Form("opt_bOrderByDescCIC") = "on"
opt_bTableSortCIC = Request.Form("opt_bTableSortCIC") = "on"
opt_bDispTableCIC = Request.Form("opt_bDispTableCIC") = "on"
aTmpFldList = Split(Request.Form("opt_fld_aCustCIC"),",")
For i = 0 to UBound(aTmpFldList)
	aTmpFldList(i) = Trim(aTmpFldList(i))
Next
opt_fld_aCustCIC = aTmpFldList

End Sub

Sub setTempDisplayOptionsCIC()

Dim aTmpFldList, i

'Response.Write("set session test #2: ")
If getSessionValue("session_test") = "ok" Then
	Call setSessionValue("opt_bSessionSettingsCIC", True)
	
	Call setSessionValue("opt_fld_bNUM", Request.Form("opt_fld_bNUM") = "on")
	Call setSessionValue("opt_fld_bRecordOwnerCIC", Request.Form("opt_fld_bRecordOwnerCIC") = "on")
	Call setSessionValue("opt_fld_bOrgCIC", Request.Form("opt_fld_bOrgCIC") = "on")
	Call setSessionValue("opt_fld_bAlertCIC", Request.Form("opt_fld_bAlertCIC") = "on" And g_bAlertColumnCIC)
	Call setSessionValue("opt_fld_bLocated", Request.Form("opt_fld_bLocated") = "on")
	Call setSessionValue("opt_fld_bUpdateScheduleCIC", Request.Form("opt_fld_bUpdateScheduleCIC") = "on")
	Call setSessionValue("opt_bUpdateCIC", Request.Form("opt_bUpdateCIC") = "on")
	Call setSessionValue("opt_bEmailCIC", Request.Form("opt_bEmailCIC") = "on" And user_bCanRequestUpdateCIC)
	Call setSessionValue("opt_bSelectCIC", Request.Form("opt_bSelectCIC") = "on")
	Call setSessionValue("opt_bWebCIC", Request.Form("opt_bWebCIC") = "on")
	Call setSessionValue("opt_bListAddRecordCIC", Request.Form("opt_bListAddRecordCIC") = "on")
	If Not Nl(Request.Form("opt_intOrderByCIC")) And IsIDType(Request.Form("opt_intOrderByCIC")) Then
		Call setSessionValue("opt_intOrderByCIC", CInt(Request.Form("opt_intOrderByCIC")))
	Else
		Call setSessionValue("opt_intOrderByCIC", OB_NAME)
	End If
	If Not Nl(Request.Form("opt_fld_intCustOrderCIC")) And IsIDType(Request.Form("opt_fld_intCustOrderCIC")) Then
		Call setSessionValue("opt_fld_intCustOrderCIC", CInt(Request.Form("opt_fld_intCustOrderCIC")))
	Else
		Call setSessionValue("opt_fld_intCustOrderCIC", Null)
	End If
	Call setSessionValue("opt_bOrderByDescCIC", Request.Form("opt_bOrderByDescCIC") = "on")
	Call setSessionValue("opt_bTableSortCIC", Request.Form("opt_bTableSortCIC") = "on")
	Call setSessionValue("opt_bDispTableCIC", Request.Form("opt_bDispTableCIC") = "on")
	Call setSessionValue("opt_bMail", Request.Form("opt_bMail") = "on" And user_bCanRequestUpdateCIC)
	Call setSessionValue("opt_bPub", Request.Form("opt_bPub") = "on" And ps_intDbArea=DM_CIC And user_intCanUpdatePubs <> UPDATE_NONE And Not user_bLimitedViewCIC)
	aTmpFldList = Split(Request.Form("opt_fld_aCustCIC"),",")
	For i = 0 to UBound(aTmpFldList)
		aTmpFldList(i) = Trim(aTmpFldList(i))
	Next
	Call setSessionValue("opt_fld_aCustCIC", Join(aTmpFldList, ","))
	
	Call handleMessage(TXT_SETTINGS_UPDATED, _
			vbNullString, vbNullString, False)
%>
<p align="center">[ <a href="<%=makeLinkB("display_options3.asp")%>" style="text-decoration: none"><%=TXT_SET_AS_DEFAULT%></a> ]</p>
<%
Else
	Call handleError(TXT_SETTINGS_NOT_UPDATED, _
		vbNullString, vbNullString)
End If
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a><%= makePageHelpLink() %> ]</p>
<%
End Sub

Sub saveDisplayOptionsCIC( _
	intUserID, _
	intViewType, _
	bShowID, _
	bShowOwner, _
	bShowAlert, _
	bShowOrg, _
	bShowCommunity, _
	bShowUpdateSchedule, _
	bLinkUpdate, _
	bLinkEmail, _
	bLinkSelect, _
	bLinkWeb, _
	bLinkCtAdd, _
	intOrderBy, _
	intOrderByCustom, _
	bOrderByDesc, _
	bTableSort, _
	bShowTable, _
	bGLinkMail, _
	bGLinkPub, _
	strFieldList _
	)

	If Nl(intUserID) Then
		intUserID = Null
	End If
	
	If Nl(intViewType) Then
		intViewType = Null
	End If

	Dim objReturn, objErrMsg
	Dim cmdDisplay, rsDisplay
	Set cmdDisplay = Server.CreateObject("ADODB.Command")
	With cmdDisplay
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.CommandText = "dbo.sp_GBL_Display_u"
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, intUserID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, DM_CIC)
		.Parameters.Append .CreateParameter("@ShowID", adBoolean, adParamInput, 1, IIf(bShowID,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@ShowOwner", adBoolean, adParamInput, 1, IIf(bShowOwner,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@ShowAlert", adBoolean, adParamInput, 1, IIf(bShowAlert And Not Nl(intUserID),SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@ShowOrg", adBoolean, adParamInput, 1, IIf(bShowOrg,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@ShowCommunity", adBoolean, adParamInput, 1, IIf(bShowCommunity,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@ShowUpdateSchedule", adBoolean, adParamInput, 1, IIf(bShowUpdateSchedule,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@LinkUpdate", adBoolean, adParamInput, 1, IIf(bLinkUpdate And Not Nl(intUserID),SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@LinkEmail", adBoolean, adParamInput, 1, IIf(bLinkEmail And Not Nl(intUserID),SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@LinkSelect", adBoolean, adParamInput, 1, IIf(bLinkSelect And Not Nl(intUserID),SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@LinkWeb", adBoolean, adParamInput, 1, IIf(bLinkWeb,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@LinkCtAdd", adBoolean, adParamInput, 1, IIf(bLinkCtAdd,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@OrderBy", adInteger, adParamInput, 4, intOrderBy)
		.Parameters.Append .CreateParameter("@OrderByCustom", adInteger, adParamInput, 4, intOrderByCustom)
		.Parameters.Append .CreateParameter("@OrderByDesc", adBoolean, adParamInput, 1, IIf(bOrderByDesc,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@TableSort", adBoolean, adParamInput, 1, IIf(bTableSort,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@GLinkMail", adBoolean, adParamInput, 1, IIf(bGLinkMail And Not Nl(intUserID),SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@GLinkPub", adBoolean, adParamInput, 1, IIf(bGLinkPub And Not Nl(intUserID),SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@ShowTable", adBoolean, adParamInput, 1, bShowTable)
		.Parameters.Append .CreateParameter("@VShowPosition", adBoolean, adParamInput, 1, SQL_FALSE)
		.Parameters.Append .CreateParameter("@VShowDuties", adBoolean, adParamInput, 1, SQL_FALSE)
		.Parameters.Append .CreateParameter("@FieldList", adLongVarChar, adParamInput, -1, strFieldList)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With

	Set rsDisplay = cmdDisplay.Execute
	Set rsDisplay = rsDisplay.NextRecordset

	If objReturn.Value <> 0 Then
		Call handleError(Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
			vbNullString, _
			vbNullString)
	End If

	Set rsDisplay = Nothing
	Set cmdDisplay = Nothing

End Sub
%>
