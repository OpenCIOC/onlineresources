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
	intDisplayOrder, _
	strPageMsg

Dim intFieldLen, _
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
		intDisplayOrder = .Fields("DisplayOrder")
		strPageMsg = .Fields("PageMsg")
	End If
End With


If Not bNew Then
	Call makePageHeader(TXT_EDIT_PAGE_MESSAGE & strMsgTitle, TXT_EDIT_PAGE_MESSAGE & strMsgTitle, True, False, True, True)
Else
	Call makePageHeader(TXT_ADD_MESSAGE, TXT_ADD_MESSAGE, True, False, True, True)
End If

%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("setup_page_msg.asp")%>"><%=TXT_RETURN_TO_MESSAGE_SETUP%></a>]</p>
<form action="setup_page_msg_edit2.asp" method="post" class="form-horizontal">
<%=g_strCacheFormVals%>
<%If Not bNew Then%>
<input type="hidden" name="PageMsgID" value="<%=intPageMsgID%>">
<%End If%>
<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h2><%=TXT_USE_THIS_FORM%></h2>
	</div>
	<div class="panel-body no-padding">
	<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
<%If Not bNew Then%>
	<tr>
		<td class="field-label-cell"><%=TXT_DATE_CREATED%></td>
		<td class="field-data-cell"><%=strCreatedDate%></td>
	</tr>
	<tr>
		<td class="field-label-cell"><%=TXT_CREATED_BY%></td>
		<td class="field-data-cell"><%=strCreatedBy%></td>
	</tr>
	<tr>
		<td class="field-label-cell"><%=TXT_LAST_MODIFIED%></td>
		<td class="field-data-cell"><%=strModifiedDate%></td>
	</tr>
	<tr>
		<td class="field-label-cell"><%=TXT_MODIFIED_BY%></td>
		<td class="field-data-cell"><%=strModifiedBy%></td>
	</tr>
<%End If%>
	<tr>
		<td class="field-label-cell"><label for="MsgTitle">
			<%=TXT_MESSAGE_TITLE%></label> <span class="Alert">*</span>
			<a data-toggle="popover" data-trigger="focus" title="" data-placement="top" data-content=<%=AttrQs(TXT_INST_MESSAGE_TITLE)%> tabindex="0" data-original-title=<%=AttrQs(TXT_HELP & TXT_COLON & TXT_MESSAGE_TITLE)%>
			<span class="glyphicon glyphicon-question-sign SimulateLink"></span>
			</a>
		</td>
		<td class="field-data-cell">
			<input type="text" name="MsgTitle" id="MsgTitle" value=<%=AttrQs(strMsgTitle)%> size="<%=TEXT_SIZE%>" maxlength="50" class="form-control">
		</td>
	</tr>
	<tr>
		<td class="field-label-cell"><%=TXT_PRINT_MODE%></td>
		<td class="field-data-cell"><label for="VisiblePrintMode"><input type="checkbox" name="VisiblePrintMode" id="VisiblePrintMode" <%If bVisiblePrintMode Then%>checked<%End If%>><%=TXT_INST_PRINT_MODE%></label></td>
	</tr>
	<tr>
		<td class="field-label-cell"><%=TXT_LOGIN_ONLY%></td>
		<td class="field-data-cell"><label for="LoginOnly"><input type="checkbox" name="LoginOnly" id="LoginOnly" <%If bLoginOnly Then%>checked<%End If%>><%=TXT_INST_LOGIN_ONLY%></label></td>
	</tr>
	<tr>
		<td class="field-label-cell"><label for="DisplayOrder"><%=TXT_ORDER%></label></td>
		<td class="field-data-cell">
			<div class="form-inline">
				<input type="text" size="4" maxlength="3" name="DisplayOrder" title=<%=AttrQs(TXT_ORDER)%> value=<%=AttrQs(intDisplayOrder)%> class="form-control">
		    </div>
		</td>
	</tr>
	
<%
	Call openSysLanguageListRst(True)
%>
	<tr>
		<td class="field-label-cell"><%=TXT_LANGUAGE%> <span class="Alert">*</span></td>
		<td class="field-data-cell"><%=makeSysLanguageList(intLangID,"LangID",False,vbNullString)%></td>
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
		<td class="field-label-cell">
			<label for="PageMsg"><%=TXT_PAGE_MESSAGE%></label> <span class="Alert">*</span>
			<a data-toggle="popover" data-trigger="focus" title="" data-placement="top" data-content=<%=AttrQs(TXT_INST_PAGE_MESSAGE)%> tabindex="0" data-original-title=<%=AttrQs(TXT_HELP & TXT_COLON & TXT_PAGE_MESSAGE)%>
			<span class="glyphicon glyphicon-question-sign SimulateLink"></span>
			</a>
		</td>
		<td class="field-data-cell"><span class="SmallNote"><%=TXT_INST_MAX_8000%>&nbsp;<%=TXT_HTML_ALLOWED%></span>
		<br><textarea name="PageMsg" id="PageMsg" wrap="soft" rows="<%=getTextAreaRows(intFieldLen,5)%>" cols="<%=TEXTAREA_COLS%>" class="form-control"><%=strPageMsg%></textarea>
		</td>
	</tr>
<%
	Set rsPageMsg = rsPageMsg.NextRecordset
