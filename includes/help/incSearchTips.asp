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
Dim	strPageText

Dim cmdSearchTips, rsSearchTips
Set cmdSearchTips = Server.CreateObject("ADODB.Command")
With cmdSearchTips
	.ActiveConnection = getCurrentBasicCnn()
	Select Case ps_intDbArea
		Case DM_CIC
			.CommandText = "sp_CIC_SearchTips_s"		
		Case DM_VOL
			.CommandText = "sp_VOL_SearchTips_s"
	End Select
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, ps_intDbAreaViewType)
End With
Set rsSearchTips = cmdSearchTips.Execute

With rsSearchTips
	If Not .EOF Then
		strPageText = .Fields("PageText")
	End If
End With

Call makePageHeader(TXT_SEARCH_TIPS, TXT_SEARCH_TIPS, True, False, True, True)

rsSearchTips.Close
Set rsSearchTips = Nothing
Set cmdSearchTips = Nothing

If Nl(strPageText) Then
%>
<p><%=TXT_NO_SEARCH_TIPS%>
<br><a href="<%=makeLinkB("~/" & StringIf(ps_intDbArea=DM_VOL, "volunteer/"))%>"><%=TXT_NEW_SEARCH%></a></p>
<%
Else
	Response.Write(strPageText)
End If
%>

<%
Call makePageFooter(True)
%>
