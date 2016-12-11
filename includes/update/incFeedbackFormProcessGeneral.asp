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
Dim strEmailContents
	
Sub addEmailField(strFldName,strInsert)
	strEmailContents = strEmailContents & vbCrLf & strFldName & TXT_COLON & strInsert
End Sub

Function addInsertField(strFldName, _
		strInsert, _
		ByRef strInsertInto, _
		ByRef strInsertValue)
	If Not Nl(strInsert) Then
		strInsertInto = strInsertInto & "," & strFldName
		strInsertValue = strInsertValue & "," & strInsert
		addInsertField = True
	Else
		addInsertField = False
	End If
End Function

Function getDateSetValue(strFldName)
	Dim dOldValue, strNewValue
	strNewValue = Trim(CStr(Request(strFldName)))
	If Not bSuggest Then
		dOldValue = rsOrg(strFldName)
		If Not Nl(dOldValue) Then
			dOldValue = DateString(dOldValue, True)
			If IsDate(strNewValue) Then
				strNewValue = DateString(strNewValue, True)
			End If
			If dOldValue = strNewValue Then
				strNewValue = Null
			ElseIf Nl(strNewValue) Then
				strNewValue = TXT_CONTENT_DELETED
			End If
		End If
	End If
	getDateSetValue = strNewValue
End Function

Function getContactStrSetValue(strContactType, strFldName, xmlNode)
	Dim strOldValue, strNewValue
	strNewValue = Replace(Replace(Trim(CStr(Request(strContactType & "_" & strFldName))), vbCr, vbNullString), vbLf, vbCrLf)
	If Not bSuggest Then
		strOldValue = xmlNode.getAttribute(strFldName)
		If Not Nl(strOldValue) Then
			strOldValue = Replace(Replace(Trim(CStr(strOldValue)), vbCr, vbNullString), vbLf, vbCrLf)
			If strOldValue = strNewValue Then
				strNewValue = Null
			ElseIf Nl(strNewValue) Then
				strNewValue = TXT_CONTENT_DELETED
			End If
		End If
	End If
	getContactStrSetValue = strNewValue
End Function

Function getStrSetValue(strFldName)
	Dim strOldValue, strNewValue
	strNewValue = Replace(Replace(Trim(CStr(Request(strFldName))), vbCr, vbNullString), vbLf, vbCrLf)
	If Not bSuggest Then
		strOldValue = rsOrg(strFldName)
		If Not Nl(strOldValue) Then
			strOldValue = Replace(Replace(Trim(CStr(strOldValue)), vbCr, vbNullString), vbLf, vbCrLf)
			If strOldValue = strNewValue Then
				strNewValue = Null
			ElseIf Nl(strNewValue) Then
				strNewValue = TXT_CONTENT_DELETED
			End If
		End If
	End If
	getStrSetValue = strNewValue
End Function

Function getBasicListSetValue(strFldName,strLBracket,strRBracket)
	Dim strOldValue, strListItems, strNewValue, strDelim

	strDelim = " ; "
	strListItems = Trim(CStr(Request(strFldName & "_LISTITEMS")))
	strListItems = reReplace(strListItems,"^" & strLBracket,vbNullString, False, False, False, False)
	strListItems = reReplace(strListItems,strRBracket & "(\s*,\s*)?$",vbNullString, False, False, False, False)
	strListItems = reReplace(strListItems,strLBracket & "\s*,\s*" & strRBracket,strDelim, False, False, True, False)

	strNewValue = Trim(CStr(Request(strFldName)))
	strCon = IIf(Not Nl(strNewValue) And Not Nl(strListItems),strDelim,vbNullString)
	strNewValue = strListItems & strCon & strNewValue

	If Not bSuggest Then
		strOldValue = rsOrg.Fields(strFldName).Value
		If Not Nl(strOldValue) Then
			strOldValue = Trim(CStr(strOldValue))
			If strOldValue = strNewValue Then
				strNewValue = Null
			ElseIf Nl(strNewValue) Then
				strNewValue = TXT_CONTENT_DELETED
			End If
		End If
	End If
	getBasicListSetValue = strNewValue
