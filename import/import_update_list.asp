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
Call setPageInfo(True, DM_GLOBAL, DM_CIC, "../", "import/", vbNullString)
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
Const DATASET_FULL = 0
Const DATASET_ADD = 1
Const DATASET_UPDATE = 2
Const DATASET_NOUPDATE = 3

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

Dim intDataSet, _
	strStoredProcName

intDataSet = Request("DataSet")
If IsNumeric(intDataSet) Then
	intDataSet = CInt(intDataSet)
End If
Select Case intDataSet
	Case DATASET_ADD
		strStoredProcName = "dbo.sp_CIC_ImportEntry_Data_Add_l"
	Case DATASET_UPDATE
		strStoredProcName = "dbo.sp_CIC_ImportEntry_Data_Update_l"
	Case DATASET_NOUPDATE
		strStoredProcName = "dbo.sp_CIC_ImportEntry_Data_NoUpdate_l"
	Case Else
		intDataSet = DATASET_FULL
		strStoredProcName = "dbo.sp_CIC_ImportEntry_Data_l"
End Select

Call makePageHeader(TXT_IMPORT_RECORD_DATA, TXT_IMPORT_RECORD_DATA, True, False, True, True)

Dim cmdListImportData, _
	rsListImportData, _
	intRecordCount, _
	fldERID, _
	fldNUM, _
	fldEXTERNALID, _
	fldOWNER, _
	fldLANGUAGES, _
	fldIMPORTED

Dim intError
intError = 0

Set cmdListImportData = Server.CreateObject("ADODB.Command")
Set rsListImportData = Server.CreateObject("ADODB.Recordset")

With cmdListImportData
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	If intDataSet = DATASET_ADD Then
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	Else
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
	End If
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
End With

With rsListImportData
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdListImportData

	If Not .EOF Then
		intError = .Fields("Error")
		If intError <> 0 Then
			Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
		End If
	End If
End With

If intError = 0 Then

Set rsListImportData = rsListImportData.NextRecordset

With rsListImportData
	intRecordCount = .RecordCount
	
%>
<p>[ <%
	Select Case intDataSet
		Case DATASET_ADD
%><a href="<%=makeLink("import_update.asp","EFID=" & intEFID & "&DataSet=" & DATASET_ADD,vbNullString)%>"><%=TXT_ADD%></a><%
		Case DATASET_UPDATE
%><a href="<%=makeLink("import_update.asp","EFID=" & intEFID & "&DataSet=" & DATASET_UPDATE,vbNullString)%>"><%=TXT_UPDATE%></a><%
		Case Else
%><a href="<%=makeLink("import_queue.asp","EFID=" & intEFID & "&DataSet=" & DATASET_FULL,vbNullString)%>"><%=TXT_QUEUE_ALL%></a><%
	End Select
%>
| <a href="<%=makeLinkB("import.asp")%>"><%=TXT_RETURN_TO_IMPORT%></a> ]</p>
<p><%=TXT_THERE_ARE%> <strong><%=intRecordCount%></strong> <%
	Select Case intDataSet
		Case DATASET_ADD
%><%=TXT_RECORDS_THAT_DONT_MATCH%><%
		Case DATASET_UPDATE
%><%=TXT_RECORDS_THAT_MATCH%><%
		Case DATASET_NOUPDATE
%><%=TXT_RECORDS_OWNED_BY_OTHERS%><%
		Case Else
%><%=TXT_RECORDS_TO_IMPORT%><%
	End Select
%></p>
<%
	If intRecordCount > 0 Then
		Set fldERID = .Fields("ER_ID")
		Set fldNUM = .Fields("NUM")
		Set fldEXTERNALID = .Fields("EXTERNAL_ID")
		Set fldOWNER = .Fields("OWNER")
		Set fldLANGUAGES = .Fields("LANGUAGES")
		Set fldIMPORTED = .Fields("IMPORTED")
%>
<table class="BasicBorder cell-padding-2">
<tr>
	<th><%=TXT_RECORD_NUM%></th>
	<th><%=IIf(intDataSet=DATASET_ADD,TXT_NAME,TXT_CURRENT_NAMES)%></th>
	<th><%=TXT_RECORD_OWNER%></th>
	<th><%=TXT_LANGUAGE%></th>
<%If intDataSet<>DATASET_ADD Then %>
	<th><%=TXT_CAN_RETRY%></th>
<%End If%>
	<th<%If intDataSet = DATASET_FULL Then%> colspan="2"<%End If%>><%=TXT_ACTION%></th>
</tr>
<%
		While Not .EOF
%>
<tr>
	<td><%=fldNUM%><%If Not Nl(fldEXTERNALID.Value) Then%> (<%=fldEXTERNALID%>)<%End If%></td>
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
	<td><%=fldOWNER.Value%></td>
	<td><%=Replace(Replace(fldLANGUAGES.Value, "[DELETED]", TXT_DELETED), "[NON_PUBLIC]", TXT_NON_PUBLIC)%></td>
<%If intDataSet <> DATASET_ADD Then%>
	<td><%=StringIf(fldIMPORTED,TXT_CAN_RETRY)%></td>
<% End If%>
<%
		If intDataSet = DATASET_FULL Then
%>
	<td><%=IIf(Nl(.Fields("MemberID")),TXT_ADD,IIf(Not .Fields("CAN_IMPORT"),"<span class=""Alert"">" & TXT_CANNOT_IMPORT & "</span>",TXT_UPDATE))%></td>
<%
		End If
%>
	<td><a href="<%=makeLink("import_view.asp","ERID=" & fldERID & "&EFID=" & intEFID & "&DataSet=" & intDataSet,vbNullString)%>"><%=TXT_VIEW_DATA%></a></td>
</tr>
<%
			.MoveNext
		Wend
%>
</table>
<%
	End If
	.Close
End With

End If

Set rsListImportData = Nothing
Set cmdListImportData = Nothing

Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
