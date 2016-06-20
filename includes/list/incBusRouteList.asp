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
Dim cmdListBusRoute, rsListBusRoute

Sub openBusRouteListRst(bShowHidden)
	Set cmdListBusRoute = Server.CreateObject("ADODB.Command")
	With cmdListBusRoute
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_BusRoute_l"
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@ShowHidden", adBoolean, adParamInput, 1, IIf(bShowHidden,SQL_TRUE,SQL_FALSE))
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	Set rsListBusRoute = Server.CreateObject("ADODB.Recordset")
	With rsListBusRoute
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdListBusRoute
	End With
End Sub

Sub closeBusRouteListRst()
	If rsListBusRoute.State <> adStateClosed Then
		rsListBusRoute.Close
	End If
	Set cmdListBusRoute = Nothing
	Set rsListBusRoute = Nothing
End Sub

Function makeBusRouteList(strSelected, strSelectName, bIncludeBlank, strOnChange)
	Dim strReturn
	
	With rsListBusRoute
		If .RecordCount > 0 Then
			.MoveFirst
		End If
		If .EOF Then
			strReturn = TXT_NO_VALUES_AVAILABLE
		Else
			strReturn = strReturn & "<select name=" & AttrQs(strSelectName) & " id=" & AttrQs(strSelectName) & " class=""form-control"""
			If Not Nl(strOnChange) Then
				strReturn = strReturn & " onChange=""" & strOnChange & """"
			End If
			strReturn = strReturn & ">"
			If bIncludeBlank Then
				strReturn = strReturn & "<option value=""""> -- </option>"
			End If
			While Not .EOF
				strReturn = strReturn & _
					"<option value=""" & .Fields("BR_ID") & """"
				If strSelected = .Fields("BR_ID") Then
					strReturn = strReturn & " selected"
				End If
				strReturn = strReturn & ">" & .Fields("RouteNumber") & _
					StringIf(Not Nl(.Fields("RouteName"))," - " & .Fields("RouteName")) & _
					StringIf(Not Nl(.Fields("Municipality"))," (" & .Fields("Municipality") & ")") & _
					"</option>"
				.MoveNext
			Wend
			strReturn = strReturn & "</select>"
		End If
	End With
	makeBusRouteList = strReturn
End Function
%>
