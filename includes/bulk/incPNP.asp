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
'On Error Resume Next

Dim	strIDList, _
	bSetNP, _
	strTitle, _
	bError

strIDList = Request("IDList")
bError = False

If Not user_bCanDoBulkOpsDOM Then
	Call securityFailure()
End If

If Request("SetTo") = "P" Then
	bSetNP = SQL_FALSE
	strTitle = TXT_SET_PUBLIC
ElseIf Request("SetTo") = "N" Then
	bSetNP = SQL_TRUE
	strTitle = TXT_SET_NONPUBLIC
Else
	bError = True
	strTitle = TXT_SET_PUBLIC & " / " & TXT_SET_NONPUBLIC
End If

Call makePageHeader(strTitle, strTitle, True, True, True, True)

If bError Then
	Call handleError(TXT_NO_ACTION, _
		vbNullString, _
		vbNullString)
ElseIf Nl(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf ps_intDbArea = DM_VOL And Not IsVNUMList(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
ElseIf ps_intDbArea = DM_CIC And Not IsNUMList(strIDList) Then
	bError = True
	Call handleError(TXT_NO_RECORD_CHOSEN, _
		vbNullString, _
		vbNullString)
End If

If Not bError Then
	Dim strUserInsert
	strUserInsert = QsN(user_strMod)

	Dim cmdSetStatus, _
		intNumAffected

	Set cmdSetStatus = Server.CreateObject("ADODB.Command")
	With cmdSetStatus
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdText
		Select Case ps_intDbArea
			Case DM_CIC
				.CommandText = "UPDATE GBL_BaseTable_Description SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert & ",NON_PUBLIC=" & bSetNP & vbCrLf & _
					"WHERE NON_PUBLIC<>" & bSetNP & " AND NUM IN (" & QsStrList(strIDList) & ") AND LangID=@@LANGID" & vbCrLf & _
					"	AND dbo.fn_CIC_CanUpdateRecord(NUM," & user_intID & "," & g_intViewTypeCIC & ",@@LANGID,GETDATE()) <> 0"
					
			Case DM_VOL
				.CommandText = "UPDATE VOL_Opportunity_Description SET MODIFIED_DATE=GETDATE(),MODIFIED_BY=" & strUserInsert & ",NON_PUBLIC=" & bSetNP & vbCrLf & _
					"WHERE NON_PUBLIC<>" & bSetNP & " AND VNUM IN (" & QsStrList(strIDList) & ") AND LangID=@@LANGID" & vbCrLf & _
					"	AND dbo.fn_VOL_CanUpdateRecord(VNUM," & user_intID & "," & g_intViewTypeVOL & ",@@LANGID,GETDATE()) <> 0"
		End Select
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
		.Parameters.Append .CreateParameter("@FieldName", adLongVarChar, adParamInput, -1, "NON_PUBLIC")
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
		.Parameters.Append .CreateParameter("@LangID", adInteger, adParamInput, 2, Null)
		.Execute
	End With
%>
<p><%=IIf(bSetNP=SQL_TRUE,TXT_NONPUBLIC_STATUS_SET_IN,TXT_PUBLIC_STATUS_SET_IN)%> <strong><%=intNumAffected%></strong> <%=TXT_RECORDS%></p>
<p><%=TXT_SET_ALREADY%></p>
<%
	If IsArray(aGetSearchArray) Then
		If UBound(aGetSearchArray) > 0 Then
%>
<p><a href="<%=makeLinkB("presults.asp")%>"><%=TXT_RETURN_PREVIOUS_SEARCH%></a> *</p>
<p><span class="SmallNote">* <%=TXT_NOTE_PREVIOUS_SEARCH%></span></p>
<%
		End If
	End If
End If

Call makePageFooter(True)
%>
