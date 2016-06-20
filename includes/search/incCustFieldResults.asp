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

Dim	strCFldDIDList1, _
	strCFldDIDList2, _
	strFirstDate1, _
	strFirstDate2, _
	strLastDate1, _
	strLastDate2, _
	strFirstDateName1, _
	strFirstDateName2, _
	strLastDateName1, _
	strLastDateName2, _
	strDateRange1, _
	strDateRange2, _
	aCFldDSelect1, _
	aCFldDSelect2, _
	aCFldDDisplay1, _
	aCFldDDisplay2

Dim strCFldIDList1, _
	strCFldIDList2, _
	strCFldType1, _
	strCFldType2, _
	strCFldVal1, _
	strCFldVal2, _
	bCFldAll1, _
	bCFldAll2, _
	bCFldInc1, _
	bCFldInc2, _
	aCFldSelect1, _
	aCFldSelect2, _
	aCFldDisplay1, _
	aCFldDisplay2
	
Sub getCustomResultsFields()
	Call getCustomFieldData(strCFldDIDList1, aCFldDSelect1, aCFldDDisplay1)
	Call getCustomFieldData(strCFldDIDList2, aCFldDSelect2, aCFldDDisplay2)
	Call getCustomFieldData(strCFldIDList1, aCFldSelect1, aCFldDisplay1)
	Call getCustomFieldData(strCFldIDList2, aCFldSelect2, aCFldDisplay2)
End Sub

Sub getCustomFieldData(strFldIDList, ByRef aCFldSelect, ByRef aCFldDisplay)
	Dim intCurFld

	Dim cmdCustField, rsCustField
	Set cmdCustField = Server.CreateObject("ADODB.Command")
	With cmdCustField
		.ActiveConnection = getCurrentAdminCnn()
		.CommandType = adCmdStoredProc
		.CommandText = "sp_" & ps_strDbArea & "_View_CustomField_s"
		.Parameters.Append .CreateParameter("@IdList", adLongVarChar, adParamInput, -1, strFldIDList)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, ps_intDbAreaViewType)
		If ps_intDbArea = DM_CIC Then
			.Parameters.Append .CreateParameter("@LoggedIn", adBoolean, adParamInput, 1, IIf(user_bLoggedIn,SQL_TRUE,SQL_FALSE))
		End If
		.CommandTimeout = 0
	End With
	Set rsCustField = Server.CreateObject("ADODB.Recordset")
	With rsCustField
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdCustField
		ReDim aCFldSelect(.RecordCount-1)
		ReDim aCFldDisplay(.RecordCount-1)
		intCurFld = 0
		While Not .EOF
			aCFldSelect(intCurFld) = .Fields("FieldSelect")
			aCFldDisplay(intCurFld) = .Fields("FieldDisplay")
			intCurFld = intCurFld + 1
			.MoveNext
		Wend
		.Close
	End With

End Sub

Sub setDateFieldVars(strRequestLead, ByRef strCFldD, ByRef strFirstDate, ByRef strLastDate, ByRef strFirstDateName, ByRef strLastDateName, ByRef strDateRange)
	If strCFldD <> "BYPASS" Then
		strCFldD = Trim(Request(strRequestLead & "DateType"))
		If Not reEquals(strCFldD,"(([0-9]{1,9},)*[0-9]{1,9})",False,False,True,False) Then
			strCFldD = NULL
		End If
	End If

	If Not Nl(strCFldD) Then
		strDateRange = Trim(Request(strRequestLead & "DateRange"))
		If Not Nl(strDateRange) Then
			Select Case strDateRange
				Case "P"
					strFirstDate = Null
					strLastDate = dateToday
					strFirstDateName = vbNullString
					strLastDateName = DateString(Date(),True)
				Case "F"
					strFirstDate = dateTomorrow
					strLastDate = Null
					strFirstDateName = DateString(DateAdd("d",1,Date()),True)
					strLastDateName = vbNullString
				Case "T"
					strFirstDate = dateToday
					strLastDate = dateTomorrow
					strFirstDateName = DateString(Date(),True)
					strLastDateName = DateString(DateAdd("d",1,Date()),True)
				Case "Y"
					strFirstDate = dateYesterday
					strLastDate = dateToday
					strFirstDateName = DateString(DateAdd("d",-1,Date()),True)
					strLastDateName = DateString(Date(),True)
				Case "7"
					strFirstDate = date7days
					strLastDate = dateTomorrow
					strFirstDateName = DateString(DateAdd("d",-6,Date()),True)
					strLastDateName = DateString(DateAdd("d",1,Date()),True)
				Case "10"
					strFirstDate = date10days
					strLastDate = dateTomorrow
					strFirstDateName = DateString(DateAdd("d",-9,Date()),True)
					strLastDateName = DateString(DateAdd("d",1,Date()),True)
				Case "TM"
					strFirstDate = dateThisMonthFirst
					strLastDate = dateNextMonthFirst
					strFirstDateName = DateString(DateAdd("d",1-Day(Date()),Date()),True)
					strLastDateName = DateString(DateAdd("m",1,DateAdd("d",1-Day(Date()),Date())),True)
				Case "PM"
					strFirstDate = dateLastMonthFirst
					strLastDate = dateThisMonthFirst
					strFirstDateName = DateString(DateAdd("m",-1,DateAdd("d",1-Day(Date()),Date())),True)
					strLastDateName = DateString(DateAdd("d",1-Day(Date()),Date()),True)
				Case "NM"
					strFirstDate = dateNextMonthFirst
					strLastDate = dateTwoMonthsFirst
					strFirstDateName = DateString(DateAdd("m",1,DateAdd("d",1-Day(Date()),Date())),True)
					strLastDateName = DateString(DateAdd("m",2,DateAdd("d",1-Day(Date()),Date())),True)
			End Select
		Else
			strFirstDate = Trim(Request(strRequestLead & "FirstDate"))
			If Not Nl(strFirstDate) And Not IsDate(strFirstDate) Then
				Call handleError(TXT_WARNING & TXT_WARNING_DATE_1_FIRST & "&quot;" & strFirstDate & "&quot;" & TXT_WARNING_DATE_2, _
					vbNullString, vbNullString)
				strFirstDate = Null
			ElseIf Not Nl(strFirstDate) Then
				If CDate(strFirstDate) < CDate("1900-01-01") Then
					Call handleError(TXT_WARNING & TXT_WARNING_DATE_1_FIRST & "&quot;" & strFirstDate & "&quot;" & TXT_WARNING_DATE_TOO_EARLY, _
						vbNullString, vbNullString)
					strFirstDate = Null
				Else
					strFirstDateName = DateString(strFirstDate,True)
					strFirstDate = QsNl(ISODateTimeStringSQL(strFirstDate))
				End If
			Else
				strFirstDate = Null
			End If
			strLastDate = Trim(Request(strRequestLead & "LastDate"))
			If Not Nl(strLastDate) And Not IsDate(strLastDate) Then
				Call handleError(TXT_WARNING & TXT_WARNING_DATE_1_LAST & "&quot;" & strLastDate & "&quot;" & TXT_WARNING_DATE_2, _
					vbNullString, vbNullString)
				strLastDate = Null
			ElseIf Not Nl(strLastDate) Then
				If CDate(strLastDate) < CDate("1900-01-01") Then
					Call handleError(TXT_WARNING & TXT_WARNING_DATE_1_FIRST & "&quot;" & strLastDate & "&quot;" & TXT_WARNING_DATE_TOO_EARLY, _
						vbNullString, vbNullString)
					strLastDate = Null
				Else
					strLastDateName = DateString(strLastDate,True)
					strLastDate = QsNl(ISODateTimeStringSQL(strLastDate))
				End If
			Else
				strLastDate = Null
			End If
		End If
		If Nl(strFirstDate) And Nl(strLastDate) And Not (strDateRange = "N" Or strDateRange = "NN") Then
			strCFldD = Null
		End If
	End If
