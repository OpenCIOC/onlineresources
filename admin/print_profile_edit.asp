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
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<%
Dim intDomain, _
	strDbArea, _
	strType, _
	intLen

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strDbArea = DM_S_CIC
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strDbArea = DM_S_VOL
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim intProfileID
intProfileID = Trim(Request("ProfileID"))

If Nl(intProfileID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intProfileID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = CLng(intProfileID)
End If

Dim	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strStyleSheet, _
	strTableClass, _
	strProfileName,_
	bMsgBeforeRecord, _
	strSeparator, _
	bPageBreak, _
	bPublic, _
	strValue, _
	strCulture, _
	intFieldCount, _
	dicDescriptions, _
	xmlDoc, _
	xmlNode, _
	xmlCultureNode

Dim cmdProfile, rsProfile
Set cmdProfile = Server.CreateObject("ADODB.Command")
With cmdProfile
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_" & strDbArea & "_PrintProfile_s"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, user_strAgency)
	.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfileID)
	.CommandTimeout = 0
End With
Set rsProfile = cmdProfile.Execute

With rsProfile
	If .EOF Then
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "." & _
			vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
			"print_profile.asp", "DM=" & intDomain)
	Else
		strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strStyleSheet = .Fields("StyleSheet")
		strTableClass = .Fields("TableClass")
		bMsgBeforeRecord = .Fields("MsgBeforeRecord")
		strSeparator = .Fields("Separator")
		bPageBreak = .Fields("PageBreak")
		bPublic = .Fields("Public")
		strProfileName = .Fields("ProfileName")
		intFieldCount = .Fields("FieldCount")
			
		Set dicDescriptions = Server.CreateObject("Scripting.Dictionary")
		Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
		With xmlDoc
			.async = False
			.setProperty "SelectionLanguage", "XPath"
		End With
		xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Descriptions"),vbNullString) & "</DESCS>"

		For Each xmlNode in xmlDoc.selectNodes("//DESC")
			Set xmlCultureNode = xmlNode.selectSingleNode("Culture")
			If Not xmlCultureNode Is Nothing Then
				Set dicDescriptions(xmlCultureNode.text) = xmlNode
			End If
		Next

	End If
End With

Set rsProfile = rsProfile.NextRecordset
Dim strInViews

With rsProfile
	If .EOF Then
		strInViews = "<br>" & TXT_NO_OTHER_VIEWS
	Else
		While Not .EOF
			strInViews = strInViews & "<br>" & _
				"<label for=""InViews_" & .Fields("ViewType") & """><input type=""checkbox"" name=""InViews"" id=""InViews_" & .Fields("ViewType") & """ value=" & attrQS(.Fields("ViewType")) & _
				Checked(.Fields("InView")) & ">&nbsp;" & _
				.Fields("ViewName") & "</label>"
			.MoveNext
		Wend
	End If
End With

Set rsProfile = Nothing
Set cmdProfile = Nothing

Call makePageHeader(TXT_EDIT_PROFILE & " (" & strType & ")" & TXT_COLON & strProfileName, TXT_EDIT_PROFILE & " (" & strType & ")" & TXT_COLON & strProfileName, True, False, True, True)
%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLink("print_profile.asp","DM=" & intDomain,vbNullString)%>"><%=TXT_RETURN_TO_PROFILES%> (<%=strType%>)</a> ]</p>
<form action="print_profile_edit2.asp" method="post">
<div style="display:none">
	<%=g_strCacheFormVals%>
	<input type="hidden" name="DM" value="<%=intDomain%>">
	<input type="hidden" name="ProfileID" value="<%=intProfileID%>">
</div>

<div class="panel panel-default max-width-lg">
	<div class="panel-heading">
		<h2><%=TXT_EDIT_PROFILE%></h2>
	</div>
	<div class="panel-body no-padding">
		<table class="BasicBorder cell-padding-4 full-width form-table inset-table responsive-table">
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
<%
For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("ProfileName")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If
%>
			<tr>
				<td class="field-label-cell">
					<label for="ProfileName_<%= strCulture %>"><%=TXT_NAME%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
				</td>
				<td class="field-data-cell">
					<p class="SmallNote"><%=TXT_INST_PROFILE_NAME%></p>
					<input type="text" name="ProfileName_<%= strCulture %>" id="ProfileName_<%= strCulture %>" value=<%=AttrQs(strValue)%> size="<%=TEXT_SIZE%>" maxlength="50" class="form-control">
				</td>
			</tr>
<%
Next
%>
			<tr>
				<td class="field-label-cell">
					<%=TXT_PUBLIC%>
				</td>
				<td class="field-data-cell">
					<div class="checkbox">
						<label for="Public"><input type="checkbox" id="Public" name="Public"<%If bPublic Then%> checked<%End If%>> <%=TXT_INST_PUBLIC%></label>
					</div>
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">
					<label for="StyleSheet"><%=TXT_STYLE_SHEET%></label>
				</td>
				<td class="field-data-cell">
					<p class="SmallNote"><%=TXT_INST_STYLE_SHEET%></p>
					<input type="text" name="StyleSheet" id="StyleSheet" value=<%=AttrQs(strStyleSheet)%> size="<%=TEXT_SIZE%>" maxlength="150" class="form-control">
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">
					<label for="TableClass"><%=TXT_TABLE_CLASS%></label>
				</td>
				<td class="field-data-cell">
					<p class="SmallNote"><%=TXT_INST_TABLE_CLASS%></p>
					<input type="text" name="TableClass" id="TableClass" value=<%=AttrQs(strTableClass)%> size="<%=TEXT_SIZE%>" maxlength="50" class="form-control">
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">
					<label for="PageBreak"><%=TXT_RECORD_SEPARATOR%></label>
				</td>
				<td class="field-data-cell">
					<p class="SmallNote"><%=TXT_INST_RECORD_SEPARATOR%></p>
					<input type="text" name="Separator" id="Separator" value=<%=AttrQs(strSeparator)%> size="<%=TEXT_SIZE%>" maxlength="255" class="form-control">
					
					<div class="checkbox">
						<label>
							<input type="checkbox" id="PageBreak" name="PageBreak"<%If bPageBreak Then%> checked<%End If%>>
							<%=TXT_INST_PAGE_BREAK%>
						</label>
					</div>
				</td>
			</tr>
