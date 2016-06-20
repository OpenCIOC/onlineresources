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
<!--#include file="../includes/core/adovbs.inc" -->
<!--#include file="../includes/core/incVBUtils.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<!--#include file="../includes/core/incRExpFuncs.asp" -->
<!--#include file="../includes/core/incHandleError.asp" -->
<!--#include file="../includes/core/incSetLanguage.asp" -->
<!--#include file="../includes/core/incPassVars.asp" -->
<!--#include file="../text/txtGeneral.asp" -->
<!--#include file="../text/txtError.asp" -->
<!--#include file="../includes/core/incConnection.asp" -->
<!--#include file="../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_GLOBAL, DM_GLOBAL, "../", "admin/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtPageMsg.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incSysLanguageList.asp" -->
<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Dim bNew
bNew = False

Dim intPageMsgID
intPageMsgID = Trim(Request("PageMsgID"))

If Nl(intPageMsgID) Then
	bNew = True
	intPageMsgID = Null
ElseIf Not IsIDType(intPageMsgID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPageMsgID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_MESSAGE, _
		"setup_page_msg.asp", vbNullString)
Else
	intPageMsgID = CLng(intPageMsgID)
End If


Dim	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strMsgTitle, _
	intLangID, _
	bVisiblePrintMode, _
	bLoginOnly, _
	strPageMsg

Dim intFieldLen, _
	intWrapAt, _
	intWrapNum, _
	intPageType


Dim cmdPageMsg, rsPageMsg
Set cmdPageMsg = Server.CreateObject("ADODB.Command")
With cmdPageMsg
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_PageMsg_s"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	.Parameters.Append .CreateParameter("@UseCIC", adBoolean, adParamInput, 1, IIf(user_bSuperUserCIC,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@UseVOL", adBoolean, adParamInput, 1, IIf(user_bSuperUserVOL,SQL_TRUE,SQL_FALSE))
	.Parameters.Append .CreateParameter("@PageMsgID", adInteger, adParamInput, 4, intPageMsgID)
	.CommandTimeout = 0
End With
Set rsPageMsg = cmdPageMsg.Execute

With rsPageMsg
	If .EOF Then
		If Not bNew Then
			Call handleError(TXT_NO_PAGE_MESSAGE & strPageName & "." & _
				vbCrLf & "<br>" & TXT_CHOOSE_MESSAGE, _
				"setup_page_msg.asp", vbNullString)
		End If
	Else
		strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strMsgTitle = .Fields("MsgTitle")
		intLangID = .Fields("LangID")
		bVisiblePrintMode = .Fields("VisiblePrintMode")
		bLoginOnly = .Fields("LoginOnly")
		strPageMsg = .Fields("PageMsg")
	End If
End With


If Not bNew Then
	Call makePageHeader(TXT_EDIT_PAGE_MESSAGE & "<br>" & strMsgTitle, TXT_EDIT_PAGE_MESSAGE & "<br>" & strMsgTitle, True, False, True, True)
Else
	Call makePageHeader(TXT_ADD_MESSAGE, TXT_ADD_MESSAGE, True, False, True, True)
End If

%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("setup_page_msg.asp")%>"><%=TXT_RETURN_TO_MESSAGE_SETUP%></a>]</p>
<form action="setup_page_msg_edit2.asp" method="post">
<%=g_strCacheFormVals%>
<%If Not bNew Then%>
<input type="hidden" name="PageMsgID" value="<%=intPageMsgID%>">
<%End If%>
<table class="BasicBorder cell-padding-4">
	<tr>
		<th colspan="2" class="RevTitleBox"><%=TXT_USE_THIS_FORM%></th>
	</tr>
<%If Not bNew Then%>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_DATE_CREATED%></td>
		<td><%=strCreatedDate%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_CREATED_BY%></td>
		<td><%=strCreatedBy%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_LAST_MODIFIED%></td>
		<td><%=strModifiedDate%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_MODIFIED_BY%></td>
		<td><%=strModifiedBy%></td>
	</tr>
