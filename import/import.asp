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
<!--#include file="../includes/list/incImportEntryList.asp" -->

<%
Const DATASET_FULL = 0
Const DATASET_ADD = 1
Const DATASET_UPDATE = 2
Const DATASET_NOUPDATE = 3

Dim bArchived, bHasIcarolImport

If Not user_bImportPermissionCIC Then
	Call securityFailure()
End If

Call makePageHeader(TXT_IMPORT_RECORD_DATA, TXT_IMPORT_RECORD_DATA, True, False, True, True)
bArchived = Request("Archived") = "on"
Call openImportEntryListRst(bArchived)

bHasIcarolImport = rsListImportEntry.Fields("HAS_ICAROL_IMPORT")
Set rsListImportEntry = rsListImportEntry.NextRecordset
%>

<p>[ <a href="javascript:openWin('<%=makeLinkB("upload")%>','dataLoad')"><%=TXT_LOAD_NEW_DATASET%></a> |
<% If bArchived Then %>
<a href="<%= makeLinkB("import.asp") %>"><%= TXT_SHOW_UNARCHIVED_IMPORTS %></a>
<% Else %>
<a href="<%= makeLink("import.asp", "Archived=on", vbNullString) %>"><%= TXT_SHOW_ARCHIVED_IMPORTS %></a>
<%
End If
If bHasIcarolImport Then
%>
| <a href="<%= makeLinkB("../admin/icarol/unmatched")%>"><%= TXT_UNMATCHED_ICAROL_RECORDS %></a>
<%
End If
%>

]</p>
<table class="BasicBorder cell-padding-3">
<tr>
	<th colspan="4" class="RevTitleBox"><%=TXT_EXISTING_DATASETS%></th>
</tr>
<tr>
	<th><%=TXT_DATE_LOADED%></th>
	<th><%=TXT_NAME%></th>
	<th><%=TXT_ACTION%></th>
</tr>
<%
Dim intQCount
intQCount = 0

With rsListImportEntry
	While Not .EOF
		If Not Nl(.Fields("QDate")) Then
			intQCount = intQCount + 1
		End If
%>
<tr>
	<td><%=DateTimeString(.Fields("LoadDate"),True)%></td>
	<td><%=.Fields("DisplayName")%></td>
	<td><%If Nl(.Fields("QDate")) Then%>
		<a href="<%=makeLink("import_queue.asp","EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_QUEUE_ALL%></a>
		<%Else%>
		<a class="Alert" href="<%=makeLink("import_queue2.asp","CancelQ=on&EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_CANCEL_QUEUE%></a>
		<%End If%>
		| <a href="<%=makeLink("import_update.asp","DataSet=" & DATASET_ADD & "&EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_ADD%></a>&nbsp;(<%=.Fields("AddCount")%>)
		| <a href="<%=makeLink("import_update.asp","DataSet=" & DATASET_UPDATE & "&EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_UPDATE%></a>&nbsp;(<%=.Fields("UpdateCount")%>)
		| <a href="<%=makeLink("import_update_list.asp","DataSet=" & DATASET_NOUPDATE & "&EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_CANNOT_IMPORT%></a>&nbsp;(<%=.Fields("NoUpdateCount")%>)
		| <a href="<%=makeLink("import_report.asp","EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_COMPLETED%></a>&nbsp;(<%=.Fields("CompletedCount")%>)
		| <a href="<%=makeLink("import_info.asp","EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_MORE_INFO%></a>
		| <a href="<%=makeLink("import_delete.asp","EFID=" & .Fields("EF_ID"),vbNullString)%>"><%=TXT_DELETE_DATASET%></a> 
		| <a href="<%=makeLink("import_archive.asp", "EFID=" & .Fields("EF_ID") & StringIf(bArchived, "&Unarchive=on"),vbNullString)%>"><%=IIf(bArchived,TXT_UNARCHIVE_DATASET,TXT_ARCHIVE_DATASET)%></a>
		</td>
</tr>
<%
		.MoveNext
	Wend
End With
Call closeImportEntryListRst()
%>
</table>
<%
If intQCount > 0 Then
%>
<p><strong><%=TXT_THERE_ARE%> <%=intQCount%> <%=TXT_FILES_IN_IMPORT_QUEUE%></strong> [ <a href="<%=makeLinkB("import_update2.asp")%>"><%=TXT_PROCESS_NOW%></a> ]</p>
<%
End If
%>
<%
Call makePageFooter(False)
%>

<!--#include file="../includes/core/incClose.asp" -->
