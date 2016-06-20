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
Dim bNoProfiles
bNoProfiles = False

Sub makeImportEntryPrivacyProfileList(bAction,bMap)
	Dim strERIDList, strERIDCon, strCulture, xmlDoc, xmlNode, strProfileName
	strERIDList = vbNullString
	strERIDCon = vbNullString

	Dim cmdListImportPrivacyProfile, rsListImportPrivacyProfile
	Set cmdListImportPrivacyProfile = Server.CreateObject("ADODB.Command")
	With cmdListImportPrivacyProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_CIC_ImportEntry_Priv_l"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@EF_ID", adInteger, adParamInput, 4, intEFID)
	End With
	Set rsListImportPrivacyProfile = Server.CreateObject("ADODB.Recordset")
	rsListImportPrivacyProfile.Open cmdListImportPrivacyProfile
	With rsListImportPrivacyProfile
		If .EOF Then
			bNoProfiles = True
	%>
	<%=TXT_NO_PRIVACY_PROFILES%>
	<%
		Else
	%>
	<%
	%>
	<table class="BasicBorder cell-padding-3">
	<tr>
	<% For Each strCulture in active_cultures() %>
	<th><%=TXT_PROFILE_NAME %> (<%= Application("Culture_" & strCulture & "_LanguageName")%></th>
	<% Next %>
	<th><%=TXT_FIELD_LIST%></th>
	<% If bAction Then %>
	<th><%=TXT_ACTION%></th>
	<%
		End If
		If bMap Then
		%><th><%=TXT_MAP_PROFILE%></th><%
		End If
	%>
	</tr>
	<%
	If bMap Then
		Call openPrivacyProfileListRst(Null)
	End If
			While Not .EOF
			If bMap Then
				strERIDList = strERIDList & strERIDCon & .Fields("ER_ID")
				strERIDCon = ","
			End If
			Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
			With xmlDoc
				.async = False
				.setProperty "SelectionLanguage", "XPath"
			End With

			xmlDoc.loadXML "<DESCS>" & Nz(.Fields("Names"),vbNullString) & "</DESCS>"

			%><tr><%
			For Each strCulture in active_cultures()
				Set xmlNode = xmlDoc.selectSingleNode("//DESC[@Culture=" & Qs(strCulture, SQUOTE) & "]")
				If xmlNode IS Nothing Then
					strProfileName = vbNullString
				Else 
					strProfileName = Server.HTMLEncode(Ns(xmlNode.getAttribute("ProfileName")))
				End If
				%><td><%=strProfileName%></td><%
			Next
			%>
				<td><%=Server.HTMLEncode(Replace(Ns(.Fields("FieldNames")),",",", "))%></td>
				<% If bAction Then %>
				<td> [ <%If Nl(.Fields("ProfileID")) Then%><a href="<%=makeLink("import_privacy.asp", "EFID=" & intEFID & "&ERID=" & .Fields("ER_ID"),vbNullString)%>"><%=TXT_ADD%></a> 
				<%Else%><%=TXT_EXISTS%><%End If%> ]
				</td>
				<%
				End If
				If bMap Then
				%>
				<td style="white-space: nowrap;"><%=makePrivacyProfileList(.Fields("ProfileID"), "QProfileMap_" & .Fields("ER_ID"), True)%> [ <a href="javascript:openWin('<%=Server.HTMLEncode(makeLink("import_privacyfields.asp","ProfileID=[ID]", vbNullString))%>'.replace('[ID]',document.getElementById('QProfileMap_<%=.Fields("ER_ID")%>').value),'privacy_fields')">fields</a> ]</td>
				<% End If %>
			</tr><%
				.MoveNext
			Wend
		If bMap Then
			Call closePrivacyProfileListRst()
		End If
	%>
	</table>
	<%
		End If
		.Close
	End With
	Set rsListImportPrivacyProfile = Nothing
	Set cmdListImportPrivacyProfile = Nothing
	If bMap Then
%><div style="display: none;"><input type="hidden" name="PrivacyProfiles" value="<%=strERIDList%>"></div><%
	End If
End Sub
%>
