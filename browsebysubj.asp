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
Call setPageInfo(False, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="includes/core/incCrypto.asp" -->
<!--#include file="includes/core/incSecurity.asp" -->
<!--#include file="includes/core/incHeader.asp" -->
<!--#include file="includes/core/incFooter.asp" -->
<!--#include file="text/txtMenu.asp" -->
<% 'End Base includes %>
<!--#include file="text/txtBrowse.asp" -->
<!--#include file="text/txtGeneralSearch1.asp" -->
<!--#include file="text/txtSubjects.asp" -->
<!--#include file="includes/thesaurus/incUseInsteadList.asp" -->
<!--#include file="includes/thesaurus/incSubjSearchUtils.asp" -->
<!--#include file="includes/list/incAlphaList.asp" -->
<% 
If Not g_bUseThesaurusView Then
	Call goToPageB("~/")
End If

Call makePageHeader(Nz(ps_strTitle,TXT_BROWSE_BY_SUBJECT_TITLE), Nz(ps_strTitle,TXT_BROWSE_BY_SUBJECT_TITLE), True, True, True, True)

'On Error Resume Next

Dim strChosenLetter, strLettersList
strChosenLetter = Trim(Request("Let"))

If Not reEquals(strChosenLetter,"([A-Z])|(0\-9)",True,False,True,False) Then
	strChosenLetter = vbNullString
End If

strLettersList = makeAlphaList(strChosenLetter, False, ps_strThisPage, False)
%>
<%=strLettersList%>
<%If g_bUseZeroSubjects Then%>
<p><%=TXT_ZERO_COUNT%></p>
<hr>
<%End If%>
<%'If a Letter has been selected
If Not Nl(strChosenLetter) Then

Dim dispSubjTerm
Dim cmdSubjects, rsSubjects, rsSubjectsCount
Set cmdSubjects = Server.CreateObject("ADODB.Command")
With cmdSubjects
	.ActiveConnection = getCurrentCICBasicCnn()
	.CommandText = "dbo.sp_CIC_BrowseBySubj"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@Letter", adChar, adParamInput, 1, strChosenLetter)
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 1, g_intViewTypeCIC)
End With

Set rsSubjects = Server.CreateObject("ADODB.Recordset")
With rsSubjects
	.CursorLocation = adUseClient
	.CursorType = adOpenStatic
	.Open cmdSubjects
End With

%>
<p><%=TXT_FOUND%><strong><%=rsSubjects.RecordCount%></strong><%=TXT_MATCHES%>.</p>
<p>
<%
With rsSubjects
	While Not .EOF
		Response.Write(getShortSubjectInfo(rsSubjects("Subj_ID"), rsSubjects("SubjectTerm"), rsSubjects("Used"), rsSubjects("UseAll"), rsSubjects("UsageCount"), True, "bresults.asp", False) & vbCrLf & "<br>")
		.MoveNext
	Wend
	.Close
End With

Set rsSubjects = Nothing
Set cmdSubjects = Nothing

End If
%>
</p>
<%
Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->

