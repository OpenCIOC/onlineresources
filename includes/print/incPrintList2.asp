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
Class FindReplaceCommand
	Public strLookFor
	Public strReplaceWith
	Public bRegEx
	Public bMatchCase
	Public bMatchAll
End Class

Dim intProfile, _
	strTitle, _
	strHeader, _
	strFooter, _
	strMessage, _
	strStyleSheet, _
	strTableTag, _
	strRecordSeparator, _
	bPageBreak, _
	bMsgBeforeRecord, _
	strSQL, _
	strWhereClause, _
	bError
	
Const FTYPE_HEADING = 1
Const FTYPE_BASIC = 2
Const FTYPE_FULL = 3
Const FTYPE_CONTINUE = 4

'On Error Resume Next
Server.ScriptTimeOut = 900

intProfile = Request("ProfileID")
If Nl(intProfile) Then
		Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
		Call handleError(TXT_NO_PROFILE_CHOSEN & " <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
			vbNullString, _
			vbNullString)
		Call makePageFooter(False)
	bError = True
End If
strMessage = Trim(Request("Msg"))

Dim strIDList, _
	strWhere, _
	strCon

strWhere = vbNullString
strCon = "WHERE "

strIDList = Request("IDList")

Dim	intGHPBID, _
	strPBType, _	
	strPBID, _
	strPBIDx

If ps_intDbArea = DM_CIC Then
	If Not g_bLimitedView Then
		intGHPBID = Trim(Request("GHPBID"))
	Else
		intGHPBID = g_intPBID
	End If
	
	If Not Nl(intGHPBID) Then
		If Not IsIDType(intGHPBID) Then
			intGHPBID = Null
		End If
		strPBType = Null
		strPBID = Null
	Else
		strPBType = Request("PBType")
		If Not reEquals(strPBType,"A|N|(AF)|F",False,False,True,False) Then
			strPBType = Null
		End If
		strPBID = Request("PBID")
		If Nl(strPBID) Then
			strPBID = Request("incPBID")
		End If
		If Not IsIDList(strPBID) Then
			strPBID = NULL
		End If
	End If
	
	strPBIDx = Request("PBIDx")
	If Not IsIDList(strPBIDx) Then
		strPBIDx = Null
	End If

	If Not IsNUMList(strIDList) Then
		strIDList = vbNullString
	End If
ElseIf ps_intDbArea = DM_VOL Then
	If Not IsVNUMList(strIDList) Then
		strIDList = vbNullString
	End If
End If

Dim	strGHType, _
	strGHID, _
	strGHIDx

If ps_intDbArea = DM_CIC Then
	strGHType = Request("GHType")
	strGHID = Request("GHID")
	If Not IsIDList(strGHID) Then
		strGHID = NULL
	End If
	
	strGHIDx = Request("GHIDx")
	If Not IsIDList(strGHIDx) Then
		strGHIDx = Null
	End If
End If

