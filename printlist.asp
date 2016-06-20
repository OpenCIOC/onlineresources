<%@LANGUAGE="VBSCRIPT"%>
<%Option Explicit%>

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

<% 'Base includes %>
<!--#include file="includes/core/adovbs.inc" -->
<!--#include file="includes/core/incVBUtils.asp" -->
<!--#include file="includes/validation/incBasicTypes.asp" -->
<!--#include file="includes/core/incRExpFuncs.asp" -->
<!--#include file="includes/core/incHandleError.asp" -->
<!--#include file="includes/core/incSetLanguage.asp" -->
<!--#include file="includes/core/incPassVars.asp" -->
<!--#include file="text/txtGeneral.asp" -->
<!--#include file="text/txtError.asp" -->
<!--#include file="includes/core/incConnection.asp" -->
<!--#include file="includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="text/txtPrintList.asp" -->
<!--#include file="text/txtSearchBasic.asp" -->
<!--#include file="text/txtSearchBasicCIC.asp" -->
<!--#include file="text/txtSearchAdvanced.asp" -->
<!--#include file="text/txtSearchAdvancedCIC.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/print/incPrintProfileList.asp" -->
<!--#include file="includes/publication/incGenHeadingList.asp" -->
<!--#include file="includes/publication/incPubList.asp" -->
<!--#include file="includes/search/incAdvSearchPub.asp" -->

<%
Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, True, False, True, True)

Dim bProfilePicked, _
	strIDList, _
	intProfileID, _
	strMessage, _
	intLen, _
	strPubList, _
	strPubListGH

bProfilePicked = Request("Picked") = "on"
strIDList = Request("IDList")
intProfileID = Request("ProfileID")

Dim	intGHPBID, _
	strPBType, _	
	strPBID, _
	strPBIDx

If Not g_bLimitedView Then
	intGHPBID = Trim(Request("GHPBID"))
Else
	intGHPBID = g_intPBID
End If

If Not Nl(intGHPBID) Then
	If Not IsIDType(intGHPBID) Then
		intGHPBID = Null
	End If
	strPBType = Null
	strPBID = Null
Else
	strPBType = Request("PBType")
	If Not reEquals(strPBType,"A|N|(AF)|F",False,False,True,False) Then
		strPBType = Null
	End If

	strPBID = Request("PBID")
	If Nl(strPBID) Then
		strPBID = Request("incPBID")
	End If
	If Not IsIDList(strPBID) Then
		strPBID = Null
	End If
End If

strPBIDx = Request("PBIDx")
If Not IsIDList(strPBIDx) Then
	strPBIDx = Null
End If

Dim	strGHType, _
	strGHID, _
	strGHIDx

strGHType = Request("GHType")
strGHID = Request("GHID")
If Not IsIDList(strGHID) Then
	strGHID = NULL
End If

strGHIDx = Request("GHIDx")
If Not IsIDList(strGHIDx) Then
	strGHIDx = Null
End If

If ps_intDbArea = DM_CIC Then
	If Not user_bLimitedViewCIC Then
		Call openPubListRst(False, False)
		If Not rsListPub.EOF Then
			strPubList = makePubList(vbNullString, vbNullString, "SubjID", "SubjID_Name_Index",True, False, False)
			Call closePubListRst()
			Call openPubListRst(True, Null)
			If Not rsListPub.EOF Then
				strPubListGH = makePubList(vbNullString, vbNullString, "SubjID", "SubjID_Subject_Index",True, False, False)
			End If
		End If
		Call closePubListRst()
	End If
End If

If Nl(intProfileID) Then
	If bProfilePicked Then
		Call handleError(TXT_NO_PROFILE_CHOSEN, vbNullString, vbNullString)
	End If
%>
<!--#include file="includes/print/incPrintOptions.asp" -->
<%
If Nl(strIDList) Then
	If Not Nl(strPubList) Then
%>
<br>
<form action="printlist_nameindex.asp" method="post" target="_BLANK">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_INST_NAME_INDEX%></th></tr>
<%If Not g_bLimitedView Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PUBLICATIONS%></td>
	<td><%=strPubList%></td>
