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
Dim aGetSearchArray, _
	intCurSearchNumber, _
	intLastSearchNumber

Dim g_strAddToHeader, g_bEnableListModeCT

Sub addToHeader(strInsert)
	g_strAddToHeader = g_strAddToHeader & vbCrLf & strInsert
End Sub

Sub addScript(strSource, strType)
	If Not Nl(strSource) Then
		addToHeader("<script src=" & Qs(strSource,DQUOTE) & _
			IIf(Nl(strType),vbNullString," type=" & Qs(strType,DQUOTE)) & _
			"></script>")
	End If
End Sub

intLastSearchNumber = -1
intCurSearchNumber = -1
Select Case ps_intDbArea
	Case DM_CIC
		aGetSearchArray = getSessionValue("aNUMSearchList")
	Case DM_VOL
		aGetSearchArray = getSessionValue("aVNUMSearchList")
End Select
If Not Nl(aGetSearchArray) Then
	aGetSearchArray = Split(aGetSearchArray, ",")
End If
If Not Nl(Request("Number")) And IsNumeric(Request("Number")) Then
	If IsArray(aGetSearchArray) Then
		intCurSearchNumber = CInt(Request("Number"))
		intLastSearchNumber = UBound(aGetSearchArray)
		If intCurSearchNumber < 0 Or intCurSearchNumber > intLastSearchNumber Then
			intLastSearchNumber = -1
			intCurSearchNumber = -1
		End If
	End If
End If
%>
<script language="python" runat="server">
import cioc.core.template as template 
from markupsafe import Markup
reload(template)

def render_popup_page_help_link(TXT_PAGE_HELP, extra_class=None):
	pageinfo = pyrequest.pageinfo
	if not pageinfo.HasHelp or not user_bLoggedIn:
		return ''
	
	exc = '' if not extra_class else ('class="%s"' % unicode(extra_class))
	return ' | <a href="%(link)s" target="pHelp" %(extra_class)s onClick="openWinL(\'%(link)s\', \'pHelp\')">%(display)s</a>' % \
				dict(link=Server.HTMLEncode(pyrequest.passvars.makeLinkAdmin('pagehelp', {'Page': pageinfo.ThisPageFull})),
					display=TXT_PAGE_HELP, extra_class=exc)

def render_header(strPageName, strDocTitle, bNoCache, bNoIndex, bPrintTable, addToHeader, focus):
	#last chance before rendering response to set cookies, etc
	run_response_callbacks()

	pyrequest.renderinfo = template.RenderInfo(pyrequest, strPageName, strDocTitle, bNoCache, bNoIndex, bPrintTable, Markup(addToHeader or ''), focus)
	Response.Write(pyrequest.renderinfo.render_header())


def render_gtranslate_ui():
	from cioc.core import gtranslate
	return gtranslate.render_ui(pyrequest)

</script>
<%

Sub makePageHeader(ByVal strPageName, ByVal strDocTitle, ByVal bQuickbar, ByVal bNoCache, ByVal bNoIndex, ByVal bPrintTable)
'On Error Resume Next

	Call render_header(strPageName, strDocTitle, bNoCache, bNoIndex, bPrintTable, g_strAddToHeader, ps_strFocus)

End Sub

Function makePageHelpLink()
	makePageHelpLink = render_popup_page_help_link(TXT_PAGE_HELP)
End Function
Function makePageHelpLinkB(strExtraClass)
	makePageHelpLinkB = render_popup_page_help_link(TXT_PAGE_HELP, strExtraClass)
End Function
%>
