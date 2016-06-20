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
Dim opt_fld_bVNUM, _
	opt_fld_bRecordOwnerVOL, _
	opt_fld_bAlertVOL, _
	opt_fld_bOrgVOL, _
	opt_fld_bComm, _
	opt_fld_bUpdateScheduleVOL, _
	opt_bUpdateVOL, _
	opt_bEmailVOL, _
	opt_bSelectVOL, _
	opt_bWebVOL, _
	opt_bListAddRecordVOL, _
	opt_intOrderByVOL, _
	opt_fld_intCustOrderVOL, _
	opt_bOrderByDescVOL, _
	opt_bDispTable, _
	opt_fld_bPosition, _
	opt_fld_bDuties, _
	opt_fld_aCustVOL	

opt_fld_bVNUM = False
opt_fld_bRecordOwnerVOL = False
opt_fld_bAlertVOL = False
opt_fld_bOrgVOL = True
opt_fld_bComm = True
opt_fld_bUpdateScheduleVOL = False
opt_bUpdateVOL = False
opt_bEmailVOL = False
opt_bSelectVOL = False
opt_bWebVOL = False
opt_bListAddRecordVOL = False
opt_intOrderByVOL = OB_REQUEST
opt_fld_intCustOrderVOL = Null
opt_bOrderByDescVOL = False
opt_bDispTable = False
opt_fld_bPosition = True
opt_fld_bDuties = True
opt_fld_aCustVOL = Null

Sub getDisplayOptionsVOL(intViewType, bForView)
Dim bAlreadyLoaded
bAlreadyLoaded = getSessionValue("opt_bSessionSettingsVOL") 

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
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, DM_VOL)
	End With
	Set rsDisplay = Server.CreateObject("ADODB.Recordset")
	With rsDisplay
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdDisplay
	End With
	
	If Not bForView And rsDisplay.EOF Then
		Call getDisplayOptionsVOL(intViewType, True)
		Exit Sub
	End If
	
	With rsDisplay
		If Not .EOF Then
			opt_fld_bVNUM = .Fields("ShowID")
			opt_fld_bRecordOwnerVOL = .Fields("ShowOwner")
			opt_fld_bAlertVOL = .Fields("ShowAlert")
			opt_fld_bOrgVOL = .Fields("ShowOrg")
			opt_fld_bComm = .Fields("ShowCommunity")
			opt_fld_bUpdateScheduleVOL = .Fields("ShowUpdateSchedule")
			opt_bUpdateVOL = .Fields("LinkUpdate")
			opt_bEmailVOL = .Fields("LinkEmail")
			opt_bSelectVOL = .Fields("LinkSelect")
			opt_bWebVOL = .Fields("LinkWeb") And Not g_bPrintMode
			opt_bListAddRecordVOL = .Fields("LinkListAdd")
			opt_intOrderByVOL = Nz(.Fields("OrderBy"),OB_REQUEST)
			opt_fld_intCustOrderVOL = .Fields("OrderByCustom")
			opt_bOrderByDescVOL = .Fields("OrderByDesc")
			opt_bDispTable = .Fields("VShowTable")
			opt_fld_bPosition = .Fields("VShowPosition")
			opt_fld_bDuties = .Fields("VShowDuties")
			opt_fld_aCustVOL = Null
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
			opt_fld_aCustVOL = aTmpFieldList
		End If
	End With
	
	If Not bForView And user_bLoggedIn Then
		Call setSessionValue("opt_bSessionSettingsVOL", True)
		Call setSessionValue("opt_fld_bVNUM", opt_fld_bVNUM)
		Call setSessionValue("opt_fld_bRecordOwnerVOL", opt_fld_bRecordOwnerVOL)
		Call setSessionValue("opt_fld_bAlertVOL", opt_fld_bAlertVOL And g_bAlertColumnVOL)
		Call setSessionValue("opt_fld_bOrgVOL", opt_fld_bOrgVOL)
		Call setSessionValue("opt_fld_bComm", opt_fld_bComm)
		Call setSessionValue("opt_fld_bUpdateScheduleVOL", opt_fld_bUpdateScheduleVOL)
		Call setSessionValue("opt_bUpdateVOL", opt_bUpdateVOL)
		Call setSessionValue("opt_bEmailVOL", opt_bEmailVOL)
		Call setSessionValue("opt_bSelectVOL", opt_bSelectVOL)
		Call setSessionValue("opt_bWebVOL", opt_bWebVOL)
		Call setSessionValue("opt_bListAddRecordVOL", opt_bListAddRecordVOL)
		Call setSessionValue("opt_intOrderByVOL", opt_intOrderByVOL)
		Call setSessionValue("opt_fld_intCustOrderVOL", opt_fld_intCustOrderVOL)
		Call setSessionValue("opt_bOrderByDescVOL", opt_bOrderByDescVOL)
		Call setSessionValue("opt_bDispTable", opt_bDispTable)
		Call setSessionValue("opt_fld_bPosition", opt_fld_bPosition)
		Call setSessionValue("opt_fld_bDuties", opt_fld_bDuties)
		If IsArray(opt_fld_aCustVOL) Then
			Call setSessionValue("opt_fld_aCustVOL", Join(opt_fld_aCustVOL, ","))
		Else
			Call setSessionValue("opt_fld_aCustVOL", vbNullString)
		End If
	End If
