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
<!--#include file="../text/txtFindReplaceCommon.asp" -->
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtPrintProfile.asp" -->
<!--#include file="../text/txtProfile.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/list/incFieldList.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->
<!--#include file="../includes/print/incPrintFieldTypeList.asp" -->
<%
Dim intDomain, _
	strType, _
	strDbArea

Const FTYPE_HEADING = 1
Const FTYPE_BASIC = 2
Const FTYPE_FULL = 3
Const FTYPE_CONTINUE = 4

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

Dim intPFLDID
intPFLDID = Trim(Request("PFLDID"))

If Nl(intPFLDID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
ElseIf Not IsIDType(intPFLDID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intPFLDID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intPFLDID = CLng(intPFLDID)
End If

Dim		intProfileID, _
		strProfileName, _
		strFieldName

Dim cnnProfileFields, cmdProfileFields, rsProfileFields
Call makeNewAdminConnection(cnnProfileFields)
Set cmdProfileFields = Server.CreateObject("ADODB.Command")
With cmdProfileFields
	.ActiveConnection = cnnProfileFields
	.CommandText = "dbo.sp_GBL_PrintProfile_Fld_FindReplace_l"
	.CommandType = adCmdStoredProc
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 4, intDomain)
	.Parameters.Append .CreateParameter("@PFLD_ID", adInteger, adParamInput, 4, intPFLDID)
	.CommandTimeout = 0
End With
Set rsProfileFields = cmdProfileFields.Execute

If rsProfileFields.EOF Then
	Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intProfileID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_PROFILE, _
		"print_profile.asp", "DM=" & intDomain)
Else
	intProfileID = rsProfileFields("ProfileID")
	strProfileName = rsProfileFields("ProfileName")
	strFieldName = rsProfileFields("FieldName")
End If

Set rsProfileFields = rsProfileFields.NextRecordset

Call makePageHeader(TXT_MANAGE_FIELDS_TITLE & TXT_COLON & strProfileName, TXT_MANAGE_FIELDS_TITLE & TXT_COLON & strProfileName, True, False, True, True)
%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a> 
| <a href="<%=makeLink("print_profile.asp","DM=" & intDomain,vbNullString)%>"><%=TXT_RETURN_TO_PROFILES%> (<%=strType%>)</a> 
| <a href="<%=makeLink("print_profile_edit.asp","ProfileID=" & intProfileID & "&DM=" & intDomain,vbNullString)%>"><%=TXT_RETURN_TO_PROFILE%><%=strProfileName%></a> 
| <a href="<%=makeLink("print_profile_edit_fields.asp","ProfileID=" & intProfileID & "&DM=" & intDomain,vbNullString)%>"><%=TXT_MANAGE_FIELDS & TXT_COLON%><%=strProfileName%></a> 
]</p>
<h2><%=TXT_MANAGE_FIND_REPLACE_TITLE & TXT_COLON & strFieldName%></h2>
<table class="BasicBorder cell-padding-3">
<% 
If Not rsProfileFields.EOF Then 
%>
<tr>
	<th class="RevTitleBox"><%=TXT_REPLACE_COMMAND%></th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<%
End If
	Dim fldPFLDRPID, _
		fldRunOrder, _
		fldLookFor, _
		fldReplaceWith, _
		fldRegEx, _
		fldMatchCase, _
		fldMatchAll, _
		fldLanguages, _
		xmlDoc, _
		xmlNode, _
		xmlCultureNode,_
		strCulture, _
		bApplyLang, _
		bFirst
	
	With rsProfileFields
		Set fldPFLDRPID = .Fields("PFLD_RP_ID")
		Set fldRunOrder = .Fields("RunOrder")
		Set fldLookFor = .Fields("LookFor")
		Set fldReplaceWith = .Fields("ReplaceWith")
		Set fldRegEx = .Fields("RegEx")
		Set fldMatchCase = .Fields("MatchCase")
		Set fldMatchAll = .Fields("MatchAll")
		Set fldLanguages = .Fields("Languages")
	End With
	
	While Not rsProfileFields.EOF
%>
<form action="print_profile_edit_fields_fr2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="PFLDID" value="<%=intPFLDID%>">
<input type="hidden" name="PFLDRPID" value="<%=fldPFLDRPID%>">
<tr valign="TOP">
	<td><table class="NoBorder cell-padding-3">
	<tr>
		<td class="FieldLabelClr"><%=TXT_ORDER%> <span class="Alert">*</span></td>
		<td><input name="RunOrder" type="text" size="3" maxlength="3" value="<%=fldRunOrder%>"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%=TXT_LOOK_FOR%> <span class="Alert">*</span></td>
		<td><span class="SmallNote"><%=TXT_INST_MAX_500%></span>
		<br><textarea name="LookFor" rows="<%=TEXTAREA_ROWS_SHORT%>" cols="<%=TEXTAREA_COLS-10%>"><%=vbCrLf & Server.HTMLEncode(fldLookFor)%></textarea></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%=TXT_REPLACE_WITH%></td>
		<td><span class="SmallNote"><%=TXT_INST_MAX_500%></span>
		<br><textarea name="ReplaceWith" rows="<%=TEXTAREA_ROWS_SHORT%>" cols="<%=TEXTAREA_COLS-10%>"><%=vbCrLf & Server.HTMLEncode(fldReplaceWith)%></textarea></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%=TXT_OPTIONS%></td>
		<td>
