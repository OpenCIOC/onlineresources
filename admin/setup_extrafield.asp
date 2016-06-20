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
'
' Purpose: Edit field names and display order
'
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
<!--#include file="../text/txtSetup.asp" -->
<%
Dim intDomain, _
	strType, _
	strFType, _
	strFTypeLabel, _
	bSuperUserGlobal, _
	strMemberNameDOM, _
	strRequestCode

Dim strStoredProcName

intDomain = Request("DM")
If IsNumeric(intDomain) Then
	intDomain = CInt(intDomain)
End If

Select Case intDomain
	Case DM_CIC
		If Not user_bSuperUserCIC Then
			Call securityFailure()
		End If
		bSuperUserGlobal = user_bSuperUserGlobalCIC
		strType = TXT_CIC
		strStoredProcName = "dbo.sp_GBL_FieldOption_l_Extra"
		strMemberNameDOM = g_strMemberNameCIC
	Case DM_VOL
		If Not user_bSuperUserVOL Then
			Call securityFailure()
		End If
		bSuperUserGlobal = user_bSuperUserGlobalVOL
		strType = TXT_VOLUNTEER
		strStoredProcName = "dbo.sp_VOL_FieldOption_l_Extra"
		strMemberNameDOM = g_strMemberNameVOL
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select

strFType = Request("FType")
Select Case strFType
	Case "d"
		strFTypeLabel = TXT_DATE
		strRequestCode = "EXTRADATE"
	Case "e"
		strFTypeLabel = TXT_EMAIL
		strRequestCode = "EXTRAEMAIL"
	Case "l"
		strFTypeLabel = TXT_CHECKLIST
		strRequestCode	= "EXTRACHECKLIST"
	Case "p"
		strFTypeLabel = TXT_DROPDOWN
		strRequestCode	= "EXTRADROPDOWN"
	Case "r"
		strFTypeLabel = TXT_RADIO
		strRequestCode = "EXTRARADIO"
	Case "t"
		strFTypeLabel = TXT_TEXT
		strRequestCode = "EXTRATEXT"
	Case "w"
		strFTypeLabel = TXT_WWW
		strRequestCode = "EXTRAWWW"
	Case Else
		Call handleError(TXT_UNABLE_DETERMINE_TYPE, _
			"setup.asp", _
			vbNullString)
End Select


Call makePageHeader(TXT_CREATE_EDIT_EXTRA_FIELDS & " (" & strType & ") - " & strFTypeLabel, TXT_CREATE_EDIT_EXTRA_FIELDS & " (" & strType & ") - " & strFTypeLabel, True, True, True, True)

Dim cmdFieldList, rsFieldList

Set cmdFieldList = Server.CreateObject("ADODB.Command")
With cmdFieldList
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.Parameters.Append .CreateParameter("@ExtraFieldType", adChar, adParamInput, 1, strFType)
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
End With
Set rsFieldList = Server.CreateObject("ADODB.Recordset")
With rsFieldList
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdFieldList
End With

%>
<p style="font-weight:bold">[ <a href="<%=makeLinkB("setup.asp")%>"><%=TXT_RETURN_TO_SETUP%></a>
<% If Not bSuperUserGlobal Then %>
| <a href="<%= makeLink("notices/new", "AreaCode=" & strRequestCode & "&DM=" & intDomain, vbNullString) %>"><%= TXT_REQUEST_CHANGE %></a>
<% End If %>
]</p>
<h2><%=TXT_EXTRA_FIELD_SETUP & " - " & strFTypeLabel%></h2>
<table class="BasicBorder cell-padding-3">
<tr>
	<th><%=TXT_DISPLAY%></th>
	<th><%=TXT_NAME%></th>
<%If strFType = "t" Then%>
	<th><%=TXT_FIELD_LENGTH%></th>
	<th><%=TXT_FULL_TEXT_INDEX%></th>
<%ElseIf strFType = "d" Then%>
	<th><%=TXT_NO_YEAR%></th>
<%End If%>
	<th><%= TXT_EXCLUSIVELY_OWNED_BY_MEMBER %>
	<th><%=TXT_USAGE%></th>
	<th><%=TXT_ACTION%></th>
</tr>

<%
With rsFieldList
	If Not .EOF Then
		While Not .EOF
			If bSuperUserGlobal Or .Fields("MemberID") = g_intMemberID Then
%>
<form action="setup_extrafield2.asp" method="post">
<!-- hidden form values -->
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="FieldID" value="<%=.Fields("FieldID")%>">
<input type="hidden" name="FType" value="<%=strFType%>">
<input type="hidden" name="OldName" value="<%=.Fields("ExtraFieldName")%>">
<input type="hidden" name="OldMaxLength" value="<%=.Fields("MaxLength")%>">
<input type="hidden" name="OldFullTextIndex" value="<%=StringIf(.Fields("FullTextIndex"),"on")%>">
<input type="hidden" name="OldNoYear" value="<%=StringIf(.Fields("ExtraFieldType")="a", "on")%>">
<input type="hidden" name="OldMemberID" value="<%=.Fields("MemberID")%>">
</div>
<%			End If %>
<tr>
	<td class="FieldLabelLeft"><label for="ExtraField_<%=.Fields("FieldID")%>"><%=.Fields("FieldDisplay")%></label></td>
	<td>
	<% If bSuperUserGlobal Or .Fields("MemberID") = g_intMemberID Then %>
	<input type="text" size="20" maxlength="25" name="ExtraFieldName" id="<%="ExtraField_" & .Fields("FieldID")%>" value="<%=Server.HTMLEncode(Ns(.Fields("ExtraFieldName")))%>">
	<% Else %>
	<%=Server.HTMLEncode(Ns(.Fields("ExtraFieldName")))%>
	<% End If %>
	</td>