Else
	opt_fld_bVNUM = Nz(getSessionValue("opt_fld_bVNUM"),opt_fld_bVNUM)
	opt_fld_bRecordOwnerVOL = Nz(getSessionValue("opt_fld_bRecordOwnerVOL"),opt_fld_bRecordOwnerVOL)
	opt_fld_bAlertVOL = Nz(getSessionValue("opt_fld_bAlertVOL"),opt_fld_bAlertVOL) And g_bAlertColumnVOL
	opt_fld_bOrgVOL = Nz(getSessionValue("opt_fld_bOrgVOL"),opt_fld_bOrgVOL)
	opt_fld_bComm = Nz(getSessionValue("opt_fld_bComm"),opt_fld_bComm)
	opt_fld_bUpdateScheduleVOL = Nz(getSessionValue("opt_fld_bUpdateScheduleVOL"),opt_fld_bUpdateScheduleVOL)
	opt_bUpdateVOL = Nz(getSessionValue("opt_bUpdateVOL"),opt_bUpdateVOL) And user_bLoggedIn
	opt_bEmailVOL = Nz(getSessionValue("opt_bEmailVOL"),opt_bEmailVOL) And user_bLoggedIn
	opt_bSelectVOL = Nz(getSessionValue("opt_bSelectVOL"),opt_bSelectVOL) And user_bLoggedIn
	opt_bWebVOL = Nz(getSessionValue("opt_bWebVOL"),opt_bWebVOL)
	opt_bListAddRecordVOL = Nz(getSessionValue("opt_bListAddRecordVOL"),opt_bListAddRecordVOL)
	If Not Nl(getSessionValue("opt_intOrderByVOL")) Then
		If IsPosSmallInt(getSessionValue("opt_intOrderByVOL")) Then
			opt_intOrderByVOL = CInt(getSessionValue("opt_intOrderByVOL"))
		End If
	End If
	opt_fld_intCustOrderVOL = Nz(getSessionValue("opt_fld_intCustOrderVOL"),opt_fld_intCustOrderVOL)
	opt_bOrderByDescVOL = Nz(getSessionValue("opt_bOrderByDescVOL"),opt_bOrderByDescVOL)
	opt_bDispTable = Nz(getSessionValue("opt_bDispTable"),opt_bDispTable)
	opt_fld_bPosition = Nz(getSessionValue("opt_fld_bPosition"),opt_fld_bPosition)
	opt_fld_bDuties = Nz(getSessionValue("opt_fld_bDuties"),opt_fld_bDuties)
	If Not Nl(getSessionValue("opt_fld_aCustVOL")) Then
		opt_fld_aCustVOL = getSessionValue("opt_fld_aCustVOL")
		If Not Nl(opt_fld_aCustVOL) Then
			opt_fld_aCustVOL = Split(opt_fld_aCustVOL, ",")
		End If
	End If
