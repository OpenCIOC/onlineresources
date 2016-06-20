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
<!--#include file="../includes/list/incImportEntryPrivacyList.asp" -->
<%
Const DATASET_FULL = 0
Const DATASET_ADD = 1
Const DATASET_UPDATE = 2

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

Dim intDataSet
intDataSet = Request("DataSet")
If IsNumeric(intDataSet) Then
	intDataSet = CInt(intDataSet)
End If
Select Case intDataSet
	Case DATASET_ADD
	Case DATASET_UPDATE
	Case Else
		intDataSet = DATASET_FULL
End Select

Call makePageHeader(TXT_VIEW_IMPORT_DATA, TXT_VIEW_IMPORT_DATA, True, False, True, True)
%>
<p>[ <a href="<%=makeLinkB("import.asp")%>"><%=TXT_RETURN_TO_IMPORT%></a> ]</p>
<%
Dim intError
intError = 0

Dim cmdImportStats, rsImportStats

Set cmdImportStats = Server.CreateObject("ADODB.Command")
Set rsImportStats = Server.CreateObject("ADODB.Recordset")

With cmdImportStats
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_Stats"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
End With

With rsImportStats
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdImportStats

	If Not .EOF Then
		intError = .Fields("Error")
		If intError <> 0 Then
			Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
		End If
	End If
End With

If intError = 0 Then
%>
<h2><%=TXT_GENERAL_INFO%></h2>
<%

Set rsImportStats = rsImportStats.NextRecordset

With rsImportStats
	If .EOF Then
		Call handleError(TXT_NO_RECORD_EXISTS_ID & Server.HTMLEncode(intEFID) & "." & _
			vbCrLf & "<br>" & TXT_CHOOSE_DATASET, _
			"import.asp", vbNullString)
	Else
%>
<table class="BasicBorder cell-padding-3">
<tr>
	<td class="FieldLabelLeft"><%=TXT_IMPORT_NAME%></td>
	<td><%=Nz(.Fields("DisplayName"),.Fields("FileName"))%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FILE_NAME%></td>
	<td><%=.Fields("FileName")%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_FILE_NAME%></td>
	<td><%=.Fields("FileName")%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_ADD%></td>
	<td><%=TXT_ENGLISH & TXT_COLON & .Fields("ADD_ENGLISH")%>
	<br><%=TXT_FRENCH & TXT_COLON & .Fields("ADD_FRENCH")%>
	<br><%=TXT_BILINGUAL & TXT_COLON & .Fields("ADD_MULTILINGUAL")%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_UPDATE%></td>
	<td><%=TXT_ENGLISH & TXT_COLON & .Fields("UPDATE_ENGLISH")%>
	<br><%=TXT_FRENCH & TXT_COLON & .Fields("UPDATE_FRENCH")%>
	<br><%=TXT_BILINGUAL & TXT_COLON & .Fields("UPDATE_MULTILINGUAL")%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_CANNOT_IMPORT%></td>
	<td><%=TXT_ENGLISH & TXT_COLON & .Fields("NOUPDATE_ENGLISH")%>
	<br><%=TXT_FRENCH & TXT_COLON & .Fields("NOUPDATE_FRENCH")%>
	<br><%=TXT_BILINGUAL & TXT_COLON & .Fields("NOUPDATE_MULTILINGUAL")%></td>
</tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_COMPLETED%></td>
	<td><%=TXT_ENGLISH & TXT_COLON & .Fields("COMPLETED_ENGLISH")%>
	<br><%=TXT_FRENCH & TXT_COLON & .Fields("UPDATE_FRENCH")%>
	<br><%=TXT_BILINGUAL & TXT_COLON & .Fields("COMPLETED_MULTILINGUAL")%></td>
</tr>
<%
	Set rsImportStats = rsImportStats.NextRecordSet
	While Not rsImportStats.EOF
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_SOURCE_DATABASE%> (<%=rsImportStats("LanguageName")%>)</td>
	<td><%If Not Nl(rsImportStats("SourceDbURL")) Then%><a href="<%=rsImportStats("SourceDbURL")%>"><%End If%>
	<%=Nz(rsImportStats("SourceDbName"),Nz(rsImportStats("SourceDbURL"),TXT_UNKNOWN))%>
	<%If Not Nl(rsImportStats("SourceDbURL")) Then%></a><%End If%></td>
</tr>
<%
		rsImportStats.MoveNext
	Wend
%>
</table>
<%
	End If
	rsImportStats.Close
End With

End If

Set rsImportStats = Nothing
Set cmdImportStats = Nothing

If intError = 0 Then
%>
<h2><%=TXT_PRIVACY_PROFILE_LIST%></h2>
<%
Call makeImportEntryPrivacyProfileList(True, False)
%>
<h2><%=TXT_PUBLICATION_LIST%></h2>
<%
Dim cmdListImportPub, rsListImportPub
Set cmdListImportPub = Server.CreateObject("ADODB.Command")
With cmdListImportPub
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_Pub_l"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
End With
Set rsListImportPub = Server.CreateObject("ADODB.Recordset")
rsListImportPub.Open cmdListImportPub
With rsListImportPub
	If .EOF Then
%>
<%=TXT_NO_PUB_CODES%>
<%
	Else
		While Not .EOF
			Response.Write(.Fields("CODE") & "<br>")
			.MoveNext
		Wend
	End If
	.Close
End With
Set rsListImportPub = Nothing
Set cmdListImportPub = Nothing
%>
<h2><%=TXT_DISTRIBUTION_LIST%></h2>
<%
Dim cmdListImportDist, rsListImportDist
Set cmdListImportDist = Server.CreateObject("ADODB.Command")
With cmdListImportDist
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_Dist_l"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
End With
Set rsListImportDist = Server.CreateObject("ADODB.Recordset")
rsListImportDist.Open cmdListImportDist
With rsListImportDist
	If .EOF Then
%>
<%=TXT_NO_DIST_CODES%>
<%
	Else
		While Not .EOF
			Response.Write(.Fields("CODE") & "<br>")
			.MoveNext
		Wend
	End If
	.Close
End With
Set rsListImportDist = Nothing
Set cmdListImportDist = Nothing
%>
<h2><%=TXT_FIELD_LIST%></h2>
<%
Dim cmdListImportFields, rsListImportFields
Set cmdListImportFields = Server.CreateObject("ADODB.Command")
With cmdListImportFields
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_Field_l"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
End With
Set rsListImportFields = Server.CreateObject("ADODB.Recordset")
rsListImportFields.Open cmdListImportFields

Dim strFieldCon
strFieldCon = vbNullString

If rsListImportFields.EOF Then
%>
<%=TXT_UNABLE_LIST_FIELDS%>
<%
Else
%>
<p>
<%
	With rsListImportFields
		While Not .EOF
%>
<%=strFieldCon%><strong><%=.Fields("FieldName")%></strong> (<%=.Fields("FieldDisplay")%>)
<%
			strFieldCon = "<br>"
			.MoveNext
		Wend
	End With
%>
</p>
<%
End If
rsListImportFields.Close
Set rsListImportFields = Nothing
Set cmdListImportFields = Nothing

End If

Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
