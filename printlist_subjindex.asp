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
<!--#include file="text/txtPrintList.asp" -->
<!--#include file="includes/core/incFormat.asp" -->

<%
Server.ScriptTimeOut = 900

Const MAX_LEVEL = 7

Dim aNameSequence, aCurNames(8), aPrevNames(7)
aNameSequence = Array("ORG_LEVEL_1","ORG_LEVEL_2","ORG_LEVEL_3","ORG_LEVEL_4","ORG_LEVEL_5","LOCATION_NAME","SERVICE_NAME_LEVEL_1","SERVICE_NAME_LEVEL_2")

Sub setNameArray(ByRef aNames, rsOrg)
	Dim i, j
	j = 0

	For i = 0 to MAX_LEVEL
		If Not Nl(rsOrg.Fields(aNameSequence(i))) Then
			aNames(j) = rsOrg.Fields(aNameSequence(i))
			j = j + 1
		End If
	Next

	For i = j to MAX_LEVEL
		aNames(i) = vbNullString
	Next
End Sub

Sub clearNameArray(ByRef aNames)
	Dim i

	If IsArray(aNames) Then
		For i = 0 to UBound(aNames)
			aNames(i) = vbNullString
		Next
	End If
End Sub 

Dim bError
bError = False

Dim intSubjID
If g_bLimitedView Then
	intSubjID = g_intPBID
Else
	intSubjID = Request("SubjID")
End If

If Nl(intSubjID) Then
	Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
	Call handleError(TXT_NO_RECORD_CHOSEN & " <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
	bError = True
ElseIf Not IsIDType(intSubjID) Then
	Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSubjID) & ". <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
		vbNullString, _
		vbNullString)
	Call makePageFooter(False)
	bError = True
Else
	intSubjID = CLng(intSubjID)
End If

If Not bError Then

	Dim bWord, _
		strWordDots, _
		intFontSize, _
		strFontFamily

	bWord = Request("ForWord") = "on"
	
	If bWord Then
		strWordDots = "<span STYLE='mso-tab-count:1 dotted'></span>"
	Else
		strWordDots = vbNullString
	End If
	
	intFontSize = Nz(Request("FontSize"),10)
	If Not IsNumeric(intFontSize) Then
		intFontSize = 10
	ElseIf Not intFontSize >= 8 and intFontSize <= 14 Then
		intFontSize = 10
	End If
	
	strFontFamily = Nz(Request("FontFamily"),SANS_SERIF_FONT)
%>
<html>
<head>
<title><%=TXT_SUBJECT_INDEX%></title>
<style type="text/css">
<!--
td {
	font-size: <%=intFontSize%>pt;
	font-family: <%=strFontFamily%>;
	padding-top: 1px;
	padding-bottom: 1px;
	vertical-align: bottom;
}
td.see {
	width:5em;
	padding-left:2em;
	padding-right: 0.5em;
	padding-top: 1px;
	padding-bottom: 1px;
}
td.seeoneline {
	width:5em;
	padding-left:2em;
	padding-right: 0.5em;
	padding-top: 10px;
	padding-bottom: 10px;
}
td.seerelated {
	padding-top: 1px;
	padding-bottom: 10px;
}
td.seealso {
	width:5em;
	padding-left:2em;
	font-weight:bold;
	padding-right: 0.5em;
	padding-top: 10px;
	padding-bottom: 10px;
}
td.seealsorelated {
	padding-top: 10px;
	padding-bottom: 10px;
}
<%
	Dim iDots
	For iDots = 1 to MAX_LEVEL+1
%>
td.dots<%=iDots%> {
<%
		If bWord Then
%>
	tab-stops:dotted 5.5in;
	margin-left: <%=2*iDots-2%>em;
<%
		Else
%>
	background: url("/images/dots.gif") repeat-x left center;
<%
		End If
%>
	width: 95%;
	vertical-align: bottom;
	text-align: left;
}
<%
	Next
	For iDots = 1 to MAX_LEVEL+1
%>
td.nodots<%=iDots%> {
<%
		If bWord Then
%>
	margin-left: <%=2*iDots-2%>em;
<%
		End If
%>
	width: 95%;
	text-align: left;
}
<%
	Next
%>
td.subject {
	padding-top: 10px;
	padding-bottom: 1px;
}
td.subjectoneline {
	padding-top: 10px;
	padding-bottom: 10px;
}
span.subject {
	font-weight:bold;
}
<%
	Dim iOrg
	For iOrg = 1 to MAX_LEVEL+1
%>
span.org<%=iOrg%> {
<%
		If Not bWord Then
%>
	background-color: white;
	padding-left: <%=2*iOrg-2%>em;
<%
		End If
%>
	padding-right: 0.5em;
}
<%
	Next
