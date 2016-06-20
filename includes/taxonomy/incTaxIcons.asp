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
'
' Purpose:		Create a list of links to various Taxonomy Icons.
'
'
%>
<%
Dim ICON_PLUS, _
	ICON_MINUS, _
	ICON_NOPLUSMINUS, _
	ICON_EDIT, _
	ICON_SELECT, _
	ICON_ZOOM
		
Sub setIcons(bJavaScript)
	'Format for use in a javascript string
	If bJavaScript Then
		ICON_PLUS = "<img border=\""0\"" align=\""bottom\"" src=\""" & ps_strPathToStart & "images/plus.gif\"" title=" & JSONQs(AttrQs(TXT_EXPAND), False) & "/>"
		ICON_MINUS = "<img border=\""0\"" align=\""bottom\"" src=\""" & ps_strPathToStart & "images/minus.gif\""  title=" & JSONQs(AttrQs(TXT_COLLAPSE), False) & "/>"
		ICON_NOPLUSMINUS = "<img border=\""0\"" align=\""bottom\"" aria-hidden=\""true\"" src=\""" & ps_strPathToStart & "images/noplusminus.gif\""/>"
		ICON_EDIT = "<img border=\""0\"" align=\""bottom\"" src=\""" & ps_strPathToStart & "images/edit.gif\""  title=" & JSONQs(AttrQs(TXT_EDIT_TAXONOMY_TERM), False) & "/>"
		ICON_SELECT = "<img border=\""0\"" align=\""bottom\"" src=\""" & ps_strPathToStart & "images/select.gif\""  title=" & JSONQs(AttrQs(TXT_SELECT), False) & "/>"
		ICON_ZOOM = "<img border=\""0\"" align=\""bottom\"" src=\""" & ps_strPathToStart & "images/zoom.gif\""  title=" & JSONQs(AttrQs(TXT_SEARCH), False) & "/>"
	'Format for use when outputting HTML
	Else
		ICON_PLUS = "<img border=""0"" align=""bottom"" title=" & AttrQs(TXT_EXPAND) & " src=""" & ps_strPathToStart & "images/plus.gif""/>"
		ICON_MINUS = "<img border=""0"" align=""bottom"" title=" & AttrQs(TXT_COLLAPSE) & " src=""" & ps_strPathToStart & "images/minus.gif""/>"
		ICON_NOPLUSMINUS = "<img border=""0"" align=""bottom"" aria-hidden=""true"" src=""" & ps_strPathToStart & "images/noplusminus.gif""/>"
		ICON_EDIT = "<img border=""0"" align=""bottom"" title=" & AttrQs(TXT_EDIT_TAXONOMY_TERM) & " src=""" & ps_strPathToStart & "images/edit.gif""/>"
		ICON_SELECT = "<img border=""0"" align=""bottom"" title=" & AttrQs(TXT_SELECT) & " src=""" & ps_strPathToStart & "images/select.gif""/>"
		ICON_ZOOM = "<img border=""0"" align=""bottom"" title=" & AttrQs(TXT_SEARCH) & " src=""" & ps_strPathToStart & "images/zoom.gif""/>"
	End If
End Sub
%>