End If

End Sub


Sub printDisplayOptionsFormVOL(intViewType, bForView)

Call getDisplayOptionsVOL(intViewType, bForView)

If Not bForView Then
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
	<th><%=TXT_SHOW_OPTIONS%></th>
</tr>
<tr>
	<td><table class="NoBorder cell-padding-2" width="100%">
	<tr>
		<td><label for="opt_bDispTable"><input name="opt_bDispTable" id="opt_bDispTable" type="checkbox"<%=Checked(opt_bDispTable)%>>&nbsp;<%=TXT_USE_TABLE_FORMAT%></label></td>
		<td><label for="opt_bWebVOL"><input name="opt_bWebVOL" id="opt_bWebVOL" type="checkbox"<%=Checked(opt_bWebVOL)%>>&nbsp;<%=TXT_WEB_ENABLE%></label></td>
	</tr>
<%If Not bForView Then%>
	<tr>
		<td><label for="opt_bUpdateVOL"><input name="opt_bUpdateVOL" id="opt_bUpdateVOL" type="checkbox"<%=Checked(opt_bUpdateVOL)%> />&nbsp;<%=TXT_UPDATE_RECORD%></label></td>
		<td><label for="opt_bSelectVOL"><input name="opt_bSelectVOL" id="opt_bSelectVOL" type="checkbox"<%=Checked(opt_bSelectVOL)%> />&nbsp;<%=TXT_SELECT_CHECKBOX%></label></td>
	</tr>
<%Else%>
<div style="display:none">
	<input type="hidden" name="opt_bUpdateVOL" value="">
	<input type="hidden" name="opt_bSelectVOL" value="">
</div>
<%End If%>
<%If user_bCanRequestUpdateDOM And Not bForView And Not g_bNoEmail Then%>
	<tr>
		<td colspan="2"><label for="opt_bEmailVOL"><input name="opt_bEmailVOL" id="opt_bEmailVOL" type="checkbox"<%=Checked(opt_bEmailVOL)%> />&nbsp;<%=TXT_EMAIL_UPDATE_REQUEST%></label></td>
	</tr>
<%Else%>
<div style="display:none">
	<input type="hidden" name="opt_bEmailVOL" value="">
</div>
<%End If%>
	</table></td>
</tr>
<tr>
	<th><%=TXT_SHOW_FIELDS%> (Table Format only)</th>
</tr>
<tr>
	<td>
	<table class="NoBorder cell-padding-2" width="100%">
		<tr>
		<td><label for="opt_fld_bVNUM"><input name="opt_fld_bVNUM" id="opt_fld_bVNUM" type="checkbox"<%=Checked(opt_fld_bVNUM)%> />&nbsp;<%=TXT_ID%></label></td>
		<td><label for="opt_fld_bPosition"><input name="opt_fld_bPosition" id="opt_fld_bPosition" type="checkbox"<%=Checked(opt_fld_bPosition)%> />&nbsp;<%=TXT_POSITION_TITLE%></label></td>
		<td><label for="opt_fld_bOrgVOL"><input name="opt_fld_bOrgVOL" id="opt_fld_bOrgVOL" type="checkbox"<%=Checked( opt_fld_bOrgVOL)%> />&nbsp;<%=TXT_ORG_NAMES_SHORT%></label></td>
		</tr>
		<tr>
		<td><label for="opt_fld_bRecordOwnerVOL"><input name="opt_fld_bRecordOwnerVOL" id="opt_fld_bRecordOwnerVOL" type="checkbox"<%=Checked(opt_fld_bRecordOwnerVOL)%> />&nbsp;<%=TXT_RECORD_OWNER%></label></td>
		<td><label for="opt_fld_bComm"><input name="opt_fld_bComm" id="opt_fld_bComm" type="checkbox"<%=Checked(opt_fld_bComm)%> />&nbsp;<%=TXT_COMMUNITIES%></label></td>
		<td><label for="opt_fld_bDuties"><input name="opt_fld_bDuties" id="opt_fld_bDuties" type="checkbox"<%=Checked(opt_fld_bDuties)%> />&nbsp;<%=TXT_DUTIES%></label></td>
		</tr>
		<tr>
		<td><label for="opt_fld_bUpdateScheduleVOL"><input name="opt_fld_bUpdateScheduleVOL" id="opt_fld_bUpdateScheduleVOL" type="checkbox"<%=Checked(opt_fld_bUpdateScheduleVOL)%> />&nbsp;<%=TXT_UPDATE_SCHEDULE%></label></td>
