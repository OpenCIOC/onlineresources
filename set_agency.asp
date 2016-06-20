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
<!--#include file="includes/core/incFormat.asp" -->
<!--#include file="text/txtSetAgency.asp" -->
<!--#include file="text/txtFindReplaceCommon.asp" -->
<!--#include file="text/txtFormDataCheck.asp" -->

<% 
'On Error Resume Next

If Not user_bSuperUserCIC Then
	Call securityFailure()
End If

Dim	strIDList, _
	strNUM, _
	strErrorList, _
	bError

strIDList = Replace(Request("IDList")," ",vbNullString)
strNUM = Request("ORG_NUM")
bError = False


Call makePageHeader(TXT_CHANGE_RECORD_AGENCY, TXT_CHANGE_RECORD_AGENCY, True, True, True, True)

If Not Nl(strNUM) And Not IsNUMType(strNUM) Then
	bError = True
	Call handleError(Server.HTMLEncode(strNUM) & TXT_NOT_VALID_ID_FOR_FIELD & TXT_AGENCY_NUM, _
		vbNullString, _
		vbNullString)
ElseIf Nl(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf Not IsNUMList(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
End If


If Not bError And Nl(strNUM) And Nl(Request("Confirmed")) Then

%>
<h2><%= TXT_CHANGE_RECORD_AGENCY %></h2>

<p><span class="AlertBubble"><%=TXT_ARE_YOU_SURE%></span></p>
<form action="<%= ps_strPathToStart %>set_agency.asp" method="post">
<div class="NotVisible">
<%= g_strCacheFormVals %>
<input type="hidden" name="IDList" value="<%=strIDList%>">
<input type="hidden" name="ORG_NUM" value="<%=strNUM%>">
<input type="hidden" name="Confirmed" value="on">
</div>
<input type="submit" name="submit" value="<%= TXT_CLEAR_FIELD %>">

<%

Else

	If Not bError Then
		Dim strUserInsert
		strUserInsert = QsN(user_strMod)

		Dim cmdUpdateOwner, _
			intNumAffected

		Set cmdUpdateOwner = Server.CreateObject("ADODB.Command")
		With cmdUpdateOwner
			.ActiveConnection = getCurrentAdminCnn()
			.CommandType = adCmdText
			.CommandText = "UPDATE GBL_BaseTable SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert & ",ORG_NUM=" & QsNl(strNUM) & vbCrLf & _
				"WHERE " & StringIf(Not Nl(strNUM),"NUM <> " & QsNl(strNUM) & " AND ") & "(ORG_NUM IS " & IIf(Nl(strNUM), "NOT NULL", "NULL OR ORG_NUM<>" & QsNl(strNUM)) & " ) AND NUM IN (" & QsStrList(strIDList) & ")" & vbCrLf & _
				"	AND dbo.fn_CIC_CanUpdateRecord(NUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0"
					
			.CommandTimeout = 0
			.Execute intNumAffected
		End With
	End If
%>
<%
	If Err.Number <> 0 Then
		Response.Write(TXT_ERROR & Err.Description)

	ElseIf Not bError Then
		Dim cmdHistory
		Set cmdHistory = Server.CreateObject("ADODB.Command")
			
		With cmdHistory
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_" & IIf(ps_intDbArea = DM_VOL,"VOL_Opportunity","GBL_BaseTable") & "_History_i_Field"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@MODIFIED_BY", adVarChar, adParamInput, 50, user_strMod)
			.Parameters.Append .CreateParameter("@MODIFIED_DATE", adDBTimeStamp, adParamInput, , Now())
			.Parameters.Append .CreateParameter("@IDList", adLongVarChar, adParamInput, -1, strIDList)
			.Parameters.Append .CreateParameter("@FieldName", adLongVarChar, adParamInput, -1, "ORG_NUM")
			.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
			.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
			.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, Null)
			.Execute
		End With
%>
<p><%=Replace(TXT_AGENCY_CHANGED, "[COUNT]", "<strong>" & intNumAffected & "</strong>")%></p>
<p><%=TXT_SET_ALREADY%></p>
<%
		If IsArray(aGetSearchArray) Then
			If UBound(aGetSearchArray) > 0 Then
%>
<p><a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a> *</p>
<p><span class="SmallNote">* <%=TXT_NOTE_PREVIOUS_SEARCH_AGENCY%></span></p>
<%
			End If
		End If
%>

<%
	End If
End If

Call makePageFooter(True)
%>
<!--#include file="includes/core/incClose.asp" -->