End Sub

Sub setCustFieldVars(strRequestLead, ByRef strCFld, ByRef strCFldType, ByRef strCFldVal, ByRef bCFldAll, ByRef bCFldInc)
	strCFld = Request(strRequestLead)
	
	If Not IsIDList(strCFld) Then
		strCFld = NULL
	End If

	strCFldType = Request(strRequestLead & "Type")
	strCFldVal = Request(strRequestLead & "Val")
	strCFldVal = Replace(strCFldVal,SQUOTE,SQUOTE & SQUOTE)
	bCFldAll = Request(strRequestLead & "All") = "on"
	bCFldInc = Request(strRequestLead & "Inc") = "on"
End Sub

Function getDateSearchString(aCFldDList, strFirstDate, strLastDate, strDateRange)
	Dim strFld, strReturn, strCon
	
	strCon = vbNullString
	
	For Each strFld In aCFldDList
		strReturn = strReturn & strCon & getDateSearchStringS(strFld, strFirstDate, strLastDate, strDateRange)
		strCon = OR_CON
	Next

	getDateSearchString = IIf(Nl(strReturn),vbNullString,"(" & strReturn & ")")
End Function

Function getDateSearchStringS(strField, strFirstDate, strLastDate, strDateRange)
	Dim strReturn, strCon
	
	strCon = vbNullString
	
	strField = Replace(strField,"cioc_shared.dbo.fn_SHR_GBL_DateString(","(")
	
	strReturn = "("
	If Not Nl(strFirstDate) Then
		strReturn = strReturn & strCon & "(" & strField & " >= " & strFirstDate & ")"
		strCon = AND_CON
	End If
	If Not Nl(strLastDate) Then
		strReturn = strReturn & strCon & "(" & strField & " < " & strLastDate & ")"
		strCon = AND_CON
	End If
	If strDateRange = "N" Then
		strReturn = strReturn & strCon & "(" & strField & " IS NULL)"
		strCon = AND_CON
	ElseIf strDateRange = "NN" Then
		strReturn = strReturn & strCon & "(" & strField & " IS NOT NULL)"
		strCon = AND_CON
	End If
	strReturn = strReturn & ")"

	getDateSearchStringS = strReturn
End Function

Function getCustSearchString(aCFldList,strCFldType,strCFldVal,bCFldAll)
	Dim strReturn, strFld, strConType, strCon
	
	strConType = IIf(bCFldAll,AND_CON,OR_CON)
	
	For Each strFld in aCFldList
		Select Case strCFldType
			Case "L"
				If Not Nl(strCFldVal) Then
					strReturn = strReturn & strCon & "(" & strFld & " LIKE '%" & strCFldVal & "%')"
					strCon = strConType
				End If
			Case "NL"
				If Not Nl(strCFldVal) Then
					strReturn = strReturn & strCon & "(" & strFld & " IS NULL OR " & strFld & " NOT LIKE '%" & strCFldVal & "%')"
					strCon = strConType
				End If
			Case "N"
				strReturn = strReturn & strCon & "(" & strFld & " IS NULL)"
				strCon = strConType
			Case "NN"
				strReturn = strReturn & strCon & "(" & strFld & " IS NOT NULL)"
				strCon = strConType
		End Select
	Next
	getCustSearchString = IIf(Nl(strReturn),vbNullString,"(" & strReturn & ")")
End Function
%>
