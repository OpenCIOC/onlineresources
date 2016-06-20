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

If user_intSavedSearchQuota < 1 Then
	Call securityFailure()
End If

Dim bNew
bNew = False

Dim intSrchID, _
	strSearchName, _
	strWhereClause, _
	strNotes, _
	bIncludeDeleted, _
	intLangID, _
	strSharedWithSLs

Dim strErrorList

intSrchID = Trim(Request("SRCHID"))

If Nl(intSrchID) Then
	bNew = True
	intSrchID = Null
ElseIf Not IsIDType(intSrchID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSrchID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_SEARCH, _
		"savedsearch.asp", vbNullString)
Else
	Dim strReferer
	strReferer = Request.ServerVariables("HTTP_REFERER")
	If Not (reEquals(strReferer, "savedsearch_edit.asp",True,False,False,False) ) Then
		Call handleError(TXT_UPDATE_REJECTED, _
			vbNullString, vbNullString)
	Else
	intSrchID = CLng(intSrchID)
	End If
End If

If Request("Submit") = TXT_DELETE Then
	Call goToPage("savedsearch2.asp","Submit=" & TXT_DELETE & "&SRCHID=" & intSrchID,vbNullString)
End If

strSearchName = Left(Trim(Request("SearchName")),255)

strWhereClause = Trim(Request("WhereClause"))
If Len(strWhereClause) > 30000 Then
	strErrorList = strErrorList & "<li>" & TXT_ERR_WHERE_CLAUSE_LENGTH & "</li>"
End If

bIncludeDeleted = Request("IncludeDeleted") = "on"

strNotes = Left(Trim(Request("Notes")),2000)

strSharedWithSLs = Request("SharedWithSLs")
If Nl(strSharedWithSLs) Then 
	strSharedWithSLs = Null
End If

intLangID = Request("LangID")
If Not IsLangID(intLangID) Then
	intLangID = g_objCurrentLang.LangID
End If

If Nl(strErrorList) Then

	Dim objReturn, objErrMsg
	Dim cmdUpdateSavedSearch, rsUpdateSavedSearch
	Set cmdUpdateSavedSearch = Server.CreateObject("ADODB.Command")
	With cmdUpdateSavedSearch 	
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_GBL_SavedSearch_u"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
		.Parameters.Append objReturn
		.Parameters.Append .CreateParameter("@SRCHID", adInteger, adParamInputOutput, 4, intSrchID)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@SearchName", adVarChar, adParamInput, 255, strSearchName)
		.Parameters.Append .CreateParameter("@WhereClause", adLongVarChar, adParamInput, -1, strWhereClause)
		.Parameters.Append .CreateParameter("@Notes", adVarChar, adParamInput, 2000, strNotes)
		.Parameters.Append .CreateParameter("@IncludeDeleted", adBoolean, adParamInput, 1, IIf(bIncludeDeleted,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, ps_intDbArea)
		.Parameters.Append .CreateParameter("@SharedWithSLs", adLongVarChar, adParamInput, -1, strSharedWithSLs)
		Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
		.Parameters.Append objErrMsg
	End With
	Set rsUpdateSavedSearch = cmdUpdateSavedSearch.Execute
	Set rsUpdateSavedSearch = rsUpdateSavedSearch.NextRecordset

	If objReturn.Value <> 0 Then
		strErrorList = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If

End If

If Err.Number = 0 And Nl(strErrorList) Then
	If bNew Then
		intSrchID = cmdUpdateSavedSearch.Parameters("@SRCHID").Value
	End If
	Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_UPDATED & ".", _
			"savedsearch_edit.asp", _
			"SRCHID=" & intSrchID, _
			False)
Else
	Dim strErrorMessage
	If Not Nl(strErrorList) Then
		strErrorMessage = "<ul>" & strErrorList & "</ul>"
	ElseIf Err.Number <> 0 Then
		strErrorMessage = Err.Description
	Else
		strErrorMessage = Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED)
	End If
	Call makePageHeader(TXT_UPDATE_SEARCH_FAILED, TXT_UPDATE_SEARCH_FAILED, True, False, True, True)
	Call handleError(TXT_RECORDS_WERE_NOT & TXT_UPDATED & TXT_COLON & strErrorMessage, _
		vbNullString, _
		vbNullString)
	Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
	Call makePageFooter(True)
End If
%>
