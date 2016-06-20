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
Dim aSQLSearch, _
	strSearchInfoSSNotes

If bSearchDisplay Then

	If Not Nl(strSearchInfoSQL) Then
		strSearchInfoSQL = "SET NOCOUNT ON" & vbCrLf & _
			strSearchInfoSQL & vbCrLf & "SELECT @searchText AS SEARCH_INFO" & vbCrLf & _
			"SET NOCOUNT OFF"

		'Response.Write("<pre>" & Server.HTMLEncode(strSearchInfoSQL) & "</pre>")
		'Response.Flush()

		Dim cnnSearchInfo, cmdSearchInfo, rsSearchInfo
		Call makeNewAdminConnection(cnnSearchInfo)
		Set cmdSearchInfo = Server.CreateObject("ADODB.Command")
		With cmdSearchInfo
			.ActiveConnection = cnnSearchInfo
			.CommandText = strSearchInfoSQL
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsSearchInfo = cmdSearchInfo.Execute
		With rsSearchInfo
			If Not .EOF Then
				If Not Nl(.Fields("SEARCH_INFO")) Then
					'Response.Write("<pre>" & Server.HTMLEncode(.Fields("SEARCH_INFO")) & "</pre>")
					'Response.Flush()
					
					aSQLSearch = Split(.Fields("SEARCH_INFO"),"</search_display_item>" & vbCrLf & "<search_display_item>")
					If IsArray(aSQLSearch) Then
						If UBound(aSQLSearch) >= 0 Then
							aSQLSearch(0) = Replace(aSQLSearch(0),vbCrLf & "<search_display_item>",vbNullString)
							aSQLSearch(UBound(aSQLSearch)) = Replace(aSQLSearch(UBound(aSQLSearch)),"</search_display_item>",vbNullString)
						End If
				
						ReDim Preserve aSearch(intCurrentSearch + UBound(aSQLSearch) + 1)
						For Each indSearch In aSQLSearch
							If Not Nl(indSearch) Then
								intCurrentSearch = intCurrentSearch + 1
								aSearch(intCurrentSearch) = indSearch
							End If
						Next

						ReDim aSQLSearch(-1)
					End If
				End If
			End If
			.Close
		End With
		Set rsSearchInfo = Nothing
		Set cmdSearchInfo = Nothing
		Set cnnSearchInfo = Nothing
	End If
	
	If intCurrentSearch > 0 Then
%>
<p id="SearchDetails"><%=TXT_YOU_SEARCHED_FOR%></p>
<ul id="SearchDetailsList">
<%
		For Each indSearch In aSearch
%>
	<li class="search-info-list"><%=indSearch%></li>
<%
		Next
%>
</ul>
<%
	ElseIf intCurrentSearch = 0 Then
%>
<p id="SearchDetails"><%=TXT_YOU_SEARCHED_FOR%><strong><%=aSearch(0)%></strong></p>
<%
	End If
	
	strSearchInfoSSNotes = Server.URLEncode("* " & Replace(Replace(Replace(Join(aSearch,vbCrLf & "* "),"<em>",vbNullString),"</em>",vbNullString),"&nbsp;"," "))

	If user_bLoggedIn And UBound(aSearch) >= 0 Then
		strSearchInfoRefineNotes = Join(aSearch,"-{|}-")
	End If
End If
%>