<%
Dim bNeedExtraTD
bNeedExtraTD = False

If g_bAlertColumnVOL And Not bForView Then
	bNeedExtraTD = True
%>
		<td><label for="opt_fld_bAlertVOL"><input name="opt_fld_bAlertVOL" id="opt_fld_bAlertVOL" type="checkbox"<%=Checked(opt_fld_bAlertVOL)%> />&nbsp;<%=TXT_ALERT_BOX%></label></td>
<%Else%>
		<input type="hidden" name="opt_fld_bAlertVOL" value="<%=IIf(opt_fld_bAlertVOL And Not bForView,"on",vbNullString)%>">
<%End If
If (g_bMyListVOL Or Not Nl(g_strClientTrackerIP)) Then
%>
		<td<%If bNeedExtraTD Then%> colspan="2"<%End If%>><label for="opt_bListAddRecordVOL"><input name="opt_bListAddRecordVOL" id="opt_bListAddRecordVOL" type="checkbox"<%=Checked(opt_bListAddRecordVOL)%> />&nbsp;<%=TXT_LIST_CLIENT_TRACKER%></label></td>
<% Else %>
<td<%If bNeedExtraTD Then %> colspan="2"<%End If%>>&nbsp;</td>
<% End If %>
		</tr>
	</table>
	</td>
</tr>
<tr>
	<td>
<%
	Call openCustFieldRst(DM_VOL, intViewType, False, False)
%>
	<table class="NoBorder cell-padding-2" width="100%">
	<tr>
		<td style="vertical-align: top;"><%=TXT_CUSTOM_FIELDS & TXT_COLON%>
		<br><span class="SmallNote">(<%=TXT_HOLD_CTRL%>)</span>
		<br><input type="BUTTON" value="<%=TXT_CLEAR_SELECTIONS%>" onClick="for(var i=0;i<document.EntryForm.opt_fld_aCustVOL.length;i++){document.EntryForm.opt_fld_aCustVOL.options[i].selected = false;};"></td>
		<td><%=makeCustFieldList(opt_fld_aCustVOL,"opt_fld_aCustVOL",False,True,5)%></td>
	</tr>
	</table>
	</td>
</tr>
<tr>
	<th><%=TXT_ORDER_RESULTS_BY%></th>
