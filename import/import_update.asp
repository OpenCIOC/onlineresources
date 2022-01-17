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
<!--#include file="../includes/list/incImportEntryPrivacyList.asp" -->
<!--#include file="../includes/list/incPrivacyProfileList.asp" -->
<%
Const DATASET_FULL = 0
Const DATASET_ADD = 1
Const DATASET_UPDATE = 2

Const CNF_KEEP_EXISTING = 0
Const CNF_TAKE_NEW = 1
Const CNF_DO_NOT_IMPORT = 2

If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

Dim intEFID
intEFID = Trim(Request("EFID"))

If Nl(intEFID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & "." & _
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
		strStoredProcName = "dbo.sp_CIC_ImportEntry_Data_Add_lc"
	Case DATASET_UPDATE
		strStoredProcName = "dbo.sp_CIC_ImportEntry_Data_Update_lc"
	Case Else
		intDataSet = DATASET_FULL
		strStoredProcName = "dbo.sp_CIC_ImportEntry_Data_lc"
End Select

Call makePageHeader(TXT_IMPORT_RECORD_DATA, TXT_IMPORT_RECORD_DATA, True, False, True, True)

Dim cmdImportData, _
	rsImportData, _
	intImportDataCount, _
	intImportRetryCount, _
	intImportDeletionCount, _
	intImportNonPublicCount

Dim intError
intError = 0

Set cmdImportData = Server.CreateObject("ADODB.Command")
Set rsImportData = Server.CreateObject("ADODB.Recordset")

With cmdImportData
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = strStoredProcName
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
End With

With rsImportData
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdImportData

	If Not .EOF Then
		intError = .Fields("Error")
		If intError <> 0 Then
			Call handleError(Nz(.Fields("ErrMsg"),TXT_UNKNOWN_ERROR_OCCURED),vbNullString,vbNullString)
		End If
	End If
End With

If intError = 0 Then
	Set rsImportData = rsImportData.NextRecordset
	intImportDataCount = rsImportData.Fields("RecordCount")
	intImportRetryCount = rsImportData.Fields("RetryRecordCount")
	intImportDeletionCount = rsImportData.Fields("Deletions")
	intImportNonPublicCount = rsImportData.Fields("NonPublics")

%>
<p>[ <a href="<%=makeLinkB("import.asp")%>"><%=TXT_RETURN_TO_IMPORT%></a> ]</p>
<p><%=TXT_THERE_ARE%> <strong><%=intImportDataCount%></strong> <%
Select Case intDataSet
	Case DATASET_ADD
%><%=TXT_RECORDS_THAT_DONT_MATCH%><%
	Case DATASET_UPDATE
%><%=TXT_RECORDS_THAT_MATCH%><%
	Case Else
%><%=TXT_RECORDS_TO_IMPORT%><%
End Select
If intImportRetryCount > 0 Then
%> <%=TXT_THERE_ARE%> <strong><%=intImportRetryCount%></strong> <%= TXT_RECORDS_TO_RETRY %><%
End If
If intImportDataCount + intImportRetryCount > 0 Then
%> [ <a href="<%=makeLink("import_update_list.asp","EFID=" & intEFID & "&DataSet=" & intDataSet,vbNullString)%>"><%=TXT_VIEW_DATA%></a> ]<%
End If
%></p>

<%
If intImportDataCount + intImportRetryCount > 0 Then
If intImportDeletionCount > 0 Then
%>
<p><%=TXT_THIS_DATASET_INCLUDES%> <%= intImportDeletionCount %></strong> <%=TXT_RECORDS_WHERE_DELETED%></p>
<%
End If
If intImportNonPublicCount > 0 Then
%>
<p><%=TXT_THIS_DATASET_INCLUDES%> <strong><%= intImportNonPublicCount %></strong> <%=TXT_RECORDS_WHERE_NON_PUBLIC%></p>
<%
End If
%>
<p><%=TXT_TO_IMPORT_SELECT%></p>
<h1><%=TXT_IMPORT_OPTIONS%></h1>
<form action="import_update2.asp">
<%=g_strCacheFormVals%>
<input type="hidden" name="EFID" value="<%=intEFID%>">
<input type="hidden" name="DataSet" value="<%=intDataSet%>">
<%
Set rsImportData = rsImportData.NextRecordset

With rsImportData
	If Not .EOF Then
		If .RecordCount > 1 Then
%>
<h2><%=TXT_SELECT_OWNERS%></h2>
<p><%=TXT_YOU_MAY_SELECT_OWNERS%></p>
<select name="ImportOwners" multiple>
<%
			While Not .EOF
%>
	<option value="<%=.Fields("OWNER")%>"><%=.Fields("OWNER")%></option>
<%
				.MoveNext
			Wend
%>
</select>
<%
		End If
	End If
End With

%>
<%
If Not intDataSet = DATASET_ADD Then
%>
<h2><%=TXT_CASE_OWNERSHIP_CONFLICT%></h2>
<table class="NoBorder cell-padding-2">
<tr>
	<td><input type="radio" id="cnf_keep" name="OwnerConflict" value="<%=CNF_KEEP_EXISTING%>"></td>
	<td><label for="cnf_keep"><%=TXT_KEEP_EXISTING%></label></td>
</tr>
<tr>
	<td><input type="radio" id="cnf_new" name="OwnerConflict" value="<%=CNF_TAKE_NEW%>"></td>
	<td><label for="cnf_new"><%=TXT_UPDATE_OWNER%></label></td>
</tr>
<tr>
	<td><input type="radio" id="cnf_skip" name="OwnerConflict" value="<%=CNF_DO_NOT_IMPORT%>" checked></td>
	<td><label for="cnf_skip"><%=TXT_DO_NOT_IMPORT%></label></td>
</tr>
</table>

<h2><%=TXT_CASE_PUBLIC_CONFLICT%></h2>
<table class="NoBorder cell-padding-2">
<tr>
	<td><input type="radio" id="cnf_pub_keep" name="PublicConflict" value="<%=CNF_KEEP_EXISTING%>"></td>
	<td><label for="cnf_pub_keep"><%=TXT_KEEP_EXISTING_PUBLIC%></label></td>
</tr>
<tr>
	<td><input type="radio" id="cnf_pub_new" name="PublicConflict" value="<%=CNF_TAKE_NEW%>" checked></td>
	<td><label for="cnf_pub_new"><%=TXT_UPDATE_PUBLIC%></label></td>
</tr>
<tr>
	<td><input type="radio" id="cnf_pub_skip" name="PublicConflict" value="<%=CNF_DO_NOT_IMPORT%>"></td>
	<td><label for="cnf_pub_skip"><%=TXT_DO_NOT_IMPORT%></label></td>
</tr>
</table>

<h2><%=TXT_CASE_DELETED_CONFLICT%></h2>
<table class="NoBorder cell-padding-2">
<tr>
	<td><input type="radio" id="cnf_del_keep" name="DeletedConflict" value="<%=CNF_KEEP_EXISTING%>"></td>
	<td><label for="cnf_del_keep"><%=TXT_KEEP_EXISTING_DELETED%></label></td>
</tr>
<tr>
	<td><input type="radio" id="cnf_del_new" name="DeletedConflict" value="<%=CNF_TAKE_NEW%>" checked></td>
	<td><label for="cnf_del_new"><%=TXT_UPDATE_DELETED%></label></td>
</tr>
<tr>
	<td><input type="radio" id="cnf_del_skip" name="DeletedConflict" value="<%=CNF_DO_NOT_IMPORT%>"></td>
	<td><label for="cnf_del_skip"><%=TXT_DO_NOT_IMPORT%></label></td>
</tr>
</table>

<%End If%>
<h2><%=TXT_PRIVACY_PROFILE_MAP%></h2>
<% Call makeImportEntryPrivacyProfileList(False, True) %>

<%If Not bNoProfiles Then%>
<h2><%=TXT_UNMAPPED_PROFILES%></h2>
<p>
<input id="UnmappedRecord" type="radio" value="R" name="UnmappedPrivacySkipFields" checked> <label for="UnmappedRecord"><%=TXT_SKIP_RECORD%></label><br>
<input id="UnmappedFields" type="radio" value="F" name="UnmappedPrivacySkipFields"> <label for="UnmappedFields"><%=TXT_SKIP_FIELDS%></label></p>

<%If Not intDataSet = DATASET_ADD Then%>
<h2><%=TXT_CASE_PRIVACY_CONFLICT%></h2>
<table class="NoBorder cell-padding-2">
<tr>
	<td><input type="radio" id="prv_keep" name="PrivacyConflict" value="<%=CNF_KEEP_EXISTING%>"></td>
	<td><label for="prv_keep"><%=TXT_KEEP_EXISTING_PRIVACY%></label></td>
</tr>
<tr>
	<td><input type="radio" id="prv_new" name="PrivacyConflict" value="<%=CNF_TAKE_NEW%>"></td>
	<td><label for="prv_new"><%=TXT_UPDATE_PRIVACY%></label></td>
</tr>
<tr>
	<td><input type="radio" id="prv_skip" name="PrivacyConflict" value="<%=CNF_DO_NOT_IMPORT%>" checked></td>
	<td><label for="prv_skip"><%=TXT_DO_NOT_IMPORT%></label></td>
</tr>
</table>
<%End If%>

<%Else%>
<input type="hidden" id="UnmappedRecord" value="R" name="UnmappedPrivacySkipFields">
<input type="hidden" id="prv_skip" name="PrivacyConflict" value="<%=CNF_DO_NOT_IMPORT%>">
<%End If%>


<%
Dim strPBCon
strPBCon = vbNullString

Set rsImportData = rsImportData.NextRecordset

With rsImportData
	If Not .EOF Then
		If .RecordCount > 1 Then
%>
<h2><%=TXT_SELECT_PUBS%></h2>
<p class="Alert"><%=TXT_FOLLOWING_PUBS_ADDED_AUTOMATICALLY%></p>
<p>
<%
			While Not .EOF
%>
	<%=strPBCon%><input type="checkbox" value="<%=.Fields("PB_ID")%>" name="AutoAddPubs" id="AutoAddPubs_<%=.Fields("PB_ID")%>" checked>&nbsp;<label for="AutoAddPubs_<%=.Fields("PB_ID")%>"><%=.Fields("PubName")%></label>
<%
				strPBCon = "<br>"
				.MoveNext
			Wend
%>
</p>
<%
		End If
	End If
	.Close
End With

Set rsImportData = Nothing
Set cmdImportData = Nothing
%>

<h2><%=TXT_NUMBER_TO_IMPORT%></h2>
<p><%=TXT_TO_LIMIT%></p>
<p><%=TXT_IMPORT_TOP%> <select name="ImportTop">
	<option value="10">10</option>
	<option value="50">50</option>
	<option value="100">100</option>
	<option value="500" selected>500</option>
	<option value="1000">1000</option>
	<option value="2000">2000</option>
	<option value=""><%=TXT_ALL_RECORDS%></option>
</select></p>
<h2><%=TXT_SOURCE_DATABASE%></h2>
<p><label for="ImportSourceDb"><input type="checkbox" name="ImportSourceDb" id="ImportSourceDb" checked><%=TXT_IMPORT_SOURCE_DATABASE_INFO%></label></p>
<p><label for="RetryFailed"><input type="checkbox" name="RetryFailed" id="RetryFailed"><%=TXT_RETRY_FAILED_RECORDS%></label></p>
<p><input type="submit" value="<%=TXT_IMPORT_RECORD_DATA%>"></p>
</form>
<%
End If

End If

Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
