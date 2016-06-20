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
<!--#include file="../text/txtInclusion.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/list/incSysLanguageList.asp" -->
<%
If Not user_bSuperUser Then
	Call securityFailure()
End If

Dim bNew
bNew = False

Dim intInclusionPolicyID
intInclusionPolicyID = Trim(Request("InclusionPolicyID"))

If Nl(intInclusionPolicyID) Then
	bNew = True
	intInclusionPolicyID = Null
ElseIf Not IsIDType(intInclusionPolicyID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intInclusionPolicyID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_POLICY, _
		"setup_inclusion.asp", vbNullString)
Else
	intInclusionPolicyID = CLng(intInclusionPolicyID)
End If


Dim	strPolicyTitle, _
	intLangID, _
	strLanguageName, _
	bVisiblePrintMode, _
	strPolicyText, _
	strCreatedDate, _
	strCreatedBy, _
	strModifiedDate, _
	strModifiedBy

Dim intFieldLen, _
	intWrapAt, _
	intWrapNum, _
	intPageType

If Not bNew Then
	Dim cmdInclusionPolicy, rsInclusionPolicy
	Set cmdInclusionPolicy = Server.CreateObject("ADODB.Command")
	With cmdInclusionPolicy
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_GBL_InclusionPolicy_s"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@InclusionPolicyID", adInteger, adParamInput, 4, intInclusionPolicyID)
		.CommandTimeout = 0
	End With
	Set rsInclusionPolicy = cmdInclusionPolicy.Execute
	
	With rsInclusionPolicy
		If .EOF Then
			Call handleError(TXT_NO_INCLUSION_POLICY & strPageName & "." & _
				vbCrLf & "<br>" & TXT_CHOOSE_POLICY, _
				"setup_inclusion.asp", vbNullString)
		Else
			strPolicyTitle = .Fields("PolicyTitle")
			intLangID = .Fields("LangID")
			strLanguageName = .Fields("LanguageName")
			strPolicyText = .Fields("PolicyText")
			strCreatedDate = Nz(DateString(.Fields("CREATED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strCreatedBy = Nz(.Fields("CREATED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
			strModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		End If
	End With

	Call makePageHeader(TXT_EDIT_POLICY & "<br>" & strPolicyTitle, TXT_EDIT_POLICY & "<br>" & strPolicyTitle, True, False, True, True)
Else
	Call makePageHeader(TXT_ADD_POLICY, TXT_ADD_POLICY, True, False, True, True)
End If

%>

<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> | <a href="<%=makeLinkB("setup_inclusion.asp")%>"><%=TXT_RETURN_TO_POLICY_SETUP%></a> ]</p>
<form action="setup_inclusion_edit2.asp" method="post">
<%=g_strCacheFormVals%>
<%If Not bNew Then%>
<input type="hidden" name="InclusionPolicyID" value="<%=intInclusionPolicyID%>">
<%End If%>
<table class="BasicBorder cell-padding-4 max-width-lg">
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
	<td class="FieldLabelLeft"><%=TXT_LANGUAGE%><%=StringIf(bNew," <span class=""Alert"">*</span>")%></td>
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
	<td class="FieldLabelLeft"><label for="PolicyTitle"><%=TXT_POLICY_TITLE%></label> <span class="Alert">*</span></td>
	<td><input type="text" name="PolicyTitle" id="PolicyTitle" value=<%=AttrQs(strPolicyTitle)%> size="<%=TEXT_SIZE%>" maxlength="50"> 
	<br><%=TXT_INST_POLICY_TITLE%></td>
</tr>
<%
	If Nl(strPolicyText) Then
		intFieldLen = 0
	Else
		intFieldLen = Len(strPolicyText)
		strPolicyText = Server.HTMLEncode(strPolicyText)
	End If
%>
<tr>
	<td class="FieldLabelLeft"><label for="PolicyText"><%=TXT_POLICY_CONTENT%></label> <span class="Alert">*</span></td>
	<td><span class="SmallNote"><%=TXT_INST_MAX_30000%>&nbsp;<%=TXT_HTML_ALLOWED%></span>
	<br><textarea name="PolicyText" id="PolicyText" wrap="soft" rows="<%=getTextAreaRows(intFieldLen,5)%>" cols="<%=TEXTAREA_COLS%>"><%=strPolicyText%></textarea>
	<%If Not bNew Then%>
	<br><a href="javascript:openWin('<%=makeLink(ps_strPathToStart & "inclusion.asp","PolicyID=" & intInclusionPolicyID,vbNullString)%>','incPolicy')"><%=TXT_VIEW_CURRENT_POLICY%></a>
	<%End If%></td>
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
