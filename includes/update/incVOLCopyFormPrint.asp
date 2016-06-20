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
Sub printCopyFieldsForm(strVNUM)
%>
<div id="copyFieldsForm">
<div id="copyFieldsInner">
<%
	Dim cmdFields, rsFields
	Set cmdFields = Server.CreateObject("ADODB.Command")
	With cmdFields
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_VOL_Opportunity_s_CanCopy_2"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	End With
	Set rsFields = cmdFields.Execute

	Dim cmdOrg, rsOrg
	Set cmdOrg = Server.CreateObject("ADODB.Command")
	With cmdOrg
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_VOL_Opportunity_s_CanCopy_3"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	End With
	Set rsOrg = cmdOrg.Execute
%>

<h2><%=TXT_FIELDS & TXT_COLON%></h2>
<%
	Dim strFieldName, strFieldContents, bFieldsToCopy
	
	bFieldsToCopy = False
	
	If Not rsFields.EOF Then
%>
<p><input type="button" onClick="CheckAll();" value="<%=TXT_CHECK_ALL%>"> <input type="button" onClick="ClearAll();" value="<%=TXT_UNCHECK_ALL%>"></p>
<table class="BasicBorder cell-padding-3">
<tr>
	<td>&nbsp;</td>
	<td class="FieldLabelLeft"><%=TXT_ORG_NAMES%></td>
	<td><%=strOrgName%></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td class="FieldLabelLeft"><%=TXT_POSITION_TITLE%> <span class="Alert">*</span></td>
	<td><input type="text" id="POSITION_TITLE" name="POSITION_TITLE" size="<%=TEXT_SIZE%>" maxlength="150" value=<%=AttrQs(strPosTitle)%> /></td>
</tr>
<%
	While Not rsFields.EOF
		strFieldName = rsFields.Fields("FieldName")
		strFieldContents = rsOrg.Fields(strFieldName)
		If Not Nl(strFieldContents) Then
			bFieldsToCopy = True
%>
<tr>
	<td><input type="checkbox" name="IDList" value=<%=AttrQs(strFieldName)%>></td>
	<td class="FieldLabelLeft"><%=rsFields.Fields("FieldDisplay")%></td>
	<td><%=textToHTML(strFieldContents)%></td>
</tr>
<%
		End If
		rsFields.MoveNext
	Wend
	
	Else
%>	
	<br>
	<table class="BasicBorder cell-padding-3">
<%
	End If

	
	rsFields.Close
	Set cmdFields = Nothing
	Set rsFields = Nothing

	rsOrg.Close
	Set cmdOrg = Nothing
	Set rsOrg = Nothing
	
	If Not bFieldsToCopy Then
%>
<tr><td><%=TXT_NO_FIELDS_TO_COPY%></td></tr>
<%
	End If
%>
</table>
</div>
</div>
<%

	
End Sub
%>