<%If strFType = "t" Then%>
	<td>
	<% If bSuperUserGlobal Or .Fields("MemberID") = g_intMemberID Then %>
	<input type="text" size="5" maxlength="4" name="MaxLength" title=<%=AttrQs(Server.HTMLEncode(.Fields("FieldDisplay") & TXT_COLON & TXT_FIELD_LENGTH))%> value="<%=.Fields("MaxLength")%>">
	<% Else %>
	<%= .Fields("MaxLength") %>
	<% End If %>
	</td>
	<td align="center">
	<% If bSuperUserGlobal Or .Fields("MemberID") = g_intMemberID Then %>
	<input type="checkbox" title=<%=AttrQs(Server.HTMLEncode(.Fields("FieldDisplay") & TXT_COLON & TXT_FULL_TEXT_INDEX))%> name="FullTextIndex"<%=Checked(.Fields("FullTextIndex"))%>>
	<% Else %>
	<%= StringIf(.Fields("FullTextIndex"), "*") %>
	<% End If %>
	</td>
<% ElseIf strFtype = "d" Then%>
	<td align="center">
	<input type="checkbox" title=<%=AttrQs(Server.HTMLEncode(.Fields("FieldDisplay") & TXT_COLON & TXT_NO_YEAR))%> name="NoYear"<%=Checked(.Fields("ExtraFieldType")="a")%>>
	</td>
<%End If%>
	<td>
	<% If bSuperUserGlobal Then %>
	<label for="Owner_<%=.Fields("FieldID")%>"><input type="checkbox" name="MemberID" value="<%=Nz(.Fields("MemberID"), g_intMemberID)%>" id="Owner_<%=.Fields("FieldID")%>"<%=StringIf(Not Nl(.Fields("MemberID")), " checked")%>> <%=IIf(.Fields("MemberID"), .Fields("MemberName"), strMemberNameDOM) %></label>
	<%Else%>
	<%=.Fields("MemberName") %>
	<%End If%>
	</td>
	<td><%=.Fields("Usage")%>
<% If strFType = "p" Or strFType = "l" Then %>
	<a href="<%= makeLink(IIf(intDomain = DM_CIC, "~/results.asp", "~/volunteer/results.asp"), "EX" & IIf(strFType = "p", "D", "C") & "=" & .Fields("ExtraFieldName") & "&EX" & IIf(strFType="p", "D", "C") & .Fields("ExtraFieldName") & "Type=A&incDel=on", vbNullString) %>"><img src="/images/zoom.gif" alt=<%=AttrQs(.Fields("FieldDisplay") & TXT_SEARCH)%> title=<%=AttrQs(.Fields("FieldDisplay") & TXT_COLON & TXT_SEARCH)%> width="17" height="14" border="0"></a>
<% End If %>
</td>
	<td>
	<% If bSuperUserGlobal Or .Fields("MemberID") = g_intMemberID Then %>
	<input type="submit" name="Submit" value="<%=TXT_UPDATE%>">
	<%If .Fields("Usage")=0 Then%>
		<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
	<%End If%>
	<% End If %>
	</td>
</tr>
<%				If bSuperUserGlobal Or .Fields("MemberID") = g_intMemberID Then %>
</form>
<%
				End If
			.MoveNext
		Wend
	End If
	.Close
End With

%>
<form action="setup_extrafield2.asp" method="post">
<!-- hidden form values -->
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="DM" value="<%=intDomain%>">
<input type="hidden" name="FType" value="<%=strFType%>">
</div>
<tr>
	<td class="FieldLabelLeft">&nbsp;</td>
	<td><input type="text" size="20" maxlength="25" name="ExtraFieldName" title=<%=AttrQs(TXT_NEW_FIELD & TXT_COLON & TXT_NAME)%>></td>
<%If strFType = "t" Then%>
	<td><input type="text" size="5" maxlength="4" name="MaxLength" title=<%=AttrQs(TXT_NEW_FIELD & TXT_COLON & TXT_FIELD_LENGTH)%>></td>
	<td align="center"><input type="checkbox" name="FullTextIndex" title=<%=AttrQs(TXT_NEW_FIELD & TXT_COLON & TXT_FULL_TEXT_INDEX)%>></td>
<%ElseIf strFType = "d" Then%>
	<td align="center"><input type="checkbox" name="NoYear" title=<%=AttrQs(TXT_NEW_FIELD & TXT_COLON & TXT_NO_YEAR)%>></td>
<%End If%>
	<td>&nbsp;</td>
	<td>
	<% If bSuperUserGlobal Then %>
	<label for="Owner_New"><input type="checkbox" name="MemberID" value="<%=g_intMemberID%>" id="Owner_Add%>"> <%=strMemberNameDOM%></label>
	<%Else%>
	&nbsp;
	<%End If%>
	</td>
	<td><input type="submit" value="<%=TXT_ADD%>"></td>
</tr>
</form>
</table>
<% 

Set rsFieldList = Nothing
Set cmdFieldList = Nothing

Call makePageFooter(False)
%>
<!--#include file="../includes/core/incClose.asp" -->

