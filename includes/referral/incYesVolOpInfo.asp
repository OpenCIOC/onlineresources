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
Dim strRecordOwner, _
	strPosition, _
	strDuties, _
	strOrgName, _
	strContactName, _
	strContactTitle, _
	strContactOrg, _
	strContactPhone, _
	strContactFax, _
	strContactEmail, _
	bInView, _
	bInDefaultView, _
	bExpired
	
Sub setOpInfo()
	Dim cmdOp, rsOp
	Set cmdOp = Server.CreateObject("ADODB.Command")
	With cmdOp
		.ActiveConnection = getCurrentVOLBasicCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "dbo.sp_VOL_YesVolunteer"
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
		.Parameters.Append .CreateParameter("@VNUM", adVarChar, adParamInput, 10, strVNUM)
		.Parameters.Append .CreateParameter("@DefaultViewType", adInteger, adParamInput, 4, user_intViewVOL)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeVOL)
		Set rsOp = .Execute
	End With

	With rsOp
		If Not .EOF Then
			strRecordOwner = .Fields("RECORD_OWNER")
			strPosition = .Fields("POSITION_TITLE")
			strDuties = .Fields("DUTIES")
			strOrgName = .Fields("ORG_NAME_FULL")
			strContactName = .Fields("CONTACT_NAME")
			strContactOrg = IIf(Nl(.Fields("CONTACT_ORG")), strOrgName, .Fields("CONTACT_ORG"))
			strContactPhone = .Fields("CONTACT_PHONE")
			strContactFax = .Fields("CONTACT_FAX")
			strContactEmail = .Fields("CONTACT_EMAIL")
			bInView = .Fields("IN_VIEW")
			bInDefaultView = .Fields("IN_DEFAULT_VIEW")
			bExpired = .Fields("EXPIRED")
		Else
			strRecordOwner = vbNullString
			strPosition = vbNullString
			strDuties = vbNullString
			strOrgName = vbNullString
			strContactName = vbNullString
			strContactOrg = vbNullString
			strContactPhone = vbNullString
			strContactFax = vbNullString
			strContactEmail = vbNullString
			bInView = False
			bInDefaultView = False
			bExpired = False
		End If
	End With
	Set rsOp = Nothing
	Set cmdOp = Nothing	
End Sub
%>