</tr>
<tr>
	<td align="center"><label class="NoWrap" for="opt_intOrderByVOL_R"><input<%If opt_intOrderByVOL = OB_REQUEST Then%> checked<%End If%> type="radio" name="opt_intOrderByVOL" id="opt_intOrderByVOL_R" value="<%=OB_REQUEST%>">&nbsp;<%=TXT_REQUEST_DATE%></label>
	<label class="NoWrap" for="opt_intOrderByVOL_P"><input<%If opt_intOrderByVOL = OB_POS Then%> checked<%End If%> type="radio" name="opt_intOrderByVOL" id="opt_intOrderByVOL_P" value="<%=OB_POS%>">&nbsp;<%=TXT_POSITION_TITLE%></label>
	<label class="NoWrap" for="opt_intOrderByVOL_O"><input<%If opt_intOrderByVOL = OB_NAME Then%> checked<%End If%> type="radio" name="opt_intOrderByVOL" id="opt_intOrderByVOL_O" value="<%=OB_NAME%>">&nbsp;<%=TXT_ORG_NAMES_SHORT%></label>
	<br><label class="NoWrap" for="opt_intOrderByVOL_U"><input<%If opt_intOrderByVOL = OB_UPDATE Then%> checked<%End If%> type="radio" name="opt_intOrderByVOL" id="opt_intOrderByVOL_U" value="<%=OB_UPDATE%>">&nbsp;<%=TXT_UPDATE_SCHEDULE%></label>
	<br><label class="NoWrap" for="opt_intOrderByVOL_C"><input<%If opt_intOrderByVOL = OB_CUSTOM Then%> checked<%End If%> type="radio" name="opt_intOrderByVOL" id="opt_intOrderByVOL_C" value="<%=OB_CUSTOM%>">&nbsp;<%=TXT_CUSTOM_SPECIFY%></label>&nbsp;<%=makeCustFieldList(opt_fld_intCustOrderVOL,"opt_fld_intCustOrderVOL",True,False,0)%>
	<br><%=TXT_SORT & TXT_COLON%><label for="opt_bOrderByDescVOL_A"><input <%=Checked(Not opt_bOrderByDescVOL)%> type="radio" name="opt_bOrderByDescVOL" id="opt_bOrderByDescVOL_A" value="">&nbsp;<%=TXT_ASCENDING%></label>
	<label for="opt_bOrderByDescVOL_D"><input <%=Checked(opt_bOrderByDescVOL)%> type="radio" name="opt_bOrderByDescVOL" id="opt_bOrderByDescVOL_D" value="on">&nbsp;<%=TXT_DESCENDING%></label></td>
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

Sub setViewDisplayOptionsFormVOL()

Dim aTmpFldList, i

opt_fld_bVNUM = Request.Form("opt_fld_bVNUM") = "on"
opt_fld_bRecordOwnerVOL = Request.Form("opt_fld_bRecordOwnerVOL") = "on"
opt_fld_bOrgVOL = Request.Form("opt_fld_bOrgVOL") = "on"
opt_fld_bComm = Request.Form("opt_fld_bComm") = "on"
opt_fld_bUpdateScheduleVOL = Request.Form("opt_fld_bUpdateScheduleVOL") = "on"
opt_bWebVOL = Request.Form("opt_bWebVOL") = "on"
opt_bListAddRecordVOL = Request.Form("opt_bListAddRecordVOL") = "on"
If Not Nl(Request.Form("opt_intOrderByVOL")) And IsIDType(Request.Form("opt_intOrderByVOL")) Then
	opt_intOrderByVOL = CInt(Request.Form("opt_intOrderByVOL"))
Else
	opt_intOrderByVOL = OB_REQUEST
End If
If Not Nl(Request.Form("opt_fld_intCustOrderVOL")) And IsIDType(Request.Form("opt_intOrderByVOL")) Then
	opt_fld_intCustOrderVOL = CInt(Request.Form("opt_fld_intCustOrderVOL"))
Else
	opt_fld_intCustOrderVOL = Null
End If
opt_bOrderByDescVOL = Request.Form("opt_bOrderByDescVOL") = "on"
opt_bDispTable = Request.Form("opt_bDispTable") = "on"
opt_fld_bPosition = Request.Form("opt_fld_bPosition") = "on"
opt_fld_bDuties = Request.Form("opt_fld_bDuties") = "on"
aTmpFldList = Split(Request.Form("opt_fld_aCustVOL"),",")
For i = 0 to UBound(aTmpFldList)
	aTmpFldList(i) = Trim(aTmpFldList(i))
Next
opt_fld_aCustVOL = aTmpFldList
	