If Not bError Then
	Select Case ps_intDbArea
		Case DM_CIC
			Select Case strPBType
				Case "A"
					strWhere = strWhere & strCon & _
						"(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM))"
					strCon = AND_CON
				Case "N" 
					strWhere = strWhere & strCon & _
						"(NOT EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM))"
					strCon = AND_CON
				Case Else
					If Not Nl(strPBID) Then
						Select Case strPBType
							Case "AF"
								Dim aPBID, strPBSrch
								aPBID = Split(strPBID,",")
								If IsArray(aPBID) Then
									If UBound(aPBID) >= 0 Then
										strPBSrch = "EXISTS(SELECT * FROM CIC_BT_PB pb " & _
											"WHERE pb.NUM=bt.NUM AND pb.PB_ID="
										strWhere = strWhere & strCon & "(" & strPBSrch & _
											Join(aPBID,") AND " & strPBSrch) & "))"
										strCon = AND_CON
									End If
								End If
							Case Else
								strWhere = strWhere & strCon & _
									"(EXISTS(SELECT * FROM CIC_BT_PB pb " & _
										"WHERE pb.NUM=bt.NUM AND pb.PB_ID IN (" & strPBID & ")))"
								strCon = AND_CON
						End Select
					End If
			End Select
			
			If Not Nl(strPBIDx) Then
				strWhere = strWhere & strCon & _
					"(NOT EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID IN (" & strPBIDx & ")))"
				strCon = AND_CON
			End If
		
			Select Case strGHType
				Case "A"
					If Not Nl(intGHPBID) Then
						strWhere = strWhere & strCon & _
							"(EXISTS(SELECT * FROM CIC_BT_PB_GH gh " & _
								"INNER JOIN CIC_BT_PB pb ON gh.BT_PB_ID = pb.BT_PB_ID " & _
								"WHERE pb.NUM=bt.NUM and pb.PB_ID=" & intGHPBID & "))"
						strCon = AND_CON
					End If
				Case "N"
					If Not Nl(intGHPBID) Then
						strWhere = strWhere & strCon & _
							"(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID=" & intGHPBID & _
							" AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH gh WHERE gh.BT_PB_ID = pb.BT_PB_ID)))"
						strCon = AND_CON
					End If
				Case Else
					If Not Nl(strGHID) Then
						Select Case strGHType
							Case "AF"
								Dim aGHID, strGHSrch
								aGHID = Split(strGHID,",")
								If IsArray(aGHID) Then
									If UBound(aGHID) >= 0 Then
										strGHSrch = "EXISTS(SELECT * FROM CIC_BT_PB_GH gh " & _
											"INNER JOIN CIC_BT_PB pb ON gh.BT_PB_ID = pb.BT_PB_ID " & _
											"WHERE pb.NUM=bt.NUM AND gh.GH_ID="
										strWhere = strWhere & strCon & "(" & strGHSrch & _
											Join(aGHID,") AND " & strGHSrch) & "))"
										strCon = AND_CON
									End If
								End If
							Case Else
								strWhere = strWhere & strCon & _
									"(EXISTS(SELECT * FROM CIC_BT_PB_GH gh " & _
										"WHERE gh.NUM_Cache=bt.NUM AND gh.GH_ID IN (" & strGHID & ")))"
								strCon = AND_CON
						End Select
					End If
			End Select
			
			If Not Nl(strGHIDx) Then
				strWhere = strWhere & strCon & _
					"(EXISTS(SELECT * FROM CIC_BT_PB pb WHERE pb.NUM=bt.NUM AND pb.PB_ID=" & intGHPBID & _
							" AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH gh WHERE gh.BT_PB_ID = pb.BT_PB_ID AND gh.GH_ID IN (" & strGHIDx & "))))"
				strCon = AND_CON
			End If
	
			If Not Nl(strIDList) Then
				strWhere = strWhere & strCon & "(bt.NUM IN (" & QsStrList(strIDList) & "))"
				strCon = AND_CON
			End If

			If Request("IncludeDeleted") = "on" Then
				strWhereClause = g_strWhereClauseCIC
			Else
				strWhereClause = g_strWhereClauseCICNoDel
			End If
			
			If Not Nl(strWhereClause) Then
				strWhere = strWhere & strCon & "(" & Replace(strWhereClause,"AND shp.Active=1","AND shp.Active=1 AND shp.CanUsePrint=1") & ")"
				strCon = AND_CON
			End If
		Case DM_VOL
			If Not Nl(strIDList) Then
				strWhere = strWhere & strCon & "(vo.VNUM IN (" & QsStrList(strIDList) & "))"
				strCon = AND_CON
			End If

			If Not Request("IncludeExpired") = "on" Then
				strWhere = strWhere & strCon & "(vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())"
				strCon = AND_CON
			End If

			If Request("IncludeDeleted") = "on" Then
				strWhereClause = g_strWhereClauseVOL
			Else
				strWhereClause = g_strWhereClauseVOLNoDel
			End If
			
			If Not Nl(strWhereClause) Then
				strWhere = strWhere & strCon & "(" & Replace(strWhereClause,"AND shp.Active=1","AND shp.Active=1 AND shp.CanUsePrint=1") & ")"
				strCon = AND_CON
			End If
		Case Else
			Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
			Call handleError(TXT_NO_RECORDS_TO_PRINT & " <a href=""javascript:parent.close()"">" & TXT_CLOSE_WINDOW & "</a>", _
				vbNullString, _
				vbNullString)
			Call makePageFooter(False)
			bError = True
	End Select
End If

