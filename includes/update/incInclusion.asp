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
Call makePageHeader(TXT_RECORD_INCLUSION_POLICY, TXT_RECORD_INCLUSION_POLICY, False, False, True, False)

Dim	intPolicyID, _
	strPolicyText

intPolicyID = Null
If user_bLoggedIn Then
	intPolicyID = Nz(Request("PolicyID"),Null)
	If Not IsIDType(intPolicyID) Then
		intPolicyID = Null
	End If
End If

Dim cmdInclusion, rsInclusion
Set cmdInclusion = Server.CreateObject("ADODB.Command")
With cmdInclusion
	.ActiveConnection = getCurrentBasicCnn()
	.CommandText = "dbo.sp_" & IIf(Not Nl(intPolicyID),"GBL",ps_strDbArea) & "_InclusionPolicy_s"
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	If Not Nl(intPolicyID) Then
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@InclusionPolicyID", adInteger, adParamInput, 4, intPolicyID)
	Else
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, ps_intDbAreaViewType)
	End If
End With
Set rsInclusion = cmdInclusion.Execute

With rsInclusion
	If .EOF Then
		strPolicyText = vbNullString
	Else
		strPolicyText = .Fields("PolicyText")
	End If
End With

rsInclusion.Close
Set rsInclusion = Nothing
Set cmdInclusion = Nothing

If Nl(strPolicyText) Then
%>
<p><%=TXT_SORRY_NOT_AVAILABLE%></p>
<%
Else
	Response.Write(strPolicyText)
End If
%>
<p align="center">[ <a href="javascript:parent.close()"><%=TXT_CLOSE_WINDOW%></a> ]</p>
<%
Call makePageFooter(False)
%>
