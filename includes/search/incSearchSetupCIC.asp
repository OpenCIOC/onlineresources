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

<%
Dim	bSearchDisplay
bSearchDisplay = False

Dim bInlineMode
bInlineMode = Not Nl(Trim(Request("InlineMode")))

Call getDisplayOptionsCIC(g_intViewTypeCIC, Not user_bCIC)
If opt_bTableSortCIC And Not g_bPrintMode Then
	Call addToHeader("<link rel=""stylesheet"" type=""text/css"" href=""//cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css""/>")
End If

If Not bInlineMode Then
Call makePageHeader(TXT_SEARCH_RESULTS, TXT_SEARCH_RESULTS, True, True, True, True)
End If

Dim strFrom, _
	strWhere, _
	strCon

strFrom = "GBL_BaseTable bt " & vbCrLf & _
	"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
	"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
	"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
	"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
	"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=" & g_objCurrentLang.LangID
			
strWhere = vbNullString
strCon = vbNullString
%>
