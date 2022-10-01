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
Function makeNumNeededContents(rst,bUseContent)
	Dim strReturnCONTACT_NAME
	Dim strVNUM, _
		intNumNeededTotal, _
		strNotes, _
		intNotesLen

	If bUseContent Then
		With rst
			strVNUM = .Fields("VNUM")
			intNumNeededTotal = .Fields("NUM_NEEDED_TOTAL")
			strNotes = .Fields("NUM_NEEDED_NOTES")
		End With
	Else
		strVNUM = Null
	End If

	Dim cnnNumNeeded, cmdNumNeeded, rsNumNeeded
	Call makeNewAdminConnection(cnnNumNeeded)
	Set cmdNumNeeded = Server.CreateObject("ADODB.Command")
	With cmdNumNeeded
		.ActiveConnection = cnnNumNeeded
		.CommandText = "dbo.sp_VOL_VNUMNumNeeded_s"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
	End With
	Set rsNumNeeded = cmdNumNeeded.Execute

	strReturn = _
		"<div class=""form-group"">" & _
			"<label for=""NUM_NEEDED_TOTAL"" class=""control-label col-xs-4 col-lg-3"">" & TXT_NUM_POSITIONS & " (" & TXT_TOTAL & ")</label>" & _
			"<div class=""col-xs-8 col-lg-9 form-inline"">" & _
				"<input type=""text"" name=""NUM_NEEDED_TOTAL"" id=""NUM_NEEDED_TOTAL"" size=""5"" maxlength=""4"" value=""" & intNumNeededTotal & """ class=""form-control"">" & _
			"</div>" & _
		"</div>" & _
		"<table class=""BasicBorder cell-padding-2"">" & _
		"<tr><th class=""RevTitleBox"">&nbsp;</th><th class=""RevTitleBox"">" & TXT_COMMUNITY & "</th><th class=""RevTitleBox"">" & TXT_NUM_POSITIONS & "</th></tr>"
	
	With rsNumNeeded
		If Not .EOF Then
			While Not .EOF
				strReturn = strReturn & _
					"<tr>" & _
						"<td><input type=""checkbox"" id=""CM_ID_" & .Fields("CM_ID") & """ name=""CM_ID_" & .Fields("CM_ID") & """ value=""on""" & Checked(Not Nl(.Fields("OP_CM_ID"))) & "></td>" & _
						"<td class=""FieldLabelLeftClr""><label for=""CM_ID_" & .Fields("CM_ID") & """>" & .Fields("Community") & "</label></td>" & _
						"<td><div class=""form-inline text-center""><input type=""text"" name=""CM_NUM_NEEDED_" & .Fields("CM_ID") & """ title=" & AttrQs(TXT_POSITIONS & TXT_COLON & .Fields("Community")) & _
							" size=""3"" maxlength=""3"" value=" & AttrQs(.Fields("NUM_NEEDED")) & " class=""form-control""></div></td>" & _
					"</tr>"
				.MoveNext
			Wend
		End If
	End With

	strReturn = strReturn & _
		"<tr>" & _
			"<td colspan=""2""><div class=""form-inline""><input type=""text"" name=""NEW_CM_0"" id=""NEW_CM_0"" title=" & AttrQs(TXT_CUSTOM_COMMUNITY & " 1") & " size=""40"" maxlength=""200"" class=""form-control""></div></td>" & _
			"<td><div class=""form-inline text-center""><input type=""text"" name=""NEW_CM_0_NUM_NEEDED"" title=" & AttrQs(TXT_POSITIONS & TXT_COLON & TXT_CUSTOM_COMMUNITY & " 1") & " size=""3"" maxlength=""3"" class=""form-control""></div></td>" & _
		"</tr>" & _
		"<tr>" & _
			"<td colspan=""2""><div class=""form-inline""><input type=""text"" name=""NEW_CM_1"" id=""NEW_CM_1"" title=" & AttrQs(TXT_CUSTOM_COMMUNITY & " 2") & " size=""40"" maxlength=""200"" class=""form-control""></div></td>" & _
			"<td><div class=""form-inline text-center""><input type=""text"" name=""NEW_CM_1_NUM_NEEDED"" title=" & AttrQs(TXT_POSITIONS & TXT_COLON & TXT_CUSTOM_COMMUNITY & " 2") & " size=""3"" maxlength=""3"" class=""form-control""></div></td>" & _
		"</tr>" & _
	"</table>"

	If Nl(strNotes) Then
		intNotesLen = 0
	Else
		intNotesLen = Len(strNotes)
		strNotes = Server.HTMLEncode(strNotes)
	End If
	strReturn = strReturn & _
		"<h4><label for=""NUM_NEEDED_NOTES"">" & TXT_OTHER_NOTES & "</label></h4>" & _
		"<textarea name=""NUM_NEEDED_NOTES""" & _
			" id=""NUM_NEEDED_NOTES""" & _
			" rows=""" & getTextAreaRows(intNotesLen,TEXTAREA_ROWS_SHORT) & """" & _
			" class=""form-control""" & _
			">" & strNotes & "</textarea>"

	makeNumNeededContents = strReturn
End Function

Function makeAreaOfInterestContents(rst,bUseContent)
	Dim strReturn
	Dim strInterests
	
	If bUseContent Then
		strInterests = rst("INTERESTS")
	End If
	
	strReturn = makeMemoFieldVal("INTERESTS", _
							strInterests, _
							TEXTAREA_ROWS_SHORT, _
							False, _
							False _
							) & _
		"<br>" & TXT_NOT_SURE_ENTER & " <a href=""javascript:openWin('" & makeLinkB("interestfind.asp") & "','sFind')"">" & TXT_AREA_OF_INTEREST_FINDER & "</a>."
	
	makeAreaOfInterestContents = strReturn
End Function
%>