%>
td.rnum {
	font-weight: bold;
	text-align: right;
	padding-left: 0.5em;
	max-width: 4em;
}
H1.letter {
	font-size: <%=intFontSize+6%>pt;
	font-family: <%=strFontFamily%>;
	font-weight:bold;
	padding-top: 1px;
	padding-bottom: 1px;
}
-->
</style>
</head>
<%
Dim cmdSubjectIndex, rsSubjectIndex
Set cmdSubjectIndex = Server.CreateObject("ADODB.Command")
With cmdSubjectIndex
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_Publication_SubjectIndex"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@Print_PB_ID", adInteger, adParamInput, 4, intSubjID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
	.Parameters.Append .CreateParameter("@NoDeleted", adBoolean, adParamInput, 1, IIf(Request("IncludeDeleted")="on",SQL_FALSE,SQL_TRUE))
End With

Set rsSubjectIndex = Server.CreateObject("ADODB.Recordset")
With rsSubjectIndex
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdSubjectIndex

	If .EOF Then
		Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
		Call handleError(TXT_NO_RECORDS_TO_PRINT & " <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
			vbNullString, _
			vbNullString)
		Call makePageFooter(False)
		bError = True
	End If
End With

If Not bError Then

Dim fldSubject, _
	fldUsed, _
	fldPNUM, _
	fldRELATED

With rsSubjectIndex
	
	Set fldSubject = .Fields("Subject")
	Set fldUsed = .Fields("Used")
	Set fldPNUM = .Fields("PNUM")
	Set fldRELATED = .Fields("RELATED")

	Dim	intCurLvl, _
		strCurS, _
		strPrevS, _
		strPrevRelated
		
		strPrevS = vbNullString
		strPrevRelated = vbNullString
%>
<body bgcolor="#FFFFFF" text="#000000">
<%
	While Not .EOF
		intCurLvl = 0
		Call setNameArray(aCurNames, rsSubjectIndex)
		strCurS = fldSubject.Value

		If strCurS <> strPrevS Then
			Call clearNameArray(aPrevNames)
			If Not Nl(strPrevRelated) Then
%>
<tr>
	<td><table class="NoBorder cell-padding-1">
		<tr valign="TOP">
			<td class="seealso"><%=TXT_SEE_ALSO%></td>
			<td class="seealsorelated"><%=strPrevRelated%></td>
		</tr>
	</table></td>
</tr>
<%
				strPrevRelated = vbNullString
			End If
			If UCase(Left(strCurS,1))<>UCase(Left(strPrevS,1)) Then
				If strPrevS <> vbNullString Then
%>
</table>
<%
				End If
%>
<h1 class="letter"><%=UCase(Left(strCurS,1))%> ...</h1>
<table width="100%" class="NoBorder" cellpadding="0" cellspacing="0">
<%
			End If
			If fldUsed.Value Then
%>
<tr>
	<td colspan="2" class="subjectoneline"><span class="subject"><%=strCurS%></span></td>
</tr>
<%
			End If
		End If
		If fldUsed.Value Then
			For intCurLvl = 0 to MAX_LEVEL
				If Not Nl(aCurNames(intCurLvl)) Then
					If Nl(aCurNames(intCurLvl+1)) Then
%>
<tr valign="TOP">
	<td class="dots<%=intCurLvl+1%>" style="padding-top: 5px;"><span class="org<%=intCurLvl+1%>"><%=aCurNames(intCurLvl)%></span><%=strWordDots%></td>
	<td class="rnum" <%If intCurLvl=0 Then%> style="padding-top: 5px;"<%End If%>><%=fldPNUM.Value%></td>
</tr>
<%
					ElseIf Not (aCurNames(intCurLvl) = aPrevNames(intCurLvl)) Then
%>
<tr valign="TOP">
	<td class="nodots<%=intCurLvl+1%>"><span class="org<%=intCurLvl+1%>"><%=aCurNames(intCurLvl)%></span></td>
	<td class="rnum">&nbsp;</td>
</tr>
<%
					End If
				End If
				aPrevNames(intCurLvl) = aCurNames(intCurLvl)
			Next

			strPrevRelated = fldRELATED			
		Else
%>
<tr>
	<td colspan="2" class="subject"><span class="subject"><%=strCurS%></span></td>
</tr>
<tr>
	<td><table border="0" class="NoBorder" cellpadding="0" cellspacing="0">
		<tr valign="TOP">
			<td class="see"><%=TXT_SEE%></td>
			<td class="seerelated"><%=fldRelated%></td>
		</tr>
	</table></td>
</tr>
<%
		End If

		strPrevS = strCurS
		.MoveNext
	Wend
	.Close
End With

If Not Nl(strPrevRelated) Then
%>
<tr>
	<td><table border="0" class="NoBorder" cellpadding="0" cellspacing="0">
		<tr valign="TOP">
			<td class="seealso"><%=TXT_SEE_ALSO%></td>
			<td class="seealsorelated"><%=strPrevRelated%></td>
		</tr>
	</table></td>
</tr>
<%
End If

Set rsSubjectIndex = Nothing
Set cmdSubjectIndex = Nothing

%>
</table>
</body>
</html>
<%
End If

End If
%>

<!--#include file="includes/core/incClose.asp" -->
