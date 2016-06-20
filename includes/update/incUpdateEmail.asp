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

Dim MESSAGE_DIVIDER
MESSAGE_DIVIDER = vbCrLf & vbCrLf & "* * * * *" & vbCrLf & vbCrLf

Class UpdateMsgData

Public	StdSubject, _
		StdGreetingStart, _
		StdGreetingEnd, _
		StdMessageBody, _
		StdDetailDesc, _
		StdFeedbackDesc, _
		StdSuggestOppDesc, _
		StdOrgOppsDesc, _
		StdContact
		
Public Sub setData( _
		strSubject, _
		strGreetingStart, _
		strGreetingEnd, _
		strMessageBody, _
		strDetailDesc, _
		strFeedbackDesc, _
		strSuggestOppDesc, _
		strOrgOppsDesc, _
		strContact _
	)
	StdSubject = strSubject
	StdGreetingStart = strGreetingStart
	StdGreetingEnd = strGreetingEnd
	StdMessageBody = strMessageBody
	StdDetailDesc = strDetailDesc
	StdFeedbackDesc = strFeedbackDesc
	StdSuggestOppDesc = strSuggestOppDesc
	StdOrgOppsDesc = strOrgOppsDesc
	StdContact = strContact
End Sub

End Class

Class UpdateRecordData

Public	HasLang, _
		PublicLang, _
		HasOpps, _
		OrgName, _
		PosTitle, _
		FBKey
		
Public Sub setData( _
		strCulture, _
		bHasLang, _
		bPublicLang, _
		bHasOpps, _
		strOrgName, _
		strPosTitle, _
		strFBKey _
	)
	HasLang = bHasLang
	If bHasLang Then
		strRecordLastCulture = strCulture
		intRecordLangCount = intRecordLangCount + 1
	End If
	PublicLang = bPublicLang
	If bPublicLang Then
		bRecordPublicLang = True
	End If
	HasOpps = bHasOpps
	If bHasOpps Then
		bRecordHasOpps = True
	End If
	If bHasLang And Not bPublicLang Then
		bRecordMustShowFbLink = True
		FBKey = strFBKey
	End If
	OrgName = strOrgName
	PosTitle = strPosTitle
End Sub

End Class

Dim aMsgCultures, _
	strDefaultCulture, _
	indCulture

strDefaultCulture = get_db_option("DefaultCulture")

aMsgCultures = Array(strDefaultCulture)
For Each indCulture in active_cultures()
	If indCulture <> strDefaultCulture Then
		ReDim Preserve aMsgCultures(UBound(aMsgCultures)+1)
		aMsgCultures(UBound(aMsgCultures)) = indCulture
	End If	
Next

Dim strMessageDivider

Dim intEmailID, _
	strStdModifiedDate, _
	strStdModifiedBy, _
	strStdSubjectBilingual, _
	bRecordPublicLang, _
	bRecordHasOpps, _
	bRecordMustShowFbLink, _
	strRecordLastCulture, _
	intRecordLangCount

bRecordHasOpps = False
bRecordPublicLang = False
bRecordMustShowFbLink = False
intRecordLangCount = 0
strRecordLastCulture = vbNullString

Dim dicMsgData
Set dicMsgData = Server.CreateObject("Scripting.Dictionary")

Dim dicRecData
Set dicRecData = Server.CreateObject("Scripting.Dictionary")

Dim strMsgTxtDisp, _
	strMsgSubjDisp, _
	strRecipient, _
	strDbArea, _
	strDbAreaPath, _
	strType, _
	strMainKeyLink, _
	bSuggestOpp

Dim	strID, _
	strNUM, _
	strNUMDesc

Sub setEmailUpdateValues(intDomain, bMultiRecord, intEmailID, bCheckNew)

Dim cmdStdUpdateEmail, rsStdUpdateEmail
Set cmdStdUpdateEmail = Server.CreateObject("ADODB.Command")

