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
<!--#include file="../text/txtHelp.asp" -->
<!--#include file="../text/txtSearchTips.asp" -->
<!--#include file="../text/txtMgmtFields.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incSysLanguageList.asp" -->

<%
Dim intDomain, _
	strType, _
	bNew

bNew = False

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Dim intSearchTipsID
intSearchTipsID = Trim(Request("SearchTipsID"))

If Nl(intSearchTipsID) Then
	bNew = True
	intSearchTipsID = Null
ElseIf Not IsIDType(intSearchTipsID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSearchTipsID) & ".", _
		"setup_searchtips.asp", vbNullString)
Else
	intSearchTipsID = CLng(intSearchTipsID)
End If

Dim	intLangID, _
	strLanguageName, _
	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy, _
	strPageTitle, _
	strPageText

If Not bNew Then
	Dim cmdDbOptions, rsDbOptions
	Set cmdDbOptions = Server.CreateObject("ADODB.Command")
	With cmdDbOptions
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_GBL_SearchTips_sf"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@SearchTipsID", adInteger, adParamInput, 4, intSearchTipsID)
		.CommandTimeout = 0
	End With
	Set rsDbOptions = cmdDbOptions.Execute
	
	With rsDbOptions
		If Not .EOF Then
			If .Fields("Domain") <> intDomain Then
				Call securityFailure()
			End If
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			intLangID = .Fields("LangID")
			strLanguageName = .Fields("LanguageName")
			strPageTitle = .Fields("PageTitle")
			strPageText = .Fields("PageText")
		End If
	End With
	
	rsDbOptions.Close
	Set rsDbOptions = Nothing
	Set cmdDbOptions = Nothing
End If

Call makePageHeader(TXT_SEARCH_TIPS & " (" & strType & ")", TXT_SEARCH_TIPS & " (" & strType & ")", True, False, True, True)

Dim intPageTextLen
If Nl(strPageText) Then
	intPageTextLen = 0
Else
	intPageTextLen = Len(strPageText)
	strPageText = Server.HTMLEncode(strPageText)
End If
%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLink("setup_searchtips.asp","DM=" & intDomain,vbNullString)%>"><%=TXT_RETURN_TO_SEARCH_TIPS_SETUP%></a> ]</p>
<form action="setup_searchtips_edit2.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="SearchTipsID" value="<%=intSearchTipsID%>">
</div>
<table class="BasicBorder cell-padding-4">
<tr>
	<th class="RevTitleBox" colspan="2"><%=TXT_EDIT_SEARCH_TIPS%> (<%=strType%>)</th>
</tr>
<%
If Not bNew Then
%>
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
<%
End If
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_LANGUAGE%></td>
	<td>
<%	If bNew Then
		Call openSysLanguageListRst(True)%>
	<%=makeSysLanguageList(intLangID,"LangID",False,vbNullString)%>
<%		Call closeSysLanguageListRst()
	Else
%>
	<%=strLanguageName%>
	<input type="hidden" name="LangID" value="<%=intLangID%>">
<%
	End If
%>
	</td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="PageTitle"><%=TXT_PAGE_TITLE%></label></td>
	<td><input type="text" name="PageTitle" id="PageTitle" value=<%=AttrQs(strPageTitle)%> size="<%=TEXT_SIZE%>" maxlength="50"></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><label for="PageText"><%=TXT_PAGE_TEXT%></label></td>
	<td>
	<span class="SmallNote"><%=TXT_HTML_ALLOWED%></span>
	<br><textarea name="PageText" id="PageText" wrap="soft" rows="<%=getTextAreaRows(intPageTextLen,5)%>" cols="<%=TEXTAREA_COLS%>"><%=strPageText%></textarea>
	</td>
</tr>
<tr>
	<td colspan="2"><input type="submit" value="<%=TXT_SUBMIT_UPDATES%>"><%If Not bNew Then%> <input type="submit" name="Submit" value="<%=TXT_DELETE%>"><%End If%> <input type="reset" value="<%=TXT_RESET_FORM%>"></td>
</tr>
</table>
</form>
<%= makeJQueryScriptTags() %>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/5.6.2/tinymce.min.js" integrity="sha512-sOO7yng64iQzv/uLE8sCEhca7yet+D6vPGDEdXCqit1elBUAJD1jYIYqz0ov9HMd/k30e4UVFAovmSG92E995A==" crossorigin="anonymous"></script>
<script type="text/javascript">
tinymce.init({
	selector: '#PageText',
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
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