<%End If%>
	<tr>
		<td class="FieldLabelLeft"><label for="MsgTitle"><%=TXT_MESSAGE_TITLE%></label> <span class="Alert">*</span></td>
		<td><input type="text" name="MsgTitle" id="MsgTitle" value=<%=AttrQs(strMsgTitle)%> size="<%=TEXT_SIZE%>" maxlength="50"> 
		<br><%=TXT_INST_MESSAGE_TITLE%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_PRINT_MODE%></td>
		<td><label for="VisiblePrintMode"><input type="checkbox" name="VisiblePrintMode" id="VisiblePrintMode" <%If bVisiblePrintMode Then%>checked<%End If%>><%=TXT_INST_PRINT_MODE%></label></td>
	</tr>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_LOGIN_ONLY%></td>
		<td><label for="LoginOnly"><input type="checkbox" name="LoginOnly" id="LoginOnly" <%If bLoginOnly Then%>checked<%End If%>><%=TXT_INST_LOGIN_ONLY%></label></td>
	</tr>
<%
	Call openSysLanguageListRst(True)
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LANGUAGE%> <span class="Alert">*</span></td>
	<td><%=makeSysLanguageList(intLangID,"LangID",False,vbNullString)%></td>
</tr>
<%
	Call closeSysLanguageListRst()
	
	If Nl(strPageMsg) Then
		intFieldLen = 0
	Else
		intFieldLen = Len(strPageMsg)
		strPageMsg = Server.HTMLEncode(strPageMsg)
	End If
%>
	<tr>
		<td class="FieldLabelLeft"><label for="PageMsg"><%=TXT_PAGE_MESSAGE%></label> <span class="Alert">*</span></td>
		<td><span class="SmallNote"><%=TXT_INST_MAX_4000%>&nbsp;<%=TXT_HTML_ALLOWED%></span>
		<br><textarea name="PageMsg" id="PageMsg" wrap="soft" rows="<%=getTextAreaRows(intFieldLen,5)%>" cols="<%=TEXTAREA_COLS%>"><%=strPageMsg%></textarea>
		<br><%=TXT_INST_PAGE_MESSAGE%></td>
	</tr>
<%
	Set rsPageMsg = rsPageMsg.NextRecordset
%>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_VIEW & " - " & TXT_CIC%></td>
		<td><%=TXT_INST_VIEW%>
		<br>&nbsp;
		<table class="NoBorder cell-padding-3">
<%
	With rsPageMsg
		intWrapAt = 1
		intWrapNum = intWrapAt
		While Not .EOF
			If intWrapNum = intWrapAt Then
%>
			<tr>
<%
			End If
%>
				<td><label for="CICViewType_<%=.Fields("ViewType")%>"><input name="CICViewType" id="CICViewType_<%=.Fields("ViewType")%>" type="checkbox" value="<%=.Fields("ViewType")%>"<%=Checked(.Fields("VIEW_SELECTED"))%><%If Not .Fields("CAN_EDIT") Then%> disabled<%End If%>>&nbsp;<%=.Fields("ViewName")%></label></td>
<%
			If intWrapNum > 0 Then
				intWrapNum = intWrapNum - 1
			Else
%>
			</tr>
<%
				intWrapNum = intWrapAt
			End If
			.MoveNext
		Wend
	End With
%>
		</table>
		</td>
	</tr>
<%
	Set rsPageMsg = rsPageMsg.NextRecordset
	If Not rsPageMsg.EOF Then
%>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_VIEW & " - " & TXT_VOLUNTEER%></td>
		<td><%=TXT_INST_VIEW%>
		<br>&nbsp;
		<table class="NoBorder cell-padding-3">
<%
		With rsPageMsg
			intWrapAt = 2
			intWrapNum = intWrapAt
			While Not .EOF
				If intWrapNum = intWrapAt Then
%>
			<tr>
<%
				End If
