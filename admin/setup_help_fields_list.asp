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
<!--#include file="../text/txtField.asp" -->
<!--#include file="../text/txtHelp.asp" -->
<!--#include file="../text/txtSetup.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->

<%
Dim intDomain, _
	strType, _
	objHelpLn, _
	bGlobal, _
	strStoredProcName

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

bGlobal = Not Nl(Trim(Request("Global")))

Set objHelpLn = create_language_object()
objHelpLn.setSystemLanguage(Nz(Request("HelpLn"),g_objCurrentLang.Culture))

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		strType = TXT_CIC
		strStoredProcName = "dbo.sp_GBL_FieldOption_l_Help"
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		strType = TXT_VOLUNTEER
		strStoredProcName = "dbo.sp_VOL_FieldOption_l_Help"
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

Call makePageHeader(TXT_FIELD_HELP & " - " & objHelpLn.LanguageName & " (" & strType & ")", TXT_FIELD_HELP & " - " & objHelpLn.LanguageName & " (" & strType & ")", True, False, True, True)

Dim cmdFieldHelp, rsFieldHelp
Set cmdFieldHelp = Server.CreateObject("ADODB.Command")
With cmdFieldHelp
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, IIf((strType=DM_VOL And user_bSuperUserGlobalVOL) Or (strType=DM_CIC And user_bSuperUserGlobalCIC),Null,g_intMemberID))
	.Parameters.Append .CreateParameter("LangID", adInteger, adParamInput, 2, objHelpLn.LangID)
End With
Set rsFieldHelp = cmdFieldHelp.Execute

%>
<table class="BasicBorder cell-padding-3">
<tr>
	<th><%=TXT_NAME%></th>
	<th><%=TXT_DISPLAY%></th>
	<th><%=TXT_HELP%></th></tr>
<%
With rsFieldHelp
	While Not .EOF
%>
<tr>
	<td class="FieldLabelLeftClr"><%=.Fields("FieldName")%></td>
	<td><%=.Fields("FieldDisplay")%></td>
	<td><%If Not Nl(.Fields(IIf(bGlobal, "HelpText", "HelpTextMember"))) Then%><%=.Fields(IIf(bGlobal, "HelpText", "HelpTextMember"))%><%Else%>&nbsp;<%End If%></td>
</tr>
<%
		.MoveNext
	Wend
	.Close
End With
%>
</table>
<%
Set rsFieldHelp = Nothing
Set cmdFieldHelp = Nothing

Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->
