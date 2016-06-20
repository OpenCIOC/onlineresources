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
'
' Purpose: 		Fetch parameters and generate SQL for record searches
'				Common to multiple modules of the software.
'
%>

<%
'--------------------------------------------------
' Saved Search
'--------------------------------------------------

Dim intSrchID, _
	strSearchName, _
	bIncludeDeleted
	
If user_intSavedSearchQuota > 0 Then
	intSrchID = Trim(Request("SRCHID"))
End If

If Not Nl(intSrchID) Then
	If Not user_bDOM Then
		Call handleError(TXT_WARNING & TXT_WARNING_SAVED_SEARCH_SECURITY, _
			vbNullString, vbNullString)
		intSrchID = Null
	ElseIf Not IsIDType(intSrchID) Then
		Call handleError(TXT_WARNING & TXT_WARNING_SAVED_SEARCH_ID & intSrchID & "." & _
			vbNullString, vbNullString)
		intSrchID = Null
	End If
End If

'--------------------------------------------------

Sub setSavedSearchData()

'--------------------------------------------------
' Saved Search
'--------------------------------------------------

	If Not Nl(intSrchID) Then
		Dim cmdSavedSearchList, rsSavedSearchList
		Set cmdSavedSearchList = Server.CreateObject("ADODB.Command")
		With cmdSavedSearchList
			.ActiveConnection = getCurrentAdminCnn()
			.Prepared = False
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.CommandText = "dbo.sp_GBL_SavedSearch_sr"
			.Parameters.Append .CreateParameter("@Srch_ID", adInteger, adParamInput, 4, intSrchID)
			.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
			.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, ps_intDbArea)
			Set rsSavedSearchList = .Execute
		End With

		With rsSavedSearchList
			If .EOF Then
				Call handleError(TXT_WARNING & TXT_WARNING_SAVED_SEARCH_INVALID, _
					vbNullString, vbNullString)
			Else
				strSearchName = .Fields("SearchName")
				If Not Nl(.Fields("WhereClause")) Then
					strWhere = strWhere & strCon & "(" & .Fields("WhereClause") & ")"
					strCon = AND_CON
				End If
				If .Fields("IncludeDeleted") Then
					bIncludeDeleted = g_bCanSeeDeletedDOM
				End If
			End If
		End With
	End If

End Sub
%>
