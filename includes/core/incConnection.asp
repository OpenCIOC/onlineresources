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

<script language="python" runat="server">
import os
import cioc.core.config as config, cioc.core.connection as connection

PERMISSION_ADMIN = connection.PERMISSION_ADMIN
PERMISSION_CIC = connection.PERMISSION_CIC
PERMISSION_VOL = connection.PERMISSION_VOL

def get_connection_string(perm, language):
	return pyrequest.connmgr.get_asp_connection_string(perm, language)

</script>

<%

Sub handleDBConnetionError()
	Dim ErrMsg
	ErrMsg = Err.Description
 	Err.Number = 0
	On Error GoTo 0
	Call Response.Clear
	Response.Status = "503 Service Unavailable"
	%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title><%=TXT_SERVICE_UNAVAILABLE_TITLE%></title>
	</head>
	<body>
	<p><%=TXT_SERVICE_UNAVAILABLE_BODY%></p>
	<!-- <%= ErrMsg %> -->
<%
	Dim indCookie, _
		bLogin

	bLogin = False
	For Each indCookie in Request.Cookies
		If reEquals(indCookie,".*_Login", False, False, True, False) Then
			bLogin = True
			Exit For
		End If
	Next

	If bLogin Then
%>
	<p><a href="http://community.cioc.ca/resources/how-to/google-search"><%=TXT_USING_GOOGLE_SEARCH%></a></p>
<%
	End If
%>
	</body>
	</html>
	<%
	%><!--#include file="../../includes/core/incClose.asp" --><%
	Response.End()
	
End Sub

Dim cnnCICEn, _
	cnnCICFr, _
	cnnCICOt, _
	strCICOt, _
	cnnVOLEn, _
	cnnVOLFr, _
	cnnVOLOt, _
	strVOLOt, _
	cnnAdminEn, _
	cnnAdminFr, _
	cnnAdminOt, _
	strAdminOt 

Sub makeNewConnection(ByRef cnnNew, strPerm)
	Err.Clear
	On Error Resume Next
	
	Set cnnNew = Server.CreateObject("ADODB.Connection")
	cnnNew.Open get_connection_string(strPerm, g_objCurrentLang.LanguageAlias)

	If Err.Number <> 0 Then
		Call handleDBConnetionError()
	End If

	On Error GoTo 0
End Sub
Sub makeNewAdminConnection(ByRef cnnNew)
	Call makeNewConnection(cnnNew, PERMISSION_ADMIN)
End Sub

Sub makeNewCICBasicConnection(ByRef cnnNew)
	Call makeNewConnection(cnnNew, PERMISSION_CIC)
End Sub

Sub makeNewVOLBasicConnection(cnnNew)
	Call makeNewConnection(cnnNew, PERMISSION_VOL)
End Sub

Function getCurrentAdminCnn()
	If Not user_bLoggedIn Then
		getCurrentAdminCnn = getCurrentBasicCnn()
	Else
		Select Case g_objCurrentLang.Culture
			Case CULTURE_FRENCH_CANADIAN
				If Not IsObject(cnnAdminFr) Then
					Call makeNewAdminConnection(cnnAdminFr)
				End If
				getCurrentAdminCnn = cnnAdminFr
			Case CULTURE_ENGLISH_CANADIAN
				If Not IsObject(cnnAdminEn) Then
					Call makeNewAdminConnection(cnnAdminEn)
				End If
				getCurrentAdminCnn = cnnAdminEn
			Case Else
				If Not IsObject(cnnAdminOt) Then
					Call makeNewAdminConnection(cnnAdminOt)
				ElseIf strAdminOt <> g_objCurrentLang.Culture Then
					cnnAdminOt = Nothing
					Call makeNewAdminConnection(cnnAdminOt)
				End If
				strAdminOt = g_objCurrentLang.Culture
				getCurrentAdminCnn = cnnAdminOt
		End Select
	End If
End Function

Function getCurrentBasicCnn()
	If ps_intDbArea = DM_VOL Then
		getCurrentBasicCnn = getCurrentVOLBasicCnn()
	Else
		getCurrentBasicCnn = getCurrentCICBasicCnn()
	End If
End Function

Function getCurrentCICBasicCnn()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			If Not IsObject(cnnCICFr) Then
				Call makeNewCICBasicConnection(cnnCICFr)
			End If
			getCurrentCICBasicCnn = cnnCICFr
		Case CULTURE_ENGLISH_CANADIAN
			If Not IsObject(cnnCICEn) Then
				Call makeNewCICBasicConnection(cnnCICEn)
			End If
			getCurrentCICBasicCnn = cnnCICEn
		Case Else
			If Not IsObject(cnnCICOt) Then
				Call makeNewCICBasicConnection(cnnCICOt)
			ElseIf strCICOt <> g_objCurrentLang.Culture Then
				cnnCICOt = Nothing
				Call makeNewCICBasicConnection(cnnCICOt)
			End If
			strCICOt = g_objCurrentLang.Culture
			getCurrentCICBasicCnn = cnnCICOt
	End Select
End Function

Function getCurrentVOLBasicCnn()
	Select Case g_objCurrentLang.Culture
		Case CULTURE_FRENCH_CANADIAN
			If Not IsObject(cnnVOLFr) Then
				Call makeNewVOLBasicConnection(cnnVOLFr)
			End If
			getCurrentVOLBasicCnn = cnnVOLFr
		Case CULTURE_ENGLISH_CANADIAN
			If Not IsObject(cnnVOLEn) Then
				Call makeNewVOLBasicConnection(cnnVOLEn)
			End If
			getCurrentVOLBasicCnn = cnnVOLEn
		Case Else
			If Not IsObject(cnnVOLOt) Then
				Call makeNewVOLBasicConnection(cnnVOLOt)
			ElseIf strVOLOt <> g_objCurrentLang.Culture Then
				cnnVOLOt = Nothing
				Call makeNewVOLBasicConnection(cnnVOLOt)
			End If
			strVOLOt = g_objCurrentLang.Culture
			getCurrentVOLBasicCnn = cnnVOLOt
	End Select
End Function
%>