%>
	<tr>
		<td class="field-label-cell"><%=TXT_VIEW & " - " & TXT_CIC%>
			<a data-toggle="popover" data-trigger="focus" title="" data-placement="top" data-content=<%=AttrQs(TXT_INST_VIEW)%> tabindex="0" data-original-title=<%=AttrQs(TXT_HELP & TXT_COLON & TXT_VIEW & " - " & TXT_CIC)%>
			<span class="glyphicon glyphicon-question-sign SimulateLink"></span>
			</a>
		</td>
		<td class="field-data-cell">
		<div class="row">
<%
	With rsPageMsg
		While Not .EOF
%>
			<div class="col-lg-4 col-md-6 col-sm-6 col-xs-12">
				<label for="CICViewType_<%=.Fields("ViewType")%>"><input name="CICViewType" id="CICViewType_<%=.Fields("ViewType")%>" type="checkbox" value="<%=.Fields("ViewType")%>"<%=Checked(.Fields("VIEW_SELECTED"))%><%If Not .Fields("CAN_EDIT") Then%> disabled<%End If%>> <%=.Fields("ViewName")%></label>
			</div>
<%
			.MoveNext
		Wend
	End With
%>
		</div>
		</td>
	</tr>
<%
	Set rsPageMsg = rsPageMsg.NextRecordset
	If Not rsPageMsg.EOF Then
%>
	<tr>
		<td class="field-label-cell"><%=TXT_VIEW & " - " & TXT_VOLUNTEER%>
			<a data-toggle="popover" data-trigger="focus" title="" data-placement="top" data-content=<%=AttrQs(TXT_INST_VIEW)%> tabindex="0" data-original-title=<%=AttrQs(TXT_HELP & TXT_COLON & TXT_VIEW & " - " & TXT_VOLUNTEER)%>
			<span class="glyphicon glyphicon-question-sign SimulateLink"></span>
			</a>
		</td>
		<td class="field-data-cell">
		<div class="row">
<%
	With rsPageMsg
		While Not .EOF
%>
			<div class="col-lg-4 col-md-6 col-sm-6 col-xs-12">
				<label for="VOLViewType_<%=.Fields("ViewType")%>"><input name="VOLViewType" id="VOLViewType_<%=.Fields("ViewType")%>" type="checkbox" value="<%=.Fields("ViewType")%>"<%=Checked(.Fields("VIEW_SELECTED"))%><%If Not .Fields("CAN_EDIT") Then%> disabled<%End If%>> <%=.Fields("ViewName")%></label>
			</div>
<%
			.MoveNext
		Wend
	End With
%>
		</div>
		</td>
	</tr>
<%
	End If
	Set rsPageMsg = rsPageMsg.NextRecordset
%>
	<tr>
		<td class="field-label-cell"><%=TXT_PAGES%> <span class="Alert">*</span></td>
		<td class="field-data-cell">
			<p class="InfoMsg"><%=TXT_INST_PAGES%></p>
<%
	Dim strPageType

	With rsPageMsg
		If Not .EOF Then
			intPageType = -1
			While Not .EOF
				If .Fields("PAGE_TYPE") <> intPageType Then
					If intPageType <> -1 Then
%>
				</div>
			</div>
		</div>
<%
					End If
					Select Case .Fields("PAGE_TYPE")
						Case DM_GLOBAL
							strPageType = TXT_SHARED
						Case DM_CIC
							strPageType = TXT_CIC
						Case DM_VOL
							strPageType = TXT_VOLUNTEER
					End Select
%>
		<div class="panel panel-default">
			<div class="panel-heading"><h2><%=strPageType%></h2></div>
			<div class="panel-body">
				<div class="row">
<%
				End If
%>
					<div class="col-lg-4 col-md-6 col-sm-6 col-xs-12"> 
<%
%>
						<label for="PageName<%=.Fields("PageName")%>" <%If Not Nl(.Fields("PageTitle")) Then%> title=<%=AttrQs(.Fields("PageTitle"))%><%End If%>><input id="PageName<%=.Fields("PageName")%>" name="PageName" type="checkbox" value=<%=AttrQs(.Fields("PageName"))%> <%=Checked(.Fields("PAGE_SELECTED"))%><%If Not .Fields("CAN_EDIT") Then%> disabled<%End If%>> <%=.Fields("PageName")%></label>
					</div>
<%
				intPageType = .Fields("PAGE_TYPE")
				.MoveNext
			Wend
%>
				</div>
			</div>
		</div>
<%
		End If
	End With
%>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<input type="submit" value="<%=TXT_SUBMIT_UPDATES%>" class="btn btn-default">
			<%If Not bNew Then%> <input type="submit" name="Submit" value="<%=TXT_DELETE%>" class="btn btn-default"><%End If%>
			<input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default"></td>
	</tr>
	</table>
</table>
</div>
</form>
<%
Call makePageFooter(False)
%>
<script type="text/javascript">
$(document).ready(function(){
    $('[data-toggle="popover"]').popover();
});
</script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/5.6.2/tinymce.min.js" integrity="sha512-sOO7yng64iQzv/uLE8sCEhca7yet+D6vPGDEdXCqit1elBUAJD1jYIYqz0ov9HMd/k30e4UVFAovmSG92E995A==" crossorigin="anonymous"></script>
<script type="text/javascript">
tinymce.init({
	selector: '#PageMsg',
	plugins: [
		'advlist anchor autolink lists link image charmap print preview anchor',
		'searchreplace visualblocks code fullscreen',
		'insertdatetime media table contextmenu paste code'
	],
	toolbar: 'insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link anchor image',
	extended_valid_elements: 'span[*],i[*]',
    convert_urls: false,
	schema: 'html5'
});
</script>
<!--#include file="../includes/core/incClose.asp" -->
