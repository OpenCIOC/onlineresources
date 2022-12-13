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
Sub printCopyFieldsForm(ByVal intCopyRTID, strNUM, strRecordTypeName)
%>
<div id="copyFieldsForm">
	<div id="copyFieldsInner">
		<%
	Call openRecordTypeListRst(True,True,False,Null)

	Dim bRTFound
	bRTFound = False

	If Nl(intCopyRTID) Then
		If Not rsListRecordType.RecordCount = 0 Then
			rsListRecordType.MoveFirst
			intCopyRTID = rsListRecordType.Fields("RT_ID")
		End If
	Else
		With rsListRecordType
			While Not .EOF And Not bRTFound
				If .Fields("RT_ID") = intCopyRTID Then
					bRTFound = True
				End If
				.MoveNext
			Wend
		End With
		If Not bRTFound Then
			intCopyRTID = Null
		End If
	End If

	Dim cmdFields, rsFields
	Set cmdFields = Server.CreateObject("ADODB.Command")
	With cmdFields
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_GBL_BaseTable_s_CanCopy_2"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intCopyRTID)
	End With
	Set rsFields = cmdFields.Execute
	
	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_GBL_BaseTable_s_CanCopy_3"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@NUM", adVarChar, adParamInput, 8, strNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.Parameters.Append .CreateParameter("@RT_ID", adInteger, adParamInput, 4, intCopyRTID)
	End With
	Set rsOrg = cmdOrg.Execute
	
	Dim dicOrgUpdate, dicOrgDisplay
	Set dicOrgUpdate = Server.CreateObject("Scripting.Dictionary")
	Set dicOrgDisplay = Server.CreateObject("Scripting.Dictionary")

	If Not rsFields.EOF Then
		While reEquals(rsFields.Fields("FieldName"),"(ORG_LEVEL_[1-5]|LOCATION_NAME|SERVICE_NAME_LEVEL_[1-2])",True,False,True,False) 
			If rsFields.Fields("CAN_UPDATE") Then
				dicOrgUpdate(rsFields("FieldName").Value) =  True
			End If
			dicOrgDisplay(rsFields("FieldName").Value) = rsFields.Fields("FieldDisplay").Value
			rsFields.MoveNext
		Wend
	End If	
		%>
		<h2><%=TXT_FIELDS & TXT_COLON%></h2>
		<table class="BasicBorder cell-padding-3 full-width clear-line-below form-table responsive-table">
			<%
	If Not rsListRecordType.RecordCount=0 Then
			%>
			<tr>
				<td class="field-label-cell" id="RecordTypeName"><%=strRecordTypeName%></td>
				<td><%=makeRecordTypeList(intCopyRTID, "RECORD_TYPE", False, vbNullString)%></td>
			</tr>
			<%
	End If
	Call closeRecordTypeListRst()
	Dim field

	For Each field in Array("ORG_LEVEL_1", "ORG_LEVEL_2", "ORG_LEVEL_3", "ORG_LEVEL_4", "ORG_LEVEL_5", "LOCATION_NAME", "SERVICE_NAME_LEVEL_1", "SERVICE_NAME_LEVEL_2")
		If dicOrgUpdate.Exists(field) Then
			%>
			<input type="hidden" name="Old<%= field %>" value=<%=AttrQs(dicOrgDisplay(field))%>>
			<tr>
				<td class="field-label-cell" id="FIELD_<%=field%>"><%=dicOrgDisplay(field)%><%= StringIf(field="ORG_LEVEL_1", " <span class=""Alert"">*</span>")%></td>
				<td data-field-display-name="<%=dicOrgDisplay(field)%>" <%=StringIf(field="ORG_LEVEL_1","data-field-required=""true""")%> id="EDIT_<%=field%>">
					<input class="form-control" type="text" size="<%=TEXT_SIZE%>" maxlength="200" name="<%=field%>" id="<%=field%>" value=<%=AttrQs(dicOrgName(field))%>>
				</td>
			</tr>
			<%
		Else
			%>
			<tr <%=StringIf(Nl(dicOrgName(field)), " style=""display:none;""") %>>
				<td class="field-label-cell"><%=dicOrgDisplay(field)%></td>
				<td>
					<input type="hidden" name="<%=field%>" id="HIDDEN_<%=field%>" value=<%=AttrQs(dicOrgName(field))%>><span id="<%=field%>_DISPLAY"><%=dicOrgName(field)%></span>
				</td>
			</tr>
				<%
		End If
	Next
				%>
		</table>
		<%
	Set rsFields = rsFields.NextRecordset
	
	Dim intPrevGroupID, strGroupContents, strGroupHeader, strFieldName, strFieldContents, bFieldsToCopy
	
	bFieldsToCopy = False
	
	If Not rsFields.EOF Then
		%>
		<p class="clear-line-below">
			<input class="btn btn-info" type="button" onclick="CheckAll();" value="<%=TXT_CHECK_ALL%>">
			<input class="btn btn-info" type="button" onclick="ClearAll();" value="<%=TXT_UNCHECK_ALL%>">
		</p>
		<table class="BasicBorder cell-padding-3 full-width clear-line-below form-table">
			<%
		While Not rsFields.EOF
			If intPrevGroupID <> rsFields.Fields("DisplayFieldGroupID") Then
				If Not Nl(strGroupContents) Then
					Response.Write(strGroupHeader)
					Response.Write(strGroupContents)
					bFieldsToCopy = True
				End If
				strGroupHeader = "<tr><th colspan=""3"" class=""RevTitleBox"">" & rsFields.Fields("DisplayFieldGroupName") & "</th></tr>"
				strGroupContents = vbNullString
			End If
			strFieldName = rsFields.Fields("FieldName")
			If strFieldName <> "RECORD_TYPE" Then
				strFieldContents = rsOrg.Fields(strFieldName)
				If Not Nl(strFieldContents) Then
					strFieldContents = textToHTML(strFieldContents)
					strGroupContents = strGroupContents & vbCrLf & "<tr>" & _
						"<td><input type=""checkbox"" name=""IDList"" value=" & AttrQs(strFieldName) & "></td>" & _
						"<td class=""field-label-cell"">" & rsFields.Fields("FieldDisplay") & "</td>" & _
						"<td>" & strFieldContents & "</td>" & _
						"</tr>"
				End If
			End If
			intPrevGroupID = rsFields.Fields("DisplayFieldGroupID")
			rsFields.MoveNext
		Wend
	Else
			%>
			<br>
			<table class="BasicBorder cell-padding-3 full-width clear-line-below">
				<%
	End If

	
	rsFields.Close
	Set cmdFields = Nothing
	Set rsFields = Nothing

	rsOrg.Close
	Set cmdOrg = Nothing
	Set rsOrg = Nothing
	
	If Not Nl(strGroupContents) Then
		Response.Write(strGroupHeader)
		Response.Write(strGroupContents)
		bFieldsToCopy = True
	End If
	
	If Not bFieldsToCopy Then
				%>
				<tr>
					<td><%=TXT_NO_FIELDS_TO_COPY%></td>
				</tr>
				<%
	End If
				%>
		</table>
	</div>
</div>
<%

	
End Sub
%>
