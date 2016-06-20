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
<!--#include file="text/txtExport.asp" -->
<!--#include file="text/txtGeneralForm.asp" -->
<!--#include file="includes/list/incDistList.asp" -->
<!--#include file="includes/list/incExcelProfileList.asp" -->
<!--#include file="includes/list/incExportProfileList.asp" -->
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="includes/publication/incPubList.asp" -->
<%

If user_intExportPermissionCIC = EXPORT_NONE And Not g_bHasExcelProfile Then
	Call securityFailure()
End If

Call makePageHeader(TXT_EXPORT_CONFIGURATION, TXT_EXPORT_CONFIGURATION, True, False, True, True)

Const XML_EXPORT_V2 = 1
Const SHARE_EXPORT = 2
Const EXCEL_EXPORT = 3

Dim strIDList
strIDList = Request("IDList")

If user_intExportPermissionCIC <> EXPORT_ALL Then
%>
<p class="Info"><%=TXT_INST_RECORD_PERMISSION%> <%
	Select Case user_intExportPermissionCIC
		Case EXPORT_OWNED
			Response.Write(TXT_INST_RECORD_PERMISSION_OWN)
		Case EXPORT_VIEW
			Response.Write(TXT_INST_RECORD_PERMISSION_VIEW)
	End Select
%>.</p>
<%
End If
%>
<form action="export2.asp" method="post">
<div style="display:none">
<%=g_strCacheFormVals%>
<input type="hidden" name="IDList" value="<%=strIDList%>">
</div>
<table class="BasicBorder cell-padding-4">
<tr><th colspan="2" class="RevTitleBox"><%=TXT_INST_CUSTOMIZE%></th></tr>
<tr>
	<td class="FieldLabelLeft"><%=TXT_EXPORT_FORMAT%></td>
	<td>
<%
If user_intExportPermissionCIC <> EXPORT_NONE And g_bHasExportProfile Then
%>
	<p class="Alert SmallNote"><%=TXT_PROFILES_NOT_AVAILABLE_ALL_FORMATS%></p>
	<label for="ExportType_MSXMLV2"><input type="radio" name="ExportType" id="ExportType_MSXMLV2" value="<%=XML_EXPORT_V2%>"> <%=TXT_MICROSOFT_XML & TXT_COLON & TXT_VERSION%>2</label>
	<br><label for="ExportType_CIOCSHARE"><input type="radio" name="ExportType" id="ExportType_CIOCSHARE" value="<%=SHARE_EXPORT%>" checked> <%=TXT_SHARE_FORMAT%></label>
<%
	Call openExportProfileListRst(False,False)
%>
	<p><span class="FieldLabelClr"><label for="ExportProfileID"><%=TXT_PROFILE & TXT_COLON%></span><%=makeExportProfileList(vbNullString,"ExportProfileID","ExportProfileID",True)%></label></p>
<%
	Call closeExportProfileListRst()
End If
If g_bHasExcelProfile Then
	If user_intExportPermissionCIC <> EXPORT_NONE And g_bHasExportProfile Then
%>
	<hr>
	<label for="ExportType_EXCEL"><input type="radio" name="ExportType" id="ExportType_EXCEL" value="<%=EXCEL_EXPORT%>"> <%=TXT_EXCEL%></label>
	<br>&nbsp;
<%
	Else
%>
	<div style="display:none">
	<input type="hidden" name="ExportType" value="<%=EXCEL_EXPORT%>">
	</div>
<%
	End If
	Call openExcelProfileListRst(DM_CIC, g_intViewTypeCIC)
%>
	<table class="NoBorder cell-padding-2">
	<tr>
		<td class="FieldLabelLeftClr"><label for="ExcelProfileID"><%=TXT_PROFILE & TXT_COLON%></label></td>
		<td><%=makeExcelProfileList(vbNullString,"ExcelProfileID",True,False,vbNullString)%></td>
	</tr>
	<tr>
		<td class="FieldLabelLeftClr"><%=TXT_FILE_FORMAT & TXT_COLON%></td><td><label for="ExcelFormat_HTML"><input type="radio" name="ExcelFormat" id="ExcelFormat_HTML" value="H" checked>HTML</label> <label for="ExcelFormat_CSV"><input type="radio" name="ExcelFormat" id="ExcelFormat_CSV" value="C">CSV</label></td>
	</tr>
	</table>
<%
	Call closeExcelProfileListRst()
End If

If Nl(strIDList) And Not user_bLimitedViewCIC Then
	Call openDistListRst(False)
	With rsListDist
		If Not .EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_EXPORT_DISTRIBUTIONS%></td>
	<td><%=TXT_HOLD_CTRL%>
	<br><select name="DSTID" multiple><%
			.MoveFirst
			While not .EOF
%><option value="<%=.Fields("DST_ID")%>"><%=.Fields("DistCode")%></option><%
				.MoveNext
			Wend
%>
			</select></td>
</tr>
<%
		End If
	End With
	Call closeDistListRst()
	Call openPubListRst(False, Null)
	With rsListPub
		If Not .EOF Then
%>
<tr>
	<td class="FieldLabelLeft"><%=TXT_PUBLICATIONS%></td>
	<td><%=TXT_HOLD_CTRL%>
	<br><select name="PBID" multiple><%
			While Not .EOF
%><option value="<%=.Fields("PB_ID")%>"><%=.Fields("PubCode")%></option><%
				.MoveNext
			Wend
%>
			</select></td>
</tr>
<%
		End If
	End With
	Call closePubListRst()
End If
%>
</table>
<input type="submit" value="<%=TXT_NEXT%> >>">
</form>
<%
Call makePageFooter(False)
%>
<!--#include file="includes/core/incClose.asp" -->