End Function

Function getCbSetValue(strFldName,strOnText,strOffText)
	Dim bOldValue, bNewValue, strNewValue
	bNewValue = Request(strFldName)
	If Not bSuggest Then
		bOldValue = rsOrg(strFldName).Value
		If Not Nl(bOldValue) Then
			bOldValue = IIf(bOldValue="True",SQL_TRUE,SQL_FALSE)
		End If
	Else
		bOldValue = Null
	End If
	If Nl(bNewValue) Then
		If Nl(bOldValue) And Not bSuggest Then
			strNewValue = Null
		Else
			strNewValue = TXT_UNKNOWN
		End If
	ElseIf Not Nl(bOldValue) And (CBool(Nz(bOldValue,False)) = CBool(bNewValue)) And Not bSuggest Then
		strNewValue = Null
	ElseIf CBool(bNewValue) Then
		strNewValue = strOnText
	Else
		strNewValue = strOffText
	End If			
	getCbSetValue = strNewValue
End Function

Sub getContactFields(strContactType,strFieldDisplay,ByRef strInsertInto,ByRef strInsertValue)
	Dim strFieldVal
	
	Dim xmlDoc, xmlNode
	
	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If Not bSuggest Then
		xmlDoc.loadXML Nz(rsOrg(strContactType).Value,"<CONTACT/>")
	Else
		xmlDoc.loadXML "<CONTACT/>"
	End If
	Set xmlNode = xmlDoc.selectSingleNode("/CONTACT")

	strFieldVal = getContactStrSetValue(strContactType, "NAME", xmlNode)
	If addInsertField(strContactType & "_NAME",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		Call addEmailField(strFieldDisplay & " " & TXT_NAME,strFieldVal)
	End If
	strFieldVal = getContactStrSetValue(strContactType, "TITLE", xmlNode)
	If addInsertField(strContactType & "_TITLE",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		Call addEmailField(strFieldDisplay & " " & TXT_TITLE,strFieldVal)
	End If
	strFieldVal = getContactStrSetValue(strContactType, "ORG", xmlNode)
	If addInsertField(strContactType & "_ORG",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		Call addEmailField(strFieldDisplay & " " & TXT_ORGANIZATION,strFieldVal)
	End If
	Dim i
	For i = 1 to 3
		strFieldVal = getContactStrSetValue(strContactType, "PHONE" & i, xmlNode)
		If addInsertField(strContactType & "_PHONE" & i,QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
			Call addEmailField(strFieldDisplay & " " & TXT_PHONE & " #" & i,strFieldVal)
		End If
	Next
	strFieldVal = getContactStrSetValue(strContactType, "FAX", xmlNode)
	If addInsertField(strContactType & "_FAX",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		call addEmailField(strFieldDisplay & " " & TXT_FAX,strFieldVal)
	End If
	strFieldVal = getContactStrSetValue(strContactType, "EMAIL", xmlNode)
	If addInsertField(strContactType & "_EMAIL",QsNNl(strFieldVal),strInsertInto,strInsertValue) Then
		Call addEmailField(strFieldDisplay & " " & TXT_EMAIL,strFieldVal)
	End If
End Sub

Sub sendNotifyEmails(intID, strRecName, strOldEmail, strNewEmail, bInView, strAccessURL, intViewType, ByVal strUseFbKey, strMasterFbKey)
	
	If Nl(strROUpdateEmail) Then
		Exit Sub
	End If

	Dim strDetailLink
	
	Dim bNotifyAdmin, _
		bNotifyAgency
		
	bNotifyAdmin = Not user_bLoggedIn Or Request("NotifyAdmin") <> "N"
	bNotifyAgency = Not user_bLoggedIn Or Request("NotifyAgency") <> "N"

	If Nl(strUseFbKey) Or strUseFbKey<>strMasterFbKey Then
		strUseFbKey = vbNullString
	End If
	strMasterFbKey = Nz(strMasterFbKey,vbNullString)

	Dim strMsgHeader, _
		strMessageHeader, _
		strMessageFooter, _
		strFrom, _
		strSender, _
		strRecipient, _
		strSubject, _
		strSourceEmail, _
		strSourceName, _
		strSourceOrg

	If bInView Then
		strDetailLink = TXT_VIEW_RECORD_AT & _
			vbCrLf & _
			Nz(strAccessURL,IIf(get_db_option("FullSSLCompatibleBaseURL" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")), "https://", "http://") & IIf(ps_intDbArea = DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL)) & _
			"/" & IIf(Nl(strRecordRoot), _
				ps_strDbAreaDefaultPath & "details.asp?" & IIf(ps_intDbArea=DM_VOL,"VNUM=" & intID,"NUM=" & intID) & "&", _
				StringIf(ps_intDbArea=DM_VOL, "volunteer/") & strRecordRoot & intID & "?") & _
			StringIf(Not Nl(intViewType),IIf(ps_intDbArea=DM_VOL,"UseVOLVw=","UseCICVw=") & intViewType & "&") & _
			"Ln=" & g_objCurrentLang.Culture
	Else
		strDetailLink = TXT_VIEW_RECORD_AT & _
			vbCrLf & _
			Nz(strAccessURL,IIf(get_db_option("FullSSLCompatibleBaseURL" & IIf(ps_intDbArea = DM_CIC, "CIC", "VOL")), "https://", "http://") & IIf(ps_intDbArea = DM_CIC,g_strBaseURLCIC,g_strBaseURLVOL)) & _
			"/" & ps_strDbAreaDefaultPath & "feedback.asp?" & _
			IIf(ps_intDbArea=DM_VOL,"VNUM=","NUM=") & intID & _
			StringIf(Not Nl(intViewType),IIf(ps_intDbArea=DM_VOL,"&UseVOLVw=","&UseCICVw=") & intViewType) & _
			"&Ln=" & g_objCurrentLang.Culture & "&Key=[FBKEY]"
	End If


	If Not user_bLoggedIn Then
		strSourceEmail = Trim(Request("SOURCE_EMAIL"))
		strSourceName = Trim(Request("SOURCE_NAME"))
		strSourceOrg = Trim(Request("SOURCE_ORG"))
	Else
		strSourceEmail = user_strEmail
		strSourceName = user_strUserFirstName & " " & user_strUserLastName
		strSourceOrg = user_strAgency
	End If
	If Nl(strSourceName) Then
		strSourceName = TXT_SUBMITTED_FEEDBACK_1_SOMEONE
	ElseIf Not Nl(strSourceOrg) Then
		strFrom = strSourceName & " (" & strSourceOrg & ")" & TXT_SUBMITTED_FEEDBACK_1_NAME
	Else
		strFrom = strSourceName & TXT_SUBMITTED_FEEDBACK_1_NAME
	End If
	
	strMsgHeader = TXT_SUBMITTED_FEEDBACK_2 & _
			vbCrLf & _
			strRecName & _
			vbCrLf & _
			TXT_RECORD_BE_UPDATED_IN & get_db_option_current_lang("DatabaseName" & ps_strDbArea) & _
			vbCrLf & vbCrLf & _
			TXT_SUMMARY_OF_CHANGES & _
			vbCrLf & _
			strEmailContents

	strSender = strROUpdateEmail & " <" & strROUpdateEmail & ">"

	strMessageFooter = TXT_CHANGES_WILL_BE_REVIEWED & _
			vbCrLf & vbCrLf & _
			strDetailLink & _
			vbCrLf & vbCrLf & _
			TXT_QUESTIONS_CONTACT & strROName & TXT_AT & strROUpdatePhone & TXT_OR_AT & strROUpdateEmail

	If bNotifyAgency And Not g_bNoEmail Then

		strMessageHeader = strFrom & strMsgHeader
		'send Email to org's original Email, if it exists
		If Not Nl(strOldEmail) Then
			strRecipient = strOldEmail
			If Not Nl(strNewEmail) Then
				strSubject = TXT_REVIEW_NEW_EMAIL & get_db_option_current_lang("DatabaseName" & ps_strDbArea)
			Else
				strSubject = TXT_REVIEW_UPDATES & get_db_option_current_lang("DatabaseName" & ps_strDbArea)
			End If

			Call sendEmail(False, strSender, strRecipient, vbNullString, strSubject, strMessageHeader & vbCrLf & vbCrLf & Replace(strMessageFooter,"&Key=[FBKEY]","&Key=" & strMasterFbKey))
		End If
		
		'send Email to org's new Email, if it exists and is different
		If Not Nl(strNewEmail) And strNewEmail <> TXT_DELETED Then
			strRecipient = strNewEmail
			strSubject = TXT_REVIEW_NEW_EMAIL & get_db_option_current_lang("DatabaseName" & ps_strDbArea)
			Call sendEmail(False, strSender, strRecipient, vbNullString, strSubject, strMessageHeader & vbCrLf & vbCrLf & Replace(strMessageFooter,"&Key=[FBKEY]",StringIf(Not Nl(strFbKey),"&Key=" & strFbKey)))
		End If
	End If

	'send Email to source, if it exists and is different
	If Not g_bNoEmail And _
			Not user_bLoggedIn And _
			Not Nl(strSourceEmail) And _
			(strSourceEmail <> strNewEmail Or Nl(strNewEmail)) And _
			(strSourceEmail <> strOldEmail Or Nl(strOldEmail)) Then
		strMessageHeader = TXT_SUBMITTED_FEEDBACK_1_YOU & strMsgHeader
		strRecipient = strSourceEmail
		strSubject = TXT_THANKS_FOR_FEEDBACK

		Call sendEmail(False, strSender, strRecipient, vbNullString, strSubject, strMessageHeader & vbCrLf & vbCrLf & Replace(strMessageFooter,"&Key=[FBKEY]",StringIf(Not Nl(strFbKey),"&Key=" & strFbKey)))
	End If
	
	'send Email to owner agency, if it exists
	Dim strAlsoNotify
	strAlsoNotify = IIf(ps_intDbArea=DM_VOL, g_strAlsoNotifyVOL, g_strAlsoNotifyCIC)

	If bNotifyAdmin And (Not Nl(strROUpdateEmail) or Not Nl(strAlsoNotify)) Then
	
		strMessageHeader = strFrom & strMsgHeader
		If Not Nl(strFbNotes) Then
			strMessageHeader = strMessageHeader & vbCrLf & TXT_FEEDBACK_NOTES & TXT_COLON & strFbNotes
		End If
		strMessageFooter = strDetailLink
		strRecipient = Ns(strROUpdateEmail)

		If Not Nl(strRecipient) And Not Nl(strAlsoNotify) Then
			strRecipient = strRecipient & ", "
		End If

		strRecipient = strRecipient & Ns(strAlsoNotify)

		strSubject = TXT_FEEDBACK_FOR & strRecName & " (" & TXT_VOL_ID & " " & intID & ")"
	
		Call sendEmail(False, strSender, strRecipient, vbNullString, strSubject, strMessageHeader & vbCrLf & vbCrLf & Replace(strMessageFooter,"&Key=[FBKEY]",vbNullString))
	End If

End Sub

Function getDropDownValue(strValue, strFunction, bLangID, strFieldName)
	Dim strReturn
	strReturn = vbNullString

	If Not Nl(strValue) And IsIDType(strValue) Then
		Dim cmdDropDown, rsDropDown
		Set cmdDropDown = Server.CreateObject("ADODB.Command")
		With cmdDropDown
			.ActiveConnection = getCurrentBasicCnn()
			.CommandText = "SELECT " & strFunction & "(" & strValue & StringIf(Not Nl(strFieldName),"," & QsNl(strFieldName)) & StringIf(bLangID,",@@LANGID") & ") AS DropDown"
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsDropDown = Server.CreateObject("ADODB.Recordset")
		With rsDropDown
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdDropDown
			If Not .EOF Then
				strReturn = .Fields("DropDown")
			End If
			.Close
		End With
		Set rsDropDown = Nothing
		Set cmdDropDown = Nothing
	End If
	
	getDropDownValue = strReturn
End Function

Sub getSocialMediaField(strFieldDisplay, strInsertInto, strInsertValue)
	Dim intSMID, strXML, strURL, strProto, strSQL, strTblPrefix, strIDName, bUpdateHistory, strEmailText, strEmailCon
	Dim xmlDoc, xmlNode, xmlChildNode

	Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument.6.0")
	With xmlDoc
		.async = False
		.setProperty "SelectionLanguage", "XPath"
	End With
	
	If Not bSuggest Then
		xmlDoc.loadXML Nz(rsOrg("SOCIAL_MEDIA").Value,"<SOCIAL_MEDIA/>")
	Else
		Dim rsSocialMedia, cmdSocialMedia
		Set cmdSocialMedia = Server.CreateObject("ADODB.Command")
		With cmdSocialMedia
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = "dbo.sp_GBL_SocialMedia_s_Entryform"
			.CommandType = adCmdStoredProc
			.CommandTimeout = 0
		End With
		Set rsSocialMedia = Server.CreateObject("ADODB.Recordset")
		With rsSocialMedia
			.CursorLocation = adUseClient
			.CursorType = adOpenStatic
			.Open cmdSocialMedia
		End With


		If Not rsSocialMedia.EOF Then
			xmlDoc.loadXML Nz(rsSocialMedia("SOCIAL_MEDIA").Value, "<SOCIAL_MEDIA/>")
		Else
			xmlDoc.loadXML "<SOCIAL_MEDIA/>"
		End If

		Call rsSocialMedia.Close()

		Set rsSocialMedia = Nothing
		Set cmdSocialMedia = Nothing
	End If

	bUpdateHistory = False
	strXML = "<SMS>"
	strEmailText = vbNullString
	strEmailCon = vbNullString

	Set xmlNode = xmlDoc.selectSingleNode("/SOCIAL_MEDIA")
	If Not xmlNode Is Nothing Then
		For Each xmlChildNode in xmlNode.childNodes
			intSMID = xmlChildNode.getAttribute("ID")
			strURL = Request("SOCIAL_MEDIA_" & intSMID)
			Call checkWebWithProtocol(rsFields.Fields("FieldDisplay"), strURL, strProto)
			If Not Nl(strURL) Then
				strEmailText = strEmailText & strEmailCon & xmlChildNode.getAttribute("Name") & TXT_COLON & strProto & strURL
				strEmailCon = vbCrLf
			End If
			If Ns(strURL) <> Ns(xmlChildNode.getAttribute("URL")) Or Ns(strProto) <> Ns(xmlChildNode.getAttribute("Proto")) Then
				bUpdateHistory = True
				strXML = strXML & "<SM SM_ID=" & AttrQs(intSMID) & StringIf(Not Nl(strURL)," URL=" & XMLQs(strURL) & " Proto=" & XMLQs(strProto)) & "/>"
				If Nl(strURL) Then
					strEmailText = strEmailText & strEmailCon & xmlChildNode.getAttribute("Name") & TXT_COLON & TXT_CONTENT_DELETED
					strEmailCon = vbCrLf
				End If
			End If
		Next
	End If
	strXML = strXML & "</SMS>"

	If bUpdateHistory Then
		Call addInsertField("SOCIAL_MEDIA", QsNl(strXML), strInsertInto,strInsertValue)
	End If
	If Not Nl(strEmailText) Then
		Call addEmailField(strFieldDisplay, strEmailText)
	End If 
End Sub

%>