%>
				<td><label for="VOLViewType_<%=.Fields("ViewType")%>"><input name="VOLViewType" id="VOLViewType_<%=.Fields("ViewType")%>" type="checkbox" value="<%=.Fields("ViewType")%>"<%=Checked(.Fields("VIEW_SELECTED"))%><%If Not .Fields("CAN_EDIT") Then%> disabled<%End If%>>&nbsp;<%=.Fields("ViewName")%></label></td>
<%
				If intWrapNum > 0 Then
					intWrapNum = intWrapNum - 1
				Else
%>
			</tr>
<%
					intWrapNum = intWrapAt
				End If
				.MoveNext
			Wend
		End With
%>
		</table>
		</td>
	</tr>
<%
	End If
	Set rsPageMsg = rsPageMsg.NextRecordset
%>
	<tr>
		<td class="FieldLabelLeft"><%=TXT_PAGES%> <span class="Alert">*</span></td>
		<td><%=TXT_INST_PAGES%>
<%
	With rsPageMsg
		If Not .EOF Then
			intWrapAt = 2
			intWrapNum = intWrapAt
			intPageType = -1
			While Not .EOF
				If .Fields("PAGE_TYPE") <> intPageType Then
					If intWrapNum <> intWrapAt Then
						While intWrapNum >= 0
%>
				<td>&nbsp;</td>
<%
						intWrapNum = intWrapNum - 1
						Wend
%>
			</tr>
<%
					End If
					intWrapNum = intWrapAt
					Select Case .Fields("PAGE_TYPE")
						Case DM_GLOBAL
							If intPageType <> -1 Then
%>
		</table>
<%
							End If
%>
		<br>&nbsp;
		<table class="BasicBorder cell-padding-3">
			<tr>
				<th class="RevTitleBox" colspan="<%=intWrapAt+1%>"><%=TXT_SHARED%></th>
			</tr>
<%
						Case DM_CIC
							If intPageType <> -1 Then
%>
		</table>
<%
							End If
%>
		<br>&nbsp;
		<table class="BasicBorder cell-padding-3">
			<tr>
				<th class="RevTitleBox" colspan="<%=intWrapAt+1%>"><%=TXT_CIC%></th>
			</tr>
<%
						Case DM_VOL
							If intPageType <> -1 Then
%>
		</table>
<%
							End If
%>
		<br>&nbsp;
		<table class="BasicBorder cell-padding-3">
			<tr>
				<th class="RevTitleBox" colspan="<%=intWrapAt+1%>"><%=TXT_VOLUNTEER%></th>
			</tr>
<%
					End Select
				End If

				If intWrapNum = intWrapAt Then
%>
			<tr>
<%
				End If
%>
				<td<%If Not Nl(.Fields("PageTitle")) Then%> title=<%=AttrQs(.Fields("PageTitle"))%><%End If%>><label for="PageName<%=.Fields("PageName")%>"><input id="PageName<%=.Fields("PageName")%>" name="PageName" type="checkbox" value="<%=.Fields("PageName")%>"<%=Checked(.Fields("PAGE_SELECTED"))%><%If Not .Fields("CAN_EDIT") Then%> disabled<%End If%>>&nbsp;<%=.Fields("PageName")%></label></td>
<%
				If intWrapNum > 0 Then
					intWrapNum = intWrapNum - 1
				Else
%>
			</tr>
<%
					intWrapNum = intWrapAt
				End If
				intPageType = .Fields("PAGE_TYPE")
				.MoveNext
			Wend
			If intWrapNum <> intWrapAt Then
				While intWrapNum >= 0
%>
				<td>&nbsp;</td>
<%
				intWrapNum = intWrapNum - 1
				Wend
%>
			</tr>
<%
			End If
%>
		</table>
<%
		End If
	End With
%>
		</td>
	</tr>
	<tr>
		<td colspan="2"><input type="submit" value="<%=TXT_SUBMIT_UPDATES%>"><%If Not bNew Then%> <input type="submit" name="Submit" value="<%=TXT_DELETE%>"><%End If%> <input type="reset" value="<%=TXT_RESET_FORM%>"></td>
	</tr>
</table>
</form>

<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
