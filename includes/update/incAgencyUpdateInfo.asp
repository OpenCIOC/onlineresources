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
Dim strROName, _
	strROFax, _
	strROUpdatePhone, _
	strROUpdateEmail, _
	strROSiteAddress, _
	strROMailAddress

Sub getROInfo(strAgencyCode, intDomain)
	If Nl(strAgencyCode) Then
		strROName = vbNullString
		strROFax = vbNullString
		strROSiteAddress = vbNullString
		strROMailAddress = vbNullString
		strROUpdatePhone = vbNullString
		strROUpdateEmail = vbNullString
	Else
		Dim cnnAgencyInfo, cmdAgencyInfo, rsAgencyInfo
		Call makeNewAdminConnection(cnnAgencyInfo)
		Set cmdAgencyInfo = Server.CreateObject("ADODB.Command")
		With cmdAgencyInfo
			.ActiveConnection = cnnAgencyInfo
			Select Case intDomain
				Case DM_CIC
					.CommandText = "dbo.sp_CIC_Agency_Update_s"
				Case DM_VOL
					.CommandText = "dbo.sp_VOL_Agency_Update_s"
			End Select
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
			.Parameters.Append .CreateParameter("@AgencyCode", adChar, adParamInput, 3, strAgencyCode)
		End With
		Set rsAgencyInfo= cmdAgencyInfo.Execute
		With rsAgencyInfo
			If Not .EOF Then
				strROName = .Fields("ORG_NAME_FULL")
				strROFax = .Fields("FAX")
				strROSiteAddress = .Fields("SITE_ADDRESS")
				strROMailAddress = .Fields("MAIL_ADDRESS")
				strROUpdatePhone = .Fields("UPDATE_PHONE")
				strROUpdateEmail = Nz(.Fields("UPDATE_EMAIL"),IIf(ps_strDbArea=DM_VOL,g_strDefaultEmailVOL,g_strDefaultEmailCIC))
			End If
		End With
	End If
End Sub

Sub printROContactInfo(bOnline)

Dim strAccessURL
strAccessURL = reReplace(Request.ServerVariables("PATH_INFO"),"(.*)\/" & ps_strThisPage,"$1",True,False,False,False)
strAccessURL = Request.ServerVariables("HTTP_HOST") & strAccessURL

%>
<ul>
<%If Not Nl(strROMailAddress) Or Not Nl(strROSiteAddress) Then%>
	<li><%=TXT_BY_MAIL_AT%>
		<blockquote><%=textToHTML(Nz(strROMailAddress,strROSiteAddress))%></blockquote></li>
<%End If%>
<%If Not Nl(strROUpdatePhone) Then%>	
	<li><%=TXT_BY_PHONE_AT%> <%=strROUpdatePhone%></li>
<%End If%>
<%If Not Nl(strROFax) Then%>
	<li><%=TXT_BY_FAX_AT%> <%=strROFax%></li>
<%End If%>
<%If Not Nl(strROUpdateEmail) Then%>
	<li><%=TXT_BY_EMAIL_AT%> <a href="mailto:<%=strROUpdateEmail%>"><%=strROUpdateEmail%></a></li>
<%End If%>
<%If bOnline Then%>
	<%Select Case ps_intDomain%>
		<%Case DM_CIC%>
	<li><%=TXT_ONLINE_AT%> <strong><%=IIf(g_bSSL, "https://", "http://") & strAccessURL%>/feedback.asp?NUM=<%=strNUM & "&Ln=" & g_objCurrentLang.Culture%></strong></li>	
		<%Case DM_VOL%>
	<li><%=TXT_ONLINE_AT%> <strong><%=IIf(g_bSSL, "https://", "http://") & strAccessURL%>/volunteer/feedback.asp?VNUM=<%=strVNUM & "&Ln=" & g_objCurrentLang.Culture%></strong></li>		
	<%End Select%>
<%End If%>
</ul>
<%
End Sub
%>