</tr>
<%Else%>
<span style="display:none">
<input type="hidden" name="SubjID" value=<%=attrQs(g_intPBID)%> />
</span>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FONT_FAMILY%></td>
	<td><label for="FontFamily_Name_Index_SANS_SERIF"><input type="radio" name="FontFamily" id="FontFamily_Name_Index_SANS_SERIF" value="<%=SANS_SERIF_FONT%>" checked> <span style="font-family:<%=SANS_SERIF_FONT%>"><%=SANS_SERIF_FONT%></label></span>
	<br><label for="FontFamily_Name_Index_SERIF"><input type="radio" name="FontFamily" id="FontFamily_Name_Index_SERIF" value="<%=SERIF_FONT%>"> <span style="font-family:<%=SERIF_FONT%>"><%=SERIF_FONT%></label></span></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FONT_SIZE%></td>
	<td><select name="FontSize">
		<option value="8">8pt</option>
		<option value="9">9pt</option>
		<option value="10" selected>10pt</option>
		<option value="11">11pt</option>
		<option value="12">12pt</option>
		<option value="14">14pt</option>
	</select></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_INCLUDE_FIELDS%></td>
	<td><table class="BasicBorder cell-padding-3">
		<tr>
			<td><input type="checkbox" name="IncEmail" id="IncEmail"></td>
			<td><label for="IncEmail">E_MAIL</label></td>
			<td class="FieldLabelClr"><label for="LblEmail"><%=TXT_LABEL_AS%></label></td>
			<td><input type="text" name="LblEmail" id="LblEmail" value="<%=TXT_EMAIL & TXT_COLON%>" size="15" maxlength="20"></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="IncOffice" id="IncOffice"></td>
			<td><label for="IncOffice">OFFICE_PHONE</label></td>
			<td class="FieldLabelClr"><label for="LblOffice"><%=TXT_LABEL_AS%></label></td>
			<td><input type="text" name="LblOffice" id="LblOffice" value="<%=TXT_OFFICE_PHONE%>" size="15" maxlength="20"></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="IncFax" id="IncFax"></td>
			<td><label for="IncFax">FAX</label></td>
			<td class="FieldLabelClr"><label for="LblFax"><%=TXT_LABEL_AS%></label></td>
			<td><input type="text" name="LblFax" id="LblFax" value="<%=TXT_FAX%>" size="15" maxlength="20"></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="IncTollFree" id="IncTollFree"></td>
			<td><label for="IncTollFree">TOLL_FREE_PHONE</label></td>
			<td class="FieldLabelClr"><label for="LblTollFree"><%=TXT_LABEL_AS%></label></td>
			<td><input type="text" name="LblTollFree" id="LblTollFree" value="<%=TXT_TOLL_FREE_PHONE%>" size="15" maxlength="20"></td>
		</tr>
<%
If ps_intDbArea = DM_CIC Then
%>
		<tr>
			<td><input type="checkbox" name="IncTDD" id="IncTDD"></td>
			<td><label for="IncTDD">TDD_PHONE</label></td>
			<td class="FieldLabelClr"><label for="LblTDD"><%=TXT_LABEL_AS%></label></td>
			<td><input type="text" name="LblTDD" id="LblTDD" value="<%=TXT_TDD_PHONE%>" size="15" maxlength="20"></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="IncAfterHrs" id="IncAfterHrs"></td>
			<td><label for="IncAfterHrs">AFTER_HRS_PHONE</label></td>
			<td class="FieldLabelClr"><label for="LblAfterHrs"><%=TXT_LABEL_AS%></label></td>
			<td><input type="text" name="LblAfterHrs" id="LblAfterHrs" value="<%=TXT_AFTER_HRS_PHONE%>" size="15" maxlength="20"></td>
		</tr>
		<tr>
			<td><input type="checkbox" name="IncCrisis" id="IncCrisis"></td>
			<td><label for="IncCrisis">CRISIS_PHONE</label></td>
			<td class="FieldLabelClr"><label for="LblCrisis"><%=TXT_LABEL_AS%></label></td>
			<td><input type="text" name="LblCrisis" id="LblCrisis" value="<%=TXT_CRISIS_PHONE%>" size="15" maxlength="20"></td>
		</tr>
<%
End If
%>
		<tr>
			<td colspan="4"><label for="LimitField"><input type="checkbox" name="LimitField" id="LimitField"><%=TXT_LIMIT_FIELD%></label></td>
		</tr>
		<tr>
			<td colspan="4"><label for="FormatBold"><input type="checkbox" name="FormatBold" id="FormatBold"><%=TXT_BOLD_FIELD%></label></td>
		</tr>
		<tr>
			<td colspan="4"><label for="CrossRef"><input type="checkbox" name="CrossRef" id="CrossRef" checked><%=TXT_INCLUDE_CROSS_REF%></label></td>
		</tr>
		<tr>
			<td colspan="4"><%=TXT_FIELD_DATA_WIDTH%>&nbsp;<select name="FieldWidth">
			<option value="100">100px</option>
			<option value="150">150px</option>
			<option value="200">200px</option>
			<option value="250" selected>250px</option>
			<option value="300">300px</option>
			<option value="350">350px</option>
			<option value="400">400px</option>
			</select></td>
		</tr>
		</table>				
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DOT_LEADER%></td>
	<td><label for="DotLeader"><input type="checkbox" name="DotLeader" id="DotLeader" checked>&nbsp;<%=TXT_INST_DOT_LEADER%></label></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FORMAT_FOR%></td>
	<td><select name="ForWord">
		<option value="off"><%=TXT_FOR_WEB%></option>
		<option value="on"><%=TXT_FOR_WORD%></option>
		</select></td>