If Not bError Then
	Dim dicFindReplace
	Set dicFindReplace = Server.CreateObject("Scripting.Dictionary")

	Dim cmdPrintProfile, rsPrintProfile
	Set cmdPrintProfile = Server.CreateObject("ADODB.Command")
	Set rsPrintProfile = Server.CreateObject("ADODB.Recordset")
	With cmdPrintProfile
		.ActiveConnection = getCurrentAdminCnn()
		.CommandText = "dbo.sp_" & ps_strDbArea & "_PrintProfile_sf"
		.CommandType = adCmdStoredProc
		.CommandTimeout = 0
		.Parameters.Append .CreateParameter("@ProfileID", adInteger, adParamInput, 4, intProfile)
		.Parameters.Append .CreateParameter("@ViewType", adInteger, adParamInput, 4, g_intViewTypeDOM)
	End With
	With rsPrintProfile
		.CursorLocation = adUseClient
		.CursorType = adOpenStatic
		.Open cmdPrintProfile
	End With
	If rsPrintProfile.EOF Then
		Call makePageHeader(TXT_PRINT_RECORD_LIST, TXT_PRINT_RECORD_LIST, False, False, True, False)
		Call handleError(TXT_NO_PROFILE_CHOSEN, vbNullString, vbNullString)
		Call makePageFooter(False)
		bError = True
	Else
		With rsPrintProfile
			strTitle = .Fields("PageTitle")
			strHeader = .Fields("Header")
			strFooter = .Fields("Footer")
			strStyleSheet = .Fields("StyleSheet")
			strTableTag = .Fields("TableClass")
			If Not Nl(strTableTag) Then
				strTableTag = "<table class=" & Qs(strTableTag,DQUOTE) & ">"
			Else
				strTableTag = "<table class=""NoBorder cell-padding-4"">"
			End If
			strRecordSeparator = .Fields("Separator")
			bPageBreak = .Fields("PageBreak")
			bMsgBeforeRecord = .Fields("MsgBeforeRecord")
		End With
		
		
		Set rsPrintProfile = rsPrintProfile.NextRecordset
		With rsPrintProfile
			If Not .EOF Then
				Dim aTemp, j
				j = -1
				ReDim aTemp(j)
				While Not .EOF
					If dicFindReplace.Exists(.Fields("PFLD_ID").Value) Then
						aTemp = dicFindReplace.Item(.Fields("PFLD_ID").Value)
						j = UBound(aTemp) + 1
						ReDim Preserve aTemp(j)
					Else
						j = 0
						ReDim aTemp(j)
					End If
					Set aTemp(j) = New FindReplaceCommand
					aTemp(j).strLookFor = .Fields("LookFor").Value
					aTemp(j).strReplaceWith = .Fields("ReplaceWith").Value
					aTemp(j).bRegEx = .Fields("RegEx").Value
					aTemp(j).bMatchCase = .Fields("MatchCase").Value
					aTemp(j).bMatchAll = .Fields("MatchAll").Value
					If dicFindReplace.Exists(.Fields("PFLD_ID").Value) Then
						dicFindReplace.Item(.Fields("PFLD_ID").Value) = aTemp
					Else
						dicFindReplace.Add .Fields("PFLD_ID").Value, aTemp
					End If
					.MoveNext
				Wend
			End If
		End With

		If ps_intDbArea = DM_CIC Then
			strSQL = "SELECT bt.NUM AS XNUM"
		Else
			strSQL = "SELECT vo.VNUM AS XVNUM"
		End If
		
		Set rsPrintProfile = rsPrintProfile.NextRecordset
		With rsPrintProfile
			While Not .EOF
				strSQL = strSQL & ", " & .Fields("FieldSelect")
				.MoveNext
			Wend
		End With
		
		If ps_intDbArea = DM_CIC Then
			strSQL = strSQL & vbCrLf & _
				"FROM GBL_BaseTable bt " & vbCrLf & _
				"INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM" & vbCrLf & _
				"LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM AND cbtd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN CCR_BaseTable ccbt ON bt.NUM=ccbt.NUM" & vbCrLf & _
				"LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=@@LANGID" & vbCrLf & _
				"LEFT JOIN cioc_shared.dbo.SHR_GBL_LetterIndex idx ON (((btd.SORT_AS_USELETTER IS NULL OR btd.SORT_AS_USELETTER=0) AND btd.ORG_LEVEL_1 LIKE idx.LetterIndex + '%') OR (btd.SORT_AS_USELETTER=1 AND btd.SORT_AS LIKE idx.LetterIndex + '%'))" & vbCrLf & _
				strWhere & vbCrLf & _
				"ORDER BY idx.LetterIndex, ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5," & vbCrLf & _
				"	STUFF(" & vbCrLf & _
				"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
				"			THEN NULL" & vbCrLf & _
				"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
				"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
				"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
				"			 END," & vbCrLf & _
				"		1, 2, ''" & vbCrLf & _
				"	)"
		Else
			strSQL = strSQL & vbCrLf & _
				"FROM VOL_Opportunity vo" & vbCrLf & _
				"INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID" & vbCrLf & _
				"INNER JOIN GBL_BaseTable bt ON vo.NUM=bt.NUM" & vbCrLf & _
				"LEFT JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)" & vbCrLf & _
				strWhere

			Select Case Request("SortBy")
				Case "P"
					strSQL = strSQL & vbCrLf & "ORDER BY vod.POSITION_TITLE"
				Case "C"
					strSQL = strSQL & vbCrLf & "ORDER BY vod.CREATED_DATE"
				Case "M"
					strSQL = strSQL & vbCrLf & "ORDER BY vod.MODIFIED_DATE"
				Case Else
					strSQL = strSQL & vbCrLf & "ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5," & vbCrLf & _
						"	STUFF(" & vbCrLf & _
						"		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)" & vbCrLf & _
						"			THEN NULL" & vbCrLf & _
						"			ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +" & vbCrLf & _
						"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +" & vbCrLf & _
						"				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')" & vbCrLf & _
						"			 END," & vbCrLf & _
						"		1, 2, ''" & vbCrLf & _
						"	)"
			End Select
		End If

		'Response.Write("<pre>" & strSQL & "</pre>")
		'Response.Flush()
		
		Dim cmdPrintList, rsPrintList
		Set cmdPrintList = Server.CreateObject("ADODB.Command")
		With cmdPrintList
			.ActiveConnection = getCurrentAdminCnn()
			.CommandText = strSQL
			.CommandType = adCmdText
			.CommandTimeout = 0
		End With
		Set rsPrintList = Server.CreateObject("ADODB.Recordset")
		With rsPrintList
			.Open cmdPrintList
			If .EOF Then
				Call makePageHeader(strTitle, strTitle, False, False, True, False)
				Call handleError(TXT_NO_RECORDS_TO_PRINT, vbNullString, vbNullString)
				Call makePageFooter(False)
				bError = True
			End If
		End With
	End If