End Sub

Sub setTempDisplayOptionsVOL()

Dim aTmpFldList, i

If getSessionValue("session_test") = "ok" Then
	Call setSessionValue("opt_bSessionSettingsVOL", True)

	Call setSessionValue("opt_fld_bVNUM", Request.Form("opt_fld_bVNUM") = "on")
	Call setSessionValue("opt_fld_bRecordOwnerVOL", Request.Form("opt_fld_bRecordOwnerVOL") = "on")
	Call setSessionValue("opt_fld_bOrgVOL", Request.Form("opt_fld_bOrgVOL") = "on")
	Call setSessionValue("opt_fld_bComm", Request.Form("opt_fld_bComm") = "on")
	Call setSessionValue("opt_fld_bAlertVOL", Request.Form("opt_fld_bAlertVOL") = "on" And g_bAlertColumnVOL)
	Call setSessionValue("opt_fld_bUpdateScheduleVOL", Request.Form("opt_fld_bUpdateScheduleVOL") = "on")
	Call setSessionValue("opt_bUpdateVOL", Request.Form("opt_bUpdateVOL") = "on")
	Call setSessionValue("opt_bEmailVOL", Request.Form("opt_bEmailVOL") = "on" And user_bCanRequestUpdateVOL)
	Call setSessionValue("opt_bSelectVOL", Request.Form("opt_bSelectVOL") = "on")
	Call setSessionValue("opt_bWebVOL", Request.Form("opt_bWebVOL") = "on")
	Call setSessionValue("opt_bListAddRecordVOL", Request.Form("opt_bListAddRecordVOL") = "on")
	If Not Nl(Request.Form("opt_intOrderByVOL")) And IsPosSmallInt(Request.Form("opt_intOrderByVOL")) Then
		Call setSessionValue("opt_intOrderByVOL", CInt(Request.Form("opt_intOrderByVOL")))
	Else
		Call setSessionValue("opt_intOrderByVOL", OB_REQUEST)
	End If
	If Not Nl(Request.Form("opt_fld_intCustOrderVOL")) And IsIDType(Request.Form("opt_fld_intCustOrderVOL")) Then
		Call setSessionValue("opt_fld_intCustOrderVOL", CInt(Request.Form("opt_fld_intCustOrderVOL")))
	Else
		Call setSessionValue("opt_fld_intCustOrderVOL", Null)
	End If
	Call setSessionValue("opt_bOrderByDescVOL", Request.Form("opt_bOrderByDescVOL") = "on")
	Call setSessionValue("opt_bDispTable", Request.Form("opt_bDispTable") = "on")
	Call setSessionValue("opt_fld_bPosition", Request.Form("opt_fld_bPosition") = "on")
	Call setSessionValue("opt_fld_bDuties", Request.Form("opt_fld_bDuties") = "on")
	aTmpFldList = Split(Request.Form("opt_fld_aCustVOL"),",")
	For i = 0 to UBound(aTmpFldList)
		aTmpFldList(i) = Trim(aTmpFldList(i))
	Next
	Call setSessionValue("opt_fld_aCustVOL", Join(aTmpFldList,","))
	
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

Sub saveDisplayOptionsVOL( _
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
	bVShowTable, _
	bVShowPosition, _
	bVShowDuties, _
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
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, DM_VOL)
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
		.Parameters.Append .CreateParameter("@GLinkMail", adBoolean, adParamInput, 1, SQL_FALSE)
		.Parameters.Append .CreateParameter("@GLinkPub", adBoolean, adParamInput, 1, SQL_FALSE)
		.Parameters.Append .CreateParameter("@VShowTable", adBoolean, adParamInput, 1, bVShowTable)
		.Parameters.Append .CreateParameter("@VShowPosition", adBoolean, adParamInput, 1, bVShowPosition)
		.Parameters.Append .CreateParameter("@VShowDuties", adBoolean, adParamInput, 1, bVShowDuties)
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
