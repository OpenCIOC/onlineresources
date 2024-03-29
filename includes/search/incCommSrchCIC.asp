﻿<%
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
Function makeCommSrchTable(ByRef bIsEmpty)
	Dim strReturn, intWrapAt
	Dim cmdSrchComm, rsSrchComm
	Set cmdSrchComm = Server.CreateObject("ADODB.Command")
	With cmdSrchComm
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_View_Community_l"
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With
	
	Set rsSrchComm = cmdSrchComm.Execute

	Dim intWrapNum, _
		strColClass

	intWrapAt = g_intCommSrchWrapAtCIC
	Select Case intWrapAt
		Case 2
			strColClass = "col-xs-12 col-sm-6"
		Case 3
			strColClass = "col-xs-12 col-sm-6 col-md-4"
		Case Else
			If 	intWrapAt < 2 Then
				strColClass = "col-xs-12"
			Else
				strColClass = "col-xs-12 col-sm-6 col-md-4 col-lg-3"
			End If
	End Select
	
	With rsSrchComm
		If .EOF Then
			bIsEmpty = True
		Else
			intWrapAt = intWrapAt - 1
			intWrapNum = intWrapAt
			bIsEmpty = False
			If bSrchCommunityDefaultOnly Then
				strReturn = "<input type=""hidden"" name=""CMType"" " & AttrQs(IIf(bSrchCommunityDefault,"S","L")) & ">"
			Else
				strReturn = "<label for=""CMType_L""><input type=""radio"" name=""CMType"" id=""CMType_L"" value=""L"" " & Checked(Not bSrchCommunityDefault) & ">" & TXT_LOCATED_IN_COMM & "</label>" & vbCrLf & _
					"<label for=""CMType_S""><input type=""radio"" name=""CMType"" id=""CMType_S"" value=""S"" " & Checked(bSrchCommunityDefault) & ">" & TXT_SERVING_COMM & "</label>" & vbCrLf
			End If


			strReturn = strReturn & "<div class=""row"">"
			While Not .EOF
				strReturn = strReturn & vbCrLf & _
					"<div class=" & AttrQs(strColClass) & ">" & _
					"<label for=""CMID_" & .Fields("CM_ID") & """><input type=""checkbox"" name=""CMID"" value=""" & _
					.Fields("CM_ID") & """ id=""CMID_" & .Fields("CM_ID") & """>&nbsp;" & .Fields("Community") & "</label>" & _
					"</div>"
				.MoveNext
			Wend
			strReturn = strReturn & vbCrLf & "</div>"
			If g_bOtherCommunityCIC Then
				strReturn = strReturn & vbCrLf & "<div class=""clear-line-above""><strong><label for=""OComm"">" & TXT_OTHER_COMMUNITY & "</label></strong>" & TXT_COLON & _
				"[ <a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cfind')"">" & TXT_INST_OTHER_COMMUNITY & "</a> ]" & _
				"<br><input id=""OComm"" name=""OComm"" TYPE=""text"" maxlength=""200"" class=""form-control""><input type=""hidden"" name=""OCommID"" id=""OCommID""></div>"
			End If
		End If
	End With

	makeCommSrchTable = strReturn
End Function

Function makeCommSrchTableTax(ByRef bIsEmpty)
	Dim strReturn
	Dim cmdSrchComm, rsSrchComm
	Set cmdSrchComm = Server.CreateObject("ADODB.Command")
	Set rsSrchComm = Server.CreateObject("ADODB.Recordset")
	With cmdSrchComm
		.ActiveConnection = getCurrentCICBasicCnn()
		.CommandText = "dbo.sp_CIC_View_Community_l"
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeCIC)
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
	End With

	With rsSrchComm
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdSrchComm
	End With
	
	With rsSrchComm

		If .EOF Then
			bIsEmpty = True
		Else
			bIsEmpty = False
			strReturn = "<div class=""TermListTitle CommunityList"">" & vbCrLf & _
					StringIf(Not bSrchCommunityDefaultOnly Or Not bSrchCommunityDefault,"<input type=""radio"" name=""CMType"" value=""L"" " & Checked(Not bSrchCommunityDefault And .RecordCount < 9) & "> " & TXT_LOCATED_IN_COMM & vbCrLf) & _
					StringIf(Not bSrchCommunityDefaultOnly Or bSrchCommunityDefault,"<input type=""radio"" name=""CMType"" value=""S""" & Checked(bSrchCommunityDefault And .RecordCount < 9) & "> " & TXT_SERVING_COMM & vbCrLf) & _
					"<input type=""radio"" name=""CMType"" value="""" id=""community-any-button"" " & Checked(.RecordCount >= 9) & "> " & TXT_ANY_COMM & vbCrLf & _
					"</div>" & vbCrLf & _
					"<div class=""TermList"" id=""CommunitySelections""><ul>"
			While Not .EOF
				strReturn = strReturn & vbCrLf & "<li><input type=""checkbox"" name=""CMID"" value=""" & _
					.Fields("CM_ID") & """ id=""CMID_" & .Fields("CM_ID") & """>&nbsp;<label for=""CMID_" & .Fields("CM_ID") & """>" & .Fields("Community") & "</label></li>"
				.MoveNext
			Wend
			If g_bOtherCommunityCIC Then
				strReturn = strReturn & vbCrLf & "<li style=""padding-top:.5em""><strong>" & TXT_OTHER_COMMUNITY & "</strong>" & TXT_COLON & vbCrLf & _
				"<br><input id=""OComm"" name=""OComm"" TYPE=""text"" size=""30"" maxlength=""200""><input type=""hidden"" name=""OCommID"" id=""OCommID"">" & vbCrLf & _
				"<br>[ <a href=""javascript:openWin('" & makeLinkB(ps_strPathToStart & "comfind.asp") & "','cfind')"">" & TXT_INST_OTHER_COMMUNITY & "</a> ]</li>"
			End If
			strReturn = strReturn & vbCrLf & "</ul></div>"
		End If
	End With

	makeCommSrchTableTax = strReturn
End Function
%>