With cmdStdUpdateEmail
	.ActiveConnection = getCurrentAdminCnn()
	.CommandText = "dbo.sp_GBL_StandardEmailUpdate_s"
	.Parameters.Append .CreateParameter("@MemberID", adInteger, adParamInput, 4, g_intMemberID)
	.Parameters.Append .CreateParameter("@Domain", adInteger, adParamInput, 1, intDomain)
	.Parameters.Append .CreateParameter("@StdForMultipleRecords", adBoolean, adParamInput, 1, bMultiRecord)
	.Parameters.Append .CreateParameter("@EmailID", adInteger, adParamInput, 4, Nz(Null,intEmailID))
	.CommandType = adCmdStoredProc
	.CommandTimeout = 0
	Set rsStdUpdateEmail = .Execute
End With

With rsStdUpdateEmail
	If Not .EOF Then
		intEmailID = .Fields("EmailID")
		strStdModifiedDate = Nz(DateString(.Fields("MODIFIED_DATE"),True),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strStdModifiedBy = Nz(.Fields("MODIFIED_BY"),TXT_UNKNOWN) & " (" & TXT_SET_AUTOMATICALLY & ")"
		strStdSubjectBilingual = .Fields("StdSubjectBilingual")
		
		Set rsStdUpdateEmail = rsStdUpdateEmail.NextRecordset

		With rsStdUpdateEmail
			While Not .EOF
				Set dicMsgData(.Fields("Culture").Value) = New UpdateMsgData
				Call dicMsgData(.Fields("Culture").Value).setData( _
					.Fields("StdSubject").Value, _
					.Fields("StdGreetingStart").Value, _
					.Fields("StdGreetingEnd").Value, _
					.Fields("StdMessageBody").Value, _
					.Fields("StdDetailDesc").Value, _
					.Fields("StdFeedbackDesc").Value, _
					.Fields("StdSuggestOppDesc").Value, _
					.Fields("StdOrgOppsDesc").Value, _
					.Fields("StdContact").Value _
				)
				.MoveNext
			Wend
		End With

	End If

	If bCheckNew Then
		strStdSubjectBilingual = Nz(Trim(Request("NewSubjectBilingual")),strStdSubjectBilingual)

		Dim strCulture
		For Each strCulture in dicMsgData.Keys
			dicMsgData(strCulture).StdSubject = Nz(Trim(Request("NewSubject_" & strCulture)),dicMsgData(strCulture).StdSubject)
			dicMsgData(strCulture).StdMessageBody = Nz(Trim(Request("NewBody_" & strCulture)),dicMsgData(strCulture).StdMessageBody)
		Next
	End If
End With

End Sub

Sub setPrepAgencyValues()
	strROName = "[" & TXT_INSERT_OWNER_AGENCY & "]"
	strROFax = "[" & TXT_INSERT_OWNER_FAX & "]"
	strROSiteAddress = "[" & TXT_INSERT_OWNER_ADDRESS & "]"
	strROMailAddress = "[" & TXT_INSERT_OWNER_MAIL_ADDRESS & "]"
	strROUpdatePhone = "[" & TXT_INSERT_OWNER_PHONE & "]"
	strROUpdateEmail = "[" & TXT_INSERT_OWNER_EMAIL & "]"
End Sub

Function makeEmailUpdateMsg( _
		intDomain, _ 
		intViewType, _
		strAccessURL, _
		strAgencyCode, _
		bFeedback _
)
	Dim strRestoreCulture
	strRestoreCulture = g_objCurrentLang.Culture
	
	Call setSessionLanguage(get_db_option("DefaultCulture"))
	
	If intRecordLangCount > 1 Then
		makeEmailUpdateMsg = TXT_OTHER_LANG_FOLLOWS & MESSAGE_DIVIDER
	End If
	
	strMessageDivider = vbNullString
	
	For Each indCulture In aMsgCultures
		If dicRecData.Exists(indCulture) Then
			If dicRecData(indCulture).HasLang Then
				Call setSessionLanguage(indCulture)
				If Nl(strAgencyCode) Then
					Call setPrepAgencyValues()
				Else
					Call getROInfo(strAgencyCode,intDomain)
				End If
				makeEmailUpdateMsg = makeEmailUpdateMsg & strMessageDivider & _
					makeMsgContents(intViewType,strAccessURL,strROName,strROUpdateEmail,strROUpdatePhone,bFeedback)	
				strMessageDivider = MESSAGE_DIVIDER
			End If
		End If
	Next

	Call setSessionLanguage(strRestoreCulture)
End Function

Function makeMsgContents( _
		intViewType, _
		strAccessURL, _
		strAgencyName, _
		strAgencyEmail, _
		strAgencyPhone, _
		bFeedback _
)
	Dim strDetailURL, _
		strFeedbackURL, _
		strOrgOppsURL, _
		strSuggestOppURL, _
		strOrgName, _
		strPosTitle, _
		strFBKey
		
	strOrgName = dicRecData(g_objCurrentLang.Culture).OrgName
	strPosTitle = dicRecData(g_objCurrentLang.Culture).PosTitle
	strFBKey = dicRecData(g_objCurrentLang.Culture).FBKey

	Dim strDetailDesc, _
		strFeedbackDesc, _
		strOrgOppsDesc, _
		strSuggestOppDesc

	strDetailDesc = dicMsgData(g_objCurrentLang.Culture).StdDetailDesc
	strFeedbackDesc = dicMsgData(g_objCurrentLang.Culture).StdFeedbackDesc
	strOrgOppsDesc = dicMsgData(g_objCurrentLang.Culture).StdOrgOppsDesc
	strSuggestOppDesc = dicMsgData(g_objCurrentLang.Culture).StdSuggestOppDesc

	strDetailURL = strAccessURL & "/" & strDbAreaPath & IIf(Nl(strRecordRoot), "details.asp?" & strMainKeyLink & "=", strRecordRoot) & strID & _
		IIf(Nl(intViewType),vbNullString,IIf(Nl(strRecordRoot),"&", "?") & "Use" & strDbArea & "Vw=" & intViewType)
	
	strFeedbackURL = strAccessURL & "/" & strDbAreaPath & "feedback.asp?" & strMainKeyLink & "=" & strID & _
		StringIf(Not Nl(intViewType),"&Use" & strDbArea & "Vw=" & intViewType) & _
		StringIf(Not Nl(strFBKey),"&Key=" & strFBKey)
	
	If bRecordHasOpps Then
		strOrgOppsURL = strAccessURL & "/" & strDbAreaPath & "results.asp?NUM=" & strNUM & _
			IIf(Nl(intViewType),vbNullString,"&Use" & strDbArea & "Vw=" & intViewType)
	End If
		
	If bSuggestOpp Then
		strSuggestOppURL = strAccessURL & "/" & strDbAreaPath & "feedback.asp?NUM=" & strNUM & _
			IIf(Nl(intViewType),vbNullString,"&Use" & strDbArea & "Vw=" & intViewType)
	End If

	makeMsgContents = dicMsgData(g_objCurrentLang.Culture).StdGreetingStart & " " & strAgencyName & _
		IIf(Not Nl(dicMsgData(g_objCurrentLang.Culture).StdGreetingEnd),", " & dicMsgData(g_objCurrentLang.Culture).StdGreetingEnd, vbNullString) & _
		vbCrLf & vbCrLf & IIf(Nl(strPosTitle),strOrgName,strPosTitle & " (" & strOrgName & ")") & _
		vbCrLf & vbCrLf & dicMsgData(g_objCurrentLang.Culture).StdMessageBody

	If Not Nl(strDetailDesc) Then
		If bRecordPublicLang Then
			makeMsgContents = makeMsgContents & _
				vbCrLf & vbCrLf & strDetailDesc
			For Each strCulture in dicRecData
				If dicRecData(strCulture).PublicLang Then
					Select Case strCulture
						Case "fr-CA"
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_FRENCH
						Case Else
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_ENGLISH
					End Select
					makeMsgContents = makeMsgContents & TXT_COLON & strDetailURL & IIf(Nl(strRecordRoot) Or Not Nl(intViewType),"&","?") & "Ln=" & strCulture
				End If
			Next
		End If
	End If

	If bFeedback And (Not Nl(dicMsgData(g_objCurrentLang.Culture).StdFeedbackDesc) Or bRecordMustShowFbLink) Then
		If intRecordLangCount > 0 Then
			makeMsgContents = makeMsgContents & _
				vbCrLf & vbCrLf & Nz(dicMsgData(g_objCurrentLang.Culture).StdFeedbackDesc,TXT_FEEDBACK_LINK_DESCRIPTION)
			For Each strCulture in dicRecData
				If dicRecData(strCulture).HasLang Then
					Select Case strCulture
						Case "fr-CA"
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_FRENCH
						Case Else
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_ENGLISH
					End Select
					makeMsgContents = makeMsgContents & TXT_COLON & strFeedbackURL & "&Ln=" & strCulture
				End If
			Next
		End If
	End If
	
	If bRecordHasOpps And Not Nl(strOrgOppsDesc) Then
		If intRecordLangCount > 0 Then
			makeMsgContents = makeMsgContents & _
				vbCrLf & vbCrLf & strOrgOppsDesc
			For Each strCulture in dicRecData
				If dicRecData(strCulture).HasLang Then
					Select Case strCulture
						Case "fr-CA"
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_FRENCH
						Case Else
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_ENGLISH
					End Select
					makeMsgContents = makeMsgContents & TXT_COLON & strOrgOppsURL & "&Ln=" & strCulture
				End If
			Next
		End If
	End If
	
	If bSuggestOpp And Not Nl(strSuggestOppDesc) Then
		If intRecordLangCount > 0 Then
			makeMsgContents = makeMsgContents & _
				vbCrLf & vbCrLf & strSuggestOppDesc
			For Each strCulture in dicRecData
				If dicRecData(strCulture).HasLang Then
					Select Case strCulture
						Case "fr-CA"
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_FRENCH
						Case Else
							makeMsgContents = makeMsgContents & _
								vbCrLf & TXT_ENGLISH
					End Select
					makeMsgContents = makeMsgContents & TXT_COLON & strSuggestOppURL & "&Ln=" & strCulture
				End If
			Next
		End If
	End If

	makeMsgContents = makeMsgContents & _
		vbCrLf & vbCrLf & dicMsgData(g_objCurrentLang.Culture).StdContact & " " & _
		TXT_CONTACT_LEADER & strAgencyName & TXT_AT & strAgencyEmail & _
		StringIf(Not Nl(strAgencyPhone),TXT_OR_AT & strAgencyPhone) & vbCrLf

End Function

Function makeEmailUpdateSubj(strID)
	Dim strRestoreCulture
	strRestoreCulture = g_objCurrentLang.Culture

	If intRecordLangCount > 1 Then
		makeEmailUpdateSubj = strStdSubjectBilingual & " (" & TXT_RECORD_BILINGUAL & " : " & strID & ")"
	Else
		Call setSessionLanguage(strRecordLastCulture)
		makeEmailUpdateSubj = dicMsgData(g_objCurrentLang.Culture).StdSubject & " (" & TXT_RECORD & " : " & strID & ")"
		Call setSessionLanguage(strRestoreCulture)
	End If
End Function

Function getEmailUpdateMultiRecord()
	Dim bMultiRecord
	bMultiRecord = Request("MR")
	If Nl(bMultiRecord) Or Not IsNumeric(bMultiRecord) Then
		bMultiRecord = False
	Else
		bMultiRecord = CBool(CInt(bMultiRecord))
	End If

	getEmailUpdateMultiRecord = bMultiRecord
End Function
%>
