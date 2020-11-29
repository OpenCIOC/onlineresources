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

Call makePageHeader(TXT_IMPORT_RECORD_DATA, TXT_IMPORT_RECORD_DATA, True, False, True, True)

Dim cmdImportData, _
	rsImportData, _
	intImportDataCount, _
	intImportRetryCount

Dim intError
intError = 0

Set cmdImportData = Server.CreateObject("ADODB.Command")
Set rsImportData = Server.CreateObject("ADODB.Recordset")

With cmdImportData
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_CIC_ImportEntry_Data_lc"
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
%>
<p>[ <a href="<%=makeLinkB("import.asp")%>"><%=TXT_RETURN_TO_IMPORT%></a> ]</p>
<p><%=TXT_THERE_ARE%> <strong><%=intImportDataCount%></strong> 
<%=TXT_RECORDS_TO_IMPORT%>
<%
If intImportRetryCount > 0 Then
%> <%=TXT_THERE_ARE%> <strong><%=intImportRetryCount%></strong> <%= TXT_RECORDS_TO_RETRY %><%
End If
If intImportDataCount + intImportRetryCount > 0 Then
%> [ <a href="<%=makeLink("import_update_list.asp","EFID=" & intEFID & "&DataSet=" & DATASET_FULL,vbNullString)%>"><%=TXT_VIEW_DATA%></a> ]<%
End If
%></p>

<%
If intImportDataCount + intImportRetryCount > 0 Then
%>
<p><%=TXT_TO_IMPORT_SELECT%></p>
<h1><%=TXT_IMPORT_OPTIONS%></h1>
<form action="import_queue2.asp">
<%=g_strCacheFormVals%>
<input type="hidden" name="EFID" value="<%=intEFID%>">
<%
Set rsImportData = rsImportData.NextRecordset
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

<h2><%=TXT_PRIVACY_PROFILE_MAP%></h2>
<% Call makeImportEntryPrivacyProfileList(False, True) %>

<%If Not bNoProfiles Then%>
<h2><%=TXT_UNMAPPED_PROFILES%></h2>
<p>
<input id="UnmappedRecord" type="radio" value="R" name="QUnmappedPrivacySkipFields" checked> <label for="UnmappedRecord"><%=TXT_SKIP_RECORD%></label><br>
<input id="UnmappedFields" type="radio" value="F" name="QUnmappedPrivacySkipFields"> <label for="UnmappedFields"><%=TXT_SKIP_FIELDS%></label></p>

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
<%Else%>
<input type="hidden" id="Hidden1" value="R" name="UnmappedPrivacySkipFields">
<input type="hidden" id="Hidden2" name="PrivacyConflict" value="<%=CNF_DO_NOT_IMPORT%>">
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
	<%=strPBCon%><input type="checkbox" value="<%=.Fields("PB_ID")%>" name="AutoAddPubs" id='AutoAddPubs_<%=.Fields("PB_ID")%>' checked>&nbsp;<label for="AutoAddPubs_<%=.Fields("PB_ID")%>"><%=.Fields("PubName")%></label>
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

<h2><%=TXT_SOURCE_DATABASE%></h2>
<p><label for="ImportSourceDb"><input type="checkbox" name="ImportSourceDb" id="ImportSourceDb" checked>&nbsp;<%=TXT_IMPORT_SOURCE_DATABASE_INFO%></label></p>
<p><label for="RetryFailed"><input type="checkbox" name="RetryFailed" id="RetryFailed"><%=TXT_RETRY_FAILED_RECORDS%></label></p>
<p><input type="submit" value="<%=TXT_QUEUE_RECORDS_FOR_LATER%>"></p>
</form>
<%
End If

End If

Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