</tr>
<%If g_bCanSeeDeletedDOM Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DELETED_RECORDS%></td>
	<td><label for="IncludeDeleted_Name"><input name="IncludeDeleted" id="IncludeDeleted_Name" type="checkbox"><%=TXT_INCLUDE_DELETED%></label></td>
</tr>
<%End If%>
</table>
<input type="submit" value="<%=TXT_NEXT & " " & TXT_NEW_WINDOW%> >>">
</form>
<%
	End If
End If
%>
<%
If Nl(strIDList) Then
	If g_bLimitedView Or Not Nl(strPubList) Then
%>
<br>
<form action="printlist_subjindex.asp" method="post" target="_BLANK">
<%=g_strCacheFormVals%>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_INST_SUBJECT_INDEX%></th></tr>
<%If Not g_bLimitedView Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PUBLICATIONS%></td>
	<td><%=strPubListGH%></td>
</tr>
<%Else%>
<span style="display:none">
<input type="hidden" name="SubjID" value=<%=attrQs(g_intPBID)%> />
</span>
<%End If%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FONT_FAMILY%></td>
	<td><label for="FontFamily_Subject_Index_SANS_SERIF"><input type="radio" name="FontFamily" id="FontFamily_Subject_Index_SANS_SERIF" value="<%=SANS_SERIF_FONT%>" checked> <span style="font-family:<%=SANS_SERIF_FONT%>"><%=SANS_SERIF_FONT%></label></span>
	<br><label for="FontFamily_Subject_Index_SERIF"><input type="radio" name="FontFamily" id="FontFamily_Subject_Index_SERIF" value="<%=SERIF_FONT%>"> <span style="font-family:<%=SERIF_FONT%>"><%=SERIF_FONT%></label></span></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FONT_SIZE%></td>
	<td><select name="FontSize">
		<option value="8">8pt</option>
		<option value="9">9pt</option>
		<option value="10" selected>10pt</option>
		<option value="11">11pt</option>
		<option value="12">12pt</option>
		<option value="14">14pt</option>
	</select></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FORMAT_FOR%></td>
	<td><select name="ForWord">
		<option value="off"><%=TXT_FOR_WEB%></option>
		<option value="on"><%=TXT_FOR_WORD%></option>
		</select></td>
</tr>
<%If g_bCanSeeDeletedDOM Then%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_DELETED_RECORDS%></td>
	<td><label for="IncludeDeleted_Subject"><input name="IncludeDeleted" id="IncludeDeleted_Subject" type="checkbox"><%=TXT_INCLUDE_DELETED%></label></td>
</tr>
<%End If%>
</table>
<input type="submit" value="<%=TXT_NEXT & " " & TXT_NEW_WINDOW%> >>">
</form>
<%
	End If
End If

Else
	Dim cmdProfileMessage, rsProfileMessage
	Set cmdProfileMessage = Server.CreateObject("ADODB.Command")
	With cmdProfileMessage
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_PrintProfile_Msg_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, ps_intDbArea)
	End With
	Set rsProfileMessage = cmdProfileMessage.Execute
	If Not rsProfileMessage.EOF Then
		strMessage = rsProfileMessage.Fields("DefaultMsg")
	End If
	rsProfileMessage.Close
	Set rsProfileMessage = Nothing
	Set cmdProfileMessage = Nothing
	
%>
<form action="printlist2.asp" method="post" target="_BLANK">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="hidden" name="PBType" value="<%=strPBType%>">
<input type="hidden" name="PBID" value="<%=strPBID%>">
<input type="hidden" name="PBIDx" value="<%=strPBIDx%>">
<input type="hidden" name="GHPBID" value="<%=intGHPBID%>">
<input type="hidden" name="GHType" value="<%=strGHType%>">
<input type="hidden" name="GHID" value="<%=strGHID%>">
<input type="hidden" name="GHIDx" value="<%=strGHIDx%>">
<%If Request("IncludeDeleted")="on" Then%>
<input type="hidden" name="IncludeDeleted" value="on">
<%End If%>
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_INST_CUSTOMIZE%></th></tr>
<tr>
	<td class="FieldLabelLeft"><label for="Msg"><%=TXT_MESSAGE%></label></td>
<%
If Nl(strMessage) Then
	intLen = 0
Else
	intLen = Len(strMessage)
	strMessage = Server.HTMLEncode(strMessage)
End If
%>
	<td><span class="SmallNote"><%=TXT_HTML_ALLOWED%></span>
	<br><textarea name="Msg" id="Msg" wrap="soft" rows="<%=getTextAreaRows(intLen,5)%>" cols="<%=TEXTAREA_COLS%>"><%=strMessage%></textarea></td>
</tr>
</table>
<input type="submit" value="<%=TXT_NEXT & " " & TXT_NEW_WINDOW%> >>">
</form>
<%
End If
Call makePageFooter(True)
%>

<!--#include file="includes/core/incClose.asp" -->
