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
Dim cmdCustFieldList, rsCustFieldList

Sub openCustFieldRst(intDomain, intViewType, bForSearch, bDates)

	Set cmdCustFieldList = Server.CreateObject("ADODB.Command")
	With cmdCustFieldList
		.ActiveConnection = getCurrentAdminCnn()
		Select Case intDomain
			Case DM_CIC
				.CommandText = "dbo.sp_CIC_View_CustomField_l"
			Case DM_VOL
				.CommandText = "dbo.sp_VOL_View_CustomField_l"
		End Select
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, intViewType)
		.Parameters.Append .CreateParameter("@ForSearch", adBoolean, adParamInput, 1, IIf(bForSearch,SQL_TRUE,SQL_FALSE))
		.Parameters.Append .CreateParameter("@Dates", adBoolean, adParamInput, 1, IIf(bDates,SQL_TRUE,SQL_FALSE))
	End With
	Set rsCustFieldList = Server.CreateObject("ADODB.Recordset")
	With rsCustFieldList
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdCustFieldList
	End With
End Sub

Sub closeCustFieldRst()
	If rsCustFieldList.State <> adStateClosed Then
		rsCustFieldList.Close
	End If
	Set cmdCustFieldList = Nothing
	Set rsCustFieldList = Nothing
End Sub

Function makeCustFieldList(aSelected, strSelectName, bIncludeBlank, bMultiple, intSize)
	Dim strReturn, indField
	With rsCustFieldList
		If .RecordCount <> 0 Then
			.MoveFirst		
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " class=""form-control""" & _
				IIf(bMultiple," MULTIPLE size=""" & intSize & """",vbNullString) & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("FieldID") & """"
				If IsArray(aSelected) And bMultiple Then
					For Each indField In aSelected
						If CInt(indField) = CInt(.Fields("FieldID")) Then
							strReturn = strReturn & " selected"
							Exit For
						End If
					Next
				ElseIf aSelected = .Fields("FieldID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & Server.HTMLEncode(.Fields("FieldDisplay")) & "</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeCustFieldList = strReturn
End Function

Sub makeDateSearchRow(intCFldNum)
%>
<tr> 
	<td class="field-label-cell-widelabel"><%=makeCustFieldList(vbNullString,"CD" & intCFldNum & "DateType",False,False,0)%></td>
	<td class="field-data-cell"><%Call printDateSearchTable("CD" & intCFldNum)%></td>
</tr>
<%
End Sub

Sub makeCustomFieldSearchRow(intCFldNum)
%>
<tr> 
	<td class="field-label-cell-widelabel"><%=makeCustFieldList(vbNullString,"CF" & intCFldNum,False,True,5)%></td>
	<td class="field-data-cell">
		<div class="row">
			<div class="col-sm-3">
				<%=makeLikeList("CF" & intCFldNum & "Type")%>
			</div>
			<div class="col-sm-9">
				<input name="CF<%=intCFldNum%>Val" type="text" title=<%=AttrQs(TXT_SEARCH_TERMS)%> maxlength="250" class="form-control">
			</div>
		</div>
		<div class="checkbox">
			<label for="CF<%=intCFldNum%>All"><input type="checkbox" name="CF<%=intCFldNum%>All" id="CF<%=intCFldNum%>All"><%=TXT_ALL_FIELDS_MUST_MATCH%></label>
		</div>
		<div class="checkbox">
			<label for="CF<%=intCFldNum%>Inc"><input type="checkbox" name="CF<%=intCFldNum%>Inc" id="CF<%=intCFldNum%>Inc"><%=TXT_INCLUDE_FIELDS_IN_DISPLAY%></label>
		</div>
		<div class="SmallNote"><%=TXT_SOME_FIELDS_NOT_AVAILABLE%></div>
	</td>
</tr>
<%
End Sub
%>