<%
	bFirst = True
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	xmlDoc.loadXML "<Langs>" & Nz(fldLanguages.Value,vbNullString) & "</Langs>"

	For Each strCulture in active_cultures()
		If Not bFirst Then
			%><br><%
		Else
			bFirst = False
		End If

		bApplyLang = xmlDoc.selectNodes("//LangID[text()=""" & Application("Culture_" & strCulture & "_LangID") & """]").length = 1
%>
		<input type="checkbox" name="LangID" value="<%= Application("Culture_" & strCulture & "_LangID")%>"<%If bApplyLang Then%> checked<%End If%>>&nbsp;<%= Replace(TXT_APPLY_TO_RECORDS, "LANG", Application("Culture_" & strCulture & "_LanguageName")) %>
<%
	Next
%>
		<br><input type="checkbox" name="RegEx"<%If fldRegEx Then%> checked<%End If%>>&nbsp;<%=TXT_USE_REGEX%>
		<br><input type="checkbox" name="MatchCase"<%If fldMatchCase Then%> checked<%End If%>>&nbsp;<%=TXT_MATCH_CASE%>
		<br><input type="checkbox" name="MatchAll"<%If fldMatchAll Then%> checked<%End If%>>&nbsp;<%=TXT_MATCH_ALL%></td>
	</tr>
	</table></td>
	<td><input type="submit" name="Submit" value="<%=TXT_UPDATE%>"><br><br><input type="submit" name="Submit" value="<%=TXT_DELETE%>"></td>
</tr>
</form>
<%
		rsProfileFields.MoveNext
	Wend
	rsProfileFields.Close
	Set rsProfileFields = Nothing
	Set cmdProfileFields = Nothing

%>
<tr>
	<th class="RevTitleBox"><%=TXT_REPLACE_COMMAND%> (<%=TXT_ADD%>)</th>
	<th class="RevTitleBox"><%=TXT_ACTION%></th>
</tr>
<form action="print_profile_edit_fields_fr2.asp" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="PFLDID" value="<%=intPFLDID%>">
<input type="hidden" name="DM" value="<%=intDomain%>">
<tr valign="TOP">
	<td><table class="NoBorder cell-padding-3">
	<tr>
		<td class="FieldLabelClr"><%=TXT_ORDER%> <span class="Alert">*</span></td>
		<td><input name="RunOrder" type="text" size="3" maxlength="3" value="0"></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%=TXT_LOOK_FOR%> <span class="Alert">*</span></td>
		<td><span class="SmallNote"><%=TXT_INST_MAX_500%></span>
		<br><textarea name="LookFor" rows="<%=TEXTAREA_ROWS_SHORT%>" cols="<%=TEXTAREA_COLS-10%>"></textarea></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%=TXT_REPLACE_WITH%></td>
		<td><span class="SmallNote"><%=TXT_INST_MAX_500%></span>
		<br><textarea name="ReplaceWith" rows="<%=TEXTAREA_ROWS_SHORT%>" cols="<%=TEXTAREA_COLS-10%>"></textarea></td>
	</tr>
	<tr>
		<td class="FieldLabelClr"><%=TXT_OPTIONS%></td>
		<td>
<%
	bFirst = True
	For Each strCulture in active_cultures()
		If Not bFirst Then
			%><br><%
		Else
			bFirst = False
		End If
%>
		<input type="checkbox" name="LangID" value="<%= Application("Culture_" & strCulture & "_LangID")%>" checked>&nbsp;<%= Replace(TXT_APPLY_TO_RECORDS, "LANG", Application("Culture_" & strCulture & "_LanguageName")) %>
<%
	Next
%>
		<br><input type="checkbox" name="RegEx">&nbsp;<%=TXT_USE_REGEX%>
		<br><input type="checkbox" name="MatchCase">&nbsp;<%=TXT_MATCH_CASE%>
		<br><input type="checkbox" name="MatchAll" checked>&nbsp;<%=TXT_MATCH_ALL%></td>
	</tr>
	</table></td>
	<td><input type="submit" value="<%=TXT_ADD%>"></td>
</tr>
</form>
</table>
<%
Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