<%
For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("PageTitle")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If
%>
			<tr>
				<td class="field-label-cell"><label for="PageTitle_<%= strCulture %>"><%=TXT_REPORT_TITLE%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label></td>
				<td class="field-data-cell">
					<p class="SmallNote"><%=TXT_INST_REPORT_TITLE%></p>
					<input type="text" name="PageTitle_<%= strCulture %>" id="PageTitle_<%= strCulture %>" value=<%=AttrQs(strValue)%> maxlength="100" class="form-control">
				</td>
			</tr>
<%
Next

For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("Header")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If

	If Nl(strValue) Then
		intLen = 0
	Else
		intLen = Len(strValue)
		strValue = Server.HTMLEncode(strValue)
	End If
%>
			<tr>
				<td class="field-label-cell">
					<label for="Header_<%= strCulture %>"><%=TXT_HEADER%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
				</td>
				<td class="field-data-cell">
					<textarea name="Header_<%= strCulture %>" id="Header_<%= strCulture %>" wrap="soft" class="form-control WYSIWYG">
						<%=strValue%>
					</textarea>
				</td>
			</tr>
<%
Next


For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("Footer")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If

	If Nl(strValue) Then
		intLen = 0
	Else
		intLen = Len(strValue)
		strValue = Server.HTMLEncode(strValue)
	End If
%>
			<tr>
				<td class="field-label-cell">
					<label for="Footer_<%= strCulture %>"><%=TXT_FOOTER%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
				</td>
				<td class="field-data-cell">
					<textarea name="Footer_<%= strCulture %>" id="Footer_<%= strCulture %>" wrap="soft" class="form-control WYSIWYG">
						<%=strValue%>
					</textarea>
				</td>
			</tr>
<%
Next

For Each strCulture In active_cultures()
	strValue = vbNullString
	If dicDescriptions.Exists(strCulture) Then
		Set xmlNode = dicDescriptions(strCulture)
		Set xmlNode = xmlNode.selectSingleNode("DefaultMsg")
		If Not xmlNode Is Nothing Then
			strValue = xmlNode.text
		End If
	End If

	If Nl(strValue) Then
		intLen = 0
	Else
		intLen = Len(strValue)
		strValue = Server.HTMLEncode(strValue)
	End If
%>
			<tr>
				<td class="field-label-cell">
					<label for="DefaultMsg_<%= strCulture %>"><%=TXT_DEFAULT_MSG%> (<%= Application("Culture_" & strCulture & "_LanguageName") %>)</label>
				</td>
				<td class="field-data-cell">
					<textarea name="DefaultMsg_<%=strCulture%>" id="DefaultMsg_<%=strCulture%>" class="form-control WYSIWYG">
						<%=strValue%>
					</textarea>
				</td>
			</tr>
<%
Next
%>
			<tr>
				<td class="field-label-cell">
					<%=TXT_MSG_LOCATION%>
				</td>
				<td class="field-data-cell">
					<div class="checkbox">
						<label for="MsgBeforeRecord">
							<input type="checkbox" id="MsgBeforeRecord" name="MsgBeforeRecord"<%If bMsgBeforeRecord Then%> checked<%End If%>>
							<%=TXT_INST_MSG_LOCATION%>
						</label>
					</div>
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">
					<%=TXT_IN_VIEWS%>
				</td>
				<td class="field-data-cell">
					<strong><%=TXT_INST_IN_VIEWS%></strong>
					<%=strInViews%>
				</td>
			</tr>
			<tr>
				<td class="field-label-cell">
					<%=TXT_FIELDS%>
				</td>
				<td class="field-data-cell">
					<a href="<%=makeLink("print_profile_edit_fields.asp","ProfileID=" & intProfileID & "&DM=" & intDomain,vbNullString)%>"><%=TXT_MANAGE_FIELDS%>&nbsp;(<%=Nz(intFieldCount,0)%>)</a>
				</td>
			</tr>
		</table>
	</div>
</div>

<input type="submit" name="Submit" value="<%=TXT_SUBMIT_UPDATES%>" class="btn btn-default">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>" class="btn btn-default">
<input type="reset" value="<%=TXT_RESET_FORM%>" class="btn btn-default">

</form>

<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.1.0/tinymce.min.js" integrity="sha512-dr3qAVHfaeyZQPiuN6yce1YuH7YGjtUXRFpYK8OfQgky36SUfTfN3+SFGoq5hv4hRXoXxAspdHw4ITsSG+Ud/g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script type="text/javascript">
	tinymce.init({
		selector: '.WYSIWYG',
		plugins: 'anchor autolink link advlist lists image charmap preview searchreplace paste visualblocks code fullscreen insertdatetime media table contextmenu help',
		menubar: 'edit view insert format table help',
		toolbar: 'undo redo styles bullist numlist link | bold italic underline forecolor removeformat | copy cut paste searchreplace code',
		extended_valid_elements: 'span[*],i[*],script[*]',
		convert_urls: false,
		schema: 'html5',
		color_map: [
			'#D3273E', 'Red',
			'#DC582A', 'Orange',
			'#007A78', 'Turquoise',
			'#1D4289', 'Blue',
			'#666666', 'Gray',
		]
	});
</script>


<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
