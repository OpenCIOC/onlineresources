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
Call setPageInfo(True, DM_CIC, DM_CIC, "../", "import/", vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<!--#include file="../includes/core/incHeader.asp" -->
<!--#include file="../includes/core/incFooter.asp" -->
<!--#include file="../text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtImport.asp" -->
<!--#include file="../includes/core/incFormat.asp" -->

<%
If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

Dim intEFID
intEFID = Trim(Request("EFID"))

If Nl(intEFID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & intEFID & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
ElseIf Not IsIDType(intEFID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intEFID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
		"import.asp", vbNullString)
Else
	intEFID = CLng(intEFID)
End If

Call makePageHeader(TXT_IMPORT_RECORD_DATA, TXT_IMPORT_RECORD_DATA, True, False, True, True)

Dim cmdListImportData, _
	rsListImportData, _
	bIsIcarolImport, _
	intRecordCount, _
	fldERID, _
	fldNUM, _
	fldOWNER, _
	fldREPORT, _
	fldCANRETRY, _
	fldCANRESCHED, _
	strReschedList, _
	strReschedListSep


Dim intError
intError = 0

strReschedList = vbNullString
strReschedListSep = vbNullString

Set cmdListImportData = Server.CreateObject("ADODB.Command")
Set rsListImportData = Server.CreateObject("ADODB.Recordset")

With cmdListImportData
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_Report_l"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
End With

With rsListImportData
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdListImportData

	If Not .EOF Then
		intError = .Fields("Error")
		bIsIcarolImport = .FIelds("IsIcarolImport")
		If intError <> 0 Then
			Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
		End If
	End If
End With

If intError = 0 Then
	Set rsListImportData = rsListImportData.NextRecordset

	With rsListImportData
		intRecordCount = .RecordCount
		if intRecordCount > 0 and bIsIcarolImport Then
			Set fldCANRESCHED = .Fields("CAN_ICAROL_RESCHED")
			Set fldERID = .Fields("ER_ID")
			While Not .EOF
				If fldCANRESCHED Then
					strReschedList = strReschedList & strReschedListSep & fldERID.Value
					strReschedListSep = ","
				End If
				.MoveNext
			Wend
			.MoveFirst
		End If

%><p>[ <a href="<%=makeLinkB("import.asp")%>"><%=TXT_RETURN_TO_IMPORT%></a><%If Not Nl(strReschedList) Then %> | <a href="<%= makeLink("import_reschedule.asp", "EFID=" & intEFID & "&ERID=" & strReschedList, vbNullString ) %>"><%= TXT_RESCHEDULE_ALL %></a><%End If%> ]</p>
<p><%=TXT_THERE_ARE%> <strong><%=intRecordCount%></strong> <%=TXT_RECORDS_IMPORTED & " " & TXT_REVIEW_LIST_BELOW%></p>
<%
		If intRecordCount > 0 Then
			Set fldERID = .Fields("ER_ID")
			Set fldNUM = .Fields("NUM")
			Set fldOWNER = .Fields("OWNER")
			Set fldREPORT = .Fields("REPORT")
			Set fldCANRETRY = .Fields("CAN_RETRY")
			Set fldCANRESCHED = .Fields("CAN_ICAROL_RESCHED")
%>
<table class="BasicBorder cell-padding-2">
<tr>
	<th><%=TXT_RECORD_NUM%></th>
	<th><%=TXT_ORG_NAMES%></th>
	<th><%=TXT_RECORD_OWNER%></th>
	<th><%=TXT_CAN_RETRY%></th>
	<% If bIsIcarolImport Then %>
	<th><%=TXT_CAN_RESCHEDULE%></th>
	<% End If %>
	<th><%=TXT_IMPORT_REPORT%></th>
</tr>
<%
			While Not .EOF
%>
<tr>
	<td><%=fldNUM%></td>
<%
		If Not .Fields("CAN_SEE") Then
%>
	<td><%=.Fields("ORG_NAME_FULL")%></td>
<%
			
		Else
%>
	<td><a href="<%=makeDetailsLink(.Fields("NUM"), vbNullString, vbNullString)%>"><%=.Fields("ORG_NAME_FULL")%></a></td>
<%
		End If
%>
	<td><%=fldOWNER%></td>
	<td><%=StringIf(fldCANRETRY, TXT_CAN_RETRY)%></td>
	<% If bIsIcarolImport Then %>
	<td>
		<% If fldCANRESCHED Then %>
		<a href="<%= makeLink("import_reschedule.asp", "EFID=" & intEFID & "&ERID=" & fldERID.Value, vbNullString ) %>"><%= TXT_RESCHEDULE %></a>
		<% End If %>
	</td>
	<% End If %>
	<td><%=IIf(Nl(fldREPORT),TXT_NO_ISSUES,"<span class=""Alert"">" & fldREPORT & "</span>")%></td>
</tr>
<%
				.MoveNext
			Wend
%>
</table>
<%

		End If
	End With
End If

rsListImportData.Close

Set rsListImportData = Nothing
Set cmdListImportData = Nothing

Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
