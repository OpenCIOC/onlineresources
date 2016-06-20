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
Sub checkForErrors()
	Dim strErrorMsg
	strErrorMsg = Trim(Request("ErrMsg"))
	If Not Nl(strErrorMsg) Then
		Call handleError(strErrorMsg, vbNullString, vbNullString)
	End If
End Sub

Sub checkForMessages()
	Dim strMsg
	strMsg = Trim(Request("InfoMsg"))
	If Not Nl(strMsg) Then
		Call handleMessage(strMsg, vbNullString, vbNullString, False)
	End If
End Sub

Sub handleDetailsMessage(strMsg, strNUM, strHTTPVals, bError)
	If Nl(strNUM) Then
		Call handleMessage(strMsg, vbNullString, strHTTPVals, bError)
	ElseIf Nl(strRecordRoot) Then
		Call handleMessage(strMsg, ps_strPathToStart & "details.asp", "NUM=" & strNUM & _
				StringIf(Not Nl(strHTTPVals), "&" & strHTTPVals), bError)
	Else
		Call handleMessage(strMsg, ps_strPathToStart & strRecordRoot & strNUM, strHTTPVals, bError)
	End If
End Sub

Sub handleVOLDetailsMessage(strMsg, strVNUM, strHTTPVals, bError)
	If Nl(strVNUM) Then
		Call handleMessage(strMsg, vbNullString, strHTTPVals, bError)
	ElseIf Nl(strRecordRoot) Then
		Call handleMessage(strMsg, ps_strPathToStart & "details.asp", "VNUM=" & strVNUM & _
				StringIf(Not Nl(strHTTPVals), "&" & strHTTPVals), bError)
	Else
		Call handleMessage(strMsg, ps_strPathToStart & "volunteer/" & strRecordRoot & strVNUM, strHTTPVals, bError)
	End If
End Sub

Sub handleMessage(strMsg, strRedirect, strHTTPVals, bError)
	If Nl(strMsg) And Nl(strRedirect) Then
		Exit Sub
	ElseIf Nl(strMsg) Then
		Call goToPage(strRedirect,strHTTPVals,vbNullString)
	ElseIf Nl(strRedirect) Then
		Response.Write("<p " & IIf(bError,"CLASS=""Alert""","CLASS=""Info""") & ">" & _
			strMsg & "</p>")
	Else
		Call goToPage(strRedirect, _
			IIf(Nl(strHTTPVals),vbNullString,strHTTPVals & "&") & _
			IIf(bError,"ErrMsg=","InfoMsg=") & Server.URLEncode(strMsg),vbNullString)
	End If
End Sub

Sub handleError(strErrorMsg, strRedirect, strHTTPVals)
	Call handleMessage(IIf(Nl(strErrorMsg),TXT_UNKNOWN_ERROR_OCCURED,strErrorMsg), _
		strRedirect, strHTTPVals, True)
End Sub
%>
