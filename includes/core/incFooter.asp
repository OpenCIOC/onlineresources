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
def render_footer(bShowMessage, bListScriptLoaded, ct_list_mode):
	if hasattr(pyrequest, 'renderinfo'):
		# some pages don't have a header so we can't show a footer
		pyrequest.renderinfo.show_message = bShowMessage
		pyrequest.renderinfo.list_script_loaded = bListScriptLoaded
		pyrequest.renderinfo.ct_list_mode = ct_list_mode
		Response.Write(pyrequest.renderinfo.render_footer())
</script>
<%
Sub makePageFooter(ByRef bShowMessage)
	Call render_footer(bShowMessage, g_bListScriptLoaded, (g_bEnableListModeCT))
End Sub
%>