End If

If Not bError Then
%>
<html>
<title><%=strTitle%></title>
<%
	If Not Nl(strStyleSheet) Then
%>
<link rel="STYLESHEET" type="text/css" href="<%=strStyleSheet%>">
<%
	End If
%>
<body bgcolor="#FFFFFF" text="#000000">
<%=strHeader%>
<%
	If Not Nl(strMessage) And Not bMsgBeforeRecord Then
%>
<p><%=strMessage%></p>
<%
	End If
				
	Dim fldID, _
		fldType, _
		fldName, _
		fldLabel, _
		fldHeadingLvl, _
		fldSeparator, _
		fldPrefix, _
		fldSuffix, _
		fldLabelStyle, _
		fldContentStyle, _
		strFieldContent
	
	Dim bPrevContent, _
		bPrevInTable, _
		strPrevStartTags, _
		strPrevEndTags, _
		indFRCommand, _
		i

	i = 0					

	Set fldID = rsPrintProfile.FieldS("PFLD_ID")
	Set fldName = rsPrintProfile.Fields("FieldName")
	Set fldType = rsPrintProfile.Fields("FieldTypeID")
	Set fldLabel = rsPrintProfile.Fields("Label")
	Set fldHeadingLvl = rsPrintProfile.Fields("HeadingLevel")
	Set fldSeparator = rsPrintProfile.Fields("Separator")
	Set fldPrefix = rsPrintProfile.Fields("Prefix")
	Set fldSuffix = rsPrintProfile.Fields("Suffix")
	Set fldLabelStyle = rsPrintProfile.Fields("LabelStyle")
	Set fldContentStyle = rsPrintProfile.Fields("ContentStyle")
	
	While Not rsPrintList.EOF
		i = i + 1
	
		If Not Nl(strMessage) And bMsgBeforeRecord Then
