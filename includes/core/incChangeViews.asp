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
Dim cmdListChangeViews, rsListChangeViews

Sub openChangeViewsListRst(bAllViews)

	Set cmdListChangeViews = Server.CreateObject("ADODB.Command")
	With cmdListChangeViews
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & ps_strDbArea & "_Views_l_Change"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@User_ID", adInteger, adParamInput, 4, user_intID)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, IIf(bAllViews, -1, g_intViewTypeDOM))
	End With
	Set rsListChangeViews = Server.CreateObject("ADODB.Recordset")
	With rsListChangeViews
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListChangeViews
	End With
End Sub

Sub closeChangeViewsListRst()
	If rsListChangeViews.State <> adStateClosed Then
		rsListChangeViews.Close
	End If
	Set cmdListChangeViews = Nothing
	Set rsListChangeViews = Nothing
End Sub

Function makeChangeViewsList(intSelected, strSelectName, bIncludeBlank, bMultiple)
	Dim strReturn
	With rsListChangeViews
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If Not .EOF Then
			strReturn = strReturn & "<select class=""form-control"" name=" & AttrQs(strSelectName) & _
							StringIf(bMultiple, "multiple") & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("ViewType") & """ " & Selected(.Fields("ViewType")=intSelected) & ">" & .Fields("ViewName") & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeChangeViewsList = strReturn
End Function

Sub printChangeViewsFormContents(bTemp, intDomain, strExtraSkip)
	Dim indItem, strVarName, strDomain
	
	Select Case intDomain
		Case DM_CIC
			strVarName = "UseCICVw" & IIf(bTemp,"Tmp",vbNullString)
		Case DM_VOL
			strVarName = "UseVOLVw" & IIf(bTemp,"Tmp",vbNullString)
	End Select

	Call openChangeViewsListRst(False)
	If Not rsListChangeViews.EOF Then

	For Each indItem In Request.QueryString()
		If indItem <> strVarName And Not reEquals(indItem,strExtraSkip,True,False,True,False) Then%>
<input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.QueryString(indItem))%>>
<%		End If
	Next%>
<%
	For Each indItem In Request.Form()
		If indItem <> strVarName And Not reEquals(indItem,strExtraSkip,True,False,True,False) Then%>
<input type="hidden" name="<%=indItem%>" value=<%=AttrQs(Request.Form(indItem))%>>
<%		End If
	Next
%>
<div class="input-group">
	<%=makeChangeViewsList(vbNullString, strVarName, True, False)%>
	<div class="input-group-btn">
		<button class="btn" type="submit"><%=TXT_CHANGE_VIEW%><%If bTemp Then%> <%=TXT_CHANGE_VIEW_TEMP%><%End If%></button>
	</div>
</div>
<%
	End If
	Call closeChangeViewsListRst()
End Sub
%>

