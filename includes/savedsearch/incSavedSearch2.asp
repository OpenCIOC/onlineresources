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

Dim intSrchID, strError
intSrchID = Request("SRCHID")
If Nl(intSrchID) Then
	Call handleError(TXT_NO_RECORD_CHOSEN & intSrchID & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_SEARCH, _
		"savedsearch.asp", vbNullString)
ElseIf Not IsIDType(intSrchID) Then
	Call handleError(TXT_INVALID_ID & Server.HTMLEncode(intSrchID) & "." & _
		vbCrLf & "<br>" & TXT_CHOOSE_SEARCH, _
		"savedsearch.asp", vbNullString)
Else
	intSrchID = CLng(intSrchID)
End If

Dim bConfirmed
bConfirmed = False

Select Case Request("Submit")
	Case TXT_SEARCH
		Call goToPage("sresults.asp","SRCHID=" & intSrchID,vbNullString)
	Case TXT_UPDATE
		Call goToPage("savedsearch_edit.asp","SRCHID=" & intSrchID,vbNullString)
	Case TXT_DELETE
		bConfirmed = Request("Confirmed") = "on"
	Case Else
		Call handleError(TXT_NO_ACTION, "savedsearch.asp", vbNullString)
End Select			

If Not bConfirmed Then
	Call makePageHeader(TXT_CONFIRM_DELETE_SEARCH, TXT_CONFIRM_DELETE_SEARCH, True, False, True, True)
%>
<p class="Alert"><%=TXT_ARE_YOU_SURE_DELETE_SEARCH%></p>
<form action="<%=ps_strThisPage%>" method="post">
<%=g_strCacheFormVals%>
<input type="hidden" name="SRCHID" value="<%=intSrchID%>">
<input type="hidden" name="Confirmed" value="on">
<input type="submit" name="Submit" value="<%=TXT_DELETE%>">
</form>
<%
	Call makePageFooter(True)
Else

Dim objReturn, objErrMsg
Dim cmdSavedSearchlist, rsSavedSearchlist
Set cmdSavedSearchlist = Server.CreateObject("ADODB.Command")
With cmdSavedSearchlist
	.ActiveConnection = getCurrentAdminCnn()
	.Prepared = False
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.CommandText = "dbo.sp_GBL_SavedSearch_d"
	Set objReturn = .CreateParameter("@RETURN_VALUE", adInteger, adParamReturnValue, 4)
	.Parameters.Append objReturn
	.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
	.Parameters.Append .CreateParameter("@SRCH_ID", adInteger, adParamInput, 4, intSrchID)
	Set objErrMsg = .CreateParameter("@ErrMsg", adVarWChar, adParamOutput, 500)
	.Parameters.Append objErrMsg
	Set rsSavedSearchlist = .Execute

	Set rsSavedSearchlist = rsSavedSearchlist.NextRecordset
	
	Select Case objReturn.Value
		Case 0
			Call handleMessage(TXT_RECORDS_WERE_SUCCESSFULLY & TXT_DELETED, _
				"savedsearch.asp", _
				"SRCHID=" & intSrchID, _
				False)
		Case Else
			Call makePageHeader(TXT_UPDATE_SEARCH_FAILED, TXT_UPDATE_SEARCH_FAILED, True, False, True, True)
			Call handleError(TXT_RECORDS_WERE_NOT & TXT_DELETED & TXT_COLON & Nz(Server.HTMLEncode(objErrMsg.Value),TXT_UNKNOWN_ERROR_OCCURED), _
				vbNullString, _
				vbNullString)
			Response.Write("<p>" & TXT_USE_BACK_BUTTON & "</p>")
			Call makePageFooter(True)
	End Select
End With

Set rsSavedSearchlist = Nothing
Set cmdSavedSearchlist = Nothing

End If
%>