%>
<p><%=strMessage%></p>
<%
		End If

		bPrevContent = False
		bPrevInTable = False
		strPrevEndTags = vbNullString
		
		If Not rsPrintProfile.BOF Then
			rsPrintProfile.MoveFirst
		End If
		
		While Not rsPrintProfile.EOF
			If bPrevContent And Not fldType = FTYPE_CONTINUE Then
				Response.Write(strPrevEndTags & vbCrLf)
			End If
			strFieldContent = rsPrintList.Fields(fldName.Value)
			If Not Nl(strFieldContent) Then
				If dicFindReplace.Exists(fldID.Value) Then
					For Each indFRCommand in dicFindReplace.Item(fldID.Value)
						If Not Nl(indFRCommand.strLookFor) Then
							strFieldContent = reReplace(strFieldContent, _
								indFRCommand.strLookFor, _
								Nz(indFRCommand.strReplaceWith,vbNullString), _
								Not indFRCommand.bMatchCase, _
								False, _
								indFRCommand.bMatchAll, _
								Not indFRCommand.bRegEx)
						End If
					Next
				End If
				strFieldContent = Replace(Nz(fldPrefix,vbNullString),"##",i) & textToHTML(strFieldContent) & Replace(Nz(fldSuffix,vbNullString),"##",i)
			End If
			Select Case fldType
				Case FTYPE_HEADING
					If bPrevInTable Then
						Response.Write("</table>")
						bPrevInTable = False
					End If
					strPrevStartTags = "<h" & Nz(fldHeadingLvl,1) & IIf(Nl(fldContentStyle.Value),vbNullString," class=""" & fldContentStyle.Value & """") & ">"
					strPrevEndTags = "</h" & Nz(fldHeadingLvl,1) & ">"
					If Not Nl(strFieldContent) Then
						Response.Write(strPrevStartTags & strFieldContent)
					End If
				Case FTYPE_BASIC
					If Not bPrevInTable Then
						Response.Write(strTableTag)
						bPrevInTable = True
					End If
					strPrevStartTags = "<tr valign=""top""><td" & IIf(Nl(fldLabelStyle.Value),vbNullString," class=""" & fldLabelStyle.Value & """") & ">" & fldLabel.Value & "</td>" & _
							"<td width=""100%""" & IIf(Nl(fldContentStyle.Value),vbNullString," class=""" & fldContentStyle.Value & """") & ">"
					strPrevEndTags = "</td></tr>"
					If Not Nl(strFieldContent) Then
						Response.Write(strPrevStartTags & strFieldContent)
					End If
				Case FTYPE_FULL
					If Not bPrevInTable Then
						Response.Write(strTableTag)
						bPrevInTable = True
					End If
					strPrevStartTags = "<tr valign=""top""><td colspan=""2""" & IIf(Nl(fldContentStyle.Value),vbNullString," class=""" & fldContentStyle.Value & """") & ">" & _
						IIf(Nl(fldLabel.Value),vbNullString,IIf(Nl(fldLabelStyle.Value),vbNullString,"<span class=""" & fldLabelStyle.Value & """>") & fldLabel.Value & IIf(Nl(fldLabelStyle.Value),vbNullString,"</span>") & "<br>")
					strPrevEndTags = "</td></tr>"
					If Not Nl(strFieldContent) Then
						Response.Write(strPrevStartTags & strFieldContent)
					End If
				Case FTYPE_CONTINUE
					If Not Nl(strFieldContent) And bPrevContent Then
						Response.Write(Nz(fldSeparator,"; "))
					ElseIf Not bPrevContent And Not Nl(strFieldContent) Then
						Response.Write(strPrevStartTags)
					End If
					If Not Nl(strFieldContent) Then
						Response.Write(strFieldContent)
					End If
			End Select
			If Not Nl(strFieldContent) Then
				bPrevContent = True
			ElseIf Not fldType = FTYPE_CONTINUE Then
				bPrevContent = False
			End If
			rsPrintProfile.MoveNext
		Wend
		If bPrevContent Then
			Response.Write(strPrevEndTags & vbCrLf)
			strPrevEndTags = vbNullString
		End If
		If bPrevInTable Then
			Response.Write("</table>")
			bPrevInTable = False
		End If
		rsPrintList.MoveNext
		If Not rsPrintList.EOF Then
			If bPageBreak Then
				Response.Write("<div style=""page-break-before: always""></div>")
			End If
			Response.Write(strRecordSeparator)
			Response.Flush()
		End If
	Wend
%>
<%=strFooter%>
</body>
</html>
<%
End If
%>
